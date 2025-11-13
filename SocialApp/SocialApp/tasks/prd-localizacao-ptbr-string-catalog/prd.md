# PRD - Localização pt-BR via String Catalog

## Contexto
O aplicativo possui strings misturadas em português e inglês, espalhadas pelo código. Não há catálogo de strings centralizado, o que dificulta padronização e futura internacionalização.

## Problema
- Inconsistência linguística (pt e en misturados).
- Dificuldade de manutenção e revisão textual.
- Bloqueio para futura internacionalização (i18n).

## Objetivos
- Centralizar 100% das strings de UI em um String Catalog (.xcstrings).
- Definir pt-BR como idioma base de desenvolvimento.
- Tornar o app pronto para i18n futura, sem alterar funcionalidades.

## Não-objetivos
- Não incluir suporte imediato a outros idiomas além de pt-BR.
- Não alterar textos de domínio/negócio além do necessário para padronização.

## Usuários/Stakeholders
- Usuários finais do app (pt-BR).
- Equipe de desenvolvimento e QA.
- Design/Conteúdo (revisão linguística).

## Métricas de Sucesso
- 0 strings literais de UI remanescentes no código (exceto logs/testes).
- Build sem novos warnings de localização.
- QA visual sem regressões textuais.

## Critérios de Aceite
- Todas as strings de UI referenciadas via `String(localized:)` ou `Text(String(localized:))`.
- `Localizable.xcstrings` criado, incluído no target e com chaves padronizadas.
- pt-BR definido como Development Region e única localização ativa.




