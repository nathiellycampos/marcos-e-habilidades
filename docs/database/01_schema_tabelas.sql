-- ============================================================
-- Marcos e Habilidades — Schema de tabelas (Supabase, schema public)
-- Exportado em 31/08/2026 a partir de information_schema + pg_constraint
-- Projeto Supabase: gcpgjiyfvoxyctjwnttd
-- Reconstrução fiel de colunas, tipos, defaults, PKs, FKs, UNIQUE e CHECK.
-- Não é uma migration executável (ordem de criação simplificada) — serve como
-- referência de estado atual. Para migrations reais, ver 03_migrations_aplicadas.md.
-- ============================================================

create extension if not exists "unaccent";

-- Tabela: filhos
create table public.filhos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  nome text not null,
  data_nascimento date,
  faixa_etaria text,
  competencia_prioritaria_1 text,
  competencia_prioritaria_2 text,
  competencia_prioritaria_3 text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Tabela: habilidades (taxonomia de 1695 micro-habilidades)
create table public.habilidades (
  id bigint primary key,
  habilidade text not null,
  competencia_principal text not null,
  nivel text,
  pilar text,
  o_que_fazer text,
  quando_fazer text,
  passo1 text,
  passo2 text,
  passo3 text,
  competencias_trabalhadas text,
  legenda text,
  faixa_etaria text not null default '13–14 anos',
  imagem_url text,
  ordem_drip integer,
  created_at timestamptz default now(),
  direcionamento_profissional text,
  image_url text  -- URL efetiva usada pelo app (bucket Cards-lote1 no Storage)
);

-- Tabela: habilidades_escolhidas (habilidades que a mãe selecionou p/ o filho)
create table public.habilidades_escolhidas (
  id uuid primary key default gen_random_uuid(),
  filho_id uuid not null references public.filhos(id) on delete cascade,
  habilidade_id bigint not null references public.habilidades(id) on delete cascade,
  criado_em timestamptz not null default now(),
  unique (filho_id, habilidade_id)
);

-- Tabela: registro_habilidade (avaliação de cada habilidade por filho)
create table public.registro_habilidade (
  id uuid primary key default gen_random_uuid(),
  filho_id uuid not null references public.filhos(id) on delete cascade,
  habilidade_id bigint not null references public.habilidades(id) on delete cascade,
  status text not null check (status in ('sempre','quase_sempre','as_vezes','quase_nunca','nunca','nao_iniciada')),
  avaliado_em timestamptz not null default now(),
  origem text not null default 'pai',          -- 'pai' | 'filho'
  revisado boolean not null default true,
  status_mae text,                              -- opinião da mãe quando diverge da do filho
  precisa_conversar boolean not null default false,
  unique (filho_id, habilidade_id)
);

-- === Gamificação ===

create table public.gamificacao_config (
  filho_id uuid not null references public.filhos(id) on delete cascade,
  ofensiva_dias integer not null check (ofensiva_dias in (7,21,60,90)),
  habilitada boolean not null default true,
  pontos integer not null,
  minimo_habilidades_dia integer not null,
  primary key (filho_id, ofensiva_dias)
);

create table public.gamificacao_streaks (
  filho_id uuid not null references public.filhos(id) on delete cascade,
  ofensiva_dias integer not null check (ofensiva_dias in (7,21,60,90)),
  dias_consecutivos integer not null default 0,
  ultima_data_contada date,
  vezes_concluida integer not null default 0,
  primary key (filho_id, ofensiva_dias)
);

create table public.gamificacao_atividade_diaria (
  filho_id uuid not null references public.filhos(id) on delete cascade,
  data date not null,
  quantidade integer not null default 0,
  primary key (filho_id, data)
);

create table public.gamificacao_avaliacoes_dia (
  filho_id uuid not null references public.filhos(id) on delete cascade,
  habilidade_id bigint not null,
  data date not null,
  primary key (filho_id, habilidade_id, data)
);

create table public.gamificacao_pontos_ledger (
  id uuid primary key default gen_random_uuid(),
  filho_id uuid not null references public.filhos(id) on delete cascade,
  pontos integer not null,
  motivo text not null,
  criado_em timestamptz not null default now()
);

create table public.gamificacao_recompensas (
  id uuid primary key default gen_random_uuid(),
  filho_id uuid not null references public.filhos(id) on delete cascade,
  nome text not null,
  comentario text,
  pontos_necessarios integer,
  origem text not null check (origem in ('sugerida_padrao','mae','filho')),
  status text not null check (status in ('pendente_aprovacao','disponivel','rejeitada')),
  criado_em timestamptz not null default now()
);

create table public.gamificacao_resgates (
  id uuid primary key default gen_random_uuid(),
  recompensa_id uuid not null references public.gamificacao_recompensas(id) on delete cascade,
  filho_id uuid not null references public.filhos(id) on delete cascade,
  pontos_gastos integer not null,
  liberada_em timestamptz not null default now()
);

-- Trigger: bônus inicial de 10 pontos ao cadastrar um filho
-- (função gamificacao_conceder_bonus_inicial em 02_funcoes_rpc.sql)
-- create trigger trg_gamificacao_bonus_inicial
--   after insert on public.filhos
--   for each row execute function public.gamificacao_conceder_bonus_inicial();
