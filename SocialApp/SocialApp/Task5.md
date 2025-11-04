<role>  
Implementar o fluxo de **validação e negociação de ingressos** no aplicativo **SocialClub (iOS)**, utilizando **SwiftUI** e a **versão mais recente do The Composable Architecture (TCA)**.  
O foco é **somente na camada mobile**, com integração às APIs existentes, mantendo segurança e experiência fluida para comprador e vendedor.  
</role>  

<instructions>  
- Desenvolver as telas e lógicas relacionadas à negociação de ingressos entre usuários, conforme os fluxos descritos:  
  - **Fluxo 1**: Comprador solicita negociação  
  - **Fluxo 2**: Vendedor aprova ou recusa negociação  
  - **Fluxo 3**: Comprador revela dados de contato após aprovação  
  - **Fluxo 4**: Vendedor valida ingresso com upload de provas  
  - **Fluxo 7**: Usuário realiza verificação progressiva de conta (email, telefone, documento)

 As telas que devem ser criadas e quebradas para ter um sentido lógico de criação seguindo,

1)Fase
 - SellerProfileFeature
 - NegotiationRequestFeature
 - NegotiationDetailsFeature
 - Telas: SellerProfileView, NegotiationDetailsView
 - Componente: NegotiationCounter
 - Componente: TrustScoreBadge

2)Fase
 - EmailVerificationFeature
 - PhoneVerificationFeature
 - DocumentVerificationFeature
 - Telas de verificação step-by-step
 - Componente: VerificationBadge

3)Fase
 - BiometricAuthService (LocalAuthentication)
 - ContactRevealFeature
 - Tela: ContactRevealView
 - DeepLinkService (WhatsApp, Telegram, Email)
 - Ofuscação de tela (background protection)

 4)Fase
 - ValidationUploadFeature
 - ValidationStatusFeature
 - Tela: ValidationUploadView
 - Image picker + compression
 - Progress bar de upload
 - Componente: ValidationStatusBanner

 5)Fase
 - NegotiationReviewFeature
 - Tela: ReviewFormView
 - Star rating component
 - Textarea com contador de caracteres

 6)Fase
 - PushNotificationService
 - Configurar Firebase SDK
 - Solicitar permissão de notificações
 - Handle notification tap (deep links)
 - Lazy loading de imagens
 - Skeleton screens
 - Error handling robusto

 	•	A interface deve seguir o estilo visual do SocialClub, com componentes reutilizáveis e consistentes com o Design System.
	•	Implementar os estados de fluxo dentro do domínio TCA, garantindo que as ações sejam rastreáveis e reversíveis.
	•	O app deve lidar com notificações push (recebimento e navegação contextual).
	•	As chamadas à API devem ocorrer através de um TicketNegotiationClient e UserVerificationClient, isolados em camadas de dependência.
	•	A autenticação e o controle de permissões (nível de verificação, limites de negociação etc.) devem ser tratados localmente com base nas respostas da API.

</instructions>

<requirements>  
- Linguagem: **Swift** com **SwiftUI**  
- Arquitetura: **TCA (The Composable Architecture)**  
- O fluxo deve contemplar os seguintes módulos:  
  - **NegotiationFeature**: gerencia estado e ações das negociações  
  - **TicketValidationFeature**: gerencia upload e status de validação de ingressos  
  - **UserVerificationFeature**: controla a evolução do nível de verificação (email, telefone, documento)
- Cada uma dessas features deve seguir a estrutura de pastas já existente no projeto.  
- A comunicação com o backend deve ocorrer via endpoints REST, com validação de tokens JWT e erros tratados com `AlertState`.  
- Implementar estados visuais de carregamento, erro e sucesso.  
- Utilizar biometria (Face ID / Touch ID) para desbloqueio de dados de contato.
- Integrar a biblioteca do Firebase para utilização do Push Notification, utilizar o SPM para integrar ao projeto.  
- Implementar deep links para WhatsApp, Telegram e Email.  
</requirements>

<critical>  
- **Não deve** haver troca direta de mensagens dentro do app (sem chat).  
- **Não deve** expor informações sensíveis publicamente.  
- **Não deve** manipular lógica de pagamento (apenas negociação).  
- **Não deve** persistir dados localmente além do necessário para o fluxo ativo (cache temporário).  
- **Não deve** modificar a arquitetura principal do app ou o roteamento principal da TabBar.  
</critical>  

<acceptance_criteria>
•	O comprador pode solicitar uma negociação apenas se possuir verificação mínima (verified) e menos de 3 negociações ativas.
•	O vendedor recebe notificação push e pode aprovar, recusar ou solicitar mais informações.
•	O comprador só visualiza os dados do vendedor após autenticação biométrica e se a negociação estiver aprovada.
•	O vendedor pode validar ingressos com upload de imagens dentro do limite e formato definidos.
•	A tela de perfil exibe o progresso de verificação (email, telefone, documento) e badges correspondentes.
•	Todos os fluxos exibem mensagens claras de feedback, status visual e persistem o estado corretamente na Store do TCA.
</acceptance_criteria>

<behaviour_details>
•	Quando o comprador clica em “Negociar Ingresso”, o app verifica o nível de verificação e quantidade de negociações ativas antes de enviar a solicitação.
•	Quando o vendedor aprova, o app atualiza o status localmente e mostra um banner de sucesso.
•	Quando o comprador revela dados de contato, o app solicita autenticação biométrica antes de liberar os dados via API.
•	Durante a validação de ingressos, o app comprime as imagens e exibe status: “Em análise”, “Aprovado” ou “Rejeitado”.
•	Durante o processo de verificação de usuário, o app exibe feedbacks visuais para cada etapa concluída (email, telefone, documento).
•	Todas as interações são refletidas em tempo real, com sincronização via refresh automático das stores correspondentes.
</behaviour_details>