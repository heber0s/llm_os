# Atualização do LLM OS — FreelaNet

Este pacote ativa a aba FreelaNet no Navegador e registra pagamentos e intervalos de cada vaga no estado persistido do jogo.

## Arquivos incluídos

- `lib/features/jogo/bloc/jogo_bloc.dart` — evento de trabalho concluído, pagamento e persistência dos cooldowns.
- `lib/features/navegador/view/navegador_view.dart` — tela de vagas, progresso, respostas, correção e pagamento.
- `lib/features/vagas/domain/vagas.dart` — catálogo de oito trabalhos e sorteio de perguntas.
- `lib/features/vagas/domain/corretor_vagas.dart` — correção por números ou palavras-chave.
- `lib/features/vagas/cubit/vagas_cubit.dart` — execução sequencial usando o contrato `ServicoLlm` existente.
- `test/features/jogo/bloc/jogo_vaga_cooldown_test.dart` e `test/features/vagas/domain/corretor_vagas_test.dart` — testes novos.

## Aplicação

Extraia o conteúdo do ZIP sobre a raiz do clone atual, aceitando substituir `jogo_bloc.dart` e `navegador_view.dart`. Os outros arquivos são novos. Não há dependências novas.

Na pasta do projeto, execute:

```powershell
flutter test
flutter run
```

## Observação sobre o modelo

As vagas chamam `ServicoLlm`; nesta versão está conectado ao `ServicoLlmSimulado` já existente. Ele só responde com base em exemplos parecidos, aprovados e treinados no dataset, e não executa inferência GGUF/nativa. O pagamento é proporcional aos acertos, com limite igual ao valor máximo da vaga. Cada vaga tem cooldown persistido de 45 segundos.
