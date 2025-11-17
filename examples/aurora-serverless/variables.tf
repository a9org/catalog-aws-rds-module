variable "vpc_id" {
  description = "VPC ID where the Aurora cluster will be created"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
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
  default     = "postgres"
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = "appdb"
}

variable "serverless_min_capacity" {
  description = "Minimum Aurora Capacity Units (ACU)"
  type        = number
  default     = 0.5
}

variable "serverless_max_capacity" {
  description = "Maximum Aurora Capacity Units (ACU)"
  type        = number
  default     = 1.0
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "additional_cidr_blocks" {
  description = "Additional CIDR blocks allowed to access the database"
  type        = list(string)
  default     = []
}

variable "store_credentials_in_secrets_manager" {
  description = "Store database credentials in AWS Secrets Manager"
  type        = bool
  default     = false
}

variable "enable_performance_insights" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "parameter_group_parameters" {
  description = "Custom parameter group settings"
  type        = map(string)
  default     = {}
}
