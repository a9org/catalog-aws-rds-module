## Descrição

<!-- Descreva as mudanças realizadas neste PR -->

## Tipo de Mudança

<!-- Marque o tipo de mudança -->

- [ ] 🐛 **fix**: Correção de bug (PATCH)
- [ ] ✨ **feat**: Nova funcionalidade (MINOR)
- [ ] 💥 **BREAKING CHANGE**: Mudança que quebra compatibilidade (MAJOR)
- [ ] 📝 **docs**: Apenas documentação
- [ ] ♻️ **refactor**: Refatoração de código
- [ ] ⚡ **perf**: Melhoria de performance
- [ ] ✅ **test**: Adição ou correção de testes
- [ ] 🔧 **chore**: Outras mudanças

## Checklist

- [ ] Meu código segue as convenções de estilo do projeto
- [ ] Executei `terraform fmt` para formatar o código
- [ ] Executei `terraform validate` e não há erros
- [ ] Atualizei a documentação conforme necessário
- [ ] Meus commits seguem o padrão [Conventional Commits](https://www.conventionalcommits.org/)
- [ ] Testei as mudanças localmente

## Conventional Commits

Este projeto usa [Conventional Commits](https://www.conventionalcommits.org/) para releases automáticas.

**Formato:** `<type>(<scope>): <subject>`

**Exemplos:**
```
feat(rds): add support for MySQL 8.0
fix(aurora): correct replica count validation
docs(readme): update usage examples
refactor(security): simplify security group rules
perf(aurora): optimize cluster parameter defaults
```

**Breaking Changes:**
```
feat(variables)!: change default instance class

BREAKING CHANGE: The default instance_class has changed from db.t3.small to db.t3.medium
```

## Contexto Adicional

<!-- Adicione qualquer contexto adicional sobre o PR aqui -->
