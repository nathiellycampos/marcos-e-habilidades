# Gamificação — Ofensivas e Recompensas
## Marcos e Habilidades — Requisitos e Regras de Negócio (para validação)

## 1. Objetivo

Criar um sistema de pontos que recompensa o filho por manter constância na autoavaliação diária, e permite que mãe e filho negociem recompensas reais em troca dos pontos acumulados.

---

## 2. Conceito: Ofensivas (Streaks)

Uma ofensiva é um marco de constância: o filho se autoavalia todos os dias, sem quebrar, até completar um número de dias definido.

| Ofensiva | Dias consecutivos | Pontos (sugerido) |
|---|---|---|
| Ofensiva 7 | 7 dias | 7 pontos |
| Ofensiva 21 | 21 dias | 21 pontos |
| Ofensiva 60 | 60 dias | 60 pontos |
| Ofensiva 90 | 90 dias | 90 pontos |

Regra sugerida: 1 dia consecutivo = 1 ponto na ofensiva correspondente. A mãe pode alterar o valor de pontos de cada ofensiva.

### 2.1. O que conta como "dia cumprido"

**Pergunta em aberto (preciso da sua decisão):** um dia é considerado cumprido quando o filho avalia pelo menos 1 habilidade nesse dia, ou existe uma quantidade mínima de habilidades por dia (você mencionou "pelo menos 3 habilidades por dia" ao falar da ofensiva de 90 dias)?

Proposta para simplificar: a mãe configura, por ofensiva, quantas habilidades o filho precisa avaliar naquele dia para o dia contar. Exemplo:
- Ofensiva 7: mínimo 1 habilidade/dia
- Ofensiva 21: mínimo 1 habilidade/dia
- Ofensiva 60: mínimo 2 habilidades/dia
- Ofensiva 90: mínimo 3 habilidades/dia

Isso também fica editável, com os valores acima como sugestão pré-configurada.

### 2.2. Quebra de ofensiva

Se o filho pular um dia sem atingir o mínimo de avaliações configurado, a contagem daquela ofensiva zera e recomeça do dia seguinte.

### 2.3. Ofensivas rodam em paralelo ou em sequência?

**Pergunta em aberto:** as 4 ofensivas contam ao mesmo tempo desde o primeiro dia (ex: no dia 21 ele já fechou a Ofensiva 7 E a Ofensiva 21 no mesmo momento), ou uma só começa a contar depois que a anterior fecha?

Recomendação: rodar em paralelo, todas contando os mesmos dias consecutivos. Assim, ao chegar no dia 90 sem quebrar, o filho já teria fechado as 4 ofensivas (7+21+60+90 = 178 pontos acumulados no total). Mais simples de calcular e mais gratificante (ele vê 4 conquistas ao longo do caminho, não só uma no fim).

---

## 3. Visão da Mãe — Configurações de Gamificação

Novo item no menu **Mais**: **"Gamificação"**, com duas seções:

### 3.1. Configurações da Gamificação

- Checkbox para habilitar/desabilitar cada ofensiva (7, 21, 60, 90) individualmente.
- Campo editável de pontos por ofensiva (pré-preenchido com a sugestão, editável).
- Campo editável do mínimo de habilidades/dia por ofensiva (pré-preenchido com a sugestão, editável).

### 3.2. Bonificações (Recompensas)

- **Bonificações sugeridas**: lista pré-cadastrada de exemplos (viagem, brinquedo, passeio, tempo de tela extra, escolha do jantar, etc.), cada uma com um campo de comentário/observação livre e um campo de pontos necessários (sugerido, editável).
- **Bonificações cadastradas pela mãe**: a mãe pode criar uma recompensa nova (nome, comentário, pontos necessários).
- **Bonificações sugeridas pelo filho** (ver seção 4): aparecem numa fila de aprovação da mãe. A mãe aceita ou recusa, e define a quantidade de pontos necessária antes de publicar.

---

## 4. Visão do Filho — Sugerir Recompensas

O filho pode cadastrar itens que ele gostaria de ganhar em troca de pontos (texto livre: nome do item + comentário opcional, sem definir pontos).

Essa sugestão vai para uma fila de aprovação da mãe (seção 3.2). Só aparece como recompensa disponível para resgate depois que a mãe aceitar e definir o valor em pontos.

---

## 5. Visão do Filho — Tela de Progresso

Na aba **Progresso**, além do que já existe hoje, adicionar:

- Pontos totais acumulados.
- Ofensiva(s) em andamento, com contador de dias (ex: "Ofensiva 21 — dia 14 de 21").
- Lista de recompensas: quais estão liberadas (pontos suficientes) e quais ainda faltam pontos (mostrando quanto falta).
- Ícones/troféus visuais para marcar cada ofensiva conquistada.

Para o infantil (≤12): visual mais lúdico — emojis, troféus, barra de progresso colorida.
Para o juvenil (13+): mesma lógica, visual mais sóbrio (sem emoji, tipografia mais adulta) — igual ao padrão já usado no Skill Card.

---

## 6. Fluxo resumido

1. Mãe habilita as ofensivas que quer usar e ajusta pontos/mínimos (ou usa a sugestão padrão).
2. Mãe cadastra bonificações (ou usa as sugeridas).
3. Filho se autoavalia diariamente → sistema conta dias consecutivos por ofensiva habilitada.
4. Ao fechar uma ofensiva, pontos são creditados automaticamente ao filho.
5. Filho pode sugerir uma recompensa nova a qualquer momento → mãe aprova e define pontos.
6. Filho acompanha em Progresso: pontos, ofensiva atual, recompensas liberadas.
7. Resgate da recompensa: **pergunta em aberto** — o filho clica em "resgatar" e os pontos são debitados automaticamente, ou isso precisa de uma confirmação da mãe (tipo um "aprovar resgate")?

---

## 7. Perguntas que preciso que você responda antes de eu implementar

1. **Mínimo de habilidades por dia**: cada ofensiva tem seu próprio mínimo configurável (proposta da seção 2.1), ou é sempre "pelo menos 1 habilidade avaliada no dia" para todas?
2. **Ofensivas em paralelo ou em sequência** (seção 2.3)? Recomendo paralelo.
3. **Resgate de recompensa**: automático (filho resgata sozinho quando tem pontos suficientes) ou precisa de aprovação da mãe a cada resgate?
4. **Pontos debitados no resgate**: ao resgatar, os pontos gastos saem do saldo do filho (ele pode juntar de novo para outra recompensa), correto?
5. **O que acontece com uma ofensiva já configurada se a mãe desabilitar ela depois**: o progresso em andamento se perde, ou fica pausado e retoma se ela reativar?
6. Confirma a tabela de pontos sugerida (7/21/60/90 pontos) como ponto de partida editável?

Assim que você validar essas 6 perguntas, eu já parto para a implementação (banco de dados, tela da mãe e tela do filho).
