# Documentação do Projeto

## Visão Geral

Este diretório contém toda a documentação técnica do projeto, incluindo padrões, guias, templates e estratégias.

## Documentos Principais

### Arquitetura

- **[PRESENTATION_LAYER.md](./PRESENTATION_LAYER.md)** - Padrões da camada de Presentation
  - Separação de responsabilidades
  - Templates de Feature e View
  - Boas práticas
  - Dependências e Clients

- **[NAVIGATION_PATTERNS.md](./NAVIGATION_PATTERNS.md)** - Padrões de navegação global
  - Tipos de navegação
  - Padrões estabelecidos
  - Fluxos principais
  - Transições recomendadas

- **[NAVIGATION_FLOWS.md](./NAVIGATION_FLOWS.md)** - Fluxos de navegação do usuário
  - 6 fluxos principais documentados
  - Detalhamento passo-a-passo
  - Triggers, Actions, State changes

- **[NAVIGATION_GUIDE.md](./NAVIGATION_GUIDE.md)** - Guia prático de navegação
  - Quick Start
  - Templates reutilizáveis
  - Exemplos práticos
  - Troubleshooting

### Migração

- **[MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md)** - Guia completo de migração
  - Processo em 8 fases
  - Checklists detalhados
  - Exemplos Before/After
  - Estimativas de tempo

- **[MIGRATION_PLAN.md](./MIGRATION_PLAN.md)** - Plano de migração incremental
  - Estratégia de migração
  - Priorização (3 fases)
  - Checklist reutilizável
  - Métricas de progresso

### Templates

- **[FEATURE_TEMPLATE.md](./FEATURE_TEMPLATE.md)** - Template de Feature TCA
  - Estrutura completa
  - State, Action, Reducer
  - View organizada
  - Client (Dependencies)
  - Checklist de implementação

### Testes

- **[TESTING_STRATEGY.md](./TESTING_STRATEGY.md)** - Estratégia de testes
  - Pirâmide de testes
  - Tipos de testes
  - Priorização
  - Cobertura de código

- **[TESTING_GUIDE.md](./TESTING_GUIDE.md)** - Guia completo de testes
  - Estrutura de testes
  - Framework (Swift Testing)
  - Padrões de teste
  - Mocking dependencies
  - Exemplos práticos

- **[TESTING_EXAMPLES.md](./TESTING_EXAMPLES.md)** - Exemplos de testes
  - Testes de mappers
  - Testes de reducers
  - Testes de integração
  - Padrões comuns

### QA

- **[QA_GUIDE.md](./QA_GUIDE.md)** - Guia de Quality Assurance
  - Checklist de QA por Feature
  - Testes manuais por contexto
  - Testes de regressão
  - Testes de performance
  - Testes de acessibilidade

## Estrutura de Documentação

```
docs/
├── README.md                    ← Este arquivo
├── PRESENTATION_LAYER.md        ← Padrões de Presentation
├── FEATURE_TEMPLATE.md          ← Template de Feature
├── NAVIGATION_PATTERNS.md       ← Padrões de navegação
├── NAVIGATION_FLOWS.md          ← Fluxos de navegação
├── NAVIGATION_GUIDE.md          ← Guia de navegação
├── MIGRATION_GUIDE.md           ← Guia de migração
├── MIGRATION_PLAN.md            ← Plano de migração
├── TESTING_STRATEGY.md          ← Estratégia de testes
├── TESTING_GUIDE.md             ← Guia de testes
├── TESTING_EXAMPLES.md          ← Exemplos de testes
└── QA_GUIDE.md                  ← Guia de QA
```

## Como Usar Esta Documentação

### Para Desenvolvedores Novos

1. Comece com **[PRESENTATION_LAYER.md](./PRESENTATION_LAYER.md)** para entender padrões
2. Use **[FEATURE_TEMPLATE.md](./FEATURE_TEMPLATE.md)** para criar novas Features
3. Consulte **[NAVIGATION_GUIDE.md](./NAVIGATION_GUIDE.md)** para implementar navegação
4. Veja **[TESTING_GUIDE.md](./TESTING_GUIDE.md)** para criar testes

### Para Migração de Features

1. Leia **[MIGRATION_PLAN.md](./MIGRATION_PLAN.md)** para entender estratégia
2. Use **[MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md)** como referência passo-a-passo
3. Consulte análise de Feature piloto em `tasks/prd-arquitetura-clean-tca/10.0_PROFILE_MIGRATION.md`
4. Siga checklist do MIGRATION_PLAN.md

### Para Testes

1. Leia **[TESTING_STRATEGY.md](./TESTING_STRATEGY.md)** para entender estratégia
2. Use **[TESTING_GUIDE.md](./TESTING_GUIDE.md)** como referência
3. Veja **[TESTING_EXAMPLES.md](./TESTING_EXAMPLES.md)** para exemplos práticos
4. Consulte **[QA_GUIDE.md](./QA_GUIDE.md)** para QA manual

### Para Navegação

1. Leia **[NAVIGATION_PATTERNS.md](./NAVIGATION_PATTERNS.md)** para padrões técnicos
2. Veja **[NAVIGATION_FLOWS.md](./NAVIGATION_FLOWS.md)** para entender fluxos do usuário
3. Use **[NAVIGATION_GUIDE.md](./NAVIGATION_GUIDE.md)** para implementar navegação

## Referências Externas

### Módulos do Projeto

- **[Domain/README.md](../Domain/README.md)** - Camada Domain
- **[Data/README.md](../Data/README.md)** - Camada Data
- **[DesignSystem/README.md](../DesignSystem/README.md)** - Design System

### Relatórios de Implementação

- `tasks/prd-arquitetura-clean-tca/3.0_IMPLEMENTACAO.md` - Domain
- `tasks/prd-arquitetura-clean-tca/4.0_IMPLEMENTACAO.md` - Data
- `tasks/prd-arquitetura-clean-tca/5.0_IMPLEMENTACAO.md` - Presentation
- `tasks/prd-arquitetura-clean-tca/6.0_IMPLEMENTACAO.md` - Design System Fundamentos
- `tasks/prd-arquitetura-clean-tca/7.0_IMPLEMENTACAO.md` - Design System Componentes
- `tasks/prd-arquitetura-clean-tca/8.0_IMPLEMENTACAO.md` - Design System Animações
- `tasks/prd-arquitetura-clean-tca/9.0_IMPLEMENTACAO.md` - Navegação
- `tasks/prd-arquitetura-clean-tca/10.0_IMPLEMENTACAO.md` - Migração (Estrutura)

## Convenções

### Nomenclatura
- Documentos em português (seguindo padrão do projeto)
- Nomes descritivos e claros
- Organização por categoria

### Estrutura
- Cada documento focado em um tópico
- Exemplos práticos quando relevante
- Checklists quando aplicável
- Referências cruzadas

## Manutenção

### Quando Atualizar
- Quando padrões mudarem
- Quando novos padrões forem estabelecidos
- Quando lições aprendidas forem identificadas
- Quando exemplos precisarem ser atualizados

### Como Contribuir
1. Seguir estrutura existente
2. Manter consistência de estilo
3. Adicionar exemplos práticos
4. Atualizar referências cruzadas

---

✅ **Documentação completa do projeto**

📚 **Use esta documentação como referência principal**

🎯 **Todos os padrões e guias estão documentados**

