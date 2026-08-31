# Marcos e Habilidades

App PWA de desenvolvimento infantojuvenil (React + Vite + Supabase + Cloudflare Workers), com landing page de vendas via Hotmart.

## ⚠️ Aviso importante — código-fonte

A pasta `src/` (código React componentizado, editável) **foi perdida** em uma sessão anterior de desenvolvimento. Só sobreviveu o bundle já compilado (`dist/index.html`, single-file, minificado).

Desde então, **toda mudança no app é feita editando o bundle minificado diretamente**, com validação de sintaxe (`node --check`) antes de cada deploy. Funciona, mas é mais lento e arriscado que editar código-fonte normal e rodar `npm run build`:
- Não há componentes, não há hot-reload.
- Edições são operações de find-and-replace por string exata num arquivo gigante.
- Classes CSS (Tailwind) que não existiam no build original **não têm efeito nenhum** se adicionadas via HTML (o CSS já vem compilado e não é regerado) — por isso, todo ajuste visual novo usa estilo inline.

**Prioridade para próxima fase do projeto:** reconstruir o projeto-fonte completo (`src/`, `package.json`, `vite.config.js`) numa sessão dedicada e versionar aqui, para eliminar essa fragilidade.

Detalhes registrados em `docs/historico/`.

## Estrutura do repositório

```
app/                  → build compilado mais recente do app (dist61), pronto pra deploy no Cloudflare Workers
landing-page/         → página de vendas (Hotmart), HTML single-file
docs/projeto/         → documentação de referência: arquitetura, requisitos, regras de negócio,
                         visão de produto "Skill Lab" (não implementada), Projeto Skill Lab v2 (documento consolidado)
docs/database/        → schema do Supabase: tabelas, funções RPC, histórico de migrations
docs/historico/       → registros de sessões de desenvolvimento anteriores (troubleshooting, decisões técnicas)
```

## Deploy

**App:** Cloudflare Workers → worker `marcos-e-habilidades` → "Upload static files" → arrastar o conteúdo de `app/` por cima do deploy anterior (`index.html`, `favicon.ico`, `favicon.png`, `manifest.json`, `sw.js`, pasta `icons/`).

**Landing page:** publicada em WordPress (`nathycampos.com.br/appmarcosehabilidades/`). **Colar sempre em um bloco Custom HTML** — nunca em bloco de texto/parágrafo, pois o filtro `wptexturize` do WordPress corrompe aspas dentro de `<script>` em blocos de texto normais, quebrando o JavaScript da página.

**Banco de dados:** Supabase, projeto `gcpgjiyfvoxyctjwnttd`. Ver `docs/database/03_migrations_aplicadas.md` para o histórico e `01_schema_tabelas.sql` / `02_funcoes_rpc.sql` para o snapshot atual do schema.

## Documento de referência principal

`docs/projeto/Projeto_Skill_Lab_v2.docx` — visão geral do produto, requisitos de sistema e técnicos, regras de negócio, modelo entidade-relacionamento (com diagrama visual), diagrama de arquitetura/componentes, o que já foi implementado, o que falta, e decisões pendentes já resolvidas com a Nathy.

## Pendência conhecida — Storage

333 imagens de cards foram enviadas por engano para o bucket `cards` (não usado pelo app). O bucket correto, referenciado por `habilidades.image_url`, é `Cards-lote1`. Essas imagens precisam ser movidas/reenviadas para o bucket correto.
