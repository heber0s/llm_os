# LLM OS — renda passiva e automação

Este pacote é um overlay da atualização, com versões completas dos arquivos Dart alterados e um novo teste. Extraia o conteúdo sobre a raiz do clone do projeto, permitindo substituir os arquivos correspondentes.

## O que foi implementado

- **Renda passiva:** a cada 10 segundos, concede 1, 3, 6 ou 12 créditos conforme o hardware, mais 2 créditos por nível de Internet.
- **Bot coletor:** a cada 20 segundos, tenta coletar 1 exemplo por nível na categoria selecionada; respeita o espaço livre, não repete perguntas e mantém a chance de 30% de resposta incorreta.
- **Upgrades na PixelStore:** RAM (máximo nível 3), Bot coletor (máximo 3) e Internet (máximo 5), com preços progressivos e persistência local.
- **RAM:** o nível é salvo e exibido como capacidade de consulta do modelo. O repositório atual ainda não tem um ChatAI funcional; conectar esse efeito ao modelo ficará para a etapa do ChatAI/FreelaNet.
- Os timers são cancelados ao fechar o JogoBloc; intervalos configuráveis permitem testes determinísticos.

## Arquivos incluídos

- `lib/features/jogo/bloc/jogo_bloc.dart` — versão completa atualizada.
- `lib/features/loja/view/pixel_store_view.dart` — versão completa atualizada.
- `test/features/jogo/bloc/jogo_income_bot_test.dart` — testes de renda, coleta, upgrades e persistência.

Depois de extrair, execute `flutter test` e `flutter run` na raiz do projeto. Não foi possível executar Flutter/Dart neste ambiente.
