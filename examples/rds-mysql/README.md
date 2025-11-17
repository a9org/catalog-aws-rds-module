# RDS MySQL Example

This example demonstrates how to provision a standard RDS MySQL instance using the AWS RDS Terraform module.

## Features

- MySQL 8.0 engine
- Provisioned RDS instance (non-Aurora)
- Configurable instance class and storage
- Optional Multi-AZ deployment for high availability
- Automated backups with configurable retention
- Encryption at rest enabled by default
- Optional Performance Insights
- Optional Secrets Manager integration

## Usage

```hcl
module "rds_mysql" {
  source = "path/to/aws-rds-module"

  # IDP-provided variables
  vpc_id         = "vpc-xxxxx"
  environment    = "dev"
  vpc_cidr_block = "10.0.0.0/16"
  subnets_pvt    = ["subnet-xxxxx", "subnet-yyyyy"]

  # Database configuration
  engine          = "mysql"
  engine_version  = "8.0.35"
  master_username = "admin"
  master_password = "your-secure-password"

  # Instance configuration
  instance_class    = "db.t3.small"
  allocated_storage = 20
  database_name     = "myapp"

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
| master_username | Master username for the database | string | admin | no |
| master_password | Master password for the database | string | - | yes |
| instance_class | Instance class for the RDS instance | string | db.t3.small | no |
| allocated_storage | Allocated storage in GB | number | 20 | no |
| database_name | Name of the initial database | string | myapp | no |
| multi_az | Enable Multi-AZ deployment | bool | false | no |
| backup_retention_period | Number of days to retain backups | number | 7 | no |
| deletion_protection | Enable deletion protection | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | RDS instance endpoint for connections |
| port | Database port (3306 for MySQL) |
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
mysql -h <endpoint> -P 3306 -u admin -p myapp
```

## Multi-AZ Configuration

For production environments, enable Multi-AZ for automatic failover:

```hcl
multi_az            = true
deletion_protection = true
environment         = "prod"
```

## Performance Insights

Enable Performance Insights for advanced monitoring:

```hcl
enable_performance_insights = true
```

## Secrets Manager Integration

Store credentials securely in AWS Secrets Manager:

```hcl
store_credentials_in_secrets_manager = true
```

The module will create a secret containing the database endpoint, port, username, and password.
