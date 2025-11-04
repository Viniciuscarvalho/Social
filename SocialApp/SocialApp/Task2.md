<role>
Você é um desenvolvedor sênior Swift especializado em iOS, responsável por implementar a tela de Perfil da Vendedora em um aplicativo de marketplace de ingressos chamado SocialClub.
</role>

<instructions>
Implemente a tela de Perfil da Vendedora seguindo o fluxo de navegação: Detalhes do Ticket → Perfil da Vendedora. Esta tela deve exibir informações completas sobre uma vendedora específica e listar todos os ingressos que ela possui disponíveis para venda.

A navegação ocorre quando o usuário clica no card da vendedora na tela de detalhes do ticket (onde atualmente mostra "Event Organizer", substituir por "Vendedora"), de acordo com as imagens anexadas.

Estrutura da tela:

1. HEADER
   - Título: "Vendedor"
   - Botão de navegação para voltar (canto superior esquerdo)

2. SEÇÃO DE PERFIL
   - Foto de perfil circular da vendedora
   - Nome da vendedora
   - Badge/selo visual de "Vendedora Certificada" (se aplicável)

3. ESTATÍSTICAS
   - Ingressos: Quantidade total de ingressos disponíveis desta vendedora
   - Seguidores: Número de seguidores da vendedora
   - Seguindo: Número de perfis que a vendedora segue

4. BOTÕES DE AÇÃO
   - Botão "Seguir" (Follow)
   - Botão "Negociar" (substituindo "Message")

5. ABAS DE CONTEÚDO
   - Aba "Sobre": Informações e biografia da vendedora
   - Aba "Ingressos": Lista de todos os ingressos disponíveis

6. LISTA DE INGRESSOS (na aba Ingressos)
   Para cada ingresso exibir:
   - Imagem do evento
   - Nome do evento
   - Tipo de ingresso (VIP, Geral, Estudante, etc.)
   - Preço atual
   - Preço original (se houver desconto, mostrar riscado)
   - Data e horário do evento
   - Local do evento
   - Indicador visual de desconto (se aplicável)
   - Botão de favoritar (coração)
   - Status do ingresso
</instructions>

<requirements>
1. DADOS E INTEGRAÇÃO
   - Consumir dados da API de tickets filtrado por sellerId.
   - Buscar informações do evento associado via eventId da api de events.
   - Calcular dinamicamente a contagem de ingressos da vendedora
   - Criar estrutura de dados para informações da vendedora, se não já existir em models ou adapte caso seja necessário:
     * id (sellerId)
     * nome
     * fotoURL
     * isCertified (Boolean)
     * biografia
     * seguidoresCount
     * seguindoCount
     * rating (opcional para futuro)
     * totalVendas (opcional para futuro)

2. FILTROS E ORDENAÇÃO
   - Exibir apenas ingressos com status "available"
   - Ordenar ingressos por data do evento (mais próximo primeiro)
   - Considerar filtros adicionais: categoria, preço, data (opcional)

3. INTERFACE E NAVEGAÇÃO
   - Implementar navegação entre abas "Sobre" e "Ingressos"
   - Botão "Negociar" deve abrir interface de comunicação com a vendedora
   - Botão "Seguir" deve alternar estado (Seguir/Seguindo)
   - Cada card de ingresso deve ser clicável para ver detalhes completos

4. ESTADOS DA UI
   - Loading state ao carregar ingressos
   - Empty state caso a vendedora não tenha ingressos disponíveis
   - Error state para falhas de carregamento

5. DESIGN SYSTEM
   - Manter consistência com as telas existentes do app
   - Usar componentes reutilizáveis (cards, botões, badges)
   - Seguir padrões de iOS (SwiftUI ou UIKit conforme projeto)
</requirements>

<critical>
1. SEGURANÇA E VALIDAÇÃO
   - Badge de "Vendedora Certificada" deve ser implementado com lógica de validação robusta
   - Não permitir manipulação manual do status de certificação no client-side
   - A certificação deve vir do backend/dados autenticados

2. SISTEMA DE CERTIFICAÇÃO
   - Criar mecanismo visual CLARO para distinguir vendedoras certificadas
   - Sugestões: ícone de verificação (checkmark), badge colorido, selo especial
   - O indicador deve ser visível mas não invasivo

3. CONTAGEM DE INGRESSOS
   - A contagem de "Ingressos" NÃO é eventos (como aparece na imagem de referência)
   - Deve contar APENAS ingressos com status "available" desta vendedora específica
   - Recalcular dinamicamente se houver mudanças

4. SUBSTITUIÇÕES OBRIGATÓRIAS
   - "Event Organizer" → "Vendedora" (tela de detalhes do evento)
   - "Organizer" → "Vendedora" (título da tela de perfil)
   - "Message" → "Negociar" (botão de ação)
   - "Events" → "Ingressos" (aba de conteúdo)
   - Métrica "Events" → "Ingressos" (estatísticas)

5. DADOS REAIS
   - Usar dados reais dos arquivos JSON fornecidos
   - Não mockar dados que já existem nos arquivos
   - As imagens de referência são apenas GUIA visual, não os dados finais
</critical>

<acceptance_criteria>
✓ A tela exibe corretamente o perfil da vendedora com foto, nome e estatísticas
✓ Badge de certificação aparece apenas para vendedoras certificadas
✓ Contagem de ingressos reflete apenas tickets disponíveis (status: "available")
✓ Lista de ingressos mostra todos os tickets da vendedora filtrados corretamente
✓ Cada card de ingresso exibe: imagem, nome do evento, tipo, preço, data, local
✓ Descontos são visualmente destacados (preço original riscado + preço atual)
✓ Botão "Negociar" está implementado e substituiu "Message"
✓ Botão "Seguir" alterna estados corretamente
✓ Navegação entre abas "Sobre" e "Ingressos" funciona
✓ Estados de loading, empty e error estão implementados
✓ Utilize as imagens em /Assets para preencher as telas de empty tickets.
✓ A navegação volta corretamente para a tela de detalhes do ticket
✓ Design é consistente com o resto do aplicativo
✓ Todos os textos estão em português (exceto quando tecnicamente necessário)
</acceptance_criteria>

<behaviour_details>
1. FLUXO DE NAVEGAÇÃO
   - Usuário está na tela de Detalhes do Ticket
   - Usuário vê card com "Vendedora: [Nome]"
   - Usuário toca no card
   - App navega para tela de Perfil da Vendedora
   - Tela carrega com animação suave
   - Dados são carregados (mostrar loading se necessário)

2. INTERAÇÃO COM BOTÕES
   - Botão "Seguir":
     * Estado inicial: "Seguir" (outline/secundário)
     * Ao tocar: Muda para "Seguindo" (preenchido/primário)
     * Animação de feedback ao tocar
     * Atualiza contador de seguidores
   
   - Botão "Negociar":
     * Sempre visível e destacado (cor primária)
     * Ao tocar: Abre tela/modal de negociação/chat
     * Passa contexto da vendedora e ingresso (se aplicável)

3. LISTA DE INGRESSOS
   - Scroll vertical com cards
   - Cada card é tapável (toca para ver detalhes completos)
   - Ícone de favorito (coração) independente do card
   - Lazy loading se lista for muito grande
   - Pull to refresh para atualizar dados
   - Mostrar indicador "Desconto" ou porcentagem quando aplicável

4. TRATAMENTO DE DADOS
   - Se vendedora não tem ingressos disponíveis:
     * Mostrar empty state com mensagem amigável
     * "Esta vendedora não possui ingressos disponíveis no momento"
     * Ícone ilustrativo
   
   - Se erro ao carregar:
     * Mostrar error state
     * Botão para tentar novamente
     * Mensagem clara do problema

5. INDICADOR DE CERTIFICAÇÃO
   - Para vendedoras certificadas (isCertified: true):
     * Mostrar badge próximo ao nome
     * Ícone de checkmark em círculo colorido
     * Tooltip/hint ao tocar: "Vendedora Verificada"
   
   - Para vendedoras não certificadas:
     * Não mostrar badge
     * Não chamar atenção para ausência

6. PERFORMANCE
   - Carregar imagem de perfil com cache
   - Lazy loading de imagens dos eventos na lista
   - Otimizar lista de ingressos (reuso de células)
   - Debounce em ações de favoritar

7. ACESSIBILIDADE
   - Labels apropriados para VoiceOver
   - Contraste adequado em textos
   - Tamanhos de toque adequados (mínimo 44x44pt)
   - Dynamic Type support
</behaviour_details>