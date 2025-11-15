# Requirements Document

## Introduction

Este documento especifica os requisitos para um módulo Terraform que provisiona instâncias AWS RDS com suporte a múltiplos SGBDs (MySQL, PostgreSQL, MariaDB, Oracle, SQL Server), modos de execução (serverless e provisionado), e variantes Aurora. O módulo será integrado ao A9 Catalog IDP (Internal Developer Platform) e deve ser totalmente personalizável, recebendo configurações de rede (VPC ID, environment, CIDR blocks, subnets privadas) do IDP.

## Glossary

- **RDS_Module**: O módulo Terraform que provisiona recursos AWS RDS
- **A9_Catalog**: Internal Developer Platform que utiliza o módulo
- **SGBD**: Sistema Gerenciador de Banco de Dados (MySQL, PostgreSQL, MariaDB, Oracle, SQL Server)
- **Aurora_Variant**: Versão compatível com Aurora do RDS (Aurora MySQL ou Aurora PostgreSQL)
- **Serverless_Mode**: Modo de execução RDS Serverless v2 com auto-scaling
- **Provisioned_Mode**: Modo de execução RDS tradicional com instâncias de tamanho fixo
- **IDP_Variables**: Variáveis fornecidas pelo A9 Catalog (vpc_id, environment, vpc_cidr_block, subnets_pvt)

## Requirements

### Requirement 1

**User Story:** Como desenvolvedor utilizando o A9 Catalog, eu quero selecionar qualquer SGBD disponível no AWS RDS, para que eu possa provisionar o banco de dados mais adequado à minha aplicação

#### Acceptance Criteria

1. THE RDS_Module SHALL accept a variable that specifies the database engine type with valid values: mysql, postgres, mariadb, oracle-ee, oracle-se2, oracle-se1, oracle-se, sqlserver-ee, sqlserver-se, sqlserver-ex, sqlserver-web
2. THE RDS_Module SHALL accept a variable that specifies the engine version compatible with the selected database engine
3. WHEN the user selects an Aurora variant, THE RDS_Module SHALL provision an Aurora cluster instead of a standard RDS instance
4. THE RDS_Module SHALL validate that the selected engine version is compatible with the chosen database engine type
5. WHERE the user selects Aurora, THE RDS_Module SHALL restrict engine options to aurora-mysql or aurora-postgresql

### Requirement 2

**User Story:** Como desenvolvedor utilizando o A9 Catalog, eu quero escolher entre modo serverless e provisionado, para que eu possa otimizar custos e performance conforme as necessidades da aplicação

#### Acceptance Criteria

1. THE RDS_Module SHALL accept a boolean variable that determines whether to use serverless mode or provisioned mode
2. WHEN serverless mode is selected AND the engine supports Aurora Serverless v2, THE RDS_Module SHALL provision an Aurora Serverless v2 cluster
3. WHEN provisioned mode is selected, THE RDS_Module SHALL accept variables for instance class and allocated storage
4. THE RDS_Module SHALL validate that serverless mode is only used with Aurora-compatible engines
5. WHERE serverless mode is enabled, THE RDS_Module SHALL accept variables for minimum and maximum capacity units

### Requirement 3

**User Story:** Como desenvolvedor utilizando o A9 Catalog, eu quero configurar o tipo de instância RDS, para que eu possa dimensionar adequadamente os recursos computacionais do banco de dados

#### Acceptance Criteria

1. WHEN provisioned mode is selected, THE RDS_Module SHALL accept a variable that specifies the instance class (e.g., db.t3.micro, db.r5.large)
2. THE RDS_Module SHALL validate that the specified instance class is compatible with the selected database engine
3. WHEN Aurora is selected in provisioned mode, THE RDS_Module SHALL accept instance class values specific to Aurora (e.g., db.r5.large, db.r6g.xlarge)
4. THE RDS_Module SHALL provide default instance class values based on the environment variable (e.g., db.t3.small for dev, db.r5.large for prod)

### Requirement 4

**User Story:** Como desenvolvedor utilizando o A9 Catalog, eu quero que o módulo utilize automaticamente as configurações de rede fornecidas pelo IDP, para que a integração com a infraestrutura existente seja transparente

#### Acceptance Criteria

1. THE RDS_Module SHALL accept the vpc_id variable provided by A9_Catalog
2. THE RDS_Module SHALL accept the environment variable provided by A9_Catalog for resource tagging and naming
3. THE RDS_Module SHALL accept the vpc_cidr_block variable provided by A9_Catalog for security group configuration
4. THE RDS_Module SHALL accept the subnets_pvt variable provided by A9_Catalog as a list of private subnet IDs
5. THE RDS_Module SHALL create a DB subnet group using the provided subnets_pvt list

### Requirement 5

**User Story:** Como desenvolvedor utilizando o A9 Catalog, eu quero configurar credenciais e parâmetros de segurança do banco de dados, para que eu possa controlar o acesso e proteger dados sensíveis

#### Acceptance Criteria

1. THE RDS_Module SHALL accept variables for master username and master password
2. THE RDS_Module SHALL create a security group that allows inbound traffic on the database port from the vpc_cidr_block
3. THE RDS_Module SHALL accept an optional variable for additional CIDR blocks allowed to access the database
4. THE RDS_Module SHALL support integration with AWS Secrets Manager for credential storage
5. THE RDS_Module SHALL accept a variable to enable or disable encryption at rest using AWS KMS

### Requirement 6

**User Story:** Como desenvolvedor utilizando o A9 Catalog, eu quero configurar opções de backup e manutenção, para que eu possa garantir a disponibilidade e recuperação dos dados

#### Acceptance Criteria

1. THE RDS_Module SHALL accept a variable that specifies the backup retention period in days (0 to 35)
2. THE RDS_Module SHALL accept a variable that specifies the preferred backup window in UTC format
3. THE RDS_Module SHALL accept a variable that specifies the preferred maintenance window in UTC format
4. THE RDS_Module SHALL accept a boolean variable to enable or disable automated minor version upgrades
5. THE RDS_Module SHALL accept a boolean variable to enable or disable deletion protection

### Requirement 7

**User Story:** Como desenvolvedor utilizando o A9 Catalog, eu quero configurar alta disponibilidade e replicação, para que eu possa garantir resiliência da aplicação

#### Acceptance Criteria

1. WHEN provisioned mode is selected for non-Aurora databases, THE RDS_Module SHALL accept a boolean variable to enable Multi-AZ deployment
2. WHEN Aurora is selected, THE RDS_Module SHALL accept a variable that specifies the number of read replicas (0 to 15)
3. THE RDS_Module SHALL distribute Aurora replicas across multiple availability zones when the count is greater than zero
4. WHEN Multi-AZ is enabled for non-Aurora databases, THE RDS_Module SHALL configure automatic failover
5. THE RDS_Module SHALL accept an optional variable for cross-region read replica configuration

### Requirement 8

**User Story:** Como desenvolvedor utilizando o A9 Catalog, eu quero que o módulo forneça outputs com informações de conexão, para que eu possa integrar facilmente o banco de dados com minhas aplicações

#### Acceptance Criteria

1. THE RDS_Module SHALL output the database endpoint address
2. THE RDS_Module SHALL output the database port number
3. THE RDS_Module SHALL output the database name
4. THE RDS_Module SHALL output the security group ID created for the database
5. WHEN Aurora is provisioned, THE RDS_Module SHALL output both the cluster endpoint and reader endpoint

### Requirement 9

**User Story:** Como desenvolvedor utilizando o A9 Catalog, eu quero personalizar completamente as configurações do banco de dados, para que eu possa atender requisitos específicos da aplicação

#### Acceptance Criteria

1. THE RDS_Module SHALL accept an optional variable for custom parameter group settings
2. THE RDS_Module SHALL accept an optional variable for custom option group settings (for engines that support it)
3. THE RDS_Module SHALL accept a variable for database name to be created on instance launch
4. THE RDS_Module SHALL accept a map variable for custom tags to be applied to all resources
5. THE RDS_Module SHALL accept variables for performance insights configuration (enabled/disabled and retention period)

### Requirement 10

**User Story:** Como desenvolvedor utilizando o A9 Catalog, eu quero que o módulo siga boas práticas de nomenclatura e organização, para que os recursos sejam facilmente identificáveis e gerenciáveis

#### Acceptance Criteria

1. THE RDS_Module SHALL generate resource names using a consistent pattern that includes the environment variable
2. THE RDS_Module SHALL apply default tags to all resources including environment, managed-by terraform, and module name
3. THE RDS_Module SHALL merge custom tags provided by the user with default tags
4. THE RDS_Module SHALL use the environment variable to determine appropriate default values for instance sizing and backup retention
5. THE RDS_Module SHALL validate that all required variables are provided before attempting to create resources
