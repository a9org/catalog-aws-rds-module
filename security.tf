# ============================================================================
# SECURITY GROUP
# ============================================================================

resource "aws_security_group" "this" {
  name_prefix = "${local.name_prefix}-sg-"
  description = "Security group for ${local.name_prefix} database"
  vpc_id      = var.vpc_id

  # Ingress rule: Allow traffic on db_port from VPC CIDR block
  ingress {
    description = "Database access from VPC"
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Dynamic ingress rules: Allow traffic from additional CIDR blocks
  dynamic "ingress" {
    for_each = var.additional_cidr_blocks
    content {
      description = "Database access from additional CIDR ${ingress.value}"
      from_port   = local.db_port
      to_port     = local.db_port
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # Egress rule: Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================================
# SECRETS MANAGER (CONDITIONAL)
# ============================================================================

resource "aws_secretsmanager_secret" "this" {
  count = var.store_credentials_in_secrets_manager ? 1 : 0

  name_prefix = "${local.name_prefix}-credentials-"
  description = "Database credentials for ${local.name_prefix}"

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "this" {
  count = var.store_credentials_in_secrets_manager ? 1 : 0

  secret_id = aws_secretsmanager_secret.this[0].id
  secret_string = jsonencode({
    username = var.master_username
    password = var.master_password
    engine   = var.engine
    port     = local.db_port
    # Endpoint will be populated after database resources are created
    # The actual endpoint reference will be added when implementing database resources
    endpoint = ""
  })

  # This resource will be updated after database creation to include the endpoint
  # The depends_on will be added when database resources are implemented
}
