# PRD — Telas de Empty State e Sucesso

## Visão Geral

Este PRD descreve a implementação de telas de empty state (estados vazios) e sucesso em pontos estratégicos do aplicativo para melhorar a experiência do usuário e fornecer feedback claro sobre ações e estados do sistema.

## Objetivos

- Implementar telas de empty state padronizadas para guiar usuários quando não há conteúdo disponível
- Criar telas de sucesso padronizadas para confirmar ações importantes do usuário
- Melhorar a experiência do usuário com mensagens claras e ações diretas
- Manter consistência visual e de interação em todo o aplicativo

## Histórias de Usuário

1. Como usuário, quero ver uma tela informativa quando não encontro resultados na busca, para entender que não há eventos correspondentes e saber o que fazer
2. Como usuário, quero ver uma mensagem clara quando não tenho ingressos futuros, para ser guiado a buscar eventos e adquirir ingressos
3. Como usuário, quero ver uma tela quando não tenho favoritos, para entender como adicionar eventos aos favoritos
4. Como vendedor, quero ver uma tela inicial ao anunciar um ingresso, para entender o processo antes de começar
5. Como vendedor, quero ver uma confirmação de sucesso após anunciar um ingresso, para ter certeza que a ação foi concluída
6. Como usuário, quero ver uma confirmação de sucesso após redefinir minha senha, para ter certeza que a ação foi concluída

## Funcionalidades Principais

### 1. Empty State de Busca Sem Resultados
- **Localização**: `SearchView` (busca de eventos)
- **Quando exibir**: Quando há texto de busca mas nenhum resultado encontrado
- **Elementos**: Ícone de lupa, título "No Results Found", mensagem orientativa, sugestão de tentar diferentes palavras-chave ou filtros

### 2. Empty State de Meus Ingressos
- **Localização**: `MyTicketsView` (tela de ingressos do usuário)
- **Quando exibir**: Quando não há ingressos futuros ou passados
- **Elementos**: Ícone de ingresso, título "No Upcoming Tickets" ou "No Past Tickets", mensagem explicativa, botão "Browse Events" para navegar para busca de eventos
- **Tabs**: "Upcoming" e "Past Ticket" para filtrar entre ingressos futuros e passados

### 3. Empty State de Favoritos
- **Localização**: `FavoritesView` (tela de favoritos)
- **Quando exibir**: Quando não há eventos favoritados
- **Elementos**: Ícone de coração, título "No Favorites Yet", mensagem explicativa sobre como adicionar favoritos, botão "Add" para navegar para eventos

### 4. Empty State de Anunciar Ingresso (Tela Inicial)
- **Localização**: `AddTicketView` (fluxo de criação de ingresso)
- **Quando exibir**: Quando o usuário acessa o fluxo de anunciar ingresso pela primeira vez ou antes de preencher dados
- **Elementos**: Ícone de calendário, título "Anunciar Ingresso" (substituindo "Create Events"), mensagem motivacional, botão "Anunciar Ingresso" para iniciar o fluxo

### 5. Tela de Sucesso de Anunciar Ingresso
- **Localização**: `AddTicketView` (após publicação bem-sucedida)
- **Quando exibir**: Após publicação bem-sucedida de um ingresso
- **Elementos**: Ícone de calendário com checkmark, título "Anunciar Ingresso Está Pronto!" (substituindo "Your Event Is Ready!"), mensagem confirmatória, botão "Confirmar & Publicar" ou "Concluir"

### 6. Tela de Sucesso de Reset de Senha
- **Localização**: `ForgotPasswordView` (fluxo de redefinição de senha)
- **Quando exibir**: Após redefinição bem-sucedida da senha
- **Elementos**: Ícone verde com checkmark, título "Successful", mensagem "Your new password has been set successfully!", botão "Done" para fechar e retornar ao login

## Experiência do Usuário

### Personas Principais
- **Usuário Comprador**: Busca eventos, adquire ingressos, favorita eventos
- **Usuário Vendedor**: Anuncia ingressos, gerencia seus ingressos

### Fluxos Principais

1. **Fluxo de Busca Vazia**:
   - Usuário digita termo de busca → Nenhum resultado → Empty state com orientações

2. **Fluxo de Meus Ingressos Vazio**:
   - Usuário acessa "Meus Ingressos" → Sem ingressos → Empty state com botão para buscar eventos

3. **Fluxo de Favoritos Vazio**:
   - Usuário acessa "Favoritos" → Sem favoritos → Empty state explicando como adicionar

4. **Fluxo de Anunciar Ingresso**:
   - Vendedor acessa "Anunciar" → Tela inicial explicativa → Preenche dados → Publica → Tela de sucesso

5. **Fluxo de Reset de Senha**:
   - Usuário esquece senha → Preenche email → Cria nova senha → Tela de sucesso → Retorna ao login

### Considerações de UI/UX
- Todas as telas devem seguir o design system existente (cores, tipografia, espaçamentos)
- Ícones devem usar SF Symbols quando possível
- Mensagens devem ser claras, concisas e orientadas a ação
- Botões de ação devem ser destacados visualmente (cor primária do app)
- Suportar Dynamic Type para acessibilidade
- Animações sutis ao exibir empty states e telas de sucesso

### Requisitos de Acessibilidade
- Suporte a Dynamic Type
- Rotulagem adequada para VoiceOver
- Contraste adequado de cores (WCAG AA)
- Estados de foco visíveis para navegação por teclado (iPad)

## Restrições Técnicas de Alto Nível

- Deve seguir a arquitetura existente (Composable Architecture/TCA)
- Componentes devem ser reutilizáveis quando possível
- Textos devem usar String Catalog (Localizable.xcstrings) para localização
- Estados devem ser gerenciados pelo Feature correspondente (Reducer pattern)
- Não deve quebrar funcionalidades existentes

## Não-Objetivos (Fora de Escopo)

- Modificar fluxos de negócio existentes
- Criar novos recursos além das telas de empty state e sucesso
- Alterar estrutura de dados ou APIs
- Implementar novos tipos de empty states além dos especificados
- Modificar telas de erro (mantidas separadas)

## Questões em Aberto

- Confirmar se a tela de sucesso de "Anunciar Ingresso" deve fechar automaticamente após alguns segundos ou apenas ao clicar no botão
- Definir se "Meus Ingressos" deve ter tabs "Upcoming" e "Past Ticket" ou apenas mostrar empty state único



