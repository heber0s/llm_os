class CorretorVagas {
  const CorretorVagas();

  bool avaliar({required String respostaEsperada, required String respostaModelo}) {
    final numerosEsperados = _numeros(respostaEsperada);
    if (numerosEsperados.isNotEmpty) {
      final numerosResposta = _numeros(respostaModelo);
      return numerosEsperados.every(numerosResposta.contains);
    }

    final palavras = _palavras(respostaEsperada);
    if (palavras.isEmpty) return respostaModelo.trim().isNotEmpty;
    final resposta = _palavras(respostaModelo);
    final acertos = palavras.where(resposta.contains).length;
    return acertos >= (palavras.length / 2).ceil();
  }

  Set<String> _numeros(String texto) => RegExp(r'-?\d+(?:[.,]\d+)?')
      .allMatches(texto)
      .map((match) => match.group(0)!.replaceAll(',', '.'))
      .toSet();

  Set<String> _palavras(String texto) {
    const stopWords = {
      'a', 'o', 'as', 'os', 'um', 'uma', 'uns', 'umas', 'de', 'da', 'do', 'das',
      'dos', 'e', 'em', 'no', 'na', 'nos', 'nas', 'por', 'para', 'com', 'que',
      'qual', 'quais', 'quem', 'como', 'quando', 'onde', 'me', 'diga', 'é', 'ser',
      'foi', 'sao', 'são', 'ao', 'aos', 'ou', 'se', 'mais', 'menos',
    };
    return _normalizar(texto)
        .split(' ')
        .where((palavra) => palavra.isNotEmpty && !stopWords.contains(palavra))
        .toSet();
  }

  String _normalizar(String texto) {
    const acentuados = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const simples = 'aaaaaeeeeiiiiooooouuuucn';
    var normalizado = texto.toLowerCase();
    for (var indice = 0; indice < acentuados.length; indice++) {
      normalizado = normalizado.replaceAll(acentuados[indice], simples[indice]);
    }
    return normalizado.replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }
}
