# Plano de Migração Incremental

## Visão Geral

Este documento define o plano de migração incremental das Features existentes para a nova arquitetura Clean TCA, seguindo os padrões estabelecidos nas tasks anteriores.

## Estratégia de Migração

### Abordagem Incremental

A migração será feita **por contexto**, uma Feature de cada vez, garantindo que:
- O app continue funcionando durante toda a migração
- Cada Feature migrada seja testada antes de prosseguir
- Não haja breaking changes drásticos
- Compatibilidade seja mantida

### Ordem de Prioridade

#### Fase 1: Features Core (Alta Prioridade)
1. ✅ **ProfileFeature** - Feature piloto (relativamente simples, bem isolada)
2. **TicketsListFeature** - Feature importante, média complexidade
3. **EventsFeature** - Feature core, complexa

#### Fase 2: Features de Apoio (Média Prioridade)
4. **NegotiationsListFeature** - Feature importante
5. **VerificationFeature** - Feature de apoio
6. **SellerProfileFeature** - Feature de apoio

#### Fase 3: Features Secundárias (Baixa Prioridade)
7. **SearchFeature** - Feature secundária
8. **SellersListFeature** - Feature secundária
9. Outras Features menores

## Checklist de Migração por Feature

Para cada Feature, seguir este checklist:

### Pré-Migração
- [ ] Analisar Feature atual (usar template do MIGRATION_GUIDE.md)
- [ ] Identificar dependências
- [ ] Identificar componentes customizados
- [ ] Identificar lógica na View
- [ ] Estimar tempo de migração

### State
- [ ] Migrar para tipos do Domain (não DTOs)
- [ ] Adicionar @ObservableState
- [ ] Adicionar derived state (computed properties)
- [ ] Organizar state por categoria

### Actions
- [ ] Organizar actions por categoria
- [ ] Garantir Equatable
- [ ] Adicionar actions de lifecycle (onAppear, onDisappear)
- [ ] Adicionar proper error handling

### Reducer
- [ ] Mover lógica da View para Reducer
- [ ] Usar @Dependency para clients
- [ ] Adicionar proper error handling com Result
- [ ] Implementar sincronização se necessário

### Views
- [ ] Substituir componentes customizados por DS
- [ ] Organizar em subviews
- [ ] Adicionar loading/empty/error states
- [ ] Remover lógica de negócio
- [ ] Adicionar transições do Design System

### Client
- [ ] Verificar se client usa DTOs da camada Data
- [ ] Verificar se mapeia para Domain
- [ ] Adicionar testValue se necessário

### Navegação
- [ ] Seguir padrões de navegação documentados
- [ ] Usar delegate pattern para cross-feature
- [ ] Adicionar transições apropriadas

### Testes
- [ ] Compilar sem erros
- [ ] Testar todos os fluxos principais
- [ ] Testar em light/dark mode
- [ ] Verificar navegação
- [ ] Verificar sincronização de dados

### Limpeza
- [ ] Remover código comentado
- [ ] Remover imports não utilizados
- [ ] Remover componentes customizados não utilizados
- [ ] Atualizar documentação

## Feature Piloto: ProfileFeature

### Status: ✅ MIGRADA

A ProfileFeature foi escolhida como piloto por ser:
- Relativamente simples
- Bem isolada (poucas dependências)
- Feature core importante
- Boa para validar padrões

### Análise Inicial

**Arquivos:**
- `ProfileFeature.swift` - Feature TCA
- `ProfileView.swift` - View principal

**State Atual:**
- ✅ Já usa tipos do Domain (User)
- ✅ Já tem @ObservableState
- ⚠️ Alguma lógica pode estar na View
- ⚠️ Pode ter componentes customizados

**UI Atual:**
- ⚠️ Possíveis componentes customizados
- ⚠️ Pode não usar Design System

**Dependencies:**
- `profileClient` - ✅ Já existe
- `ticketsClient` - ✅ Já existe

### Migração Realizada

Ver relatório detalhado em: `tasks/prd-arquitetura-clean-tca/10.0_PROFILE_MIGRATION.md`

## Próximas Features

### TicketsListFeature

**Prioridade**: Alta  
**Complexidade**: Média  
**Estimativa**: 4-5 horas

**Checklist:**
- [ ] Analisar Feature atual
- [ ] Migrar state para Domain types
- [ ] Substituir componentes UI por DS
- [ ] Adicionar swipe gestures (delete, favorite)
- [ ] Integrar pull-to-refresh
- [ ] Adicionar animações
- [ ] Testar todos os fluxos

### EventsFeature

**Prioridade**: Alta  
**Complexidade**: Alta  
**Estimativa**: 6-8 horas

**Checklist:**
- [ ] Analisar Feature atual
- [ ] Migrar state para Domain types
- [ ] Substituir EventCard por DSCard
- [ ] Adicionar animações de entrada
- [ ] Integrar transições
- [ ] Testar todos os fluxos

## Código Legado para Limpeza

### Arquivos a Remover/Migrar

#### Domain Layer
- [ ] `Domain/Sources/APIModels.swift` - Migrar DTOs restantes para Data layer
- [ ] Verificar se há tipos duplicados

#### Presentation Layer
- [ ] Componentes customizados não utilizados
- [ ] Views antigas não migradas
- [ ] Código comentado

#### Design System
- [ ] `SocialApp/Sources/ThemeApp/` - Já migrado para DesignSystem
- [ ] Verificar se há referências antigas

### Limpeza Incremental

A limpeza será feita **após** migrar cada Feature:
1. Migrar Feature
2. Testar Feature
3. Remover código legado relacionado
4. Verificar compilação
5. Prosseguir para próxima Feature

## Métricas de Progresso

### Features Migradas
- ✅ ProfileFeature (Piloto)
- [ ] TicketsListFeature
- [ ] EventsFeature
- [ ] NegotiationsListFeature
- [ ] VerificationFeature
- [ ] SellerProfileFeature
- [ ] SearchFeature
- [ ] SellersListFeature

### Progresso Geral
- **Features migradas**: 1/8 (12.5%)
- **Código legado removido**: 0%
- **Componentes DS integrados**: 1/8 (12.5%)

## Riscos e Mitigações

### Risco 1: Breaking Changes
**Mitigação**: Migração incremental, testar cada Feature antes de prosseguir

### Risco 2: Regressões
**Mitigação**: Testes manuais completos após cada migração

### Risco 3: Dependências Cruzadas
**Mitigação**: Migrar Features mais isoladas primeiro, depois as dependentes

### Risco 4: Tempo de Migração
**Mitigação**: Priorizar Features mais importantes, deixar secundárias para depois

## Referências

- [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md) - Guia detalhado de migração
- [PRESENTATION_LAYER.md](./PRESENTATION_LAYER.md) - Padrões de Presentation
- [FEATURE_TEMPLATE.md](./FEATURE_TEMPLATE.md) - Template de Feature
- [NAVIGATION_PATTERNS.md](./NAVIGATION_PATTERNS.md) - Padrões de navegação
- [Design System README](../DesignSystem/README.md) - Componentes disponíveis

---

✅ **Plano de migração estabelecido**

📚 **Use este plano para guiar a migração incremental**

🎯 **Próximo passo**: Migrar ProfileFeature como piloto

