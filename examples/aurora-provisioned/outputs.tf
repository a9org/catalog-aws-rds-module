output "cluster_endpoint" {
  description = "Aurora cluster writer endpoint for write operations"
  value       = module.aurora_provisioned.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint for read operations"
  value       = module.aurora_provisioned.cluster_reader_endpoint
}

output "endpoint" {
  description = "Primary endpoint (same as cluster_endpoint)"
  value       = module.aurora_provisioned.endpoint
}

output "port" {
  description = "Database port"
  value       = module.aurora_provisioned.port
}

output "database_name" {
  description = "Name of the database"
  value       = module.aurora_provisioned.database_name
}

output "master_username" {
  description = "Master username"
  value       = module.aurora_provisioned.master_username
}

output "cluster_id" {
  description = "Aurora cluster identifier"
  value       = module.aurora_provisioned.cluster_id
}

output "cluster_arn" {
  description = "Aurora cluster ARN"
  value       = module.aurora_provisioned.cluster_arn
}

output "cluster_members" {
  description = "List of cluster instance identifiers"
  value       = module.aurora_provisioned.cluster_members
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.aurora_provisioned.security_group_id
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = module.aurora_provisioned.db_subnet_group_name
}

output "secret_arn" {
  description = "Secrets Manager secret ARN (if enabled)"
  value       = module.aurora_provisioned.secret_arn
  sensitive   = true
}
