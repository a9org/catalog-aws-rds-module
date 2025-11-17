output "endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds_postgres.endpoint
}

output "port" {
  description = "RDS instance port"
  value       = module.rds_postgres.port
}

output "database_name" {
  description = "Name of the database"
  value       = module.rds_postgres.database_name
}

output "master_username" {
  description = "Master username"
  value       = module.rds_postgres.master_username
}

output "instance_id" {
  description = "RDS instance ID"
  value       = module.rds_postgres.instance_id
}

output "instance_arn" {
  description = "RDS instance ARN"
  value       = module.rds_postgres.instance_arn
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.rds_postgres.security_group_id
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = module.rds_postgres.db_subnet_group_name
}
