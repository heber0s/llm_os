# Atualização do LLM OS — ChatAI e busca por similaridade

Esta atualização corresponde ao próximo marco do plano: conectar o ChatAI ao dataset já existente, usando uma implementação simulada do serviço de resposta.

## Arquivos

- `lib/features/chat/domain/busca_exemplos.dart`: normalização de texto, remoção de stopwords, Jaccard mínimo de 0,7, conferência de números e limite por hardware/RAM.
- `lib/features/chat/data/servico_llm.dart`: contrato `ServicoLlm`, serviço simulado e montagem de contexto few-shot.
- `lib/features/chat/cubit/chat_cubit.dart`: histórico do chat, temperatura, recuperação de exemplos aprovados/treinados e controle de resposta em andamento.
- `lib/features/chat/view/chat_view.dart`: tela ChatAI com histórico, campo de mensagem, temperatura e contagem de exemplos consultados.
- `lib/app/llm_os_app.dart`: arquivo completo da tela principal com a janela ChatAI conectada.
- `test/features/chat/domain/busca_exemplos_test.dart`: testes unitários para busca, elegibilidade, números, ordenação e capacidade.

## Como aplicar

Extraia o conteúdo deste pacote sobre a raiz do clone do projeto e aceite a substituição do `lib/app/llm_os_app.dart`. Os demais caminhos são novos. Não há dependências novas.

Depois, execute na pasta do projeto:

```powershell
flutter test
flutter run
```

## Limite desta etapa

O ChatAI ainda usa `ServicoLlmSimulado`: responde com a resposta do exemplo mais parecido e dá uma mensagem de contingência quando não há correspondência. A temperatura e o limite de tokens são apresentados à interface do serviço, mas o simulador não faz amostragem nem executa um modelo real; o histórico e a temperatura também ficam apenas enquanto a janela ChatAI permanecer aberta. A integração com o modelo nativo GGUF permanece como a próxima etapa.
