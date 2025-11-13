# Diretrizes de Localização (pt-BR + String Catalog)

## Objetivo
Padronizar todo texto de UI via String Catalog (`Localizable.xcstrings`) com idioma base pt-BR, facilitando manutenção e futura internacionalização.

## Como usar no código
- Textos simples:
  - `Text(String(localized: "chave.dot.case"))`
  - `Button(String(localized: "chave.dot.case")) { ... }`
- Placeholders:
  - `TextField(String(localized: "login.email.placeholder"), text: $email)`
- Títulos:
  - `.navigationTitle(String(localized: "events.search.title"))`
- Alertas:
  - `.alert(String(localized: "common.error.title"), isPresented: ...) { ... }`
- Interpolação:
  - Use formatação padrão com `String(format: String(localized: "emailverify.subtitle"), email)`
- Pluralização simples:
  - Quando necessário, use chaves distintas para singular e plural (ex.: `tickets.units.single` / `tickets.units.plural`).

## Convenções de chaves
- Formato: dot-case, sem acentos. Ex.: `login.title`, `common.buttons.continue`.
- Domínios:
  - `common.*`, `login.*`, `events.*`, `tickets.*`, `negotiations.*`, `profile.*`, `commons.*`.
- Evite textos longos como chave; chaves devem ser estáveis e semânticas.

## Adicionando novas strings
1. Adicione a entrada no `SocialApp/Resources/Localizable.xcstrings`.
2. Use a chave no código com `String(localized:)`.
3. Para variáveis, use `String(format: ...)` com placeholders `%@`, `%d`, etc.

## Boas práticas
- Não deixe strings literais de UI no código.
- Não traduza nomes próprios/marcas (ex.: `brand.name` = SocialClub).
- Prefira chaves reutilizáveis para botões comuns (ex.: `common.back`, `common.save`).

## QA
- Verifique que não há strings em inglês visíveis.
- Teste variações de tamanho de texto e quebras de linha.





