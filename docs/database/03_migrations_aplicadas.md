# Migrations aplicadas — Supabase (projeto gcpgjiyfvoxyctjwnttd)

Lista real das migrations já aplicadas no banco de produção, via `list_migrations`. Não são arquivos `.sql` individuais recuperáveis (o histórico de migration files não fica acessível fora do Supabase) — o snapshot completo do schema resultante está em `01_schema_tabelas.sql` e `02_funcoes_rpc.sql`.

| Versão | Nome |
|---|---|
| 20260804192126 | create_habilidades_table |
| 20260804195823 | add_direcionamento_profissional_column |
| 20260805010429 | create_cards_storage_bucket_v2 |
| 20260805041956 | create_filhos_and_registro_habilidade |
| 20260805042200 | create_habilidades_escolhidas |
| 20260806174125 | grant_authenticated_crud_privileges |
| 20260806180101 | add_competencia_prioritaria_3 |
| 20260807001813 | allow_nao_iniciada_status |
| 20260817195214 | create_status_acesso_rpc |
| 20260824132159 | create_autoavaliacao_public_rpcs |
| 20260824133303 | add_autoavaliacao_do_filho |
| 20260824133837 | reconcile_autoavaliacao_rpcs |
| 20260824210916 | add_conversar_com_filho |
| 20260825132950 | extend_autoavaliacao_for_skill_card_v2 |
| 20260825183531 | add_faixa_etaria_to_autoavaliacao_escolhidas |
| 20260825185117 | add_faixa_etaria_to_feedback_and_conversar_rpcs |
| 20260827140835 | gamificacao_schema |
| 20260827140908 | gamificacao_marcar_extension |
| 20260827141020 | gamificacao_rpcs |
| 20260827141055 | gamificacao_seed_recompensas_padrao |
| 20260827194310 | gamificacao_recompensa_editar_excluir |
| 20260827200822 | gamificacao_pontos_por_avaliacao |
| 20260827200957 | gamificacao_bonus_inicial |

## Tabelas confirmadas (schema `public`)
`filhos`, `habilidades` (1695 linhas), `habilidades_escolhidas`, `registro_habilidade`, `gamificacao_config`, `gamificacao_atividade_diaria`, `gamificacao_streaks`, `gamificacao_pontos_ledger`, `gamificacao_recompensas`, `gamificacao_resgates`, `gamificacao_avaliacoes_dia`.

## Storage buckets
- **Cards-lote1** — bucket em uso real, referenciado por `habilidades.image_url` (1734 arquivos em 30/08/2026).
- **cards** — bucket legado, **não referenciado em lugar nenhum do app/banco**. Contém 333 arquivos enviados por engano (deveriam estar em `Cards-lote1`). Ver `docs/historico` para o registro dessa pendência.

## Extensões
`unaccent` — usada para casar nomes de arquivos de imagem com `habilidades.habilidade` ignorando acentuação.
