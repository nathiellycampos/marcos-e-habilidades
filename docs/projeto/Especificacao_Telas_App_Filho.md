# Especificação de Telas — App do Filho ("Skill Lab")

**Nome do app: Skill Lab** — único, para os dois modos. Não muda de nome entre criança e adolescente; muda a interface (visual e tom) conforme a idade validada no cadastro. "Planeta de Treino" (nome do protótipo atual) é descontinuado em favor de "Skill Lab".

Prompt para Google AI Studio. Base: protótipo já existente (screenshots anexos) — manter identidade visual (header amarelo #FFC940, CTA rosa/vermelho #FF3B5C, cards brancos com borda arredondada, tipografia bold em navy #1C2B2D). Não redesenhar do zero — evoluir o que já existe.

Integração de dados: mesmo Supabase do app da mãe (`filhos`, `habilidades_escolhidas`, `registro_habilidade` + tabelas novas `evidencias`, `transacoes_coins`, `premios`, `resgates_premio`).

---

## Regra de bifurcação por idade

O app tem **duas interfaces distintas**, escolhidas automaticamente pela idade do filho — a criança/adolescente não escolhe, o sistema decide.

- **0–12 anos → Skill Lab Modo Criança:** interface lúdica (especificação abaixo, evolução do protótipo "Planeta de Treino").
- **13+ anos → Skill Lab Modo Adolescente:** interface própria, com linguagem e visual mais maduros (especificação na segunda parte deste documento).

O nome "Skill Lab" aparece igual nas duas interfaces (splash/login, título de aba) — o que muda é só a experiência interna pós-login, depois da idade validada.

**Cálculo:** requer campo de data de nascimento em `filhos` (adicionar se não existir):

```sql
alter table filhos add column if not exists data_nascimento date;
```

Idade = `date_part('year', age(current_date, data_nascimento))`. Calcular no login/carregamento da sessão do filho e definir o tema (`modo_crianca` ou `modo_adolescente`) como estado global do app — não recalcular a cada tela.

**Transição de aniversário:** ao completar 13 anos, o app troca automaticamente para o Modo Adolescente no próximo acesso. Sem aviso ou celebração especial no MVP — troca silenciosa.

---

# PARTE 1 — Modo Criança (0–12 anos)

## Tela 1 — Header global (presente em todas as telas)

**Layout:** barra amarela fixa no topo.

- Esquerda: ícone de estrela em círculo laranja + "SKILL LAB" (bold, navy) + subtítulo "Olá, {nome_filho}! Pronto para detonar?" (nome em laranja).
- Direita: pílula "🪙 {saldo_coins} MOEDAS" (fundo laranja claro) + botão "↪ Painel da Mamãe" (navy, sai do modo filho — deve pedir confirmação simples, sem senha, ex. "Chamar a mamãe?").
- Abaixo do header: navegação de duas pílulas — "🎯 Missões do Dia" (ativa = rosa/vermelho preenchida) e "🎁 Loja de Prêmios" (inativa = contorno).

**Regra:** `{saldo_coins}` é somatório em tempo real de `transacoes_coins` do filho logado (créditos de missão aprovada menos débitos de resgate). Atualiza sem precisar recarregar a página ao voltar de uma aprovação.

---

## Tela 2 — Missões do Dia (home)

**Bloco de destaque (topo, borda amarela):**
"🎯 Suas Missões Combinadas: Fazer os deveres certinho dá moedas! Estude, tire foto ou desenhe e mande para a mamãe!" — texto fixo, tom de instrução simples para criança.

**Grid de cards de missão** (2 colunas desktop, 1 coluna mobile), com cards de **duas origens misturadas na mesma lista** (o filho não precisa saber a diferença técnica):
- Habilidades pendentes de `habilidades_escolhidas`.
- Deveres do dia de `deveres_do_dia` (instância gerada automaticamente a cada dia enquanto o devir estiver ativo).

Cada card contém:
- Badge de status no topo: `PENDENTE` (cinza/lilás), `AGUARDANDO APROVAÇÃO` (amarelo), `REPROVADA — TENTE DE NOVO` (vermelho claro).
- Título (bold, navy) — da habilidade ou do devir.
- Descrição/instrução ("O que fazer") — texto já existente na base de habilidades, ou a descrição cadastrada do devir.
- Selo "🪙 até {pontos_base + maior_bonus_evidencia} coins" no canto do card — como a pontuação final depende do tipo de evidência escolhido na Tela 3, o card mostra o **teto possível** (pontos-base + 10, o bônus do vídeo, que é o maior) como chamada, não um número fixo.
- Botão de ação, que muda conforme status:
  - `PENDENTE` → "▶ Iniciar Missão!" (rosa, leva à Tela 3).
  - `AGUARDANDO APROVAÇÃO` → botão desabilitado, texto "⏳ Esperando a mamãe conferir...".
  - `REPROVADA` → "🔁 Tentar de Novo" (leva à Tela 3 para reenvio).

**Estado vazio:** se não houver missões pendentes, mostrar ilustração/texto: "Você mandou tudo pra mamãe! 🎉 Volte mais tarde para novas missões."

**Regra de ordenação:** missões recomendadas pela mãe (`[Missão Recomendada]`) aparecem primeiro; deveres do dia aparecem sempre no topo da lista (são compromissos diários, prioridade sobre habilidades pontuais).

---

## Tela 3 — Execução da Missão

**Bloco superior (borda amarela, igual ao protótipo):** badge "MISSÃO ATIVA" + título da habilidade + descrição completa.

**Selo de pontos-base fixo no topo do bloco:** "Esta missão vale {pontos_base} 🪙 de base" — vem do pilar/nível da habilidade (ou 1, se for devir), calculado no server.

**Seletor de tipo de evidência** — 5 opções lado a lado/em grid (cards clicáveis, o selecionado fica com borda laranja preenchida), cada uma mostrando o bônus de pontos daquele tipo, para o filho entender que a forma de comprovar também rende pontos:

1. **📝 Diário de Texto** — "+3 🪙"
2. **🎨 Lousa Mágica** (desenho) — "+3 🪙"
3. **📷 Foto do Dia** — "+5 🪙"
4. **🎙️ Áudio (link)** *(novo, não existia no protótipo)* — "+7 🪙". Copy de apoio: "Peça pra mamãe ou papai gravar um áudio seu fazendo a missão e me manda o link aqui!"
5. **🎬 Vídeo seu (link)** *(novo, não existia no protótipo)* — "+10 🪙", o maior bônus. Copy de apoio: "Peça pra alguém filmar VOCÊ fazendo a missão e me manda o link aqui! Vale mais moedas porque mostra tudo!"

**Total dinâmico visível acima do botão de enviar:** "Você vai ganhar {pontos_base + bônus_do_tipo_selecionado} 🪙 se a mamãe aprovar!" — recalcula ao trocar o tipo de evidência selecionado.

**Área de input dinâmica conforme seleção:**
- Texto → textarea "Escreva aqui bem bonitinho o que você conseguiu fazer...".
- Lousa Mágica → canvas de desenho simples (cores básicas, borracha, botão limpar) com botão "Salvar Desenho"; alternativa: botão "📎 Enviar foto do desenho".
- Foto → botão "📷 Tirar Foto ou Escolher da Galeria" (input file com `capture="environment"` para mobile).
- Áudio → input de URL com validação simples (precisa começar com `http`).
- Vídeo → input de URL com validação simples + texto de reforço "Tem que ser você aparecendo, viu? 😉" (a validação de que é realmente o filho fica a cargo da mãe na aprovação, não é automática).

**Botão final:** "Enviar para aprovação da Mamãe! 🚀" — **fica desabilitado até haver conteúdo válido no campo ativo** (texto não vazio, desenho salvo, foto anexada, ou link válido). Ao enviar: grava em `evidencias`, muda status para `pendente_aprovacao`, volta para Tela 2 mostrando a missão com badge "AGUARDANDO APROVAÇÃO".

**Feedback de sucesso:** modal ou toast simples: "Enviado! 🎉 Assim que a mamãe conferir, suas moedas caem na conta."

---

## Tela 4 — Loja de Prêmios

**Bloco de destaque (topo, borda amarela):** "🎁 Lojinha de Prêmios Combinados! Troque as moedinhas que você ganhou fazendo tarefas e deveres por prêmios muito legais!"

**Grid de cards de prêmio**, um por registro ativo em `premios`:

- Pílula "🪙 {custo_coins} Coins" no topo do card.
- Texto cinza pequeno "Resgatado: {n}x" (histórico de quantas vezes já trocou esse prêmio).
- Título do prêmio (bold, navy).
- Descrição.
- Botão de ação, muda conforme saldo:
  - Saldo suficiente → botão rosa "🎉 Resgatar Prêmio!".
  - Saldo insuficiente → botão cinza desabilitado "🔒 Falta {custo_coins - saldo_coins} Coins".

**Ao resgatar:** confirmação simples ("Trocar {custo_coins} coins por {nome_premio}?") → debita em `transacoes_coins` (origem `resgate_premio`) → cria registro em `resgates_premio` com status `solicitado` → atualiza saldo no header instantaneamente → mostra mensagem "Prêmio resgatado! Combine com a mamãe como e quando vai receber. 🎁".

*(Depende da decisão pendente: se o fluxo final for resgate-com-confirmação-da-mãe ou débito imediato sem aprovação — está marcado no prompt de melhorias do app da mãe. Especificar aqui como débito imediato + registro de acompanhamento é o caminho mais simples para MVP.)*

---

## Tela 5 — Meu Progresso *(nova, não existia no protótipo)*

Acesso via ícone/aba adicional no header (ex. "⭐ Meu Progresso").

- Card de saldo atual: "🪙 Você tem {saldo_coins} moedas".
- Card de total histórico: "Você já ganhou {total_ganho} moedas no total!".
- Lista simples (não gráfico) de missões aprovadas recentes: nome da habilidade + data + "+{valor_coins} 🪙".
- Sem métricas de competência/gargalo aqui — isso é do painel da mãe, não do app do filho. Manter a tela simples e recompensadora, sem linguagem técnica.

---

## Estados e regras transversais

- **Sem habilidades cadastradas para o filho:** tela inicial mostra mensagem amigável pedindo para a mamãe escolher as primeiras missões no painel dela — nunca uma tela em branco ou erro técnico.
- **Sem conexão/erro de envio:** manter o conteúdo digitado/anexado no formulário (não perder o que a criança já fez) e mostrar "Não consegui enviar, tenta de novo!" com botão de retry.
- **Linguagem em todas as telas:** frases curtas, tom de aventura/jogo, sempre na 2ª pessoa direta com a criança ("Você", "Sua missão"), nunca termos técnicos (não usar "status", "registro", "aprovação pendente" — usar "esperando a mamãe conferir").

---

# PARTE 2 — Modo Adolescente (13+ anos)

Mesma estrutura de dados e regras de negócio da Parte 1 (pontos só na aprovação, evidência obrigatória, 5 tipos de evidência com bônus de pontos igual — texto/desenho +3, foto +5, áudio +7, vídeo do próprio adolescente +10 —, ordenação por recomendação, deveres diários misturados com habilidades). O que muda é **tom, densidade visual e nomenclatura** — sair do registro infantil ("missão", "moedinhas", emojis fofos) para um registro mais próximo de app de produtividade/hábitos, sem infantilizar.

**Paleta e estilo:** trocar amarelo lúdico + emojis por paleta mais neutra e contemporânea (ex. navy escuro + um accent color vibrante único — verde ou roxo —, cards com mais respiro, ícones lineares no lugar de emojis, tipografia menos "bold arredondado" e mais editorial). Não usar carinha de estrela, "detonar", "lousa mágica".

**Renomeação de conceitos:**
| Modo Criança | Modo Adolescente |
|---|---|
| Skill Lab (nome do app, igual nos dois modos) | Skill Lab |
| Missões do Dia | Atividades de Hoje |
| Iniciar Missão! | Registrar |
| Moedas / Coins | Pontos (mesmo backend `transacoes_coins`, copy diferente) |
| Loja de Prêmios | Recompensas |
| Diário de Texto / Lousa Mágica / Foto do Dia / Áudio / Vídeo seu | Texto / Desenho / Foto / Áudio / Vídeo (sem apelido lúdico) |
| "Esperando a mamãe conferir" | "Aguardando aprovação" |
| Devir (interno, não aparece pro filho) | Mesmo termo — "devir" não é exposto na UI em nenhum modo, é só nome de tabela; na tela aparece só o título cadastrado pela mãe |

### Tela 1 (adolescente) — Header

Barra superior neutra (não amarela): nome do app à esquerda, saudação direta e curta ("Olá, {nome}") sem tom infantil, saldo de pontos como badge discreto, acesso ao "Painel dos Pais" (não "Painel da Mamãe" — neutro, pode ser mãe ou pai conferindo). Navegação por abas ou ícones lineares: Atividades / Recompensas / Meu Progresso.

### Tela 2 (adolescente) — Atividades de Hoje

Lista (não cards grandes e coloridos) mais compacta, estilo checklist de app de hábitos: título da habilidade, descrição em texto secundário menor, status como texto simples ("Pendente", "Aguardando aprovação", "Reprovada — reenviar"), pontos à direita. Prioriza densidade de informação sobre lúdico — adolescente quer resolver rápido, não "brincar".

### Tela 3 (adolescente) — Registrar Atividade

Mesmo fluxo funcional da Tela 3 do Modo Criança (seletor de evidência, 4 tipos, botão de envio), mas:
- Sem canvas de desenho "mágico" — se o adolescente quiser enviar desenho, é upload de foto/imagem, mesmo campo de "Foto".
- Copy do link de vídeo/áudio mais direta: "Cole aqui o link do vídeo ou áudio (YouTube, Drive, etc.)".
- Confirmação de envio sem emoji/comemoração exagerada: "Enviado para aprovação."

### Tela 4 (adolescente) — Recompensas

Mesma lógica de custo em pontos e resgate da Loja de Prêmios, com layout mais sóbrio (lista ou grid discreto, sem "Lojinha", sem "🎉"). Texto de apoio: "Troque pontos acumulados por recompensas combinadas com seus pais."

### Tela 5 (adolescente) — Meu Progresso

Mantém saldo atual, total histórico e lista de atividades aprovadas — mesma função da Tela 5 do Modo Criança, com visual alinhado ao restante do modo adolescente (sem elementos lúdicos). Pode incluir, aqui sim, uma visão levemente mais analítica (ex. gráfico simples de atividades por semana) já que o público tolera mais dado — mas isso é melhoria futura, não obrigatória no MVP.

---

## Fora de escopo desta especificação

- Tela de login/PIN do filho (tratar como item separado, provavelmente seleção simples de avatar/perfil já cadastrado pela mãe, sem senha) — vale tanto para modo criança quanto adolescente.
- Notificações.
- Upload de arquivo de vídeo/áudio (só link, conforme já definido).
- Customização manual do modo pelo usuário (o modo é 100% determinado pela idade cadastrada, sem toggle).
