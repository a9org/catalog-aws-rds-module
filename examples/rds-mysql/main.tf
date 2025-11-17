module "rds_mysql" {
  source = "../.."

  # IDP-provided variables
  vpc_id         = var.vpc_id
  environment    = var.environment
  vpc_cidr_block = var.vpc_cidr_block
  subnets_pvt    = var.subnets_pvt

  # Database configuration
  engine          = "mysql"
  engine_version  = "8.0.35"
  master_username = var.master_username
  master_password = var.master_password

  # Execution mode - RDS provisioned instance
  is_aurora        = false
  is_serverless    = false
  instance_class   = var.instance_class
  allocated_storage = var.allocated_storage

  # Database settings
  database_name = var.database_name

  # High availability
  multi_az = var.multi_az

  # Backup and maintenance
  backup_retention_period   = var.backup_retention_period
  backup_window             = "03:00-04:00"
  maintenance_window        = "sun:04:00-sun:05:00"
  auto_minor_version_upgrade = true
  deletion_protection       = var.deletion_protection

  # Security
  additional_cidr_blocks              = var.additional_cidr_blocks
  enable_encryption                   = true
  store_credentials_in_secrets_manager = var.store_credentials_in_secrets_manager

  # Performance
  enable_performance_insights           = var.enable_performance_insights
  performance_insights_retention_period = 7

  # Custom tags
  custom_tags = {
    Example     = "rds-mysql"
    Application = "demo"
  }
}
