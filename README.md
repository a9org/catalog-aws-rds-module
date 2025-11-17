# AWS RDS Terraform Module

A comprehensive and flexible Terraform module for provisioning AWS RDS databases with support for multiple database engines, execution modes (serverless and provisioned), and Aurora variants. Designed for seamless integration with the A9 Catalog Internal Developer Platform (IDP).

## Features

- **Multi-Engine Support**: MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, Aurora MySQL, Aurora PostgreSQL
- **Flexible Execution Modes**: Standard RDS instances, Aurora provisioned clusters, Aurora Serverless v2
- **High Availability**: Multi-AZ deployments for RDS, read replicas for Aurora
- **Security First**: Encryption at rest by default, VPC security groups, AWS Secrets Manager integration
- **Environment-Aware**: Intelligent defaults based on environment (dev, staging, prod)
- **IDP Integration**: Native support for A9 Catalog IDP variables
- **Comprehensive Customization**: Parameter groups, option groups, Performance Insights, custom tags

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Usage

### Basic RDS MySQL Instance

```hcl
module "rds_mysql" {
  source = "./path-to-module"

  # IDP-provided variables
  vpc_id         = "vpc-12345678"
  environment    = "dev"
  vpc_cidr_block = "10.0.0.0/16"
  subnets_pvt    = ["subnet-abc123", "subnet-def456"]

  # Database configuration
  engine          = "mysql"
  engine_version  = "8.0.35"
  master_username = "admin"
  master_password = "your-secure-password"  # Use Secrets Manager in production

  # Optional: Override defaults
  allocated_storage = 100
  instance_class    = "db.t3.medium"
}
```

### Aurora PostgreSQL Serverless v2

```hcl
module "aurora_serverless" {
  source = "./path-to-module"

  # IDP-provided variables
  vpc_id         = "vpc-12345678"
  environment    = "staging"
  vpc_cidr_block = "10.0.0.0/16"
  subnets_pvt    = ["subnet-abc123", "subnet-def456"]

  # Database configuration
  engine          = "aurora-postgresql"
  engine_version  = "14.7"
  master_username = "admin"
  master_password = "your-secure-password"

  # Aurora Serverless configuration
  is_aurora               = true
  is_serverless           = true
  serverless_min_capacity = 0.5
  serverless_max_capacity = 2.0

  # Store credentials securely
  store_credentials_in_secrets_manager = true
}
```

### Aurora MySQL with Read Replicas

```hcl
module "aurora_ha" {
  source = "./path-to-module"

  # IDP-provided variables
  vpc_id         = "vpc-12345678"
  environment    = "prod"
  vpc_cidr_block = "10.0.0.0/16"
  subnets_pvt    = ["subnet-abc123", "subnet-def456", "subnet-ghi789"]

  # Database configuration
  engine          = "aurora-mysql"
  engine_version  = "8.0.mysql_aurora.3.04.0"
  master_username = "admin"
  master_password = "your-secure-password"

  # Aurora provisioned with replicas
  is_aurora     = true
  replica_count = 2

  # High availability settings
  backup_retention_period = 30
  deletion_protection     = true
  enable_performance_insights = true
}
```

### RDS PostgreSQL with Multi-AZ

```hcl
module "rds_postgres_ha" {
  source = "./path-to-module"

  # IDP-provided variables
  vpc_id         = "vpc-12345678"
  environment    = "prod"
  vpc_cidr_block = "10.0.0.0/16"
  subnets_pvt    = ["subnet-abc123", "subnet-def456"]

  # Database configuration
  engine          = "postgres"
  engine_version  = "14.7"
  master_username = "admin"
  master_password = "your-secure-password"

  # High availability
  multi_az          = true
  allocated_storage = 500

  # Security
  enable_encryption = true
  kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  # Additional access
  additional_cidr_blocks = ["192.168.1.0/24"]
}
```

## A9 Catalog IDP Integration

This module is designed to work seamlessly with the A9 Catalog IDP. The IDP automatically provides the following variables:

- `vpc_id`: VPC where the database will be deployed
- `environment`: Environment name (dev, staging, prod)
- `vpc_cidr_block`: VPC CIDR for security group configuration
- `subnets_pvt`: List of private subnet IDs for the DB subnet group

When using this module through the A9 Catalog, these variables are automatically populated, and you only need to specify database-specific configuration.

## Input Variables

### IDP-Provided Required Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | VPC ID provided by A9 Catalog IDP | `string` | n/a | yes |
| environment | Environment name (dev, staging, prod) provided by A9 Catalog IDP | `string` | n/a | yes |
| vpc_cidr_block | VPC CIDR block provided by A9 Catalog IDP for security group configuration | `string` | n/a | yes |
| subnets_pvt | List of private subnet IDs provided by A9 Catalog IDP | `list(string)` | n/a | yes |

### Database Configuration Required Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| engine | Database engine type. Valid values: mysql, postgres, mariadb, aurora-mysql, aurora-postgresql, oracle-ee, oracle-se2, oracle-se1, oracle-se, sqlserver-ee, sqlserver-se, sqlserver-ex, sqlserver-web | `string` | n/a | yes |
| engine_version | Database engine version | `string` | n/a | yes |
| master_username | Master username for the database | `string` | n/a | yes |
| master_password | Master password for the database (sensitive) | `string` | n/a | yes |

### Execution Mode Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| is_aurora | If true, provisions Aurora cluster instead of standard RDS instance | `bool` | `false` | no |
| is_serverless | If true and is_aurora is true, uses Aurora Serverless v2 | `bool` | `false` | no |
| instance_class | Instance class for provisioned mode (e.g., db.t3.small, db.r5.large). If not specified, defaults based on environment (dev: db.t3.small, staging: db.t3.medium, prod: db.r5.large) | `string` | `null` | no |
| allocated_storage | Allocated storage in GB for non-Aurora RDS instances | `number` | `20` | no |

### Serverless Configuration Optional Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| serverless_min_capacity | Minimum Aurora Serverless v2 capacity units (ACU) | `number` | `0.5` | no |
| serverless_max_capacity | Maximum Aurora Serverless v2 capacity units (ACU) | `number` | `1.0` | no |

### High Availability Optional Variables

| Name | Description | Type | Default | Required | Validation |
|------|-------------|------|---------|:--------:|------------|
| multi_az | Enable Multi-AZ deployment for non-Aurora RDS instances | `bool` | `false` | no | n/a |
| replica_count | Number of read replicas for Aurora clusters | `number` | `0` | no | Must be between 0 and 15 |

### Backup and Maintenance Optional Variables

| Name | Description | Type | Default | Required | Validation |
|------|-------------|------|---------|:--------:|------------|
| backup_retention_period | Backup retention period in days | `number` | `7` | no | Must be between 0 and 35 |
| backup_window | Preferred backup window in UTC format (e.g., 03:00-04:00) | `string` | `"03:00-04:00"` | no | n/a |
| maintenance_window | Preferred maintenance window in UTC format (e.g., sun:04:00-sun:05:00) | `string` | `"sun:04:00-sun:05:00"` | no | n/a |
| auto_minor_version_upgrade | Enable automated minor version upgrades | `bool` | `true` | no | n/a |
| deletion_protection | Enable deletion protection | `bool` | `true` | no | n/a |

### Security Optional Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional_cidr_blocks | Additional CIDR blocks allowed to access the database | `list(string)` | `[]` | no |
| enable_encryption | Enable encryption at rest using AWS KMS | `bool` | `true` | no |
| kms_key_id | KMS key ARN for encryption at rest (uses AWS default key if not specified) | `string` | `null` | no |
| store_credentials_in_secrets_manager | Store database credentials in AWS Secrets Manager | `bool` | `false` | no |

### Customization Optional Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| database_name | Name of the initial database to create on instance launch | `string` | `null` | no |
| parameter_group_parameters | Map of custom parameter group settings | `map(string)` | `{}` | no |
| option_group_options | List of custom option group settings for engines that support it | `list(object)` | `[]` | no |
| custom_tags | Custom tags to apply to all resources (merged with default tags) | `map(string)` | `{}` | no |
| enable_performance_insights | Enable Performance Insights | `bool` | `false` | no |
| performance_insights_retention_period | Performance Insights retention period in days | `number` | `7` | no |

## Outputs

### Common Outputs

| Name | Description | Type |
|------|-------------|------|
| endpoint | The connection endpoint for the database | `string` |
| port | The port on which the database accepts connections | `number` |
| database_name | The name of the default database | `string` |
| security_group_id | The ID of the security group created for the database | `string` |
| db_subnet_group_name | The name of the DB subnet group | `string` |
| master_username | The master username for the database | `string` |

### RDS-Specific Outputs (Non-Aurora)

| Name | Description | Type |
|------|-------------|------|
| instance_id | The RDS instance ID (only for non-Aurora databases) | `string` |
| instance_arn | The ARN of the RDS instance (only for non-Aurora databases) | `string` |
| instance_resource_id | The resource ID of the RDS instance (only for non-Aurora databases) | `string` |

### Aurora-Specific Outputs

| Name | Description | Type |
|------|-------------|------|
| cluster_id | The Aurora cluster identifier (only for Aurora databases) | `string` |
| cluster_arn | The ARN of the Aurora cluster (only for Aurora databases) | `string` |
| cluster_endpoint | The cluster endpoint (writer) for Aurora databases | `string` |
| cluster_reader_endpoint | The cluster reader endpoint for Aurora databases | `string` |
| cluster_members | List of instance IDs that are part of the Aurora cluster | `list(string)` |

### Secrets Manager Output

| Name | Description | Type | Sensitive |
|------|-------------|------|-----------|
| secret_arn | The ARN of the Secrets Manager secret containing database credentials | `string` | yes |

## Security Best Practices

### Encryption

- **Encryption at Rest**: Enabled by default (`enable_encryption = true`)
- **KMS Keys**: Use customer-managed KMS keys for production workloads
- **Encryption in Transit**: All RDS instances support SSL/TLS connections

### Credentials Management

- **Never hardcode passwords**: Use AWS Secrets Manager or parameter stores
- **Secrets Manager Integration**: Enable `store_credentials_in_secrets_manager = true` for automatic credential storage
- **Password Rotation**: Implement regular password rotation policies
- **Sensitive Variables**: The `master_password` variable is marked as sensitive

### Network Security

- **VPC Isolation**: Databases are deployed in private subnets only
- **Security Groups**: Restrictive security groups allow access only from VPC CIDR by default
- **Additional Access**: Use `additional_cidr_blocks` sparingly and document all exceptions
- **No Public Access**: This module does not support publicly accessible databases

### Access Control

- **IAM Authentication**: Consider enabling IAM database authentication for supported engines
- **Least Privilege**: Grant only necessary permissions to database users
- **Audit Logging**: Enable CloudWatch Logs exports for audit trails

### Backup and Recovery

- **Automated Backups**: Enabled by default with 7-day retention
- **Production Retention**: Increase `backup_retention_period` to 30 days for production
- **Deletion Protection**: Enabled by default to prevent accidental deletion
- **Point-in-Time Recovery**: Automatically enabled with automated backups

### Monitoring

- **Performance Insights**: Enable for production workloads to identify performance issues
- **CloudWatch Metrics**: Monitor CPU, memory, storage, and connection metrics
- **Enhanced Monitoring**: Consider enabling for detailed OS-level metrics
- **Alarms**: Set up CloudWatch alarms for critical metrics

## Troubleshooting

### Common Issues

#### Issue: "Serverless mode is only supported with Aurora engines"

**Cause**: Attempting to use `is_serverless = true` with a non-Aurora engine.

**Solution**: Set `is_aurora = true` or use an Aurora engine (`aurora-mysql` or `aurora-postgresql`).

```hcl
# Correct configuration
engine        = "aurora-postgresql"
is_aurora     = true
is_serverless = true
```

#### Issue: "DB subnet group requires subnets in at least 2 availability zones"

**Cause**: The `subnets_pvt` list contains subnets from only one availability zone.

**Solution**: Provide subnets from at least two different availability zones.

```hcl
subnets_pvt = [
  "subnet-abc123",  # us-east-1a
  "subnet-def456"   # us-east-1b
]
```

#### Issue: "Invalid instance class for the selected engine"

**Cause**: The specified `instance_class` is not compatible with the selected database engine.

**Solution**: Refer to AWS documentation for valid instance classes for your engine. For Aurora, use instance classes like `db.r5.large`, `db.r6g.xlarge`. For RDS, use classes like `db.t3.small`, `db.m5.large`.

#### Issue: "Backup retention period must be between 0 and 35 days"

**Cause**: The `backup_retention_period` value is outside the valid range.

**Solution**: Set a value between 0 and 35 days.

```hcl
backup_retention_period = 30  # Valid
```

#### Issue: "Aurora replica count must be between 0 and 15"

**Cause**: The `replica_count` value exceeds the maximum allowed replicas.

**Solution**: Set `replica_count` to a value between 0 and 15.

```hcl
replica_count = 2  # Valid
```

#### Issue: Connection timeout when accessing the database

**Cause**: Security group rules may not allow traffic from your source, or the database is not in a reachable subnet.

**Solution**:
1. Verify security group rules allow traffic on the database port
2. Add your CIDR block to `additional_cidr_blocks` if accessing from outside the VPC
3. Ensure you're connecting from within the VPC or through a VPN/bastion host
4. Check that the database is in private subnets with proper routing

```hcl
additional_cidr_blocks = ["10.1.0.0/16"]  # Add your network
```

#### Issue: "Error creating DB Instance: InvalidParameterCombination"

**Cause**: Incompatible parameter combinations, such as using Multi-AZ with Aurora or serverless with non-Aurora engines.

**Solution**: Review the parameter combinations:
- Multi-AZ is only for non-Aurora RDS instances
- For Aurora high availability, use `replica_count` instead
- Serverless requires Aurora engines

```hcl
# For Aurora HA, use replicas not multi_az
is_aurora     = true
replica_count = 2
multi_az      = false  # Not applicable for Aurora
```

#### Issue: Terraform state shows resources will be replaced

**Cause**: Certain RDS parameters cannot be modified in-place and require replacement.

**Solution**: 
1. Review the changes carefully
2. For production databases, consider creating a snapshot before applying
3. Some changes like engine type or storage type require replacement
4. Use `lifecycle` blocks to prevent accidental destruction

#### Issue: "Error: timeout while waiting for state to become 'available'"

**Cause**: RDS instance creation can take 10-30 minutes depending on configuration.

**Solution**: 
1. Be patient - this is normal for RDS provisioning
2. Check AWS Console for any error messages
3. Verify all prerequisites (VPC, subnets, security groups) are correctly configured
4. For large storage allocations, provisioning takes longer

### Getting Help

If you encounter issues not covered here:

1. Check AWS RDS documentation for engine-specific requirements
2. Review Terraform AWS provider documentation
3. Verify all required variables are correctly set
4. Check CloudWatch Logs for detailed error messages
5. Contact your platform team or AWS support

## Examples

Additional examples are available in the `examples/` directory:

- `examples/rds-mysql/` - Basic RDS MySQL instance
- `examples/rds-postgres/` - RDS PostgreSQL with Multi-AZ
- `examples/aurora-serverless/` - Aurora Serverless v2 configuration
- `examples/aurora-provisioned/` - Aurora with read replicas

## License

This module is licensed under the MIT License. See LICENSE file for details.

## Authors

Maintained by the Platform Engineering Team.

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

### Conventional Commits

This project uses [Conventional Commits](https://www.conventionalcommits.org/) for automated releases. Please format your commit messages accordingly:

```
feat(rds): add support for MySQL 8.0
fix(aurora): correct replica count validation
docs(readme): update usage examples
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Versioning

This project follows [Semantic Versioning](https://semver.org/). Releases are automated using [Semantic Release](https://semantic-release.gitbook.io/) based on commit messages.

- **MAJOR** version: Breaking changes (e.g., `feat!:` or `BREAKING CHANGE:`)
- **MINOR** version: New features (e.g., `feat:`)
- **PATCH** version: Bug fixes and improvements (e.g., `fix:`, `docs:`, `refactor:`)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.
