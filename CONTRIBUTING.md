# Guia de Contribuição

Obrigado por considerar contribuir para este módulo Terraform! Este documento fornece diretrizes para contribuir com o projeto.

## 📋 Índice

- [Conventional Commits](#conventional-commits)
- [Processo de Release](#processo-de-release)
- [Como Contribuir](#como-contribuir)
- [Padrões de Código](#padrões-de-código)
- [Testes](#testes)

## 🔖 Conventional Commits

Este projeto usa [Conventional Commits](https://www.conventionalcommits.org/) para gerar releases automáticas seguindo o [Semantic Versioning](https://semver.org/).

### Formato

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Tipos

| Tipo | Descrição | Release |
|------|-----------|---------|
| `feat` | Nova funcionalidade | MINOR (0.x.0) |
| `fix` | Correção de bug | PATCH (0.0.x) |
| `docs` | Apenas documentação | PATCH (0.0.x) |
| `refactor` | Refatoração de código | PATCH (0.0.x) |
| `perf` | Melhoria de performance | PATCH (0.0.x) |
| `test` | Adição/correção de testes | Sem release |
| `build` | Mudanças no build | Sem release |
| `ci` | Mudanças em CI/CD | Sem release |
| `chore` | Outras mudanças | Sem release |
| `revert` | Reverte commit anterior | PATCH (0.0.x) |

### Breaking Changes

Para indicar uma mudança que quebra compatibilidade (MAJOR release):

```
feat(variables)!: change default instance class

BREAKING CHANGE: The default instance_class has changed from db.t3.small to db.t3.medium.
Users must explicitly set instance_class if they want to keep using db.t3.small.
```

### Exemplos

**Nova funcionalidade:**
```
feat(rds): add support for MySQL 8.0

Add support for MySQL 8.0 engine version with new parameter group settings.
```

**Correção de bug:**
```
fix(aurora): correct replica count validation

Fix validation logic that was preventing replica_count of 0 for single-instance clusters.

Closes #123
```

**Documentação:**
```
docs(readme): update usage examples

Add examples for Aurora Serverless v2 configuration.
```

**Breaking change:**
```
feat(outputs)!: rename cluster outputs

BREAKING CHANGE: Renamed outputs for consistency:
- cluster_endpoint_writer -> cluster_endpoint
- cluster_endpoint_reader -> cluster_reader_endpoint
```

## 🚀 Processo de Release

As releases são geradas automaticamente pelo GitHub Actions quando commits são merged na branch `master`.

### Versionamento Automático

- **MAJOR** (x.0.0): Breaking changes (`feat!:` ou `BREAKING CHANGE:`)
- **MINOR** (0.x.0): Novas funcionalidades (`feat:`)
- **PATCH** (0.0.x): Correções e melhorias (`fix:`, `docs:`, `refactor:`, `perf:`)

### Workflow

1. Commits são feitos em uma branch de feature
2. PR é aberto para `master`
3. CI valida formatação e commits
4. PR é aprovado e merged
5. GitHub Actions executa semantic-release
6. Nova versão é criada automaticamente
7. CHANGELOG.md é atualizado
8. GitHub Release é criada com notas de release

## 🤝 Como Contribuir

### 1. Fork e Clone

```bash
git clone https://github.com/seu-usuario/aws-rds-terraform-module.git
cd aws-rds-terraform-module
```

### 2. Crie uma Branch

```bash
git checkout -b feat/minha-nova-funcionalidade
```

Use prefixos descritivos:
- `feat/` - Nova funcionalidade
- `fix/` - Correção de bug
- `docs/` - Documentação
- `refactor/` - Refatoração

### 3. Faça suas Mudanças

Siga os [padrões de código](#padrões-de-código) do projeto.

### 4. Commit com Conventional Commits

```bash
git add .
git commit -m "feat(rds): add support for custom port configuration"
```

### 5. Push e Abra um PR

```bash
git push origin feat/minha-nova-funcionalidade
```

Abra um Pull Request para a branch `master` usando o template fornecido.

## 📝 Padrões de Código

### Terraform

1. **Formatação**: Use `terraform fmt -recursive`
2. **Validação**: Execute `terraform validate`
3. **Nomenclatura**: Use snake_case para variáveis e recursos
4. **Documentação**: Adicione descrições em todas as variáveis e outputs

### Estrutura de Arquivos

```
.
├── main.tf              # Recursos principais
├── variables.tf         # Variáveis de entrada
├── outputs.tf           # Outputs do módulo
├── locals.tf            # Variáveis locais
├── versions.tf          # Versões de providers
├── security.tf          # Security groups
├── examples/            # Exemplos de uso
│   ├── rds-mysql/
│   ├── rds-postgres/
│   ├── aurora-serverless/
│   └── aurora-provisioned/
└── README.md            # Documentação principal
```

### Variáveis

```hcl
variable "instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.small"

  validation {
    condition     = can(regex("^db\\.", var.instance_class))
    error_message = "Instance class must start with 'db.'"
  }
}
```

### Outputs

```hcl
output "endpoint" {
  description = "RDS instance endpoint for database connections"
  value       = try(aws_db_instance.this[0].endpoint, aws_rds_cluster.this[0].endpoint, null)
}
```

## 🧪 Testes

### Validação Local

```bash
# Formatação
terraform fmt -check -recursive

# Validação
terraform init -backend=false
terraform validate

# Verificar commits
npx commitlint --from HEAD~1 --to HEAD --verbose
```

### Exemplos

Teste os exemplos localmente:

```bash
cd examples/rds-mysql
terraform init
terraform plan
```

## 📚 Recursos

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Semantic Release](https://semantic-release.gitbook.io/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

## ❓ Dúvidas

Se tiver dúvidas, abra uma [issue](https://github.com/seu-usuario/aws-rds-terraform-module/issues) ou entre em contato com os mantenedores.

## 📄 Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a mesma licença do projeto.
