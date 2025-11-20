# PRD: Ajustes de Perfil e Fluxo de Vendedor

## Visão Geral

Este documento descreve os ajustes necessários nas telas de perfil do usuário, perfil do vendedor e fluxo de negociação de ingressos para alinhar a aplicação com o design do Figma e corrigir comportamentos de navegação. As mudanças incluem reintrodução da seleção de tema, correção da navegação para perfil de vendedor, ajustes na exibição de ingressos do vendedor, remoção de botões desnecessários e correção do fluxo de negociação a partir do detalhe do evento.

## Objetivos

- **Restaurar funcionalidade de seleção de tema**: Reintroduzir a seleção de tema na tela de perfil do usuário para permitir que usuários escolham entre modo claro, escuro ou automático.
- **Corrigir navegação para perfil de vendedor**: Garantir que ao clicar no perfil do vendedor na tela de perfil, o usuário seja direcionado corretamente para a tela de perfil do vendedor.
- **Ajustar tela de perfil do vendedor**: Exibir título "Vendedor" (não "Organizer") e mostrar lista de ingressos do vendedor ao invés de eventos.
- **Remover botão desnecessário**: Remover o botão "Salvar para depois" da tela de detalhe do evento que não está condizente com o Figma.
- **Corrigir fluxo de negociação**: Ao clicar em "Negociar ingresso" a partir do detalhe do evento, direcionar para listagem de vendedores que vendem ingressos daquele evento, não para listagem completa de ingressos.

**Métricas principais**:
- Taxa de sucesso de navegação para perfil de vendedor
- Taxa de uso da seleção de tema
- Taxa de conversão de negociações iniciadas a partir do detalhe do evento

## Histórias de Usuário

### Usuário Geral
- Como usuário, eu quero selecionar o tema da aplicação (claro/escuro/automático) na tela de perfil para que eu possa personalizar minha experiência visual.
- Como usuário, eu quero clicar no perfil de um vendedor na minha tela de perfil para que eu possa visualizar os detalhes e ingressos disponíveis desse vendedor.

### Comprador
- Como comprador, eu quero ver o título "Vendedor" na tela de perfil do vendedor para que eu entenda claramente que estou visualizando um vendedor.
- Como comprador, eu quero ver os ingressos que um vendedor possui ao invés de eventos para que eu possa identificar quais ingressos estão disponíveis para compra.
- Como comprador, eu quero clicar em "Negociar ingresso" no detalhe do evento para que eu seja direcionado para uma lista de vendedores que vendem ingressos daquele evento específico.

## Funcionalidades Principais

### 1. Seleção de Tema na Tela de Perfil

**O que faz**: Permite que usuários selecionem o tema da aplicação (claro, escuro ou automático) diretamente na tela de perfil.

**Por que é importante**: Melhora a experiência do usuário permitindo personalização visual e acessibilidade.

**Como funciona**:
- Usuário acessa a tela de perfil
- Visualiza opção de seleção de tema (provavelmente um toggle ou picker)
- Seleciona entre Claro, Escuro ou Automático
- Aplicação atualiza o tema imediatamente

**Requisitos funcionais**:
1. RF-001: A tela de perfil deve exibir um componente de seleção de tema
2. RF-002: O componente deve permitir seleção entre três opções: Claro, Escuro e Automático
3. RF-003: A seleção deve ser persistida e aplicada imediatamente na aplicação
4. RF-004: O estado atual do tema deve ser refletido visualmente no componente

### 2. Navegação para Perfil de Vendedor

**O que faz**: Restaura a funcionalidade de navegação da tela de perfil para a tela de perfil do vendedor quando o usuário clica no card/área do vendedor.

**Por que é importante**: Permite que usuários acessem informações e ingressos disponíveis de vendedores.

**Como funciona**:
- Usuário visualiza card/área do vendedor na tela de perfil
- Ao tocar no card, navega para a tela de perfil do vendedor
- Tela de perfil do vendedor exibe informações e ingressos do vendedor

**Requisitos funcionais**:
5. RF-005: O card/área do vendedor na tela de perfil deve ser clicável
6. RF-006: Ao clicar, deve navegar para a tela de perfil do vendedor correspondente
7. RF-007: A navegação deve passar o ID do vendedor como parâmetro

### 3. Ajuste da Tela de Perfil do Vendedor

**O que faz**: Ajusta o título e o conteúdo da tela de perfil do vendedor para exibir "Vendedor" como título e lista de ingressos ao invés de eventos.

**Por que é importante**: Alinha a interface com a terminologia correta e exibe informações relevantes para compradores (ingressos disponíveis).

**Como funciona**:
- Tela exibe título "Vendedor" no topo (não "Organizer")
- Aba "Ingressos" (ou similar) lista os ingressos que o vendedor possui
- Cada ingresso pode ser clicável para ver detalhes

**Requisitos funcionais**:
8. RF-008: O título da tela deve ser "Vendedor" (não "Organizer")
9. RF-009: A tela deve exibir lista de ingressos do vendedor ao invés de eventos
10. RF-010: Os ingressos devem ser exibidos em formato de cards/listagem
11. RF-011: Cada ingresso deve exibir informações relevantes (evento, preço, disponibilidade, etc.)
12. RF-012: Ao clicar em um ingresso, deve navegar para detalhe do ingresso ou iniciar negociação

### 4. Remoção do Botão "Salvar para depois"

**O que faz**: Remove o botão "Salvar para depois" que aparece abaixo do botão "Negociar ticket" na tela de detalhe do evento.

**Por que é importante**: Alinha a interface com o design do Figma e remove funcionalidade que não está no escopo atual.

**Como funciona**:
- Tela de detalhe do evento é revisada
- Botão "Salvar para depois" é removido
- Layout é ajustado para manter hierarquia visual adequada

**Requisitos funcionais**:
13. RF-013: O botão "Salvar para depois" deve ser removido da tela de detalhe do evento
14. RF-014: O layout deve ser ajustado para manter espaçamentos e hierarquia visual adequados conforme Figma

### 5. Correção do Fluxo de Negociação a partir do Detalhe do Evento

**O que faz**: Corrige o fluxo de negociação para que ao clicar em "Negociar ingresso" no detalhe do evento, o usuário seja direcionado para uma lista de vendedores que vendem ingressos daquele evento específico, não para a listagem completa de ingressos.

**Por que é importante**: Melhora a experiência do usuário direcionando-o diretamente para vendedores relevantes do evento que está visualizando.

**Como funciona**:
- Usuário está na tela de detalhe do evento
- Clica no botão "Negociar ingresso"
- É direcionado para uma tela que lista vendedores que possuem ingressos daquele evento
- Pode selecionar um vendedor para iniciar negociação ou ver perfil

**Requisitos funcionais**:
15. RF-015: Ao clicar em "Negociar ingresso" no detalhe do evento, deve navegar para lista de vendedores do evento
16. RF-016: A lista deve exibir apenas vendedores que possuem ingressos disponíveis para aquele evento específico
17. RF-017: Cada vendedor na lista deve exibir informações relevantes (nome, foto, preço do ingresso, etc.)
18. RF-018: Ao selecionar um vendedor, deve permitir iniciar negociação ou visualizar perfil do vendedor

## Experiência do Usuário

### Personas de Usuário

**Comprador**: Usuário que busca ingressos para eventos. Precisa encontrar vendedores confiáveis e ingressos disponíveis de forma rápida e intuitiva.

**Vendedor**: Usuário que vende ingressos. Precisa que seu perfil seja acessível e que seus ingressos sejam facilmente encontrados.

### Fluxos Principais

1. **Fluxo de Seleção de Tema**:
   - Usuário acessa perfil → Visualiza opção de tema → Seleciona tema → Tema é aplicado

2. **Fluxo de Visualização de Perfil de Vendedor**:
   - Usuário acessa perfil → Clica no card do vendedor → Visualiza perfil do vendedor com ingressos

3. **Fluxo de Negociação a partir do Evento**:
   - Usuário visualiza detalhe do evento → Clica em "Negociar ingresso" → Visualiza lista de vendedores do evento → Seleciona vendedor → Inicia negociação

### Considerações de UI/UX

- Manter consistência visual com o design do Figma
- Garantir que navegação seja intuitiva e clara
- Manter feedback visual adequado em todas as interações
- Seguir padrões de acessibilidade (tamanhos de toque, contraste, etc.)

### Requisitos de Acessibilidade

- Componentes interativos devem ter tamanho mínimo de toque de 44x44 pontos
- Contraste adequado entre texto e fundo
- Suporte a VoiceOver quando aplicável
- Feedback visual claro em todas as ações

## Restrições Técnicas de Alto Nível

- **Arquitetura**: Manter uso de TCA (The Composable Architecture) já estabelecido no projeto
- **Integrações**: Pode ser necessário ajustar endpoints de API para:
  - Listar vendedores por evento (filtrar vendedores que possuem ingressos de um evento específico)
  - Listar ingressos por vendedor (filtrar ingressos de um vendedor específico)
- **Performance**: Listagens devem suportar paginação se necessário para grandes volumes de dados
- **Dados**: Garantir que dados de vendedores e ingressos sejam atualizados corretamente após mudanças

## Não-Objetivos (Fora de Escopo)

- Implementação de funcionalidade de "Salvar para depois" (será removida, não implementada)
- Mudanças na estrutura de dados de vendedores ou ingressos no backend (apenas ajustes de filtros/endpoints se necessário)
- Implementação de novos fluxos de negociação (apenas correção do fluxo existente)
- Mudanças em outras telas não mencionadas

## Questões em Aberto

1. A seleção de tema deve ser exibida como toggle, picker ou outro componente? (Verificar Figma)
2. A lista de vendedores por evento deve incluir informações adicionais além de nome, foto e preço?
3. A lista de ingressos do vendedor deve permitir filtros ou ordenação?
4. Existe limite de vendedores/ingressos a serem exibidos por vez ou deve haver paginação?

