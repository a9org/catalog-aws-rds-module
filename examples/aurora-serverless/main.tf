module "aurora_serverless" {
  source = "../.."

  # IDP-provided variables
  vpc_id         = var.vpc_id
  environment    = var.environment
  vpc_cidr_block = var.vpc_cidr_block
  subnets_pvt    = var.subnets_pvt

  # Database configuration
  engine          = "aurora-postgresql"
  engine_version  = "15.4"
  master_username = var.master_username
  master_password = var.master_password

  # Execution mode - Aurora Serverless v2
  is_aurora     = true
  is_serverless = true

  # Serverless scaling configuration
  serverless_min_capacity = var.serverless_min_capacity
  serverless_max_capacity = var.serverless_max_capacity

  # Database settings
  database_name = var.database_name

  # Backup and maintenance
  backup_retention_period    = var.backup_retention_period
  backup_window              = "03:00-04:00"
  maintenance_window         = "mon:04:00-mon:05:00"
  auto_minor_version_upgrade = true
  deletion_protection        = var.deletion_protection

  # Security
  additional_cidr_blocks               = var.additional_cidr_blocks
  enable_encryption                    = true
  store_credentials_in_secrets_manager = var.store_credentials_in_secrets_manager

  # Custom parameter group settings
  parameter_group_parameters = var.parameter_group_parameters

  # Performance
  enable_performance_insights           = var.enable_performance_insights
  performance_insights_retention_period = 7

  # Custom tags
  custom_tags = {
    Example     = "aurora-serverless"
    Application = "demo"
    ScalingMode = "serverless"
  }
}
