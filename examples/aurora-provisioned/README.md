# Aurora Provisioned with Read Replicas Example

This example demonstrates how to provision an Aurora MySQL cluster with read replicas for high availability and read scalability using the AWS RDS Terraform module.

## Features

- Aurora MySQL provisioned cluster
- Multiple read replicas for high availability
- Automatic distribution across availability zones
- Separate reader endpoint for load balancing
- Fixed instance sizing for predictable performance
- Automated backups with 14-day retention
- Encryption at rest enabled by default
- Secrets Manager integration for credential storage
- Performance Insights enabled
- Custom parameter group support

## Architecture

```
┌─────────────────────────────────────────────────┐
│           Aurora MySQL Cluster                  │
│                                                 │
│  ┌──────────────┐         ┌──────────────┐    │
│  │   Writer     │         │   Reader 1   │    │
│  │  Instance    │────────▶│  (Replica)   │    │
│  │   (AZ-1)     │         │   (AZ-2)     │    │
│  └──────────────┘         └──────────────┘    │
│         │                                       │
│         │                 ┌──────────────┐    │
│         └────────────────▶│   Reader 2   │    │
│                           │  (Replica)   │    │
│                           │   (AZ-3)     │    │
│                           └──────────────┘    │
└─────────────────────────────────────────────────┘
         │                          │
         │                          │
    Writer Endpoint          Reader Endpoint
  (Write Operations)      (Read Operations)
```

## Usage

```hcl
module "aurora_provisioned" {
  source = "path/to/aws-rds-module"

  # IDP-provided variables
  vpc_id         = "vpc-xxxxx"
  environment    = "prod"
  vpc_cidr_block = "10.0.0.0/16"
  subnets_pvt    = ["subnet-xxxxx", "subnet-yyyyy", "subnet-zzzzz"]

  # Database configuration
  engine          = "aurora-mysql"
  engine_version  = "8.0.mysql_aurora.3.04.0"
  master_username = "admin"
  master_password = "your-secure-password"

  # Provisioned mode with replicas
  is_aurora      = true
  is_serverless  = false
  instance_class = "db.r5.large"
  replica_count  = 2

  database_name = "appdb"
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_id | VPC ID where the Aurora cluster will be created | string | - | yes |
| environment | Environment name (dev, staging, prod) | string | staging | no |
| vpc_cidr_block | VPC CIDR block for security group rules | string | - | yes |
| subnets_pvt | List of private subnet IDs (min 2 AZs) | list(string) | - | yes |
| master_username | Master username for the database | string | admin | no |
| master_password | Master password for the database | string | - | yes |
| instance_class | Instance class for cluster instances | string | db.r5.large | no |
| replica_count | Number of read replicas | number | 2 | no |
| database_name | Name of the initial database | string | appdb | no |
| backup_retention_period | Number of days to retain backups | number | 14 | no |
| deletion_protection | Enable deletion protection | bool | true | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_endpoint | Aurora cluster writer endpoint for write operations |
| cluster_reader_endpoint | Aurora cluster reader endpoint for read operations |
| port | Database port (3306 for MySQL) |
| database_name | Name of the created database |
| cluster_id | Aurora cluster identifier |
| cluster_arn | Aurora cluster ARN |
| cluster_members | List of all instance identifiers in the cluster |
| security_group_id | Security group ID for the database |

## Example Deployment

1. Create a `terraform.tfvars` file:

```hcl
vpc_id         = "vpc-0123456789abcdef"
vpc_cidr_block = "10.0.0.0/16"
subnets_pvt    = ["subnet-abc123", "subnet-def456", "subnet-ghi789"]
master_password = "YourSecurePassword123!"
environment    = "prod"

# High availability configuration
instance_class = "db.r5.xlarge"
replica_count  = 2
```

2. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

3. Connect to your database:

**For write operations:**
```bash
mysql -h <cluster_endpoint> -P 3306 -u admin -p appdb
```

**For read operations:**
```bash
mysql -h <cluster_reader_endpoint> -P 3306 -u admin -p appdb
```

## High Availability Configuration

### Replica Count Recommendations

**Development:**
```hcl
replica_count  = 0  # Single instance for cost savings
instance_class = "db.t3.medium"
```

**Staging:**
```hcl
replica_count  = 1  # One replica for testing HA
instance_class = "db.r5.large"
```

**Production (Standard):**
```hcl
replica_count  = 2  # Two replicas across 3 AZs
instance_class = "db.r5.xlarge"
```

**Production (High Traffic):**
```hcl
replica_count  = 4  # Four replicas for read scaling
instance_class = "db.r5.2xlarge"
```

### Availability Zone Distribution

The module automatically distributes instances across availability zones:
- With 2 replicas: 3 instances across 3 AZs (1 writer + 2 readers)
- With 4 replicas: 5 instances distributed across available AZs
- Maximum: 15 replicas (16 total instances)

## Instance Class Selection

### Memory-Optimized (R5/R6g) - Recommended for Production

| Instance Class | vCPU | Memory | Network | Use Case |
|---------------|------|--------|---------|----------|
| db.r5.large | 2 | 16 GB | Up to 10 Gbps | Small production |
| db.r5.xlarge | 4 | 32 GB | Up to 10 Gbps | Medium production |
| db.r5.2xlarge | 8 | 64 GB | Up to 10 Gbps | Large production |
| db.r5.4xlarge | 16 | 128 GB | 10 Gbps | High-traffic production |

### Burstable (T3) - For Development/Testing

| Instance Class | vCPU | Memory | Use Case |
|---------------|------|--------|----------|
| db.t3.medium | 2 | 4 GB | Development |
| db.t3.large | 2 | 8 GB | Testing |

## Read/Write Split Strategy

### Application-Level Split

```python
# Python example with SQLAlchemy
from sqlalchemy import create_engine

# Writer endpoint for INSERT, UPDATE, DELETE
writer_engine = create_engine(f"mysql://{user}:{password}@{writer_endpoint}/appdb")

# Reader endpoint for SELECT queries
reader_engine = create_engine(f"mysql://{user}:{password}@{reader_endpoint}/appdb")

# Write operation
with writer_engine.connect() as conn:
    conn.execute("INSERT INTO users (name) VALUES ('John')")

# Read operation
with reader_engine.connect() as conn:
    result = conn.execute("SELECT * FROM users")
```

### Connection Pooling

```hcl
# Configure connection pooling in your application
max_connections_per_instance = 1000
total_instances = 3  # 1 writer + 2 readers
recommended_pool_size = 50  # Per application instance
```

## Failover Behavior

Aurora automatically handles failover:
1. **Detection**: Failure detected in ~30 seconds
2. **Promotion**: Read replica promoted to writer
3. **DNS Update**: Cluster endpoint updated automatically
4. **Application**: Reconnect to same endpoint (automatic)

**Typical Failover Time**: 30-120 seconds

## Backup and Recovery

### Automated Backups

```hcl
backup_retention_period = 14  # 14 days retention
backup_window          = "03:00-04:00"  # UTC
```

### Point-in-Time Recovery

Aurora supports point-in-time recovery to any second within the retention period.

```bash
# Restore to specific time using AWS CLI
aws rds restore-db-cluster-to-point-in-time \
  --source-db-cluster-identifier prod-aurora-cluster \
  --db-cluster-identifier prod-aurora-restored \
  --restore-to-time 2024-01-15T10:30:00Z
```

## Performance Optimization

### Custom Parameter Group

```hcl
parameter_group_parameters = {
  "max_connections"              = "1000"
  "innodb_buffer_pool_size"      = "{DBInstanceClassMemory*3/4}"
  "innodb_log_file_size"         = "512M"
  "query_cache_type"             = "1"
  "query_cache_size"             = "32M"
  "slow_query_log"               = "1"
  "long_query_time"              = "2"
  "log_queries_not_using_indexes" = "1"
}
```

### Performance Insights

Performance Insights is enabled by default in this example:

```hcl
enable_performance_insights = true
```

Access Performance Insights in the AWS Console to:
- Identify slow queries
- Monitor database load
- Analyze wait events
- Track connection patterns

## Monitoring

### Key CloudWatch Metrics

- `CPUUtilization`: CPU usage across instances
- `DatabaseConnections`: Active connections
- `FreeableMemory`: Available memory
- `ReadLatency` / `WriteLatency`: I/O latency
- `AuroraReplicaLag`: Replication lag for readers
- `CommitThroughput`: Transactions per second

### Recommended Alarms

```hcl
# Example CloudWatch alarms (not included in module)
- CPUUtilization > 80% for 5 minutes
- DatabaseConnections > 900 (90% of max)
- AuroraReplicaLag > 1000ms
- FreeableMemory < 1GB
```

## Cost Optimization

### Instance Sizing

- Start with smaller instances and scale up based on metrics
- Use T3 instances for non-production environments
- Consider Reserved Instances for production (up to 60% savings)

### Replica Count

- Start with 1-2 replicas
- Add more replicas only if read traffic requires it
- Monitor `DatabaseConnections` and `CPUUtilization` on readers

### Backup Retention

```hcl
# Development
backup_retention_period = 1

# Staging
backup_retention_period = 7

# Production
backup_retention_period = 14  # or 30 for compliance
```

## Security Best Practices

1. **Encryption**: Enabled by default with AWS-managed keys
2. **Secrets Manager**: Credentials stored securely
3. **Network Isolation**: Database in private subnets only
4. **Security Groups**: Restricted to VPC CIDR by default
5. **Deletion Protection**: Enabled for production

## Troubleshooting

### High Replication Lag

```sql
-- Check replication lag
SHOW SLAVE STATUS\G

-- Identify long-running queries
SELECT * FROM information_schema.processlist 
WHERE time > 60 ORDER BY time DESC;
```

### Connection Issues

1. Verify security group rules
2. Check subnet routing
3. Confirm endpoint DNS resolution
4. Validate credentials in Secrets Manager

### Performance Issues

1. Enable Performance Insights
2. Review slow query log
3. Check for missing indexes
4. Monitor CloudWatch metrics
5. Consider scaling instance class
