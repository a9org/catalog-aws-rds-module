output "endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds_mysql.endpoint
}

output "port" {
  description = "RDS instance port"
  value       = module.rds_mysql.port
}

output "database_name" {
  description = "Name of the database"
  value       = module.rds_mysql.database_name
}

output "master_username" {
  description = "Master username"
  value       = module.rds_mysql.master_username
}

output "instance_id" {
  description = "RDS instance ID"
  value       = module.rds_mysql.instance_id
}

output "instance_arn" {
  description = "RDS instance ARN"
  value       = module.rds_mysql.instance_arn
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.rds_mysql.security_group_id
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = module.rds_mysql.db_subnet_group_name
}

output "secret_arn" {
  description = "Secrets Manager secret ARN (if enabled)"
  value       = module.rds_mysql.secret_arn
  sensitive   = true
}
