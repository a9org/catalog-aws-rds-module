# RDS PostgreSQL Example

This example demonstrates how to provision a standard RDS PostgreSQL instance using the AWS RDS Terraform module.

## Features

- PostgreSQL 15 engine
- Provisioned RDS instance (non-Aurora)
- Configurable instance class and storage
- Optional Multi-AZ deployment for high availability
- Automated backups with configurable retention
- Encryption at rest enabled by default
- Custom parameter group support
- Optional Performance Insights

## Usage

```hcl
module "rds_postgres" {
  source = "path/to/aws-rds-module"

  # IDP-provided variables
  vpc_id         = "vpc-xxxxx"
  environment    = "dev"
  vpc_cidr_block = "10.0.0.0/16"
  subnets_pvt    = ["subnet-xxxxx", "subnet-yyyyy"]

  # Database configuration
  engine          = "postgres"
  engine_version  = "15.4"
  master_username = "postgres"
  master_password = "your-secure-password"

  # Instance configuration
  instance_class    = "db.t3.small"
  allocated_storage = 20
  database_name     = "appdb"

  # High availability
  multi_az = false
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_id | VPC ID where the RDS instance will be created | string | - | yes |
| environment | Environment name (dev, staging, prod) | string | dev | no |
| vpc_cidr_block | VPC CIDR block for security group rules | string | - | yes |
| subnets_pvt | List of private subnet IDs | list(string) | - | yes |
| master_username | Master username for the database | string | postgres | no |
| master_password | Master password for the database | string | - | yes |
| instance_class | Instance class for the RDS instance | string | db.t3.small | no |
| allocated_storage | Allocated storage in GB | number | 20 | no |
| database_name | Name of the initial database | string | appdb | no |
| multi_az | Enable Multi-AZ deployment | bool | false | no |
| backup_retention_period | Number of days to retain backups | number | 7 | no |
| deletion_protection | Enable deletion protection | bool | false | no |
| parameter_group_parameters | Custom parameter group settings | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | RDS instance endpoint for connections |
| port | Database port (5432 for PostgreSQL) |
| database_name | Name of the created database |
| instance_id | RDS instance identifier |
| instance_arn | RDS instance ARN |
| security_group_id | Security group ID for the database |

## Example Deployment

1. Create a `terraform.tfvars` file:

```hcl
vpc_id         = "vpc-0123456789abcdef"
vpc_cidr_block = "10.0.0.0/16"
subnets_pvt    = ["subnet-abc123", "subnet-def456"]
master_password = "YourSecurePassword123!"
environment    = "dev"
```

2. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

3. Connect to your database:

```bash
psql -h <endpoint> -p 5432 -U postgres -d appdb
```

## Custom Parameter Group

Configure PostgreSQL-specific parameters:

```hcl
parameter_group_parameters = {
  "max_connections"           = "200"
  "shared_buffers"            = "256MB"
  "effective_cache_size"      = "1GB"
  "maintenance_work_mem"      = "128MB"
  "checkpoint_completion_target" = "0.9"
  "wal_buffers"               = "16MB"
  "default_statistics_target" = "100"
  "random_page_cost"          = "1.1"
  "effective_io_concurrency"  = "200"
  "work_mem"                  = "4MB"
}
```

## Multi-AZ Configuration

For production environments, enable Multi-AZ for automatic failover:

```hcl
multi_az            = true
deletion_protection = true
environment         = "prod"
instance_class      = "db.r5.large"
```

## Performance Insights

Enable Performance Insights for advanced monitoring:

```hcl
enable_performance_insights = true
```

## PostgreSQL Extensions

After deployment, you can enable PostgreSQL extensions:

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```
