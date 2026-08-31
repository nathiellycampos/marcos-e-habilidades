-- ============================================================
-- Marcos e Habilidades — Funções RPC (Supabase, schema public)
-- Exportado em 31/08/2026 via pg_get_functiondef, projeto gcpgjiyfvoxyctjwnttd
-- Não inclui as funções internas da extensão unaccent (unaccent, unaccent_init, unaccent_lexize)
-- ============================================================

CREATE OR REPLACE FUNCTION public.autoavaliacao_escolhidas(p_filho_id uuid)
 RETURNS TABLE(habilidade_id bigint, habilidade text, o_que_fazer text, quando_fazer text, image_url text, competencia_principal text, faixa_etaria text)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select h.id, h.habilidade, h.o_que_fazer, h.quando_fazer, h.image_url, h.competencia_principal, h.faixa_etaria
  from habilidades_escolhidas he
  join habilidades h on h.id = he.habilidade_id
  where he.filho_id = p_filho_id;
$function$;

CREATE OR REPLACE FUNCTION public.autoavaliacao_filho_info(p_filho_id uuid)
 RETURNS TABLE(nome text, faixa_etaria text, competencia_prioritaria_1 text, competencia_prioritaria_2 text, competencia_prioritaria_3 text)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select nome, faixa_etaria, competencia_prioritaria_1, competencia_prioritaria_2, competencia_prioritaria_3
  from filhos where id = p_filho_id;
$function$;

CREATE OR REPLACE FUNCTION public.autoavaliacao_marcar(p_filho_id uuid, p_habilidade_id bigint, p_status text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  hoje date := current_date;
  qtd_hoje int;
  tier record;
  minimo_efetivo int;
  pontos_efetivo int;
  habilitada_efetiva boolean;
  novos_dias int;
  ja_pontuada_hoje boolean;
begin
  if not exists (select 1 from filhos where id = p_filho_id) then
    raise exception 'filho nao encontrado';
  end if;
  if p_status is null then
    delete from registro_habilidade where filho_id = p_filho_id and habilidade_id = p_habilidade_id;
    return;
  end if;
  if p_status not in ('nunca','quase_nunca','as_vezes','quase_sempre','sempre') then
    raise exception 'status invalido';
  end if;
  insert into registro_habilidade (filho_id, habilidade_id, status, avaliado_em, origem, revisado)
  values (p_filho_id, p_habilidade_id, p_status, now(), 'filho', false)
  on conflict (filho_id, habilidade_id) do update set status = excluded.status, avaliado_em = excluded.avaliado_em, origem = 'filho', revisado = false;

  -- dedup: só conta/pontua a 1a vez que ESSA habilidade e avaliada NESTE dia
  insert into gamificacao_avaliacoes_dia (filho_id, habilidade_id, data)
  values (p_filho_id, p_habilidade_id, hoje)
  on conflict (filho_id, habilidade_id, data) do nothing;
  ja_pontuada_hoje := not found;

  if not ja_pontuada_hoje then
    insert into gamificacao_atividade_diaria (filho_id, data, quantidade)
    values (p_filho_id, hoje, 1)
    on conflict (filho_id, data) do update set quantidade = gamificacao_atividade_diaria.quantidade + 1
    returning quantidade into qtd_hoje;

    insert into gamificacao_pontos_ledger (filho_id, pontos, motivo)
    values (p_filho_id, 1, 'avaliacao_habilidade');

    for tier in
      select * from (values (7,7,1),(21,21,1),(60,60,2),(90,90,3)) as t(dias, pontos_padrao, minimo_padrao)
    loop
      select coalesce(c.habilitada, true) into habilitada_efetiva
      from (select 1) x
      left join gamificacao_config c on c.filho_id = p_filho_id and c.ofensiva_dias = tier.dias;

      if not habilitada_efetiva then
        continue;
      end if;

      select coalesce(c.minimo_habilidades_dia, tier.minimo_padrao), coalesce(c.pontos, tier.pontos_padrao)
      into minimo_efetivo, pontos_efetivo
      from (select 1) x
      left join gamificacao_config c on c.filho_id = p_filho_id and c.ofensiva_dias = tier.dias;

      insert into gamificacao_streaks (filho_id, ofensiva_dias, dias_consecutivos, ultima_data_contada, vezes_concluida)
      values (p_filho_id, tier.dias, 0, null, 0)
      on conflict (filho_id, ofensiva_dias) do nothing;

      if qtd_hoje >= minimo_efetivo then
        select dias_consecutivos into novos_dias from gamificacao_streaks where filho_id = p_filho_id and ofensiva_dias = tier.dias for update;

        if (select ultima_data_contada from gamificacao_streaks where filho_id = p_filho_id and ofensiva_dias = tier.dias) is distinct from hoje then
          if (select ultima_data_contada from gamificacao_streaks where filho_id = p_filho_id and ofensiva_dias = tier.dias) = hoje - 1 then
            novos_dias := novos_dias + 1;
          else
            novos_dias := 1;
          end if;

          update gamificacao_streaks
          set dias_consecutivos = novos_dias, ultima_data_contada = hoje
          where filho_id = p_filho_id and ofensiva_dias = tier.dias;

          if novos_dias >= tier.dias then
            insert into gamificacao_pontos_ledger (filho_id, pontos, motivo)
            values (p_filho_id, pontos_efetivo, 'ofensiva_' || tier.dias);

            update gamificacao_streaks
            set dias_consecutivos = 0, vezes_concluida = vezes_concluida + 1
            where filho_id = p_filho_id and ofensiva_dias = tier.dias;
          end if;
        end if;
      end if;
    end loop;
  end if;
end;
$function$;

CREATE OR REPLACE FUNCTION public.autoavaliacao_status(p_filho_id uuid)
 RETURNS TABLE(habilidade_id bigint, status text, avaliado_em timestamp with time zone)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select habilidade_id, status, avaliado_em from registro_habilidade where filho_id = p_filho_id;
$function$;

CREATE OR REPLACE FUNCTION public.conversar_com_filho_pendentes(p_filho_id uuid)
 RETURNS TABLE(habilidade_id bigint, habilidade text, competencia_principal text, o_que_fazer text, status text, status_mae text, faixa_etaria text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not exists (select 1 from public.filhos f where f.id = p_filho_id and f.user_id = auth.uid()) then
    raise exception 'acesso negado';
  end if;
  return query
  select h.id, h.habilidade, h.competencia_principal, h.o_que_fazer, r.status, r.status_mae, h.faixa_etaria
  from public.registro_habilidade r
  join public.habilidades h on h.id = r.habilidade_id
  where r.filho_id = p_filho_id and r.precisa_conversar = true;
end;
$function$;

CREATE OR REPLACE FUNCTION public.conversar_com_filho_resolver(p_filho_id uuid, p_habilidade_id bigint, p_status_final text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not exists (select 1 from public.filhos f where f.id = p_filho_id and f.user_id = auth.uid()) then
    raise exception 'acesso negado';
  end if;
  if p_status_final not in ('sempre','quase_sempre','as_vezes','quase_nunca','nunca','nao_iniciada') then
    raise exception 'status invalido';
  end if;
  update public.registro_habilidade
  set status = p_status_final, status_mae = null, precisa_conversar = false, origem = 'pai'
  where filho_id = p_filho_id and habilidade_id = p_habilidade_id;
end;
$function$;

CREATE OR REPLACE FUNCTION public.feedback_filho_discordar(p_filho_id uuid, p_habilidade_id bigint, p_status_mae text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not exists (select 1 from public.filhos f where f.id = p_filho_id and f.user_id = auth.uid()) then
    raise exception 'acesso negado';
  end if;
  if p_status_mae not in ('sempre','quase_sempre','as_vezes','quase_nunca','nunca','nao_iniciada') then
    raise exception 'status invalido';
  end if;
  update public.registro_habilidade
  set status_mae = p_status_mae, precisa_conversar = true, revisado = true
  where filho_id = p_filho_id and habilidade_id = p_habilidade_id;
end;
$function$;

CREATE OR REPLACE FUNCTION public.feedback_filho_pendentes(p_filho_id uuid)
 RETURNS TABLE(habilidade_id bigint, habilidade text, competencia_principal text, o_que_fazer text, status text, faixa_etaria text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not exists (select 1 from public.filhos f where f.id = p_filho_id and f.user_id = auth.uid()) then
    raise exception 'acesso negado';
  end if;
  return query
  select h.id, h.habilidade, h.competencia_principal, h.o_que_fazer, r.status, h.faixa_etaria
  from public.registro_habilidade r
  join public.habilidades h on h.id = r.habilidade_id
  where r.filho_id = p_filho_id and r.origem = 'filho' and r.revisado = false and r.status <> 'nao_iniciada';
end;
$function$;

CREATE OR REPLACE FUNCTION public.feedback_filho_revisar(p_filho_id uuid, p_habilidade_id bigint, p_aprovado boolean)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not exists (select 1 from public.filhos f where f.id = p_filho_id and f.user_id = auth.uid()) then
    raise exception 'acesso negado';
  end if;
  if p_aprovado then
    update public.registro_habilidade set revisado = true where filho_id = p_filho_id and habilidade_id = p_habilidade_id;
  else
    delete from public.registro_habilidade where filho_id = p_filho_id and habilidade_id = p_habilidade_id;
  end if;
end;
$function$;

CREATE OR REPLACE FUNCTION public.gamificacao_conceder_bonus_inicial()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  insert into gamificacao_pontos_ledger (filho_id, pontos, motivo)
  values (new.id, 10, 'bonus_inicial');
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.gamificacao_config_efetiva(p_filho_id uuid)
 RETURNS TABLE(ofensiva_dias integer, habilitada boolean, pontos integer, minimo_habilidades_dia integer, dias_consecutivos integer, vezes_concluida integer)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select t.dias,
    coalesce(c.habilitada, true),
    coalesce(c.pontos, t.pontos_padrao),
    coalesce(c.minimo_habilidades_dia, t.minimo_padrao),
    coalesce(s.dias_consecutivos, 0),
    coalesce(s.vezes_concluida, 0)
  from (values (7,7,1),(21,21,1),(60,60,2),(90,90,3)) as t(dias, pontos_padrao, minimo_padrao)
  left join gamificacao_config c on c.filho_id = p_filho_id and c.ofensiva_dias = t.dias
  left join gamificacao_streaks s on s.filho_id = p_filho_id and s.ofensiva_dias = t.dias
  order by t.dias;
$function$;

CREATE OR REPLACE FUNCTION public.gamificacao_liberar_recompensa(p_filho_id uuid, p_recompensa_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  saldo_atual int;
  custo int;
begin
  if not exists (select 1 from filhos where id = p_filho_id and user_id = auth.uid()) then
    raise exception 'nao autorizado';
  end if;
  select pontos_necessarios into custo from gamificacao_recompensas where id = p_recompensa_id and filho_id = p_filho_id and status = 'disponivel';
  if custo is null then
    raise exception 'recompensa invalida ou indisponivel';
  end if;
  select coalesce(sum(pontos),0) into saldo_atual from gamificacao_pontos_ledger where filho_id = p_filho_id;
  if saldo_atual < custo then
    raise exception 'saldo insuficiente';
  end if;
  insert into gamificacao_pontos_ledger (filho_id, pontos, motivo) values (p_filho_id, -custo, 'resgate:' || p_recompensa_id);
  insert into gamificacao_resgates (recompensa_id, filho_id, pontos_gastos) values (p_recompensa_id, p_filho_id, custo);
end;
$function$;

CREATE OR REPLACE FUNCTION public.gamificacao_recompensa_aprovar(p_filho_id uuid, p_recompensa_id uuid, p_pontos integer)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not exists (select 1 from filhos where id = p_filho_id and user_id = auth.uid()) then
    raise exception 'nao autorizado';
  end if;
  update gamificacao_recompensas set status = 'disponivel', pontos_necessarios = p_pontos
  where id = p_recompensa_id and filho_id = p_filho_id;
end;
$function$;

CREATE OR REPLACE FUNCTION public.gamificacao_recompensa_criar(p_filho_id uuid, p_nome text, p_comentario text, p_pontos integer)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not exists (select 1 from filhos where id = p_filho_id and user_id = auth.uid()) then
    raise exception 'nao autorizado';
  end if;
  insert into gamificacao_recompensas (filho_id, nome, comentario, pontos_necessarios, origem, status)
  values (p_filho_id, p_nome, p_comentario, p_pontos, 'mae', 'disponivel');
end;
$function$;

CREATE OR REPLACE FUNCTION public.gamificacao_recompensa_editar(p_filho_id uuid, p_recompensa_id uuid, p_nome text, p_comentario text, p_pontos integer)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not exists (select 1 from filhos where id = p_filho_id and user_id = auth.uid()) then
    raise exception 'nao autorizado';
  end if;
  update gamificacao_recompensas
  set nome = p_nome, comentario = p_comentario, pontos_necessarios = p_pontos
  where id = p_recompensa_id and filho_id = p_filho_id;
end;
$function$;

CREATE OR REPLACE FUNCTION public.gamificacao_recompensa_excluir(p_filho_id uuid, p_recompensa_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not exists (select 1 from filhos where id = p_filho_id and user_id = auth.uid()) then
    raise exception 'nao autorizado';
  end if;
  delete from gamificacao_recompensas where id = p_recompensa_id and filho_id = p_filho_id;
end;
$function$;

CREATE OR REPLACE FUNCTION public.gamificacao_recompensa_rejeitar(p_filho_id uuid, p_recompensa_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not exists (select 1 from filhos where id = p_filho_id and user_id = auth.uid()) then
    raise exception 'nao autorizado';
  end if;
  update gamificacao_recompensas set status = 'rejeitada'
  where id = p_recompensa_id and filho_id = p_filho_id;
end;
$function$;

CREATE OR REPLACE FUNCTION public.gamificacao_recompensa_sugerir(p_filho_id uuid, p_nome text, p_comentario text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not exists (select 1 from filhos where id = p_filho_id) then
    raise exception 'filho nao encontrado';
  end if;
  insert into gamificacao_recompensas (filho_id, nome, comentario, pontos_necessarios, origem, status)
  values (p_filho_id, p_nome, p_comentario, null, 'filho', 'pendente_aprovacao');
end;
$function$;

CREATE OR REPLACE FUNCTION public.gamificacao_recompensas_list(p_filho_id uuid, p_todas boolean DEFAULT false)
 RETURNS TABLE(id uuid, nome text, comentario text, pontos_necessarios integer, origem text, status text, criado_em timestamp with time zone)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select id, nome, comentario, pontos_necessarios, origem, status, criado_em
  from gamificacao_recompensas
  where filho_id = p_filho_id and (p_todas or status = 'disponivel')
  order by criado_em desc;
$function$;

CREATE OR REPLACE FUNCTION public.gamificacao_saldo(p_filho_id uuid)
 RETURNS integer
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select coalesce(sum(pontos),0)::int from gamificacao_pontos_ledger where filho_id = p_filho_id;
$function$;

CREATE OR REPLACE FUNCTION public.gamificacao_set_config(p_filho_id uuid, p_ofensiva_dias integer, p_habilitada boolean, p_pontos integer, p_minimo_habilidades_dia integer)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  dias_atuais int;
begin
  if not exists (select 1 from filhos where id = p_filho_id and user_id = auth.uid()) then
    raise exception 'nao autorizado';
  end if;
  if p_ofensiva_dias not in (7,21,60,90) then
    raise exception 'ofensiva invalida';
  end if;
  select dias_consecutivos into dias_atuais from gamificacao_streaks where filho_id = p_filho_id and ofensiva_dias = p_ofensiva_dias;
  if not p_habilitada and coalesce(dias_atuais,0) > 0 then
    raise exception 'nao e possivel desabilitar uma ofensiva em andamento';
  end if;
  insert into gamificacao_config (filho_id, ofensiva_dias, habilitada, pontos, minimo_habilidades_dia)
  values (p_filho_id, p_ofensiva_dias, p_habilitada, p_pontos, p_minimo_habilidades_dia)
  on conflict (filho_id, ofensiva_dias) do update set habilitada = excluded.habilitada, pontos = excluded.pontos, minimo_habilidades_dia = excluded.minimo_habilidades_dia;
end;
$function$;

CREATE OR REPLACE FUNCTION public.status_acesso(p_email text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
declare
  v_last timestamptz;
  v_found boolean := false;
begin
  select last_sign_in_at into v_last from auth.users where lower(email) = lower(p_email) limit 1;
  v_found := found;
  if not v_found then
    return 'nao_encontrado';
  end if;
  if v_last is not null then
    return 'ja_cadastrado';
  end if;
  return 'primeiro_acesso';
end;
$function$;
