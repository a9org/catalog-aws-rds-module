# AWS RDS Terraform Module

Módulo Terraform para provisionamento de instâncias AWS RDS com suporte a múltiplos SGBDs (MySQL, PostgreSQL, MariaDB, Oracle, SQL Server), modos de execução (serverless e provisionado), e variantes Aurora.

## Características

- Suporte a todos os engines RDS disponíveis (MySQL, PostgreSQL, MariaDB, Oracle, SQL Server)
- Suporte a Aurora MySQL e Aurora PostgreSQL
- Modo Serverless v2 para Aurora
- Modo provisionado com suporte a Multi-AZ e read replicas
- Integração com A9 Catalog IDP
- Encryption at rest habilitado por padrão
- Integração opcional com AWS Secrets Manager
- Security groups configuráveis
- Backup e manutenção configuráveis
- Performance Insights opcional

## Requisitos

- Terraform >= 1.0
- AWS Provider >= 4.0

## Variáveis Fornecidas pelo A9 Catalog IDP

O módulo espera receber as seguintes variáveis do A9 Catalog:

- `vpc_id`: ID da VPC onde os recursos serão criados
- `environment`: Nome do ambiente (dev, staging, prod)
- `vpc_cidr_block`: CIDR block da VPC para configuração de security groups
- `subnets_pvt`: Lista de subnet IDs privadas para o DB subnet group

## Uso Básico

```hcl
module "rds" {
  source = "./path-to-module"

  # Variáveis do IDP
  vpc_id         = var.vpc_id
  environment    = var.environment
  vpc_cidr_block = var.vpc_cidr_block
  subnets_pvt    = var.subnets_pvt

  # Configuração do banco de dados
  engine          = "postgres"
  engine_version  = "14.7"
  master_username = "admin"
  master_password = var.db_password

  # Modo de execução
  is_aurora      = false
  instance_class = "db.t3.small"
  allocated_storage = 20
}
```

## Exemplos

Consulte o diretório `examples/` para exemplos completos de uso:

- `examples/rds-mysql/` - RDS MySQL tradicional
- `examples/rds-postgres/` - RDS PostgreSQL tradicional
- `examples/aurora-serverless/` - Aurora Serverless v2
- `examples/aurora-provisioned/` - Aurora provisionado com read replicas

## Outputs

O módulo fornece os seguintes outputs:

- `endpoint`: Endereço do endpoint do banco de dados
- `port`: Porta do banco de dados
- `database_name`: Nome do banco de dados
- `security_group_id`: ID do security group criado
- `cluster_endpoint`: Endpoint do cluster Aurora (quando aplicável)
- `cluster_reader_endpoint`: Endpoint de leitura do cluster Aurora (quando aplicável)

## Documentação Completa

Para documentação detalhada sobre todas as variáveis, validações e configurações avançadas, consulte:

- `.kiro/specs/aws-rds-terraform-module/requirements.md` - Requisitos funcionais
- `.kiro/specs/aws-rds-terraform-module/design.md` - Arquitetura e design
- `.kiro/specs/aws-rds-terraform-module/tasks.md` - Plano de implementação

## Licença

Ver arquivo LICENSE para detalhes.
