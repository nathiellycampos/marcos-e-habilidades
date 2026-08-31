# Resumo da sessão — Marcos e Habilidades

Cobre do dist19 ao dist43. Documento pra retomar o trabalho numa próxima conversa sem perder contexto.

## Estado atual do produto

App PWA "Marcos e Habilidades", React + Vite (build single-file) + Supabase + Cloudflare Workers. Compra única via Hotmart, webhook cria conta no Supabase Auth, cliente cadastra senha no primeiro acesso.

Deploy: Cloudflare Workers → worker `marcos-e-habilidades` → "Upload static files" → arrastar a pasta do zip mais recente (arquivos: `index.html`, `favicon.ico`, `favicon.png`, `manifest.json`, `sw.js`, pasta `icons/`) por cima do deploy anterior.

## Funcionalidades principais (visão da mãe)

- **Hoje**: microação do dia (marco em atraso > escolhida pelos pais > competência prioritária, nessa ordem de prioridade).
- **Marcos**: diagnóstico completo por faixa etária (atual ou anteriores), com todas as habilidades listadas (sem limite), descrição aberta por padrão (ícone +/− pra fechar/abrir), status incluindo "Não Iniciada".
- **Progresso**: dois cards percentuais (faixa atual / faixas anteriores) cada um seguido do detalhamento por competência com o mesmo denominador; filtro por Consolidadas/Em construção/Gargalo/Não Iniciada, com as habilidades priorizadas aparecendo primeiro (⭐).
- **Feedback do Filho** (no menu fixo, no lugar do antigo "Buscar"): mostra as respostas que o filho deu na autoavaliação, com os mesmos botões de status que ele viu, resposta dele destacada. Confirmar (✓) finaliza. Escolher outra opção manda pra "Conversar com o Filho".
- **Mais**: Filhos Cadastrados (editar/excluir), Priorizar Competências (antigo "Buscar", renomeado, com descrição das prioridades atuais), Conversar com o Filho (resolver divergências de percepção), Enviar Autoavaliação para o Filho (gera link público por filho), links externos, Sair da conta.

## Autoavaliação do filho (link público, sem senha)

Acessível em `#/autoavaliacao/<id_do_filho>`, fora do gate de autenticação. Duas abas:
- **Avaliar**: habilidades da faixa atual + todas as anteriores, com botões de status (sem "Não Iniciada") + "Não sei responder" (não pontua, mesmo comportamento visual dos outros — item desce na lista quando respondido). Visual infantil (≤12 anos, cores/fontes maiores) ou juvenil (13+).
- **Meu progresso**: percentual de habilidades das faixas anteriores já consolidadas, no mesmo formato visual da tela da mãe.

## Regras de negócio importantes

- **Percentuais**: denominador = total fixo de habilidades da taxonomia naquela faixa/competência (não muda com avaliação). Numerador = só `sempre`/`quase_sempre`. "Não Iniciada" nunca pontua, mas conta no total (mesmo peso que "nunca avaliada").
- **Origem da resposta**: toda linha de `registro_habilidade` tem `origem` ('pai'/'filho') e `revisado` (bool). Resposta do filho entra com `revisado=false`, aparece em Feedback até a mãe confirmar ou discordar.
- **Divergência de percepção**: `status_mae` e `precisa_conversar` guardam a opinião da mãe separada da do filho até serem resolvidas em "Conversar com o Filho".

## Login

Duas abas: Login (e-mail+senha, principal) e Primeiro Acesso (auxiliar). Primeiro Acesso verifica via RPC `status_acesso` se o e-mail já tem conta ativa (`last_sign_in_at` não nulo) — se sim, orienta a ir pro Login; se nunca acessou, envia link de definição de senha; se e-mail não é de compra aprovada, avisa e indica contato@nathycampos.com.br. "Esqueci minha senha" no Login vira uma tela só com e-mail (sem campo de senha).

## Riscos e observações técnicas

1. **Não existe mais o código-fonte completo (`src/`) do projeto** — o ambiente de trabalho perdeu essa pasta no meio da sessão, e desde então todas as mudanças foram feitas editando diretamente o `index.html` já compilado (bundle minificado), validando cada mudança com `node --check` (sintaxe) e um teste em DOM headless (jsdom) antes de empacotar. Funciona, mas é mais arriscado que editar o código-fonte original e rodar `npm run build`. **Recomendação forte:** pedir pra reconstruir o projeto fonte completo (`src/`, `package.json`, `vite.config.js`) numa sessão dedicada e salvá-lo nos arquivos do projeto, pra næo depender mais dessa técnica.
2. **Classes Tailwind "fantasmas":** como o CSS já vem compilado, qualquer classe nova que eu adicione no HTML e que não existia antes no projeto simplesmente não tem efeito (sem erro, sem aviso — só não funciona). Já aconteceu bug real por isso (`text-left`, `mb-7`, `-mt-1`, tema infantil da Autoavaliação). Desde então, uso estilo inline pra qualquer ajuste visual novo, que sempre funciona independente do CSS compilado.
3. **Supabase pode pausar por inatividade** (plano gratuito) — já aconteceu uma vez nesta sessão, causando erro "Failed to fetch" em toda a aplicação. Foi restaurado via `restore_project`. Se voltar a acontecer com frequência, vale considerar upgrade de plano.
4. Duas funções RPC (`autoavaliacao_info`, `autoavaliacao_habilidades`, `autoavaliacao_salvar`) foram criadas por engano nesta sessão (duplicando funcionalidade que já existia com outro nome) e depois removidas — não há mais lixo no banco por causa disso, mas é um lembrete de checar o que já existe antes de criar RPC novo.

## Deploy mais recente

`marcos_e_habilidades_dist43.zip` — inclui tudo listado acima. Ainda não testado ao vivo (sem navegador real neste ambiente); recomenda-se testar o fluxo completo (login, autoavaliação do filho ponta a ponta, feedback, conversar com o filho) após o deploy.
