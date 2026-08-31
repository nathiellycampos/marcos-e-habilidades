# Prompt de Engenharia — MVP App do Filho ("Planeta de Treino")

## Contexto (não reconstruir do zero)

Já existe um protótipo funcional do app do filho ("Planeta de Treino") rodando sobre a mesma infraestrutura do app "Marcos e Habilidades" (mãe):

- **Backend:** Supabase (Postgres). Tabelas existentes: `filhos`, `habilidades_escolhidas`, `registro_habilidade`. FKs de `registro_habilidade` e `habilidades_escolhidas` para `filhos` já têm `ON DELETE CASCADE`.
- **Deploy:** Cloudflare Workers, build single-file (`dist/index.html`), publicado em `marcos-e-habilidades.nathielly.workers.dev`.
- **Telas já existentes no protótipo do filho:** "Missões do Dia" (lista de habilidades pendentes com botão "Iniciar Missão"), tela de execução de missão com 3 formatos de evidência (Diário de Texto, Lousa Mágica/desenho, Foto do Dia), botão "Enviar para aprovação da Mamãe", contador de moedas no header, "Loja de Prêmios" (cards de prêmio com custo em coins e status "Resgatado: Nx" / "Falta N Coins").

Use essa base. O trabalho aqui é especificar o que falta para virar MVP completo e consistente com o app da mãe.

## Objetivo

Filho acessa **duas fontes de atividade**: as habilidades que a mãe selecionou (`habilidades_escolhidas`, pontuais) e os deveres que a mãe cadastrou (`deveres`, recorrentes diários — ver prompt de melhorias do app da mãe). Executa a atividade, anexa evidência, e o registro fica **pendente de aprovação da mãe**. Pontos só são creditados após aprovação — nunca no envio.

## Regras de negócio obrigatórias

1. **Fonte das atividades — duas listas unificadas na mesma tela:**
   - Habilidades: de `habilidades_escolhidas` do `filho_id` logado, cruzando com `registro_habilidade` para status.
   - Deveres: de `deveres` ativos do `filho_id` logado — **gera uma instância nova todo dia** (ex. via `deveres_do_dia`, ver modelo abaixo), independente de aprovação do dia anterior.
2. **Evidência é obrigatória para pontuar.** Sem evidência anexada, o envio não gera pontos nem muda status para aprovação — trava no client e valida no server (RLS/constraint).
3. **Tipos de evidência aceitos:**
   - Texto (Diário de Texto) — direto no banco.
   - Desenho (Lousa Mágica) — captura como imagem, mesmo pipeline de upload de foto.
   - Foto — upload de arquivo para Supabase Storage (bucket dedicado, ex. `evidencias`).
   - Vídeo e áudio — **não temos upload de mídia pesada.** Filho cola um **link** (YouTube não listado, Google Drive, WhatsApp status, etc.) num campo de texto com validação simples de URL. Não fazer upload de binário de vídeo/áudio no MVP.
4. **Pontos são creditados só na aprovação**, feita no Painel da Mãe. Status do registro segue o fluxo: `nao_iniciada` → `pendente_aprovacao` → `aprovada` (credita pontos) ou `reprovada` (sem pontos, filho pode reenviar).
5. **Pontuação é calculada automaticamente, não definida manualmente pela mãe** (ver regra completa e tabela de referência no prompt de melhorias do app da mãe):
   - **Pontos-base da atividade:** 2 pontos se a habilidade for de um pilar/nível específico (ex. P1/N2, P1/N4 — lista a confirmar), 1 ponto para os demais pilares/níveis e para deveres.
   - **Bônus por tipo de evidência:** Texto = 3, Desenho = 3, Foto = 5, Áudio = 7, Vídeo do próprio filho = 10.
   - **Total creditado = pontos-base + bônus da evidência.** O app do filho só exibe o resultado do cálculo (feito no server/Supabase, nunca no client), nunca deixa o filho escolher ou editar o valor.
6. **Loja de Prêmios:** resgate desconta pontos do saldo do filho, gera um registro de resgate (`resgates_premio`) com status `solicitado` → a mãe confirma entrega no painel dela (evita o filho "gastar" pontos que a mãe não vai efetivamente entregar sem saber). Se preferir fluxo mais simples para o MVP: resgate imediato, desconta na hora, e a mãe só visualiza o histórico — decidir isso é o único ponto que vale confirmar com a Nathy antes de implementar, o resto pode seguir direto.

## Modelo de dados — o que falta

```sql
-- Instância diária de um devir (novo) — gerada automaticamente todo dia para cada devir ativo do filho
create table deveres_do_dia (
  id uuid primary key default gen_random_uuid(),
  devir_id uuid references deveres(id) on delete cascade,
  filho_id uuid references filhos(id) on delete cascade,
  data date not null default current_date,
  status_aprovacao text check (status_aprovacao in ('pendente_aprovacao','aprovada','reprovada')) default null,
  pontos_creditados integer,
  criado_em timestamptz default now(),
  unique (devir_id, data)
);

-- Evidências (novo) — aponta para UM dos dois tipos de atividade, nunca os dois
create table evidencias (
  id uuid primary key default gen_random_uuid(),
  registro_habilidade_id uuid references registro_habilidade(id) on delete cascade,
  devir_do_dia_id uuid references deveres_do_dia(id) on delete cascade,
  tipo text check (tipo in ('texto','desenho','foto','video_link','audio_link')) not null,
  conteudo_texto text,          -- para tipo = texto
  arquivo_url text,             -- para tipo = desenho/foto (Supabase Storage)
  link_externo text,            -- para tipo = video_link/audio_link
  criado_em timestamptz default now(),
  check (
    (registro_habilidade_id is not null and devir_do_dia_id is null) or
    (registro_habilidade_id is null and devir_do_dia_id is not null)
  )
);

-- Status de aprovação em registro_habilidade (ajustar constraint existente)
alter table registro_habilidade
  add column status_aprovacao text check (status_aprovacao in ('pendente_aprovacao','aprovada','reprovada')) default null,
  add column pontos_creditados integer;

-- Saldo e histórico de pontos/coins (novo)
create table transacoes_coins (
  id uuid primary key default gen_random_uuid(),
  filho_id uuid references filhos(id) on delete cascade,
  quantidade integer not null,       -- positivo = ganho, negativo = resgate
  origem text check (origem in ('habilidade_aprovada','devir_aprovado','resgate_premio')) not null,
  referencia_id uuid,                -- registro_habilidade_id, devir_do_dia_id ou resgate_id
  criado_em timestamptz default now()
);
-- saldo do filho = sum(quantidade) por filho_id (view ou cálculo no client)
-- pontos creditados em cada aprovação = pontos_base (pilar/nível ou devir) + bônus da evidência (ver prompt do app da mãe)
```

## Telas / fluxos a implementar

1. **Login/seleção do filho** (se ainda não existir): acesso simplificado, sem senha complexa — é uso doméstico com supervisão da mãe.
2. **Atividades do Dia:** já existe como "Missões do Dia". Ajustar para puxar de **duas fontes**: `habilidades_escolhidas` (pontual) e `deveres_do_dia` (recorrente, uma instância nova por dia). Exibir na mesma lista, sem necessariamente distinguir visualmente a origem — para o filho é só "atividade de hoje".
3. **Execução de atividade:** já existe (3 tipos de evidência). Adicionar campo de link para vídeo/áudio como 4º tipo, com texto claro: "Grave um vídeo ou áudio e cole o link aqui (YouTube, Drive, WhatsApp)". Mostrar o total de pontos possível antes de enviar (pontos-base da atividade + bônus do tipo de evidência selecionado, calculado em tempo real conforme o filho escolhe o tipo).
4. **Estado pós-envio:** trocar "Iniciar Missão" por badge "Aguardando aprovação da mamãe" — filho não pode reenviar a mesma atividade enquanto está pendente.
5. **Saldo de pontos:** manter no header. Criar uma aba simples "Meu Progresso" com total de atividades aprovadas e pontos acumulados no tempo (gamificação básica, sem gráfico sofisticado).
6. **Loja de Prêmios:** já existe visualmente. Conectar ao saldo real (`transacoes_coins`) em vez de mock. Bloquear resgate se saldo insuficiente (já há esse estado visual: "Falta N Coins").

## Fora de escopo do MVP (não implementar agora)

- Upload de arquivos de vídeo/áudio no próprio app.
- Notificações push.
- Multi-filho no mesmo login (cada filho já tem acesso individual).
- Login social.

## Critério de aceite

- Filho só vê habilidades escolhidas pela mãe e deveres ativos cadastrados para ele.
- Devir aparece na lista todo dia enquanto ativo, gerando uma instância nova em `deveres_do_dia`.
- Envio sem evidência é bloqueado no client e no server.
- Pontuação creditada bate exatamente com pontos-base + bônus do tipo de evidência, calculada no server.
- Pontos só aparecem no saldo após a mãe aprovar no painel dela.
- Resgate na Loja de Prêmios desconta corretamente e fica visível no histórico da mãe.
