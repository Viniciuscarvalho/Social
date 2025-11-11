# Convenções de Chaves de Localização

- Formato: dot-case, estável e sem acentos. Ex.: `login.title`, `common.buttons.continue`, `events.search.placeholder`.
- Organização por domínio:
  - `common.*` para botões, estados genéricos, mensagens universais.
  - `login.*`, `events.*`, `tickets.*`, `negotiations.*`, `profile.*`, etc.
- Evitar valores embutidos em código: use sempre `String(localized:)`.
- Interpolação/plural: definir variáveis e regras no `.xcstrings`.
- Manter chaves curtas e semânticas; evite textos completos nas chaves.

