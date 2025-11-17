output "cluster_endpoint" {
  description = "Aurora cluster writer endpoint"
  value       = module.aurora_serverless.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = module.aurora_serverless.cluster_reader_endpoint
}

output "endpoint" {
  description = "Primary endpoint (same as cluster_endpoint)"
  value       = module.aurora_serverless.endpoint
}

output "port" {
  description = "Database port"
  value       = module.aurora_serverless.port
}

output "database_name" {
  description = "Name of the database"
  value       = module.aurora_serverless.database_name
}

output "master_username" {
  description = "Master username"
  value       = module.aurora_serverless.master_username
}

output "cluster_id" {
  description = "Aurora cluster identifier"
  value       = module.aurora_serverless.cluster_id
}

output "cluster_arn" {
  description = "Aurora cluster ARN"
  value       = module.aurora_serverless.cluster_arn
}

output "cluster_members" {
  description = "List of cluster instance identifiers"
  value       = module.aurora_serverless.cluster_members
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.aurora_serverless.security_group_id
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = module.aurora_serverless.db_subnet_group_name
}

output "secret_arn" {
  description = "Secrets Manager secret ARN (if enabled)"
  value       = module.aurora_serverless.secret_arn
  sensitive   = true
}
