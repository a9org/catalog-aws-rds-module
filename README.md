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

### RDS PostgreSQL Tradicional

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
  is_aurora         = false
  instance_class    = "db.t3.small"
  allocated_storage = 20
}
```

### Aurora Serverless v2

```hcl
module "rds_aurora_serverless" {
  source = "./path-to-module"

  # Variáveis do IDP
  vpc_id         = var.vpc_id
  environment    = var.environment
  vpc_cidr_block = var.vpc_cidr_block
  subnets_pvt    = var.subnets_pvt

  # Configuração do banco de dados
  engine          = "aurora-postgresql"
  engine_version  = "14.7"
  master_username = "admin"
  master_password = var.db_password

  # Modo serverless
  is_aurora              = true
  is_serverless          = true
  serverless_min_capacity = 0.5
  serverless_max_capacity = 2.0
}
```

### Aurora Provisionado com Read Replicas

```hcl
module "rds_aurora_ha" {
  source = "./path-to-module"

  # Variáveis do IDP
  vpc_id         = var.vpc_id
  environment    = var.environment
  vpc_cidr_block = var.vpc_cidr_block
  subnets_pvt    = var.subnets_pvt

  # Configuração do banco de dados
  engine          = "aurora-mysql"
  engine_version  = "8.0.mysql_aurora.3.02.0"
  master_username = "admin"
  master_password = var.db_password

  # Alta disponibilidade
  is_aurora     = true
  is_serverless = false
  instance_class = "db.r5.large"
  replica_count  = 2
}
```

## Exemplos

Consulte o diretório `examples/` para exemplos completos de uso:

- `examples/rds-mysql/` - RDS MySQL tradicional
- `examples/rds-postgres/` - RDS PostgreSQL tradicional
- `examples/aurora-serverless/` - Aurora Serverless v2
- `examples/aurora-provisioned/` - Aurora provisionado com read replicas

## Variáveis de Entrada

### Variáveis Obrigatórias

| Nome | Tipo | Descrição |
|------|------|-----------|
| `vpc_id` | string | VPC ID fornecido pelo A9 Catalog |
| `environment` | string | Nome do ambiente (dev, staging, prod) |
| `vpc_cidr_block` | string | CIDR block da VPC |
| `subnets_pvt` | list(string) | Lista de subnet IDs privadas |
| `engine` | string | Engine do banco de dados (mysql, postgres, aurora-mysql, etc.) |
| `engine_version` | string | Versão do engine |
| `master_username` | string | Username master |
| `master_password` | string | Password master (sensitive) |

### Variáveis Opcionais Principais

| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| `is_aurora` | bool | false | Provisionar Aurora cluster |
| `is_serverless` | bool | false | Usar Aurora Serverless v2 |
| `instance_class` | string | null | Classe da instância (default baseado em environment) |
| `allocated_storage` | number | 20 | Storage em GB (não-Aurora) |
| `multi_az` | bool | false | Multi-AZ para RDS tradicional |
| `replica_count` | number | 0 | Número de read replicas Aurora (0-15) |
| `backup_retention_period` | number | 7 | Retenção de backup em dias (0-35) |
| `enable_encryption` | bool | true | Habilitar encryption at rest |
| `deletion_protection` | bool | true | Proteção contra exclusão |

### Defaults Inteligentes

O módulo aplica defaults baseados no ambiente quando `instance_class` não é especificado:

- **dev**: `db.t3.small` - Instâncias menores para desenvolvimento
- **staging**: `db.t3.medium` - Instâncias médias para testes
- **prod**: `db.r5.large` - Instâncias otimizadas para produção

O módulo também detecta automaticamente se o engine é Aurora baseado no nome (engines começando com `aurora-`), mesmo se `is_aurora` não for explicitamente definido.

### Validações Implementadas

- **Engine**: Apenas engines suportados pela AWS RDS
- **Serverless**: Requer `is_aurora = true`
- **Multi-AZ**: Não aplicável para Aurora (usar `replica_count`)
- **Replica Count**: Entre 0 e 15 para Aurora
- **Backup Retention**: Entre 0 e 35 dias

## Outputs

### Outputs Comuns

| Nome | Descrição |
|------|-----------|
| `endpoint` | Endereço do endpoint do banco de dados |
| `port` | Porta do banco de dados |
| `database_name` | Nome do banco de dados |
| `security_group_id` | ID do security group criado |
| `db_subnet_group_name` | Nome do DB subnet group |
| `master_username` | Username master |

### Outputs RDS (não-Aurora)

| Nome | Descrição |
|------|-----------|
| `instance_id` | ID da instância RDS |
| `instance_arn` | ARN da instância RDS |
| `instance_resource_id` | Resource ID da instância |

### Outputs Aurora

| Nome | Descrição |
|------|-----------|
| `cluster_id` | ID do cluster Aurora |
| `cluster_arn` | ARN do cluster Aurora |
| `cluster_endpoint` | Endpoint de escrita do cluster |
| `cluster_reader_endpoint` | Endpoint de leitura do cluster |
| `cluster_members` | Lista de instance IDs no cluster |

### Outputs Secrets Manager

| Nome | Descrição |
|------|-----------|
| `secret_arn` | ARN do secret (quando habilitado) |

## Documentação Completa

Para documentação detalhada sobre todas as variáveis, validações e configurações avançadas, consulte:

- `.kiro/specs/aws-rds-terraform-module/requirements.md` - Requisitos funcionais
- `.kiro/specs/aws-rds-terraform-module/design.md` - Arquitetura e design
- `.kiro/specs/aws-rds-terraform-module/tasks.md` - Plano de implementação

## Licença

Ver arquivo LICENSE para detalhes.
