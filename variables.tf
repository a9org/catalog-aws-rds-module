# ============================================================================
# DATABASE CONFIGURATION REQUIRED VARIABLES
# ============================================================================

variable "engine" {
  description = "Database engine type"
  type        = string

  validation {
    condition = contains([
      "mysql", "postgres", "mariadb",
      "aurora-mysql", "aurora-postgresql",
      "oracle-ee", "oracle-se2", "oracle-se1", "oracle-se",
      "sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web"
    ], var.engine)
    error_message = "Invalid engine specified. Supported engines: mysql, postgres, mariadb, aurora-mysql, aurora-postgresql, oracle-ee, oracle-se2, oracle-se1, oracle-se, sqlserver-ee, sqlserver-se, sqlserver-ex, sqlserver-web."
  }
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

# ============================================================================
# EXECUTION MODE VARIABLES
# ============================================================================

variable "is_aurora" {
  description = "If true, provisions Aurora cluster instead of standard RDS instance"
  type        = bool
  default     = false
}

variable "is_serverless" {
  description = "If true and is_aurora is true, uses Aurora Serverless v2"
  type        = bool
  default     = false
}

variable "instance_class" {
  description = "Instance class for provisioned mode (e.g., db.t3.small, db.r5.large). If not specified, defaults based on environment."
  type        = string
  default     = null
  nullable    = true
}

variable "allocated_storage" {
  description = "Allocated storage in GB for non-Aurora RDS instances"
  type        = number
  default     = 20
}

# ============================================================================
# SERVERLESS CONFIGURATION OPTIONAL VARIABLES
# ============================================================================

variable "serverless_min_capacity" {
  description = "Minimum Aurora Serverless v2 capacity units (ACU)"
  type        = number
  default     = 0.5
}

variable "serverless_max_capacity" {
  description = "Maximum Aurora Serverless v2 capacity units (ACU)"
  type        = number
  default     = 1.0
}

# ============================================================================
# HIGH AVAILABILITY OPTIONAL VARIABLES
# ============================================================================

variable "multi_az" {
  description = "Enable Multi-AZ deployment for non-Aurora RDS instances"
  type        = bool
  default     = false
}

variable "replica_count" {
  description = "Number of read replicas for Aurora clusters (0 to 15)"
  type        = number
  default     = 0

  validation {
    condition     = var.replica_count >= 0 && var.replica_count <= 15
    error_message = "Aurora replica count must be between 0 and 15."
  }
}

# ============================================================================
# BACKUP AND MAINTENANCE OPTIONAL VARIABLES
# ============================================================================

variable "backup_retention_period" {
  description = "Backup retention period in days (0 to 35)"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "backup_window" {
  description = "Preferred backup window in UTC format (e.g., 03:00-04:00)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window in UTC format (e.g., sun:04:00-sun:05:00)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "auto_minor_version_upgrade" {
  description = "Enable automated minor version upgrades"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

# ============================================================================
# SECURITY OPTIONAL VARIABLES
# ============================================================================

variable "additional_cidr_blocks" {
  description = "Additional CIDR blocks allowed to access the database"
  type        = list(string)
  default     = []
}

variable "enable_encryption" {
  description = "Enable encryption at rest using AWS KMS"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ARN for encryption at rest (uses AWS default key if not specified)"
  type        = string
  default     = null
  nullable    = true
}

variable "store_credentials_in_secrets_manager" {
  description = "Store database credentials in AWS Secrets Manager"
  type        = bool
  default     = false
}

# ============================================================================
# CUSTOMIZATION OPTIONAL VARIABLES
# ============================================================================

variable "database_name" {
  description = "Name of the initial database to create on instance launch"
  type        = string
  default     = null
  nullable    = true
}

variable "parameter_group_parameters" {
  description = "Map of custom parameter group settings"
  type        = map(string)
  default     = {}
}

variable "option_group_options" {
  description = "List of custom option group settings for engines that support it"
  type = list(object({
    option_name = string
    option_settings = optional(list(object({
      name  = string
      value = string
    })), [])
  }))
  default = []
}

variable "custom_tags" {
  description = "Custom tags to apply to all resources (merged with default tags)"
  type        = map(string)
  default     = {}
}

variable "enable_performance_insights" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7
}

# ============================================================================
# IDP-PROVIDED REQUIRED VARIABLES
# ============================================================================

variable "vpc_id" {
  description = "VPC ID provided by A9 Catalog IDP"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name (dev, staging, prod) provided by A9 Catalog IDP"
  type        = string
  default     = null
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block provided by A9 Catalog IDP for security group configuration"
  type        = string
  default     = null
}

variable "subnets_pvt" {
  description = "List of private subnet IDs provided by A9 Catalog IDP"
  type        = list(string)
  default     = null
}