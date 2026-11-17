import '../domain/busca_exemplos.dart';

class MensagemChat {
  const MensagemChat({required this.texto, required this.usuario, this.exemplosConsultados = 0});

  final String texto;
  final bool usuario;
  final int exemplosConsultados;
}

abstract interface class ServicoLlm {
  Future<String> responder({
    required String pergunta,
    required List<ExemploConsultado> exemplos,
    required double temperatura,
    required int maxTokens,
  });
}

/// Implementação determinística para o marco de ChatAI sem depender de um
/// runtime de modelo nativo. Retorna a resposta do melhor exemplo relacionado;
/// sem correspondência, produz uma resposta de contingência honesta.
class ServicoLlmSimulado implements ServicoLlm {
  const ServicoLlmSimulado();

  @override
  Future<String> responder({
    required String pergunta,
    required List<ExemploConsultado> exemplos,
    required double temperatura,
    required int maxTokens,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (exemplos.isEmpty) {
      return 'Ainda não encontrei um exemplo treinado suficientemente parecido. '
          'Colete, audite e treine exemplos relacionados para melhorar esta resposta.';
    }
    final melhor = exemplos.last;
    return melhor.dado.resposta;
  }
}

/// Cria um resumo few-shot dos exemplos recuperados para futura implementação
/// do backend nativo, mantendo ordem de similaridade crescente.
List<Map<String, String>> montarContextoFewShot(List<ExemploConsultado> exemplos) => [
      for (final exemplo in exemplos) ...[
        {'role': 'user', 'content': exemplo.dado.pergunta},
        {'role': 'assistant', 'content': exemplo.dado.resposta},
      ],
    ];
