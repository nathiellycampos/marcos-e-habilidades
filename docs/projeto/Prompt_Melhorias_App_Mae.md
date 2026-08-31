# Prompt de Engenharia — Melhorias no App da Mãe ("Marcos e Habilidades")

## Contexto (infraestrutura existente, não recriar)

App já em produção em `marcos-e-habilidades.nathielly.workers.dev`, Cloudflare Workers, backend Supabase. Tabelas atuais: `filhos`, `habilidades_escolhidas`, `registro_habilidade` (com `ON DELETE CASCADE` para `filhos`). Já existem telas Marcos, Hoje, Progresso, Filhos Cadastrados. Status de avaliação já suporta: Nunca, Quase nunca, Às vezes, Quase sempre, Sempre, Não Iniciada.

**Atenção operacional:** no histórico do projeto, o código-fonte (`src/`) foi perdido entre sessões e o time trabalhou editando o `dist/index.html` compilado diretamente. Antes de iniciar as melhorias abaixo, confirmar que existe uma pasta `src/` versionada (git ou arquivo do projeto) — sem isso, qualquer mudança é frágil e não reproduzível.

## Objetivo desta rodada

Integrar o app da mãe ao sistema de coins do app do filho: cadastrar prêmios, definir custo em coins de cada missão, aprovar evidências enviadas pelo filho, e exibir o saldo de coins do filho na tela de Progresso.

## Funcionalidades novas

### 0. Cadastro de Deveres (novo tipo de atividade, além das habilidades)

Até aqui a mãe só selecionava **habilidades** da pirâmide (`habilidades_escolhidas`). Agora ela também cadastra **deveres** — tarefas do dia a dia (lição de casa, arrumar a cama, etc.) que não fazem parte da pirâmide de competências, mas viram atividade pontuável para o filho.

- Deveres são **recorrentes diários**: uma vez cadastrado e ativo, aparece na lista de Atividades de Hoje do filho todo dia, até a mãe desativar.
- Habilidades continuam como estão hoje: selecionadas pela mãe, aparecem como atividade até serem aprovadas (não são diárias por padrão, salvo se a mãe repetir a seleção).

```sql
create table deveres (
  id uuid primary key default gen_random_uuid(),
  filho_id uuid references filhos(id) on delete cascade,
  titulo text not null,
  descricao text,
  ativo boolean default true,
  criado_em timestamptz default now()
);
```

Tela "Deveres" no painel da mãe: CRUD simples (título, descrição, ativo/inativo). Ativar/desativar controla se ele aparece amanhã na lista do filho — não apaga histórico de dias já cumpridos.

### 1. Cadastro de recompensas (Loja de Prêmios)

Nova tela/seção no painel da mãe: "Prêmios". CRUD simples:

- Nome do prêmio (ex. "30 minutos extras de videogame")
- Descrição
- Custo em coins
- Ativo/inativo (permite desativar sem apagar histórico)

```sql
create table premios (
  id uuid primary key default gen_random_uuid(),
  filho_id uuid references filhos(id) on delete cascade, -- ou null se for prêmio geral para todos os filhos
  nome text not null,
  descricao text,
  custo_coins integer not null check (custo_coins > 0),
  ativo boolean default true,
  criado_em timestamptz default now()
);
```

### 2. Pontuação automática (substitui o campo manual `valor_coins`)

A mãe **não define mais um valor de coins manualmente por missão.** A pontuação é calculada automaticamente por regra fixa, com dois componentes que se somam: pontos-base da atividade (pilar/nível da pirâmide, ou devir) + bônus pelo tipo de evidência anexada.

**a) Pontos-base por pilar/nível da habilidade:**

| Pilar/Nível | Pontos-base |
|---|---|
| P1, N2, N4 *(confirmar com a Nathy a lista completa — estes são os exemplos citados)* | 2 |
| Qualquer outro pilar/nível da pirâmide | 1 |
| Devir (tarefa cadastrada em `deveres`, fora da pirâmide) | 1 |

Implementar como função ou view, não como campo editável — evita a mãe ter que lembrar de configurar cada habilidade. Precisa de uma tabela de referência com os pares pilar/nível que valem 2 pontos, para não hardcodar no client:

```sql
create table pontuacao_base_pilar_nivel (
  pilar text not null,
  nivel text not null,
  pontos_base integer not null default 1,
  primary key (pilar, nivel)
);
-- seed: inserir as combinações que valem 2 (ex. P1/N2, P1/N4) — confirmar lista completa com a Nathy
```

**b) Bônus por tipo de evidência anexada:**

| Tipo de evidência | Pontos |
|---|---|
| Texto | 3 |
| Desenho | 3 |
| Foto | 5 |
| Áudio (link) | 7 |
| Vídeo do próprio filho (link) | 10 |

**Pontuação total creditada na aprovação = pontos-base da atividade + bônus da evidência.** Exemplo: habilidade P1/N2 (2 pontos-base) com foto anexada (5 pontos) = 7 pontos creditados ao aprovar.

*Assumção a validar com a Nathy: o modelo é aditivo (soma dos dois componentes). Se a intenção for outra (ex. multiplicar, ou usar só um dos dois valores dependendo do tipo de atividade), ajustar a função de cálculo — a estrutura de tabelas acima suporta qualquer uma das duas regras sem redesenho.*

Renomear `valor_coins`/coins para **pontos** de forma consistente em todo o app (mãe e filho), já que a unidade de gamificação virou pontuação calculada, não mais um valor fixo por missão.

### 3. Fila de aprovação de evidências

Nova tela "Aprovações Pendentes" (ou aba dentro de Hoje): lista registros com `status_aprovacao = 'pendente_aprovacao'`, mostrando a evidência (texto, imagem, ou link de vídeo/áudio) e dois botões: **Aprovar** (credita `valor_coins` em `transacoes_coins`, muda status para `aprovada`) e **Reprovar** (muda para `reprovada`, sem crédito, libera o filho para reenviar).

Esta tela depende das tabelas `evidencias` e `transacoes_coins` especificadas no prompt do app do filho — construir os dois lados juntos, mesmo schema.

### 4. Confirmação de resgate de prêmio

Se o fluxo de resgate do filho gerar um registro `solicitado` (ver decisão pendente no prompt do filho), a mãe precisa de uma tela para marcar como entregue. Se o fluxo for resgate imediato (desconto automático), a mãe só precisa de um histórico de resgates — sem ação pendente.

### 5. Saldo de coins na tela de Progresso

Adicionar ao topo da tela de Progresso (mesmo local do card-resumo de "Competências consolidadas"): card com saldo atual de coins do filho e total de coins já ganhos historicamente (soma de créditos em `transacoes_coins`, ignorando débitos de resgate). Usar o mesmo denominador/estilo de card já padronizado nas correções recentes de Progresso (não criar um componente visual novo).

## Regras de negócia a manter consistentes com o app do filho

- Coins só entram no saldo do filho na aprovação, nunca no envio.
- "Não Iniciada" continua fora do cálculo de avaliação — não mexer nessa lógica.
- Exclusão de filho deve continuar removendo em cascata: adicionar `premios`, `deveres`, `transacoes_coins` e `evidencias` à cadeia de `ON DELETE CASCADE` a partir de `filhos` (via `registro_habilidade_id` para evidências de habilidade e via `devir_id` para evidências de devir — ver modelo ajustado no prompt do app do filho).

## Critério de aceite

- Mãe cadastra prêmio com custo em coins e ele aparece na Loja de Prêmios do filho.
- Mãe cadastra devir e ele aparece diariamente na lista de atividades do filho, enquanto ativo.
- Pontuação de cada atividade é calculada automaticamente (base do pilar/nível + bônus da evidência), sem input manual da mãe.
- Mãe aprova/reprova evidência e o saldo do filho reflete corretamente, com o total exato da soma base + evidência.
- Card de saldo de coins visível na tela de Progresso, com número batendo com o que o filho vê no header dele.
- Excluir filho remove prêmios, deveres, transações e evidências associadas sem deixar órfão no banco.
