# Local values and computed variables

locals {
  # Name prefix computation using environment
  name_prefix = "${var.environment}-rds"

  # Aurora detection logic - checks is_aurora flag or aurora-* engine names
  is_aurora = var.is_aurora || can(regex("^aurora-", var.engine))

  # Serverless detection logic - serverless only valid with Aurora
  is_serverless = var.is_serverless && local.is_aurora

  # Port mapping for all supported database engines
  port_map = {
    mysql             = 3306
    postgres          = 5432
    aurora-mysql      = 3306
    aurora-postgresql = 5432
    mariadb           = 3306
    oracle-ee         = 1521
    oracle-se2        = 1521
    oracle-se1        = 1521
    oracle-se         = 1521
    sqlserver-ee      = 1433
    sqlserver-se      = 1433
    sqlserver-ex      = 1433
    sqlserver-web     = 1433
  }

  # Database port lookup based on engine
  db_port = lookup(local.port_map, var.engine, 3306)

  # Environment-based default instance classes
  default_instance_class = {
    dev     = "db.t3.small"
    staging = "db.t3.medium"
    prod    = "db.r5.large"
  }

  # Instance class selection with fallback to environment-based default
  instance_class = var.instance_class != null ? var.instance_class : lookup(local.default_instance_class, var.environment, "db.t3.small")

  # Default tags applied to all resources
  default_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "aws-rds-module"
  }

  # Merged tags combining default_tags and custom_tags
  tags = merge(local.default_tags, var.custom_tags)

  # Parameter group family mapping based on engine and version
  # This is a simplified mapping - in production, you might want to parse engine_version more carefully
  parameter_group_family_map = {
    mysql             = "mysql8.0"
    postgres          = "postgres14"
    mariadb           = "mariadb10.6"
    aurora-mysql      = "aurora-mysql8.0"
    aurora-postgresql = "aurora-postgresql14"
    oracle-ee         = "oracle-ee-19"
    oracle-se2        = "oracle-se2-19"
    oracle-se1        = "oracle-se1-11.2"
    oracle-se         = "oracle-se-11.2"
    sqlserver-ee      = "sqlserver-ee-15.0"
    sqlserver-se      = "sqlserver-se-15.0"
    sqlserver-ex      = "sqlserver-ex-15.0"
    sqlserver-web     = "sqlserver-web-15.0"
  }

  # Determine parameter group family - use map or construct from engine_version
  # For simplicity, using the map with common versions
  parameter_group_family = lookup(local.parameter_group_family_map, var.engine, "mysql8.0")

  # Engines that support option groups
  supports_option_group = contains([
    "mysql", "mariadb",
    "oracle-ee", "oracle-se2", "oracle-se1", "oracle-se",
    "sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web"
  ], var.engine)

  # Extract major engine version for option group
  # This is a simplified approach - assumes version format like "8.0.35" or "15.00.4073.23.v1"
  major_engine_version = split(".", var.engine_version)[0]
}
