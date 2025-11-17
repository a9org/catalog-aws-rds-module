# Aurora Serverless v2 Example

This example demonstrates how to provision an Aurora Serverless v2 PostgreSQL cluster using the AWS RDS Terraform module.

## Features

- Aurora PostgreSQL Serverless v2
- Automatic scaling based on workload
- Pay-per-use pricing model
- Configurable min/max capacity units (ACU)
- Automated backups with configurable retention
- Encryption at rest enabled by default
- Optional Secrets Manager integration
- Optional Performance Insights
- Custom parameter group support

## What is Aurora Serverless v2?

Aurora Serverless v2 is an on-demand, auto-scaling configuration for Amazon Aurora. It automatically scales database capacity up and down based on your application's needs, allowing you to pay only for the resources you consume.

### Key Benefits

- **Cost Optimization**: Pay only for the capacity you use
- **Automatic Scaling**: Scales in fine-grained increments (0.5 ACU)
- **Instant Scaling**: Scales up/down in seconds
- **High Availability**: Built-in fault tolerance
- **No Capacity Planning**: No need to provision specific instance sizes

## Usage

```hcl
module "aurora_serverless" {
  source = "path/to/aws-rds-module"

  # IDP-provided variables
  vpc_id         = "vpc-xxxxx"
  environment    = "dev"
  vpc_cidr_block = "10.0.0.0/16"
  subnets_pvt    = ["subnet-xxxxx", "subnet-yyyyy"]

  # Database configuration
  engine          = "aurora-postgresql"
  engine_version  = "15.4"
  master_username = "postgres"
  master_password = "your-secure-password"

  # Serverless configuration
  is_aurora               = true
  is_serverless           = true
  serverless_min_capacity = 0.5
  serverless_max_capacity = 1.0

  database_name = "appdb"
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_id | VPC ID where the Aurora cluster will be created | string | - | yes |
| environment | Environment name (dev, staging, prod) | string | dev | no |
| vpc_cidr_block | VPC CIDR block for security group rules | string | - | yes |
| subnets_pvt | List of private subnet IDs | list(string) | - | yes |
| master_username | Master username for the database | string | postgres | no |
| master_password | Master password for the database | string | - | yes |
| database_name | Name of the initial database | string | appdb | no |
| serverless_min_capacity | Minimum Aurora Capacity Units (ACU) | number | 0.5 | no |
| serverless_max_capacity | Maximum Aurora Capacity Units (ACU) | number | 1.0 | no |
| backup_retention_period | Number of days to retain backups | number | 7 | no |
| deletion_protection | Enable deletion protection | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_endpoint | Aurora cluster writer endpoint for write operations |
| cluster_reader_endpoint | Aurora cluster reader endpoint for read operations |
| port | Database port (5432 for PostgreSQL) |
| database_name | Name of the created database |
| cluster_id | Aurora cluster identifier |
| cluster_arn | Aurora cluster ARN |
| security_group_id | Security group ID for the database |

## Example Deployment

1. Create a `terraform.tfvars` file:

```hcl
vpc_id         = "vpc-0123456789abcdef"
vpc_cidr_block = "10.0.0.0/16"
subnets_pvt    = ["subnet-abc123", "subnet-def456"]
master_password = "YourSecurePassword123!"
environment    = "dev"

# Serverless scaling configuration
serverless_min_capacity = 0.5
serverless_max_capacity = 2.0
```

2. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

3. Connect to your database:

```bash
psql -h <cluster_endpoint> -p 5432 -U postgres -d appdb
```

## Capacity Planning

Aurora Serverless v2 capacity is measured in Aurora Capacity Units (ACU). Each ACU provides approximately:
- 2 GiB of memory
- Corresponding compute and networking

### Recommended Configurations

**Development/Testing:**
```hcl
serverless_min_capacity = 0.5  # Minimum capacity
serverless_max_capacity = 1.0  # Low maximum for cost control
```

**Staging:**
```hcl
serverless_min_capacity = 0.5
serverless_max_capacity = 4.0  # Allow scaling for load testing
```

**Production (Variable Workload):**
```hcl
serverless_min_capacity = 1.0  # Higher baseline
serverless_max_capacity = 16.0 # Scale for peak loads
```

**Production (Consistent Workload):**
```hcl
serverless_min_capacity = 2.0
serverless_max_capacity = 8.0  # Moderate scaling range
```

## Cost Optimization Tips

1. **Set Appropriate Min Capacity**: Start with the lowest capacity that meets your baseline needs
2. **Monitor Scaling Patterns**: Use CloudWatch to understand your scaling patterns
3. **Use Reader Endpoints**: Distribute read traffic to optimize costs
4. **Enable Auto Pause**: For dev/test environments with intermittent usage (Note: Aurora Serverless v2 doesn't pause, consider v1 for this)
5. **Right-size Max Capacity**: Set max capacity based on actual peak requirements

## Secrets Manager Integration

Store credentials securely in AWS Secrets Manager:

```hcl
store_credentials_in_secrets_manager = true
```

The module will create a secret containing the cluster endpoint, port, username, and password.

## Custom Parameter Group

Configure PostgreSQL-specific parameters:

```hcl
parameter_group_parameters = {
  "shared_preload_libraries" = "pg_stat_statements"
  "log_statement"            = "all"
  "log_min_duration_statement" = "1000"
}
```

## Performance Insights

Enable Performance Insights for advanced monitoring:

```hcl
enable_performance_insights = true
```

## Monitoring

Key CloudWatch metrics to monitor:
- `ServerlessDatabaseCapacity`: Current capacity in ACU
- `ACUUtilization`: Percentage of allocated capacity being used
- `DatabaseConnections`: Number of active connections
- `CPUUtilization`: CPU usage percentage
- `FreeableMemory`: Available memory

## Scaling Behavior

Aurora Serverless v2 scales:
- **Up**: Immediately when workload increases
- **Down**: After 15 minutes of reduced workload
- **Increments**: In 0.5 ACU steps

The cluster will scale between your configured min and max capacity based on:
- CPU utilization
- Connection count
- Memory usage
