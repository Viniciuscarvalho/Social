PRD: Ticket Resale Negotiation (P2P)

🧭 Visão Geral

Marketplace P2P de revenda de ingressos com negociação estruturada (proposta → contraproposta → aceito → encerrado), sem pagamento no app.
Contatos externos (WhatsApp/Telegram/telefone) são liberados somente após “aceito” e com autenticação biométrica.
Usuários precisam de verificação mínima (e-mail + telefone) para listar/comprar; ingressos são validados por evento pelo backend após criação.
Tickets e preferências essenciais são persistidos localmente com SwiftData.

⸻

🎯 Objetivos
	•	Aumentar liquidez de ingressos com um fluxo de negociação simples e seguro.
	•	Reduzir fraude através de gates de verificação e validação de ingressos.
	•	Otimizar experiência de descoberta (todos → populares → recomendados) com filtros temporais.

Métricas principais
	•	Taxa de aceite
	•	Tempo médio até aceite
	•	Propostas por listagem
	•	Cancelamentos pós-aceite
	•	Denúncias/abusos

⸻

👤 Histórias de Usuário
	•	Como comprador, quero negociar 1 a 3 ingressos de um lote para ajustar meu orçamento e necessidade.
	•	Como vendedor, quero listar até 3 ingressos por evento, gerenciar propostas e encerrar quando esgotar.
	•	Como comprador, quero ver os contatos do vendedor somente após aceite e com Face ID/Touch ID para segurança.
	•	Como moderador, quero limitar abusos (propostas excessivas/listagens excessivas) e bloquear reincidentes.

⸻

⚙️ Funcionalidades Principais

1️⃣ Descoberta e Listagens

O que:
Listar ingressos (quantidade N, mesmo tipo/preço) por evento.
Descoberta: todos → populares (agrupado por tipo) → recomendados.
Filtros: hoje / amanhã / essa semana / este mês.
Expiração automática em 30 dias.

Requisitos funcionais:
	•	Usuário pode listar até 3 ingressos por evento (quantidade N na mesma listagem).
	•	Comprador pode negociar de 1 a 3 ingressos de um mesmo lote (parcial permitido).
	•	Listagens expiram após 30 dias ou quando o evento expira.
	•	Se o vendedor remover uma listagem com negociações ativas, compradores impactados devem ser notificados.
	•	Seções de descoberta:
	•	Todos os eventos
	•	Populares (por tipo: aventura, cultura, comida, música, esportes, tecnologia, negócios)
	•	Recomendados

⸻

2️⃣ Gate de Verificação e Validação

O que:
Gate mínimo para listar/comprar (e-mail + telefone).
Validação do ingresso por evento no backend (upload de foto + metadados).

Requisitos:
	•	Listar/comprar exige usuário verificado (e-mail + telefone).
	•	Ingressos só aparecem na busca após validação por evento (status: em análise / aprovado / rejeitado).
	•	App exibe claramente o status e mensagens de erro de validação.

⸻

3️⃣ Negociação Estruturada

O que:
Fluxo proposta → até 2 ciclos de contraproposta → aceito → encerrado,
com timeouts de 2 dias por etapa e encerramento automático por timeout/evento expirado/quantidade esgotada.

Requisitos:
	•	Proposta inclui: preço ofertado, quantidade desejada, observação.
	•	Máximo de 2 contrapropostas por negociação (round-trip cap).
	•	Timeout por etapa de 2 dias; ao expirar, negociação encerra automaticamente.
	•	Encerramento automático se evento encerrar ou quantidade esgotar.
	•	Desistência/cancelamento:
	•	Antes de “aceito” → encerra sem contato
	•	Após “aceito” → exige notificação recíproca ao contraparte

⸻

4️⃣ Revelação de Contato (após “aceito”)

O que:
Contatos (WhatsApp/Telegram/telefone) mascarados até “aceito”.
Revelação exige biometria.

Requisitos:
	•	Contatos permanecem mascarados até estado “aceito”.
	•	Revelação de contato exige autenticação biométrica (Face ID / Touch ID) por sessão.
	•	Registrar auditoria local (timestamp / negociação) da revelação.

⸻

5️⃣ Anti-Abuso e Moderação

O que:
Limites anti-cambismo e controles de abuso.

Requisitos:
	•	Rate limit: até 3 propostas/contrapropostas por usuário (janela configurável).
	•	Listagens: até 3 ingressos por usuário por evento simultaneamente.
	•	Bloquear usuários reincidentes ou com baixo trust score (política de moderação).
	•	Denúncia de listagem/usuário disponível; pipeline de moderação ativo.

⸻

6️⃣ Notificações e Preferências

O que:
Push/in-app para eventos chave; preferências com opt-in padrão habilitado.

Requisitos:
	•	Notificar: nova proposta, contraproposta, aceite, expiração de etapa.
	•	Opt-in padrão habilitado; usuário pode desativar por categoria.

⸻

7️⃣ Persistência Local (SwiftData)

O que:
Tickets e preferências essenciais salvos localmente; dados sensíveis ofuscados.

Requisitos:
	•	Salvar ingressos cadastrados do usuário via SwiftData; atualizar após negociação; remover ao excluir listagem.
	•	Salvar preferências essenciais do usuário (no cadastro); filtros não são persistidos.
	•	Dados sensíveis (contatos) devem ir para UserDefaults com ofuscação mínima (não SwiftData).

⸻

🎨 Experiência do Usuário

Personas:
	•	Compradores frequentes
	•	Vendedores casuais

Fluxos principais:
	1.	Descoberta
	2.	Detalhe do evento/listagem
	3.	Iniciar negociação
	4.	Ciclos de contraproposta (≤2)
	5.	Aceite
	6.	Biometria
	7.	Contato revelado

Considerações de UI/UX:
	•	Estado visível da listagem/negociação (em análise, aprovado, rejeitado, expirado).
	•	Feedback claro de timeouts e limites atingidos.
	•	Acessibilidade: tamanho de fonte dinâmico, contraste adequado, rótulos descritivos.

⸻

🧱 Restrições Técnicas de Alto Nível

Integrações:
	•	REST APIs existentes (negociação / validação)
	•	Firebase Push
	•	LocalAuthentication (biometria)

Segurança / Privacidade:
	•	Contatos mascarados até “aceito”; revelação com biometria.
	•	Verificação mínima obrigatória (e-mail + telefone).

Performance:
	•	Atualizações de estado responsivas.
	•	Sincronização SwiftData eficiente.

Conformidade:
	•	Políticas de moderação presentes.
	•	Atenção a regulações regionais sobre revenda.

⸻

🚫 Não-Objetivos (Fora de Escopo)
	•	Pagamentos (ex.: Stripe) neste release.
	•	Chat dentro do app.
	•	Mapa de assentos / assentos marcados.
	•	KYC completo obrigatório (documento) como gate mínimo.

⸻

❓ Questões em Aberto
	•	Jurisdições / regulatórios aplicáveis por região para revenda (regras/limites).
	•	Parâmetros exatos de rate limit e critérios de bloqueio automático (limiares/tempo).
	•	SLA do backend para validação de ingressos (prazos e retries) e mensagens padrão.
	•	Política de retenção / expurgo de dados locais (SwiftData) e logs de auditoria.
	•	Critérios de score baixo de confiança e processo de recuperação / desbloqueio.