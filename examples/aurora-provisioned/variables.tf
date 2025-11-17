variable "vpc_id" {
  description = "VPC ID where the Aurora cluster will be created"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "staging"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block for security group rules"
  type        = string
}

variable "subnets_pvt" {
  description = "List of private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Instance class for Aurora cluster instances"
  type        = string
  default     = "db.r5.large"
}

variable "replica_count" {
  description = "Number of read replicas to create"
  type        = number
  default     = 2
}

variable "database_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = "appdb"
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 14
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "additional_cidr_blocks" {
  description = "Additional CIDR blocks allowed to access the database"
  type        = list(string)
  default     = []
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (optional)"
  type        = string
  default     = null
}

variable "store_credentials_in_secrets_manager" {
  description = "Store database credentials in AWS Secrets Manager"
  type        = bool
  default     = true
}

variable "enable_performance_insights" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "parameter_group_parameters" {
  description = "Custom parameter group settings"
  type        = map(string)
  default     = {}
}
