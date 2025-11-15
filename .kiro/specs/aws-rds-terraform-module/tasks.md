# Implementation Plan

- [x] 1. Set up module structure and version constraints
  - Create directory structure for the Terraform module
  - Write versions.tf with Terraform and AWS provider version constraints (>= 1.0, >= 4.0)
  - Create .gitignore for Terraform files
  - _Requirements: 10.1, 10.5_

- [ ] 2. Implement input variables with validation
  - [ ] 2.1 Define IDP-provided required variables in variables.tf
    - Write variable declarations for vpc_id, environment, vpc_cidr_block, subnets_pvt
    - Add descriptions and type constraints
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  
  - [ ] 2.2 Define database configuration required variables
    - Write variable declarations for engine, engine_version, master_username, master_password
    - Mark master_password as sensitive
    - Add validation block for engine with all supported values (mysql, postgres, mariadb, aurora-mysql, aurora-postgresql, oracle-*, sqlserver-*)
    - _Requirements: 1.1, 1.2, 5.1_
  
  - [ ] 2.3 Define execution mode variables
    - Write variable declarations for is_aurora, is_serverless, instance_class, allocated_storage
    - Add validation block ensuring serverless is only used with Aurora engines
    - Set nullable = true for instance_class with environment-based defaults
    - _Requirements: 1.3, 1.5, 2.1, 2.3, 2.4, 3.1_
  
  - [ ] 2.4 Define serverless configuration optional variables
    - Write variable declarations for serverless_min_capacity and serverless_max_capacity
    - Set defaults (0.5 and 1.0 respectively)
    - _Requirements: 2.5_
  
  - [ ] 2.5 Define high availability optional variables
    - Write variable declarations for multi_az and replica_count
    - Add validation for replica_count (0 to 15)
    - Add validation preventing multi_az with Aurora
    - Set defaults (false and 0)
    - _Requirements: 7.1, 7.2_
  
  - [ ] 2.6 Define backup and maintenance optional variables
    - Write variable declarations for backup_retention_period, backup_window, maintenance_window, auto_minor_version_upgrade, deletion_protection
    - Add validation for backup_retention_period (0 to 35)
    - Set appropriate defaults
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 2.7 Define security optional variables
    - Write variable declarations for additional_cidr_blocks, enable_encryption, kms_key_id, store_credentials_in_secrets_manager
    - Set defaults ([], true, null, false)
    - _Requirements: 5.2, 5.3, 5.4, 5.5_
  
  - [ ] 2.8 Define customization optional variables
    - Write variable declarations for database_name, parameter_group_parameters, option_group_options, custom_tags, enable_performance_insights, performance_insights_retention_period
    - Set appropriate defaults
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ] 3. Implement local values and computed logic
  - Write locals.tf with name_prefix computation using environment
  - Implement is_aurora detection logic (checking is_aurora flag or aurora-* engine names)
  - Implement is_serverless logic (is_serverless && is_aurora)
  - Create port_map for all supported engines
  - Implement db_port lookup based on engine
  - Create default_instance_class map based on environment (dev: db.t3.small, staging: db.t3.medium, prod: db.r5.large)
  - Implement instance_class selection with fallback to environment-based default
  - Create default_tags map with Environment, ManagedBy, Module
  - Implement tags merge logic combining default_tags and custom_tags
  - _Requirements: 3.4, 10.1, 10.2, 10.3, 10.4_

- [ ] 4. Implement security resources
  - [ ] 4.1 Create security group resource
    - Write aws_security_group resource in security.tf
    - Set name using name_prefix pattern
    - Configure vpc_id from variable
    - Add ingress rule allowing traffic on db_port from vpc_cidr_block
    - Add dynamic ingress rules for additional_cidr_blocks
    - Add egress rule allowing all outbound traffic
    - Apply merged tags
    - _Requirements: 5.2, 5.3_
  
  - [ ] 4.2 Create Secrets Manager resources (conditional)
    - Write aws_secretsmanager_secret resource with count based on store_credentials_in_secrets_manager
    - Set name using name_prefix pattern
    - Write aws_secretsmanager_secret_version resource
    - Create JSON secret_string with username, password, endpoint, port (using depends_on for endpoint)
    - Apply merged tags
    - _Requirements: 5.4_

- [ ] 5. Implement database subnet group
  - Write aws_db_subnet_group resource in main.tf
  - Set name using name_prefix pattern
  - Configure subnet_ids from subnets_pvt variable
  - Apply merged tags
  - _Requirements: 4.5_

- [ ] 6. Implement parameter and option groups
  - [ ] 6.1 Create parameter group for non-Aurora databases
    - Write aws_db_parameter_group resource with count = !local.is_aurora ? 1 : 0
    - Set name using name_prefix pattern
    - Determine family based on engine (use data source or local map)
    - Add dynamic parameter blocks from parameter_group_parameters variable
    - Apply merged tags
    - _Requirements: 9.1_
  
  - [ ] 6.2 Create parameter group for Aurora clusters
    - Write aws_rds_cluster_parameter_group resource with count = local.is_aurora ? 1 : 0
    - Set name using name_prefix pattern
    - Determine family based on engine
    - Add dynamic parameter blocks from parameter_group_parameters variable
    - Apply merged tags
    - _Requirements: 9.1_
  
  - [ ] 6.3 Create option group (conditional)
    - Write aws_db_option_group resource with count based on engine support (mysql, mariadb, oracle-*, sqlserver-*)
    - Set name using name_prefix pattern
    - Determine engine_name and major_engine_version
    - Add dynamic option blocks from option_group_options variable
    - Apply merged tags
    - _Requirements: 9.2_

- [ ] 7. Implement RDS instance for non-Aurora databases
  - Write aws_db_instance resource with count = !local.is_aurora ? 1 : 0
  - Set identifier using name_prefix pattern
  - Configure engine and engine_version from variables
  - Set instance_class from local.instance_class
  - Configure allocated_storage from variable
  - Set db_subnet_group_name from subnet group resource
  - Set vpc_security_group_ids from security group resource
  - Configure master_username and master_password
  - Set database_name from variable (if provided)
  - Configure multi_az from variable
  - Set backup_retention_period, backup_window, maintenance_window from variables
  - Configure auto_minor_version_upgrade and deletion_protection from variables
  - Set storage_encrypted from enable_encryption variable
  - Configure kms_key_id from variable (if provided)
  - Set parameter_group_name from parameter group resource (if created)
  - Set option_group_name from option group resource (if created)
  - Configure performance_insights_enabled and performance_insights_retention_period from variables
  - Add lifecycle block with ignore_changes for master_password
  - Add lifecycle block with prevent_destroy for production environment
  - Configure timeouts for create, update, delete operations
  - Apply merged tags
  - _Requirements: 1.1, 1.2, 2.3, 3.1, 5.1, 5.5, 6.1, 6.2, 6.3, 6.4, 6.5, 7.1, 7.4, 9.3, 9.5_

- [ ] 8. Implement Aurora cluster and instances
  - [ ] 8.1 Create Aurora cluster resource
    - Write aws_rds_cluster resource with count = local.is_aurora ? 1 : 0
    - Set cluster_identifier using name_prefix pattern
    - Configure engine and engine_version from variables
    - Set engine_mode to "provisioned"
    - Set db_subnet_group_name from subnet group resource
    - Set vpc_security_group_ids from security group resource
    - Configure master_username and master_password
    - Set database_name from variable (if provided)
    - Set backup_retention_period, preferred_backup_window, preferred_maintenance_window from variables
    - Add dynamic serverlessv2_scaling_configuration block when is_serverless is true
    - Configure min_capacity and max_capacity from serverless variables
    - Set storage_encrypted from enable_encryption variable
    - Configure kms_key_id from variable (if provided)
    - Set db_cluster_parameter_group_name from cluster parameter group resource (if created)
    - Configure enabled_cloudwatch_logs_exports based on engine
    - Add lifecycle block with ignore_changes for master_password
    - Add lifecycle block with prevent_destroy for production environment
    - Apply merged tags
    - _Requirements: 1.3, 1.5, 2.2, 2.5, 5.1, 5.5, 6.1, 6.2, 6.3, 6.4, 6.5, 9.3_
  
  - [ ] 8.2 Create Aurora cluster instances for provisioned mode
    - Write aws_rds_cluster_instance resource with count = local.is_aurora && !local.is_serverless ? 1 + var.replica_count : 0
    - Set identifier using name_prefix pattern with count index
    - Set cluster_identifier from cluster resource
    - Configure instance_class from local.instance_class
    - Set engine from variable
    - Configure performance_insights_enabled and performance_insights_retention_period from variables
    - Distribute instances across availability zones using count.index modulo
    - Configure auto_minor_version_upgrade from variable
    - Apply merged tags
    - _Requirements: 3.3, 7.2, 7.3, 9.5_
  
  - [ ] 8.3 Create Aurora cluster instance for serverless mode
    - Write aws_rds_cluster_instance resource with count = local.is_serverless ? 1 : 0
    - Set identifier using name_prefix pattern
    - Set cluster_identifier from cluster resource
    - Set instance_class to "db.serverless"
    - Set engine from variable
    - Configure performance_insights_enabled and performance_insights_retention_period from variables
    - Apply merged tags
    - _Requirements: 2.2, 9.5_


- [ ] 9. Implement output values
  - [ ] 9.1 Create common outputs
    - Write output for endpoint (conditional based on is_aurora)
    - Write output for port using local.db_port
    - Write output for database_name
    - Write output for security_group_id
    - Write output for db_subnet_group_name
    - Write output for master_username (non-sensitive)
    - _Requirements: 8.1, 8.2, 8.3, 8.4_
  
  - [ ] 9.2 Create RDS-specific outputs
    - Write output for instance_id with value from aws_db_instance (conditional)
    - Write output for instance_arn with value from aws_db_instance (conditional)
    - Write output for instance_resource_id with value from aws_db_instance (conditional)
    - _Requirements: 8.1_
  
  - [ ] 9.3 Create Aurora-specific outputs
    - Write output for cluster_id with value from aws_rds_cluster (conditional)
    - Write output for cluster_arn with value from aws_rds_cluster (conditional)
    - Write output for cluster_endpoint with value from aws_rds_cluster (conditional)
    - Write output for cluster_reader_endpoint with value from aws_rds_cluster (conditional)
    - Write output for cluster_members with list of instance IDs (conditional)
    - _Requirements: 8.1, 8.5_
  
  - [ ] 9.4 Create Secrets Manager output
    - Write output for secret_arn with value from aws_secretsmanager_secret (conditional)
    - Mark as sensitive
    - _Requirements: 5.4_

- [ ] 10. Create module documentation
  - Write README.md with module overview and description
  - Document all input variables with descriptions, types, defaults, and validation rules
  - Document all outputs with descriptions and types
  - Add usage examples section with basic configuration
  - Document integration with A9 Catalog IDP
  - Add requirements section (Terraform version, AWS provider version)
  - Include notes on security best practices
  - Add troubleshooting section for common issues
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ] 11. Create usage examples
  - [ ] 11.1 Create RDS MySQL example
    - Create examples/rds-mysql directory
    - Write main.tf calling the module with mysql engine configuration
    - Write variables.tf for example-specific variables
    - Write outputs.tf displaying relevant outputs
    - Write README.md explaining the example
    - _Requirements: 1.1, 1.2_
  
  - [ ] 11.2 Create RDS PostgreSQL example
    - Create examples/rds-postgres directory
    - Write main.tf calling the module with postgres engine configuration
    - Write variables.tf for example-specific variables
    - Write outputs.tf displaying relevant outputs
    - Write README.md explaining the example
    - _Requirements: 1.1, 1.2_
  
  - [ ] 11.3 Create Aurora Serverless example
    - Create examples/aurora-serverless directory
    - Write main.tf calling the module with aurora-postgresql, is_aurora=true, is_serverless=true
    - Configure serverless_min_capacity and serverless_max_capacity
    - Write variables.tf for example-specific variables
    - Write outputs.tf displaying cluster endpoints
    - Write README.md explaining serverless configuration
    - _Requirements: 1.3, 1.5, 2.1, 2.2, 2.5_
  
  - [ ] 11.4 Create Aurora Provisioned with replicas example
    - Create examples/aurora-provisioned directory
    - Write main.tf calling the module with aurora-mysql, is_aurora=true, replica_count=2
    - Write variables.tf for example-specific variables
    - Write outputs.tf displaying cluster and replica information
    - Write README.md explaining high availability configuration
    - _Requirements: 1.3, 1.5, 7.2, 7.3_
