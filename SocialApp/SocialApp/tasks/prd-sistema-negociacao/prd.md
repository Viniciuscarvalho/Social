# PRD: Sistema de Negociação de Ingressos

## Visão Geral

O Sistema de Negociação de Ingressos permite que compradores e vendedores interajam de forma estruturada para negociar a venda de ingressos. O sistema facilita a comunicação através de perguntas pré-definidas, verificação de documentos e revelação segura de contatos, garantindo transparência e segurança nas transações.

Esta funcionalidade resolve o problema de comunicação desorganizada entre compradores e vendedores, oferecendo um fluxo guiado que aumenta a confiança e reduz fricções na negociação de ingressos.

## Objetivos

- **Aumentar a taxa de conclusão de negociações**: Facilitar a comunicação estruturada entre compradores e vendedores
- **Melhorar a segurança das transações**: Implementar verificação de documentos e controle de acesso aos dados de contato
- **Reduzir tempo de negociação**: Fornecer perguntas pré-definidas e fluxo claro de etapas
- **Métricas principais**:
  - Taxa de conversão de negociações iniciadas para concluídas
  - Tempo médio de resposta a perguntas
  - Taxa de aprovação de documentos enviados
  - Taxa de revelação de contatos após aprovação

## Histórias de Usuário

### Comprador
- Como comprador, eu quero fazer perguntas sobre o ingresso para que eu possa tomar uma decisão informada antes de comprar
- Como comprador, eu quero ver os documentos de verificação do ingresso para que eu tenha confiança na autenticidade
- Como comprador, eu quero receber os dados de contato do vendedor após aprovação para que eu possa finalizar a negociação
- Como comprador, eu quero ver o status da negociação em tempo real para que eu saiba em qual etapa estou

### Vendedor
- Como vendedor, eu quero responder perguntas dos compradores para que eu possa esclarecer dúvidas e aumentar a confiança
- Como vendedor, eu quero enviar documentos de verificação do ingresso para que eu possa comprovar a autenticidade
- Como vendedor, eu quero aprovar ou rejeitar negociações para que eu tenha controle sobre com quem negocio
- Como vendedor, eu quero ver notificações de novas perguntas para que eu possa responder rapidamente

## Funcionalidades Principais

### 1. Sistema de Perguntas e Respostas

**O que faz**: Permite que compradores selecionem perguntas pré-definidas e vendedores respondam de forma estruturada.

**Por que é importante**: Facilita a comunicação estruturada e reduz ambiguidades na negociação.

**Como funciona**: 
- Comprador seleciona até 5 perguntas de uma lista pré-definida
- Vendedor recebe notificação e pode responder cada pergunta
- Respostas são exibidas de forma organizada na tela de detalhes

**Requisitos funcionais**:
1. RF-001: O sistema deve permitir que o comprador selecione até 5 perguntas pré-definidas por negociação
2. RF-002: As perguntas devem ser organizadas por categorias (ex: Autenticidade, Condições, Entrega)
3. RF-003: O vendedor deve receber notificação quando houver perguntas não respondidas
4. RF-004: O vendedor deve poder responder cada pergunta individualmente
5. RF-005: Respostas não podem ser editadas após envio
6. RF-006: O sistema deve exibir badge visual indicando perguntas não respondidas

### 2. Upload e Verificação de Documentos

**O que faz**: Permite que vendedores enviem fotos do ingresso e documentos de identificação para verificação automática.

**Por que é importante**: Aumenta a confiança do comprador na autenticidade do ingresso e do vendedor.

**Como funciona**:
- Vendedor seleciona fotos da galeria ou câmera
- Sistema comprime imagens antes do upload
- Backend realiza verificação automática
- Status de verificação é exibido na interface

**Requisitos funcionais**:
7. RF-007: O sistema deve permitir upload de até 2 documentos por negociação
8. RF-008: Documentos aceitos: fotos do ingresso, CNH, RG
9. RF-009: O sistema deve comprimir imagens antes do upload para otimizar performance
10. RF-010: O sistema deve exibir progresso de upload em tempo real
11. RF-011: O sistema deve exibir status de verificação (pendente/aprovado/rejeitado) para cada documento
12. RF-012: O sistema deve permitir visualização em tela cheia e zoom dos documentos

### 3. Fluxo de Aprovação e Revelação de Contato

**O que faz**: Controla o fluxo de aprovação da negociação e revelação segura dos dados de contato do vendedor.

**Por que é importante**: Garante que o comprador só tenha acesso aos dados de contato após aprovação, protegendo a privacidade do vendedor.

**Como funciona**:
- Vendedor pode aprovar ou rejeitar a negociação
- Após aprovação, comprador pode revelar contato com autenticação biométrica
- Dados revelados incluem nome, e-mail e telefone (quando disponível)
- Sistema gera deep link para WhatsApp com mensagem pré-formatada

**Requisitos funcionais**:
13. RF-013: O vendedor deve poder aprovar ou rejeitar negociações com status "pending"
14. RF-014: Ao rejeitar, o vendedor deve informar motivo da recusa
15. RF-015: Após aprovação, o comprador deve poder revelar contato com autenticação biométrica (Face ID/Touch ID)
16. RF-016: Dados revelados devem ser copiáveis e acionáveis (e-mail, telefone)
17. RF-017: O sistema deve gerar deep link para WhatsApp com mensagem pré-formatada incluindo detalhes da negociação
18. RF-018: O sistema deve exibir máquina de estados visual mostrando progresso (Perguntas → Verificação → Aprovação → Contato Revelado)

### 4. Listagem de Negociações

**O que faz**: Exibe lista de todas as negociações do usuário com informações resumidas e status.

**Por que é importante**: Permite que usuários acompanhem todas as negociações ativas de forma organizada.

**Como funciona**:
- Lista exibe cards com foto, nome da outra pessoa, status e contador de perguntas
- Badge visual indica itens não lidos
- Pull-to-refresh atualiza lista
- Navegação para detalhes ao tocar no card

**Requisitos funcionais**:
19. RF-019: A lista deve exibir foto e nome da outra pessoa (comprador ou vendedor)
20. RF-020: A lista deve exibir status da negociação com badge visual
21. RF-021: A lista deve exibir contador de perguntas respondidas vs total
22. RF-022: Badge visual deve indicar negociações com perguntas não respondidas
23. RF-023: O sistema deve suportar pull-to-refresh para atualizar lista
24. RF-024: Ao tocar em um card, deve navegar para tela de detalhes

### 5. Sistema de Notificações In-App

**O que faz**: Monitora e exibe notificações não lidas relacionadas a negociações.

**Por que é importante**: Mantém usuários informados sobre atualizações importantes sem interrupções desnecessárias.

**Como funciona**:
- Sistema monitora perguntas não respondidas
- Badge na tab bar exibe contador de perguntas pendentes
- Badge é atualizado quando app abre ou periodicamente em foreground
- Negociação é marcada como lida ao abrir detalhes

**Requisitos funcionais**:
25. RF-025: O sistema deve monitorar perguntas não respondidas globalmente
26. RF-026: Badge na tab bar deve exibir contador de perguntas não respondidas
27. RF-027: Badge deve ser atualizado quando app abre
28. RF-028: Negociação deve ser marcada como visualizada automaticamente ao abrir detalhes
29. RF-029: Timestamp de visualização deve ser atualizado no backend

### 6. Integração com Tela de Tickets

**O que faz**: Adiciona botão "Iniciar Negociação" na tela de detalhes do ticket.

**Por que é importante**: Facilita o início de negociações diretamente a partir da visualização do ticket.

**Como funciona**:
- Botão aparece apenas para tickets com status "available"
- Sistema verifica se já existe negociação ativa antes de criar nova
- Ao iniciar, navega para tela de seleção de perguntas
- Cria negociação no backend e atualiza estado

**Requisitos funcionais**:
30. RF-030: Botão "Iniciar Negociação" deve aparecer apenas em tickets com status "available"
31. RF-031: Sistema deve impedir criação de nova negociação se já existir uma ativa para o mesmo ticket
32. RF-032: Ao iniciar negociação, deve navegar para tela de seleção de perguntas
33. RF-033: Sistema deve criar negociação no backend e atualizar estado local

## Experiência do Usuário

### Personas

**Comprador (João, 28 anos)**:
- Busca ingressos para eventos específicos
- Precisa de informações claras antes de comprar
- Valoriza transparência e verificação de autenticidade
- Usa WhatsApp como principal canal de comunicação

**Vendedor (Maria, 35 anos)**:
- Vende ingressos regularmente
- Precisa responder perguntas rapidamente para não perder vendas
- Quer proteger seus dados de contato até aprovação
- Valoriza ferramentas que facilitam a comunicação

### Fluxos Principais

**Fluxo 1: Comprador inicia negociação**
1. Comprador visualiza ticket disponível
2. Toca em "Iniciar Negociação"
3. Seleciona até 5 perguntas pré-definidas
4. Sistema cria negociação e notifica vendedor
5. Comprador aguarda respostas e pode visualizar documentos quando enviados

**Fluxo 2: Vendedor responde e envia documentos**
1. Vendedor recebe notificação de nova negociação
2. Abre detalhes e visualiza perguntas
3. Responde cada pergunta
4. Envia documentos (foto do ingresso, CNH/RG)
5. Aguarda verificação automática
6. Aprova ou rejeita negociação

**Fluxo 3: Comprador revela contato**
1. Comprador visualiza negociação aprovada
2. Toca em "Revelar Dados de Contato"
3. Autentica com Face ID/Touch ID
4. Visualiza dados de contato
5. Pode copiar ou abrir WhatsApp diretamente

### Requisitos de UI/UX

- Interface deve seguir design system existente do app
- Estados de loading devem ser claros e informativos
- Mensagens de erro devem ser amigáveis e acionáveis
- Animações devem ser sutis e melhorar compreensão do fluxo
- Componentes devem ser reutilizáveis e consistentes

### Requisitos de Acessibilidade

- Todos os elementos interativos devem ter labels apropriados
- Contraste de cores deve atender WCAG AA
- Navegação por teclado deve ser suportada onde aplicável
- Textos devem ser legíveis em diferentes tamanhos de fonte

## Restrições Técnicas de Alto Nível

- **Integrações externas**: 
  - Backend API REST para negociações, perguntas, respostas, documentos e revelação de contato
  - LocalAuthentication framework para autenticação biométrica
  - PhotosPicker para seleção de imagens
  - Deep linking para WhatsApp

- **Conformidade e segurança**:
  - Dados de contato devem ser protegidos até aprovação
  - Autenticação biométrica obrigatória para revelação de contato
  - Upload de documentos deve usar HTTPS
  - Tokens JWT para autenticação de API

- **Performance**:
  - Upload de imagens deve ser otimizado (compressão antes de enviar)
  - Lista de negociações deve suportar paginação se necessário
  - Respostas de API devem ter latência < 2s para 95% das requisições

- **Sensibilidade de dados**:
  - Dados de contato são sensíveis e devem ser tratados com cuidado
  - Documentos enviados devem ser armazenados de forma segura no backend
  - Logs não devem conter informações pessoais sensíveis

## Não-Objetivos (Fora de Escopo)

- **Chat em tempo real**: Sistema não inclui chat livre, apenas perguntas pré-definidas
- **Notificações push**: Apenas notificações in-app serão implementadas nesta fase
- **Pagamento integrado**: Sistema não processa pagamentos, apenas facilita comunicação
- **Avaliações pós-negociação**: Sistema de reviews não está incluído nesta fase
- **Negociação de preço**: Sistema não permite negociação de valores, apenas comunicação
- **Múltiplas negociações simultâneas**: Apenas uma negociação ativa por ticket é permitida
- **Edição de perguntas**: Comprador não pode editar perguntas após seleção
- **Edição de respostas**: Vendedor não pode editar respostas após envio

## Questões em Aberto

- **Categorias de perguntas**: Quais categorias específicas de perguntas pré-definidas serão disponibilizadas? (requer definição de produto)
- **Critérios de verificação automática**: Quais são os critérios exatos para aprovação/rejeição automática de documentos? (requer alinhamento com backend)
- **Timeout de negociações**: Qual o tempo máximo que uma negociação pode ficar pendente antes de expirar? (requer definição de negócio)
- **Limite de negociações simultâneas**: Um usuário pode ter quantas negociações ativas ao mesmo tempo? (requer definição de negócio)

