# ============================================================================
# COMMON OUTPUTS
# ============================================================================

output "endpoint" {
  description = "The connection endpoint for the database"
  value       = local.is_aurora ? (length(aws_rds_cluster.this) > 0 ? aws_rds_cluster.this[0].endpoint : null) : (length(aws_db_instance.this) > 0 ? aws_db_instance.this[0].endpoint : null)
}

output "port" {
  description = "The port on which the database accepts connections"
  value       = local.db_port
}

output "database_name" {
  description = "The name of the default database"
  value       = var.database_name
}

output "security_group_id" {
  description = "The ID of the security group created for the database"
  value       = aws_security_group.this.id
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.this.name
}

output "master_username" {
  description = "The master username for the database"
  value       = var.master_username
}

# ============================================================================
# RDS-SPECIFIC OUTPUTS (NON-AURORA)
# ============================================================================

output "instance_id" {
  description = "The RDS instance ID (only for non-Aurora databases)"
  value       = !local.is_aurora && length(aws_db_instance.this) > 0 ? aws_db_instance.this[0].id : null
}

output "instance_arn" {
  description = "The ARN of the RDS instance (only for non-Aurora databases)"
  value       = !local.is_aurora && length(aws_db_instance.this) > 0 ? aws_db_instance.this[0].arn : null
}

output "instance_resource_id" {
  description = "The resource ID of the RDS instance (only for non-Aurora databases)"
  value       = !local.is_aurora && length(aws_db_instance.this) > 0 ? aws_db_instance.this[0].resource_id : null
}

# ============================================================================
# AURORA-SPECIFIC OUTPUTS
# ============================================================================

output "cluster_id" {
  description = "The Aurora cluster identifier (only for Aurora databases)"
  value       = local.is_aurora && length(aws_rds_cluster.this) > 0 ? aws_rds_cluster.this[0].id : null
}

output "cluster_arn" {
  description = "The ARN of the Aurora cluster (only for Aurora databases)"
  value       = local.is_aurora && length(aws_rds_cluster.this) > 0 ? aws_rds_cluster.this[0].arn : null
}

output "cluster_endpoint" {
  description = "The cluster endpoint (writer) for Aurora databases"
  value       = local.is_aurora && length(aws_rds_cluster.this) > 0 ? aws_rds_cluster.this[0].endpoint : null
}

output "cluster_reader_endpoint" {
  description = "The cluster reader endpoint for Aurora databases"
  value       = local.is_aurora && length(aws_rds_cluster.this) > 0 ? aws_rds_cluster.this[0].reader_endpoint : null
}

output "cluster_members" {
  description = "List of instance IDs that are part of the Aurora cluster"
  value = local.is_aurora ? concat(
    [for instance in aws_rds_cluster_instance.provisioned : instance.id],
    [for instance in aws_rds_cluster_instance.serverless : instance.id]
  ) : []
}

# ============================================================================
# SECRETS MANAGER OUTPUT
# ============================================================================

output "secret_arn" {
  description = "The ARN of the Secrets Manager secret containing database credentials"
  value       = var.store_credentials_in_secrets_manager && length(aws_secretsmanager_secret.this) > 0 ? aws_secretsmanager_secret.this[0].arn : null
  sensitive   = true
}
