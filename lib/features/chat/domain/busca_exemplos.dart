import '../../jogo/data/dado_treino.dart';

class ExemploConsultado {
  const ExemploConsultado({required this.dado, required this.similaridade});

  final DadoTreino dado;
  final double similaridade;
}

/// Recupera exemplos aprovados e treinados usando Jaccard sobre tokens.
/// Exemplos com valores numéricos diferentes nunca são considerados similares.
class BuscaExemplos {
  const BuscaExemplos();

  static const double similaridadeMinima = 0.7;
  static const Set<String> _stopWords = {
    'a', 'o', 'as', 'os', 'um', 'uma', 'uns', 'umas', 'de', 'da', 'do', 'das',
    'dos', 'e', 'em', 'no', 'na', 'nos', 'nas', 'por', 'para', 'com', 'que',
    'qual', 'quais', 'quem', 'como', 'quando', 'onde', 'me', 'diga', 'é', 'ser',
    'foi', 'sao', 'são', 'ao', 'aos', 'ou', 'se', 'mais', 'menos',
  };

  List<ExemploConsultado> buscar({
    required String pergunta,
    required Iterable<DadoTreino> dados,
    required int limite,
  }) {
    if (limite <= 0 || pergunta.trim().isEmpty) return const [];
    final tokensPergunta = _tokens(pergunta);
    if (tokensPergunta.isEmpty) return const [];
    final numerosPergunta = _numeros(pergunta);
    final candidatos = <ExemploConsultado>[];

    for (final dado in dados) {
      if (!dado.treinado || !dado.auditado || dado.ruim) continue;
      final numerosExemplo = _numeros(dado.pergunta);
      if (numerosPergunta.isNotEmpty &&
          numerosExemplo.isNotEmpty &&
          !_mesmosNumeros(numerosPergunta, numerosExemplo)) {
        continue;
      }
      final tokensExemplo = _tokens(dado.pergunta);
      if (tokensExemplo.isEmpty) continue;
      final intersecao = tokensPergunta.intersection(tokensExemplo).length;
      final uniao = tokensPergunta.union(tokensExemplo).length;
      if (uniao == 0) continue;
      final similaridade = intersecao / uniao;
      if (similaridade >= similaridadeMinima) {
        candidatos.add(ExemploConsultado(dado: dado, similaridade: similaridade));
      }
    }

    candidatos.sort((a, b) {
      final porSimilaridade = b.similaridade.compareTo(a.similaridade);
      if (porSimilaridade != 0) return porSimilaridade;
      return a.dado.id.compareTo(b.dado.id);
    });
    final selecionados = candidatos.take(limite).toList();
    // O contexto é montado do menos ao mais similar para dar prioridade
    // ao exemplo mais forte no fim do prompt.
    selecionados.sort((a, b) => a.similaridade.compareTo(b.similaridade));
    return selecionados;
  }

  Set<String> _tokens(String texto) => _normalizar(texto)
      .split(' ')
      .where((token) => token.isNotEmpty && !_stopWords.contains(token))
      .toSet();

  String _normalizar(String texto) {
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucn';
    var valor = texto.toLowerCase();
    for (var i = 0; i < comAcento.length; i++) {
      valor = valor.replaceAll(comAcento[i], semAcento[i]);
    }
    return valor.replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  Set<String> _numeros(String texto) =>
      RegExp(r'\d+(?:[.,]\d+)?').allMatches(texto).map((match) => match.group(0)!).toSet();

  bool _mesmosNumeros(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}

/// Limite configurado no hardware mais os módulos de RAM instalados.
int limiteExemplosConsultados({required int nivelHardware, required int nivelRam}) {
  const consultasHardware = [1, 3, 4, 5];
  final nivel = nivelHardware.clamp(0, consultasHardware.length - 1).toInt();
  return consultasHardware[nivel] + nivelRam;
}
