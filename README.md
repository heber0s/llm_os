# LLM OS — base inicial

LLM OS é um jogo single-player sobre desenvolver um modelo de linguagem: coletar e revisar dados, treinar de forma simulada, melhorar o computador e usar o modelo em atividades.

## O que já está nesta primeira base

- Desktop responsivo com identidade pixel art e paleta retrô.
- Ícones e janelas para TreinaAI, ChatAI, Navegador e PixelStore.
- Barra de tarefas, relógio, menu Iniciar e ação para reiniciar o jogo.
- Gerenciamento de janelas isolado em `JanelasCubit`.
- `JogoBloc` com créditos, coleta, auditoria, remoção de dados suspeitos e salvamento.
- Repositório local com `shared_preferences` para preparar a persistência do progresso.
- Organização por funcionalidades para evoluir sem colocar regras de jogo nos widgets.

TreinaAI já permite coletar, auditar e remover exemplos. ChatAI, Navegador e PixelStore ainda são estruturas visuais; treino, economia adicional e integração com o modelo serão implementados nas próximas etapas. O modelo de linguagem ainda não está integrado.

## Requisitos

- Flutter com suporte a Dart 3.3 ou superior.
- Android Studio, VS Code ou outro ambiente Flutter configurado para a plataforma desejada.

## Executar

Na pasta do projeto:

```bash
flutter pub get
flutter run
```

Para rodar os testes existentes do Flutter quando forem adicionados:

```bash
flutter test
```

## Estrutura principal

```text
lib/
  app/                         # MaterialApp e desktop
  core/theme/                  # Paleta e tema pixel art
  features/desktop/cubit/       # Estado das janelas
  features/jogo/bloc/          # Estado principal do jogo
  features/jogo/data/          # Persistência local
```

## Etapa atual: coleta e auditoria no TreinaAI

- O jogador pode selecionar Geografia, Matemática ou Natureza e coletar até 4 exemplos por lote.
- Cada pergunta é única por jogador; perguntas já coletadas continuam registradas mesmo se o exemplo for removido.
- A coleta respeita o limite inicial de 40 exemplos e cada resposta tem 30% de chance de vir incorreta.
- Auditar custa 10 créditos e revela os exemplos suspeitos; remover suspeitos exclui apenas exemplos incorretos já auditados.
- Dataset, categoria escolhida, créditos e perguntas já utilizadas são salvos localmente.

O próximo incremento pode implementar o treino simulado e conectar os exemplos aprovados ao ChatAI. O modelo de linguagem real, loja e atividades de renda ainda não estão integrados.
