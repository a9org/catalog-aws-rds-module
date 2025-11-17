# Main resource definitions and conditional logic
# This file will contain DB subnet group, parameter groups, option groups,
# RDS instances, and Aurora cluster resources

# DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-subnet-group"
  subnet_ids = var.subnets_pvt

  tags = local.tags
}

# Parameter Group for non-Aurora databases
resource "aws_db_parameter_group" "this" {
  count = !local.is_aurora ? 1 : 0

  name   = "${local.name_prefix}-pg"
  family = local.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Parameter Group for Aurora clusters
resource "aws_rds_cluster_parameter_group" "this" {
  count = local.is_aurora ? 1 : 0

  name   = "${local.name_prefix}-cluster-pg"
  family = local.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Option Group for engines that support it (MySQL, MariaDB, Oracle, SQL Server)
resource "aws_db_option_group" "this" {
  count = !local.is_aurora && local.supports_option_group ? 1 : 0

  name                     = "${local.name_prefix}-og"
  option_group_description = "Option group for ${var.engine}"
  engine_name              = var.engine
  major_engine_version     = local.major_engine_version

  dynamic "option" {
    for_each = var.option_group_options
    content {
      option_name = option.value.option_name

      dynamic "option_settings" {
        for_each = option.value.option_settings
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================================
# RDS INSTANCE (NON-AURORA)
# ============================================================================

resource "aws_db_instance" "this" {
  count = !local.is_aurora ? 1 : 0

  # Identifier
  identifier = "${local.name_prefix}-${var.engine}"

  # Engine configuration
  engine         = var.engine
  engine_version = var.engine_version

  # Instance configuration
  instance_class    = local.instance_class
  allocated_storage = var.allocated_storage

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  publicly_accessible    = false

  # Database configuration
  db_name  = var.database_name
  username = var.master_username
  password = var.master_password

  # High availability
  multi_az = var.multi_az

  # Backup configuration
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window

  # Maintenance configuration
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Deletion protection
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = false
  final_snapshot_identifier = "${local.name_prefix}-${var.engine}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Encryption
  storage_encrypted = var.enable_encryption
  kms_key_id        = var.kms_key_id

  # Parameter and option groups
  parameter_group_name = !local.is_aurora && length(aws_db_parameter_group.this) > 0 ? aws_db_parameter_group.this[0].name : null
  option_group_name    = !local.is_aurora && local.supports_option_group && length(aws_db_option_group.this) > 0 ? aws_db_option_group.this[0].name : null

  # Performance Insights
  enabled_cloudwatch_logs_exports       = []
  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention_period : null

  # Lifecycle rules
  lifecycle {
    ignore_changes = [
      password,
      final_snapshot_identifier
    ]
  }

  # Timeouts
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }

  # Tags
  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-${var.engine}"
    }
  )
}

# ============================================================================
# AURORA CLUSTER
# ============================================================================

resource "aws_rds_cluster" "this" {
  count = local.is_aurora ? 1 : 0

  # Identifier
  cluster_identifier = "${local.name_prefix}-aurora-cluster"

  # Engine configuration
  engine         = var.engine
  engine_version = var.engine_version
  engine_mode    = "provisioned"

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  # Database configuration
  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password

  # Backup configuration
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.backup_window
  preferred_maintenance_window = var.maintenance_window

  # Serverless v2 scaling configuration (only when serverless is enabled)
  dynamic "serverlessv2_scaling_configuration" {
    for_each = local.is_serverless ? [1] : []
    content {
      min_capacity = var.serverless_min_capacity
      max_capacity = var.serverless_max_capacity
    }
  }

  # Encryption
  storage_encrypted = var.enable_encryption
  kms_key_id        = var.kms_key_id

  # Parameter group
  db_cluster_parameter_group_name = local.is_aurora && length(aws_rds_cluster_parameter_group.this) > 0 ? aws_rds_cluster_parameter_group.this[0].name : null

  # CloudWatch Logs exports based on engine
  enabled_cloudwatch_logs_exports = can(regex("^aurora-mysql", var.engine)) ? ["audit", "error", "general", "slowquery"] : can(regex("^aurora-postgresql", var.engine)) ? ["postgresql"] : []

  # Deletion protection
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = false
  final_snapshot_identifier = "${local.name_prefix}-aurora-cluster-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Lifecycle rules
  lifecycle {
    ignore_changes = [
      master_password,
      final_snapshot_identifier
    ]
  }

  # Tags
  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-aurora-cluster"
    }
  )
}

# ============================================================================
# AURORA CLUSTER INSTANCES (PROVISIONED MODE)
# ============================================================================

resource "aws_rds_cluster_instance" "provisioned" {
  count = local.is_aurora && !local.is_serverless ? 1 + var.replica_count : 0

  # Identifier with count index
  identifier = "${local.name_prefix}-aurora-instance-${count.index}"

  # Cluster association
  cluster_identifier = aws_rds_cluster.this[0].id

  # Instance configuration
  instance_class = local.instance_class
  engine         = var.engine

  # Performance Insights
  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention_period : null

  # Distribute instances across availability zones
  # This uses modulo to cycle through available AZs
  # Note: In production, you might want to use data source to get actual AZ list
  availability_zone = null # Let AWS distribute automatically for better HA

  # Auto minor version upgrade
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Tags
  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-aurora-instance-${count.index}"
      Role = count.index == 0 ? "writer" : "reader"
    }
  )
}

# ============================================================================
# AURORA CLUSTER INSTANCE (SERVERLESS MODE)
# ============================================================================

resource "aws_rds_cluster_instance" "serverless" {
  count = local.is_serverless ? 1 : 0

  # Identifier
  identifier = "${local.name_prefix}-aurora-serverless-instance"

  # Cluster association
  cluster_identifier = aws_rds_cluster.this[0].id

  # Instance configuration for Serverless v2
  instance_class = "db.serverless"
  engine         = var.engine

  # Performance Insights
  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention_period : null

  # Tags
  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-aurora-serverless-instance"
      Mode = "serverless"
    }
  )
}
