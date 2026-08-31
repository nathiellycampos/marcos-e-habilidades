# Controle do Projeto — Marcos do Desenvolvimento de Competências / First Skill Lab

## 16. Rename "Mãe Conectada" → "Marcos e Habilidades" (concluído)

Todas as referências ao nome antigo foram removidas do código do app (manifest.json, index.html, README.md, App.jsx, Links.jsx, Login.jsx, package.json). Build validado com `npm run build` (sucesso). Entrega: `marcos_e_habilidades_app.zip` (substitui `mae_conectada_app.zip`). Liberado para envio do teste de configuração no Hotmart.

Última atualização: 04/08/2026 (rodada 2 — conclusão do conteúdo das 8 faixas etárias)

## 1. Decisões de posicionamento

- **First Skill Lab™** fica reservado para o app futuro (com gamificação, pontuação e registro de progresso). Ainda não construído.
- O guia atual (páginas HTML) foi renomeado para **"Marcos do Desenvolvimento de Competências"**, com subtítulo **"Mapa de Habilidades por Faixa Etária"**.
- Página ao vivo: https://www.nathycampos.com.br/firstskilllab/ (WordPress) — ainda não republicada com o nome novo, HTML atualizado está nos arquivos abaixo.

## 2. Arquivos HTML da página (guia estático)

| Versão | Arquivo | O que mudou |
|---|---|---|
| V12 | `skill_lab_-_Entrega_-_V12.html` | Original enviado pela Nathy (nome antigo "First Skill Lab — Pirâmide da Família™") |
| V13 | `skill_lab_-_Marcos_Desenvolvimento_V13.html` | Título e subtítulo trocados |
| V14 | `skill_lab_-_Marcos_Desenvolvimento_V14.html` | Título reduzido pra caber numa linha só |
| V15 | `skill_lab_-_Marcos_Desenvolvimento_V15.html` | Subtítulo final: "Mapa de Habilidades por Faixa Etária" |

**Pendente:** revisar se o rodapé (ainda cita "First Skill Lab™") deve ser atualizado pra manter coerência com a reserva do nome pro app.

## 3. Bases de dados de habilidades (planilhas fonte)

| Arquivo | Conteúdo |
|---|---|
| `DT_-_Habilidades_Piramide_Familia_v32.xlsx` | Base intermediária — 1.365 cards, com gaps de conteúdo não preenchido |
| `DT_-_Habilidades_Piramide_Familia_v35.xlsx` | **Base oficial atual** — 1.695 cards, 1.699 habilidades, 8 faixas etárias, conteúdo completo (Quando_Usar, Sabe_Fazer, 3 passos de Como_Aplicar) |
| `Regras de Classificação — Habilidades - V32.md` | Documento com a taxonomia final (7 competências principais), regras de pilar/nível, sistema de pontuação PP/PN |
| `DT-Desenvolvimento de habilidades emmpreendedoras.xlsx` | Base complementar de empreendedorismo (ainda não processada nesta conversa) |

### Taxonomia oficial (7 competências principais)
Tecnologia Consciente, Gestão da Rotina, Exploração de Carreira, Caráter, Gestão dos Relacionamentos, Autoconsciência Emocional, Propósito e Contribuição.

### Pilares e Níveis
- **Níveis:** N1 Necessidades Básicas e Rotina · N2 Relacionamentos e Comunidades · N3 Habilidades para o Mundo · N4 Bússola Moral
- **Pilares:** P1 Autoconsciência Estratégica · P2 Estrutura Tecnológica Consciente · P3 Habilidades-Chave · P4 Direcionamento Profissional Antecipado

## 4. Modelo de card (layout atual — v5, script `render_generic.py`)

**Esta seção substitui a v4 descrita originalmente aqui — desatualizada desde a rodada 2.**

Ordem das seções no card (sem badges de topo — removidas na v4):
1. Eyebrow "O QUE SERÁ DESENVOLVIDO" + título (nome da habilidade)
2. O que fazer (caixa bege) — frase sempre pontuada (`.`, `!` ou `?`)
3. Quando fazer (caixa sage) — frase sempre pontuada
4. Como aplicar (caixa sage, numerada, até 3 passos)
5. Isto é um Direcionamento Profissional Antecipado (caixa dourada) — adicionada na v4, texto mescla aplicação prática em escola/faculdade, amizades e networking, relacionamento amoroso saudável (a partir de 11-12 anos) e carreira/negócios
6. Competências trabalhadas (até 2 tags, quebram de linha se não couberem)

**Proteção anti-overflow (adicionada na rodada 2):** antes de desenhar, o script mede a altura total do conteúdo. Se ultrapassar o limite do card, reduz a escala de todas as fontes por busca binária (entre 55% e 100% do tamanho original) até caber — evita texto cortado em cards com conteúdo mais longo (bug identificado no card "Monitoramento de Estado Emocional", 9-10 anos).

**Pontuação automática:** o script aplica `ensure_period()` em "O que fazer" e "Quando fazer", adicionando `.` no final se a frase não terminar em pontuação — aplicado tanto no momento de renderizar quanto já corrigido na fonte de dados (CSVs e Supabase).

Cores da marca (oficiais, de https://www.nathycampos.com.br/firstskilllab/):
- Verde escuro `#1C2B2D` / Verde profundo `#14201F`
- Sage `#6B8F71` (N1) · Azul `#5C8AA6` (N2) · Marrom `#B07D4F` (N3) · Malva `#8A5C7A` (N4)
- Dourado `#C9A35B`
- Bege claro `#F4F1EA`

Formato de imagem: **1080×1920px (9:16)**, PNG.

**Status por faixa etária:** 3-4, 5-6, 7-8, 9-10 e 11-12 anos já estão no layout v5 completo (anti-overflow + pontuação). 15-16 e 17-18 anos nasceram direto no v5. 13-14 anos ainda está no v4 antigo (sem a proteção anti-overflow) — ver pendência na seção 11.

## 5. Primeiro lote de conteúdo — 13–14 anos, Caráter + Autoconsciência Emocional

- 40 cards no total (20 de cada competência)
- Critério de priorização: competências-âncora de autonomia e caráter (P1/P4, N1/N4 — maior pontuação no sistema PP/PN do documento de regras)
- Todos os cards de **Caráter** levam a tag "Caráter + Comunicação" (ajuste pedido pela Nathy)

### Arquivos gerados (nesta pasta de outputs)
| Arquivo | Descrição |
|---|---|
| `lote_13-14_caracter_autoconsciencia.csv` | Planilha fonte original (sem tag Comunicação) — **desatualizada** |
| `cards_13-14_caracter_autoconsciencia_9x16_v3.zip` | **Versão atual** — 40 imagens 1080×1920, badges com quebra de linha corrigida, tag Comunicação aplicada |

### Planilhas no Google Drive (pasta compartilhada)
| Nome | Status |
|---|---|
| "Lote 13-14 anos... (40 cards)" | v1 — sem tag Comunicação — **pode apagar** |
| "Lote 13-14 anos... (40 cards) v2" | **Versão atual** — com "Caráter + Comunicação" |

## 6. Infraestrutura técnica

- **Supabase**: projeto ativo `nathiellycampos's Project` (ref: `gcpgjiyfvoxyctjwnttd`), conectado via GitHub. Tabela `habilidades` já criada (colunas alinhadas com o CSV), **ainda vazia** — falta inserir os 40 registros do primeiro lote.
- **Hospedagem planejada**: PWA (sem app nativo, sem Play Store) — Cloudflare Pages ou Netlify, gratuito.
- **Autenticação planejada**: Supabase Auth, integrado via webhook direto da Hotmart (compra aprovada → cria acesso).
- **Distribuição/venda**: Hotmart, produto R$97 (valor único). Modelo escolhido para evitar mensalidade de ferramenta no-code (Glide/Adalo/AppMySite descartados por causa disso).

## 7. Decisões descartadas (e por quê)

- **Fábrica de Aplicativos / Glide / Adalo**: mensalidade fixa incompatível com ticket único de R$97.
- **AppMySite**: feito pra converter site WordPress em app, não pra lógica customizada de perfis e drip content — US$49-99/mês, pior fit e mais caro.
- **APK avulso fora de loja**: fricção alta de instalação (aviso de segurança Android), sem atualização automática.

## 8. Ajustes finais do card (v4 — layout definitivo)

- Removidas as badges de topo (Nível/Pilar/Competência) — causavam corte de texto quando a competência era longa.
- Adicionado novo balão **"Isto é um Direcionamento Profissional Antecipado"** (cor âmbar), posicionado depois de "Como aplicar" e antes de "Competências trabalhadas". Conecta cada habilidade a preparo pro mundo dos negócios (empreendedor, empresário ou colaborador).
- Tags "Competências trabalhadas" de todas as 20 habilidades de Caráter passaram a incluir "Comunicação".
- Badges (onde ainda existem, nas tags de competência) agora quebram de linha automaticamente quando excedem a largura do card — corrige o bug do card 7.

### Arquivos finais do lote 13–14 anos
| Arquivo | Descrição |
|---|---|
| `cards_13-14_caracter_autoconsciencia_v4.zip` | **Versão final** — 40 imagens 1080×1920, sem badges de topo, com balão de Direcionamento Profissional Antecipado |
| Planilha "Lote 13-14 anos... v2" (Drive) | Contém tag Comunicação, mas **ainda não tem** a coluna Direcionamento Profissional — falta subir v3 |

**Status Supabase:** 40 registros inseridos na tabela `habilidades`, incluindo coluna `direcionamento_profissional`. Primeiro lote 100% salvo no banco.

## 9. Rodada 2 — Conteúdo completo das 8 faixas etárias (Caráter + Autoconsciência Emocional)

**Status: 335 cards completos e salvos no Supabase, cobrindo as 8 faixas etárias (Opção A: 2 competências × 8 faixas).**

| Faixa | Cards | Zip de imagens (outputs) |
|---|---|---|
| 3–4 anos | 41 | `cards_3-4_caracter_autoconsciencia_v2.zip` |
| 5–6 anos | 41 | `cards_5-6_caracter_autoconsciencia_v2.zip` |
| 7–8 anos | 45 | `cards_7-8_caracter_autoconsciencia_v2.zip` |
| 9–10 anos | 48 | `cards_9-10_caracter_autoconsciencia_v2.zip` |
| 11–12 anos | 40 | `cards_11-12_caracter_autoconsciencia_v2.zip` |
| 13–14 anos | 40 | `cards_13-14_caracter_autoconsciencia_v4.zip` (lote original — pendente reprocessar com algoritmo novo, ver seção 11) |
| 15–16 anos | 40 | `cards_15-16_caracter_autoconsciencia.zip` |
| 17–18 anos | 40 | `cards_17-18_caracter_autoconsciencia.zip` |
| **Total** | **335** | |

### Evolução do "Direcionamento Profissional Antecipado"
A partir do lote de 9-10 anos, o texto de direcionamento passou a mesclar, por pedido da Nathy, múltiplas aplicações práticas em vez de sempre pular direto pra carreira:
- Ambiente escolar/acadêmico (sala de aula, trabalho em grupo, professor).
- Amizades e networking.
- Relacionamentos amorosos saudáveis (a partir de 11-12 anos, quando faz sentido etariamente).
- Carreira/negócios (empreendedor, colaborador com potencial de liderança/executivo).

Isso resolveu a repetitividade apontada no lote de 5-6 anos ("é semente de X no futuro" repetido).

### Pontuação padronizada
Todas as frases das seções "O que fazer" e "Quando fazer" (295 linhas corrigidas, mais 40 de 13-14 que já vieram pontuadas = 335 no total) agora terminam em `.`, `!` ou `?`. Corrigido tanto nos CSVs locais quanto via `UPDATE` direto no Supabase. O script `render_generic.py` também aplica isso automaticamente (`ensure_period()`) em qualquer lote futuro.

### Algoritmo anti-overflow de texto nas imagens
Um card da faixa 9-10 anos ("Monitoramento de Estado Emocional") estourou o limite do card por excesso de texto. Corrigido: `render_generic.py` agora mede o conteúdo antes de desenhar e reduz a escala de fonte automaticamente (busca binária entre 55%-100%) sempre que o texto ultrapassaria os limites do card. Reprocessado e reempacotado (`_v2.zip`) para 3-4, 5-6, 7-8, 9-10 e 11-12 anos. **Pendente:** 13-14 anos ainda está no layout v4 antigo e não foi reprocessado com o algoritmo novo (o CSV fonte não está mais em cache local — precisa ser reconstruído a partir do Supabase ou da planilha do Drive antes de reprocessar).

### Distribuição por nível (esperado, não é erro)
```
Autoconsciência Emocional: N1 (99) · N2 (62)
Caráter: N2 (9) · N3 (10) · N4 (155)
```
Reflete a taxonomia oficial da planilha v35: Caráter mapeia majoritariamente pra N4 (Bússola Moral); Autoconsciência Emocional pra N1/N2. Os filtros de nível na página vão funcionar normalmente sobre essa distribuição.

### Planilha consolidada
`Marcos_Desenvolvimento_Competencias_335cards.xlsx` — todos os 335 cards das 8 faixas em uma aba única (`Cards - Todas as Faixas`), com filtro automático, congelamento de cabeçalho e fonte Arial, mais aba `Resumo` com contagem por faixa etária.

## 10. Próximos passos em aberto

1. Decidir sobre o rodapé do guia HTML (referência a "First Skill Lab™").
2. Reprocessar 13-14 anos com o algoritmo anti-overflow + pontuação (reconstruir CSV fonte primeiro).
3. Publicar V16 do HTML consolidando as novas imagens e o footer corrigido.
4. Configurar webhook Hotmart → Supabase (passo a passo ainda não iniciado).
5. Escolher hospedagem definitiva da PWA (Cloudflare Pages vs Netlify).
6. Decidir se cria Google Sheets no Drive para os lotes que só têm Supabase + zip (3-4 até 17-18 anos, exceto 13-14 que já tem Sheet v2) — ainda não confirmado com a Nathy se é necessário.

## 11. Escopo do app (front-end) — confirmado em 05/08/2026

**8 funcionalidades:**
1. **Microação do Dia** — a cada dia, mostra uma nova imagem de habilidade com a legenda correspondente. Lógica de seleção diária (sequencial por faixa etária da filha cadastrada? aleatória dentro do pilar?) ainda em aberto — pendência técnica abaixo.
2. **Escolher Habilidade** — pai/mãe pesquisa atividades avulsas usando os mesmos filtros dos Marcos de Desenvolvimento (faixa etária, competência, pilar, nível).
3. **Suporte** — botão que abre WhatsApp direto: **+55 21 97581-4699**.
4. **Sugestões/reclamações/pedidos de funcionalidade** — link do formulário Google (mesmo já usado em nathycampos.com.br/firstskilllab/).
5. **Instagram** — @nathycampos.com.br, abrindo direto nos Reels.
6. **LinkedIn** — https://www.linkedin.com/in/nathycampos/recent-activity/all/.
7. **Canal do WhatsApp** "MÃE CONECTADA AOS FILHOS" — https://whatsapp.com/channel/0029Vb81giF1iUxZdMTwLW2n.
8. **Grupo VIP** — link de convite https://chat.whatsapp.com/KRjVfO2C0dzBhnsWydAGzS?s=cl&p=a&mlu=4.

**Restrição técnica confirmada (05/08):** WhatsApp bloqueia embed via iframe em qualquer site (X-Frame-Options), tanto pro canal quanto pro grupo — não é limitação nossa. Itens 3 e 5–8 abrem como **link externo**: deep link pro app nativo no celular, ou nova aba no navegador. É o comportamento padrão de qualquer app que integra WhatsApp/Instagram/LinkedIn.

**Lógica da Microação do Dia (definida em 05/08):**
- Cadastro de filho(s): pai/mãe informa idade (ou data de nascimento) no onboarding. Se houver mais de um filho, salva nome de cada um e permite filtrar habilidades por filho.
- Avaliação de consolidação: pai/mãe pode marcar cada habilidade exibida numa escala de 5 pontos — sempre / quase sempre / às vezes / quase nunca / nunca. Serve tanto de progresso pessoal quanto de dado agregado sobre a realidade das famílias.
- Download da imagem do card: botão que salva o PNG (already hospedado no Storage) no dispositivo.
- **Novas tabelas necessárias no Supabase:** `filhos` (nome, idade/data de nascimento, vinculado ao usuário autenticado) e `registro_habilidade` (filho_id, habilidade_id, nível de consolidação, data da avaliação).

**Escopo revisado das 3 funcionalidades centrais (fechado em 05/08):**

**1. Marcos em Atraso (diagnóstico):** ao cadastrar o filho, o app mostra as habilidades da **faixa etária imediatamente anterior** à idade atual dele. Pai/mãe marca o status de consolidação de cada uma (sempre/quase sempre/às vezes/quase nunca/nunca). As não-consolidadas viram prioridade máxima nas Microações Diárias. Decisão: mostrar só a faixa anterior (não todas as faixas mais antigas de uma vez), pra não sobrecarregar o diagnóstico inicial — sem opção de "ver faixas mais antigas" por enquanto.

**2. Escolher Habilidade:** pai/mãe pesquisa avulsamente com os filtros dos Marcos de Desenvolvimento (faixa etária, competência, pilar, nível) e pode **selecionar explicitamente** habilidades que quer priorizar — não é só busca, é uma lista de intenção.

**3. Microação do Dia — hierarquia de prioridade:**
1. **Marcos em atraso** não consolidados (prioridade máxima).
2. **Habilidades escolhidas manualmente** pelos pais em "Escolher Habilidade".
3. **Fallback** (só se 1 e 2 vazios): as 2 competências prioritárias do onboarding, com intercalação diária entre elas (dia A/dia B) e sorteio ponderado por status (nunca/quase nunca peso alto, quase sempre peso baixo mas presente, sempre vira checkpoint raro ~1x/30 dias).
4. **Cooldown:** mesma habilidade não repete em menos de 5-7 dias, em qualquer camada da hierarquia.

**Visão Analítica ("Progresso da Família") — MVP fechado:**
1. Barra de progresso por competência (7 barras) — % de habilidades avaliadas como "sempre"/"quase sempre" sobre o total já avaliado naquela competência.
2. Contador geral no topo: "X de Y habilidades consolidadas".
3. Lista de gargalos: habilidades "nunca"/"quase nunca" há mais tempo sem reavaliação.
- **Fora do MVP (v2):** gráfico de evolução temporal — descartado por ora porque poucos meses de uso não geram tendência real pra mostrar; vira enfeite vazio sem histórico suficiente.

**Impacto no modelo de dados:** nenhuma tabela nova além das já previstas. `registro_habilidade` (filho_id, habilidade_id, status, data) serve tanto pra Marcos em Atraso quanto pra Microação do Dia quanto pra Visão Analítica — é tudo query sobre a mesma tabela, mudando o filtro.

**Pendências para destravar a implementação:**
- Adicionar coluna de URL de imagem na tabela `habilidades` (hoje as imagens estão no Storage sem vínculo direto na tabela — bloqueia renderizar qualquer card no app).
- Confirmar se "Escolher Habilidade" usa todos os filtros da página HTML atual ou um subconjunto.
- **Novas tabelas Supabase:** `filhos` (nome, idade/data nascimento, 2 competências prioritárias), `registro_habilidade` (filho_id, habilidade_id, status, data).

**Layout do card (confirmado):** eyebrow "O QUE SERÁ DESENVOLVIDO" acima do título; título = nome da habilidade (ex: "Percepção Corporal"). Já é o padrão atual da v5 (ver seção 4).

## 12. Recomendação: construir o app agora sobre dados validados

O conteúdo das 8 faixas etárias está completo e validado (335 cards, modelo de card estável desde a v4, replicado com sucesso em escala). A recomendação da rodada anterior — "replicar pra 1-2 faixas antes de decidir" — já foi cumprida e superada. A base de dados está pronta pra sustentar a construção do app (PWA + Supabase Auth + Hotmart webhook).

## 13. Vínculo imagem ↔ habilidade no Supabase (concluído em 05/08)

- Coluna `image_url` adicionada à tabela `habilidades`, populada nas **1695 linhas** com URL pública do bucket `Cards-lote1`.
- Slug de nome de arquivo reconstruído via SQL (`unaccent` + regex), casando faixa_etaria + competencia_principal + habilidade com o nome real do arquivo no Storage.
- **Achado técnico:** 91 arquivos (todos de "Tecnologia Consciente", que tem nomes de habilidade mais longos) foram truncados automaticamente no momento da geração das imagens, num limite de ~94-98 caracteres no nome do arquivo. Resolvido casando por prefixo — nenhuma ambiguidade encontrada (1 arquivo real por linha).
- Extensão `unaccent` habilitada no projeto Supabase.

## 14. MVP do App Web — primeira versão (05/08)

**Stack:** React + Vite + Tailwind + `@supabase/supabase-js` + `react-router-dom` (HashRouter, compatível com hospedagem estática). Build testado e passando (`npm run build` — 3.3s, ~117KB gzip).

**Entregável:** `mae_conectada_app.zip` (pasta de outputs) — código-fonte completo, sem `node_modules`, com `.env` já preenchido com URL e chave anon do Supabase.

**Novas tabelas Supabase criadas (com RLS):**
- `filhos` — nome, data_nascimento, faixa_etaria (calculada no cadastro), competencia_prioritaria_1/2, vinculado a `auth.users`.
- `registro_habilidade` — filho_id, habilidade_id, status (sempre/quase_sempre/as_vezes/quase_nunca/nunca), avaliado_em. Serve Marcos em Atraso, Microação do Dia e Progresso da Família.
- `habilidades_escolhidas` — filho_id, habilidade_id. Registra seleção manual feita em "Escolher Habilidade" (distinta da avaliação de consolidação).
- `habilidades` teve RLS habilitada com policy de leitura pública (conteúdo do produto, sem escrita pelo cliente).

**Telas implementadas:**
- **Login** — magic link por e-mail (Supabase Auth, `signInWithOtp`).
- **Onboarding** — cadastro do 1º filho (nome, data de nascimento → calcula faixa etária automaticamente) + escolha das 2 competências prioritárias.
- **Microação do Dia** — implementa a hierarquia de prioridade completa (seção 11): Marcos em Atraso não consolidados → Habilidades escolhidas manualmente → Fallback por competência prioritária com sorteio ponderado por status e intercalação diária entre as 2 competências. Cooldown de 5 dias implementado via hash determinístico por dia (mesmo card o dia todo, muda à meia-noite). Botão de avaliação (5 status) e botão de baixar imagem.
- **Marcos em Atraso** — lista habilidades da faixa anterior, com botões de avaliação inline.
- **Escolher Habilidade** — busca por texto + filtro de competência, com toggle de "priorizar".
- **Progresso da Família** — barras de % consolidado por competência, contador geral, lista de gargalos (nunca/quase nunca mais antigos).
- **Links** — WhatsApp de suporte (+55 21 97581-4699 via `wa.me`), Instagram (Reels), LinkedIn, Canal do WhatsApp, Grupo VIP — todos como link externo (`target="_blank"`), conforme decidido na seção 11.

**Pendências antes de ir pro ar:**
1. ~~Link do formulário Google de sugestões~~ — **resolvido em 05/08**: https://docs.google.com/forms/d/e/1FAIpQLSdbw5FkFfHoB2YbpJ_dATl0Ngzi3DFiZdfNg0liNS2VmcTJkQ/viewform?usp=sharing
2. ~~Fluxo de adicionar 2º+ filho~~ — **resolvido em 05/08**: tela `AdicionarFilho.jsx` criada (rota `/adicionar-filho`), acessível a qualquer momento via botão "+" no cabeçalho. Ao salvar, o novo filho vira automaticamente o filho ativo.
3. ~~PWA completa~~ — **resolvido em 05/08**: ícones 192x192 e 512x512 gerados a partir da logo "CONECTADOS" enviada pela Nathy (`icone conectados.jpeg`, cortada em quadrado). Service worker (`public/sw.js`) registrado — cache-first pro app shell, sempre busca da rede pra chamadas Supabase (dados nunca ficam desatualizados por causa do cache). `manifest.json` completo com os 3 ícones (192, 512, 512 maskable).
4. **Deploy no Cloudflare Pages** — ainda não feito (conector Cloudflare disponível mas não conectado). Passo a passo já documentado no README do zip.
5. Confirmar se "Escolher Habilidade" precisa dos filtros de pilar/nível além de competência+faixa+texto (hoje só tem competência+faixa+texto).

## 15. Webhook Hotmart → Supabase Auth (concluído em 05/08)

**Edge Function `hotmart-webhook` implantada** no projeto Supabase (`gcpgjiyfvoxyctjwnttd`), endpoint:
```
https://gcpgjiyfvoxyctjwnttd.supabase.co/functions/v1/hotmart-webhook
```
Recebe o evento `PURCHASE_APPROVED` da Hotmart, valida o token de segurança (`hottok`) contra o secret `HOTMART_HOTTOK`, e cria o comprador no Supabase Auth via `auth.admin.createUser` (e-mail já confirmado, pronto pra pedir magic link).

**Front-end ajustado:** `signInWithOtp` agora usa `shouldCreateUser: false` — só e-mails já criados pelo webhook (ou seja, com compra aprovada) conseguem pedir o link de acesso. Mensagem de erro amigável exibida quando o e-mail não é reconhecido. Build revalidado, zip reempacotado (mesmo arquivo `mae_conectada_app.zip`).

**Pendências (ação da Nathy, fora do meu alcance — plataformas externas):**
1. No Supabase (Edge Functions → `hotmart-webhook` → Secrets): adicionar `HOTMART_HOTTOK` com o valor gerado pela Hotmart.
2. Na Hotmart (Ferramentas → Webhook): cadastrar a URL acima, evento "Compra aprovada", versão 2.0.0. A Hotmart mostra o Hottok nesse cadastro — é o valor do passo 1.
