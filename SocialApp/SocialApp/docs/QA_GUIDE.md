# Guia de QA (Quality Assurance)

## Visão Geral

Este guia descreve o processo de QA para garantir qualidade e confiabilidade do app após a refatoração para Clean TCA.

## Checklist de QA por Feature

### Checklist Geral

#### Funcionalidade
- [ ] Todas as funcionalidades principais funcionam
- [ ] Navegação entre telas funciona corretamente
- [ ] Dados são carregados e exibidos corretamente
- [ ] Ações do usuário têm feedback apropriado
- [ ] Estados de loading/error/empty são exibidos corretamente

#### UI/UX
- [ ] Design consistente (usa Design System)
- [ ] Animações suaves e apropriadas
- [ ] Feedback visual para interações
- [ ] Estados vazios informativos
- [ ] Mensagens de erro claras

#### Performance
- [ ] Telas carregam rapidamente
- [ ] Animações são fluidas (60fps)
- [ ] Sem memory leaks
- [ ] Scroll é suave

#### Acessibilidade
- [ ] VoiceOver funciona corretamente
- [ ] Dynamic Type suportado
- [ ] Contraste de cores adequado (WCAG AA)
- [ ] Tamanhos de toque adequados (mínimo 44pt)

#### Compatibilidade
- [ ] Funciona em iOS 15+
- [ ] Funciona em diferentes tamanhos de tela
- [ ] Funciona em light mode
- [ ] Funciona em dark mode

## Testes Manuais por Contexto

### Contexto: Profile

#### Fluxo Principal
1. [ ] Abrir app e navegar para Profile
2. [ ] Verificar perfil carrega corretamente
3. [ ] Verificar avatar, nome, email exibidos
4. [ ] Tocar "Editar Perfil"
5. [ ] Editar informações e salvar
6. [ ] Verificar atualização reflete na tela

#### Fluxos Secundários
- [ ] Tocar "Meus Ingressos" → Ver lista
- [ ] Tocar "Favoritos" → Ver lista
- [ ] Tocar "Aparência" → Mudar tema
- [ ] Tocar "Perfil de Vendedor" (se tiver tickets)
- [ ] Tocar "Logout" → Volta para login

#### Estados
- [ ] Loading state (enquanto carrega)
- [ ] Error state (simular erro de rede)
- [ ] Empty state (sem tickets)

### Contexto: Tickets

#### Fluxo Principal
1. [ ] Abrir app e navegar para Tickets
2. [ ] Verificar lista de tickets carrega
3. [ ] Tocar em ticket → Ver detalhes
4. [ ] Swipe para deletar → Confirmar
5. [ ] Swipe para favoritar → Toggle
6. [ ] Pull-to-refresh → Recarregar

#### Filtros
- [ ] Filtrar por evento
- [ ] Filtrar por preço
- [ ] Filtrar por tipo
- [ ] Limpar filtros

#### Estados
- [ ] Loading state
- [ ] Empty state (sem tickets)
- [ ] Error state

### Contexto: Events

#### Fluxo Principal
1. [ ] Abrir app (Home)
2. [ ] Verificar eventos recomendados
3. [ ] Tocar em evento → Ver detalhes
4. [ ] Tocar "Ver Ingressos" → Navega para Tickets
5. [ ] Tocar "Ver Vendedores" → Ver lista
6. [ ] Tocar em vendedor → Ver perfil

#### Estados
- [ ] Loading state
- [ ] Empty state
- [ ] Error state

### Contexto: Negotiations

#### Fluxo Principal
1. [ ] Navegar para Negotiations
2. [ ] Ver lista de negociações
3. [ ] Tocar em negociação → Ver detalhes
4. [ ] Responder pergunta
5. [ ] Enviar documento
6. [ ] Revelar contato (se aprovado)

#### Estados
- [ ] Loading state
- [ ] Empty state
- [ ] Error state

## Testes de Regressão

### Checklist de Regressão

#### Navegação
- [ ] Todas as navegações funcionam
- [ ] Back button funciona
- [ ] Modals abrem e fecham corretamente
- [ ] Tabs mudam corretamente
- [ ] Deep links funcionam (se implementados)

#### Sincronização de Dados
- [ ] Criar ticket → Aparece em todas as listas
- [ ] Deletar ticket → Remove de todas as listas
- [ ] Atualizar ticket → Reflete em todas as views
- [ ] Criar negociação → Aparece na lista
- [ ] Atualizar perfil → Reflete em todas as views

#### Estados Persistidos
- [ ] Tema selecionado persiste
- [ ] Filtros persistem (se aplicável)
- [ ] Scroll position persiste (se aplicável)

## Testes de Performance

### Métricas

#### Tempo de Carregamento
- [ ] Home carrega em < 2s
- [ ] Listas carregam em < 1s
- [ ] Detalhes carregam em < 1s

#### Animações
- [ ] Transições são fluidas (60fps)
- [ ] Sem jank ou lag
- [ ] Animações completam corretamente

#### Memory
- [ ] Sem memory leaks
- [ ] Memory usage estável
- [ ] Imagens são carregadas eficientemente

## Testes de Acessibilidade

### VoiceOver
- [ ] Todos os elementos são acessíveis
- [ ] Labels são descritivos
- [ ] Navegação funciona com VoiceOver
- [ ] Ações são executáveis com VoiceOver

### Dynamic Type
- [ ] Texto ajusta com tamanhos maiores
- [ ] Layout não quebra
- [ ] Todos os textos são legíveis

### Contraste
- [ ] Texto tem contraste adequado (WCAG AA)
- [ ] Botões têm contraste adequado
- [ ] Funciona em light e dark mode

## Testes de Compatibilidade

### Versões iOS
- [ ] iOS 15.0+
- [ ] iOS 16.0+
- [ ] iOS 17.0+
- [ ] iOS 18.0+ (se suportado)

### Dispositivos
- [ ] iPhone SE (tela pequena)
- [ ] iPhone 15 (tela padrão)
- [ ] iPhone 15 Pro Max (tela grande)
- [ ] iPad (se suportado)

### Orientação
- [ ] Portrait funciona
- [ ] Landscape funciona (se suportado)

## Testes de Integração

### Fluxos End-to-End

#### Fluxo 1: Criar e Gerenciar Ticket
1. [ ] Login
2. [ ] Navegar para Add Ticket
3. [ ] Criar ticket
4. [ ] Verificar aparece em "Meus Ingressos"
5. [ ] Verificar aparece em lista completa
6. [ ] Editar ticket
7. [ ] Deletar ticket
8. [ ] Verificar removido de todas as listas

#### Fluxo 2: Negociação Completa
1. [ ] Ver ticket
2. [ ] Iniciar negociação
3. [ ] Selecionar perguntas
4. [ ] Responder perguntas
5. [ ] Enviar documentos
6. [ ] Aprovar negociação
7. [ ] Revelar contato
8. [ ] Abrir WhatsApp

#### Fluxo 3: Explorar e Comprar
1. [ ] Ver eventos na Home
2. [ ] Tocar em evento
3. [ ] Ver ingressos disponíveis
4. [ ] Tocar em ingresso
5. [ ] Ver detalhes
6. [ ] Favoritar ingresso
7. [ ] Iniciar negociação

## Checklist de Design System

### Componentes
- [ ] Botões usam DSButton
- [ ] Cards usam DSCard
- [ ] Badges usam DSBadge
- [ ] Empty states usam DSEmptyState
- [ ] Loading usa DSLoadingIndicator
- [ ] List cells usam DSListCell

### Tokens
- [ ] Cores usam DSColors
- [ ] Tipografia usa DSTypography
- [ ] Espaçamento usa DSSpacing
- [ ] Radius usa DSRadius
- [ ] Gradientes usam DSGradients

### Animações
- [ ] Transições usam DSViewTransitions
- [ ] Feedback de toque usa DSMicroInteractions
- [ ] Swipe gestures usam DSSwipeGestures
- [ ] Pull-to-refresh usa DSPullToRefresh

## Testes de Navegação

### Padrões de Navegação
- [ ] Tab navigation funciona
- [ ] Modal/Sheet navigation funciona
- [ ] Navigation stack funciona
- [ ] Delegate pattern funciona (cross-feature)

### Transições
- [ ] Transições são consistentes
- [ ] Transições são suaves
- [ ] Transições apropriadas para cada tipo

## Relatório de Bugs

### Template de Bug Report

```markdown
## Bug: [Título]

### Descrição
[Descrição clara do problema]

### Passos para Reproduzir
1. [Passo 1]
2. [Passo 2]
3. [Passo 3]

### Comportamento Esperado
[O que deveria acontecer]

### Comportamento Atual
[O que está acontecendo]

### Ambiente
- iOS: [versão]
- Dispositivo: [modelo]
- Feature: [nome da feature]

### Screenshots/Videos
[Se aplicável]

### Logs
[Logs relevantes]
```

## Critérios de Aceitação

### Para cada Feature Migrada

- [ ] Todos os testes unitários passam
- [ ] Todos os testes de integração passam
- [ ] QA manual completa sem bugs críticos
- [ ] Design System integrado
- [ ] Navegação funciona corretamente
- [ ] Performance adequada
- [ ] Acessibilidade verificada
- [ ] Documentação atualizada

## Referências

- [TESTING_GUIDE.md](./TESTING_GUIDE.md) - Guia de testes
- [PRESENTATION_LAYER.md](./PRESENTATION_LAYER.md) - Padrões de Presentation
- [NAVIGATION_PATTERNS.md](./NAVIGATION_PATTERNS.md) - Padrões de navegação
- [Design System README](../DesignSystem/README.md) - Componentes DS

---

✅ **Guia completo de QA estabelecido**

📚 **Use este guia para garantir qualidade**

🎯 **Checklists prontos para uso em QA manual**

