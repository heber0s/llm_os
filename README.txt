LLM OS — patch de treino simulado

Aplique os arquivos deste pacote sobre a raiz do clone atual do repositório.
Os três arquivos mantêm os caminhos lib/ e test/ do projeto.

O treino usa somente exemplos auditados, corretos e ainda não treinados.
Custo: 5 créditos + 1 crédito por grupo completo de 4 exemplos treináveis.
Duração simulada: 10 segundos, com progresso e loss visual de 2.8 até 0.3.
A conclusão incrementa a época, marca os exemplos aprovados como treinados e
salva o estado existente pelo JogoRepositorio.

Validação local recomendada, na raiz do projeto:
  flutter test
  flutter run

Este ambiente não inclui Flutter/Dart; os testes não foram executados aqui.
