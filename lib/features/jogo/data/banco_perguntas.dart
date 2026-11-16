class CategoriaDados {
  const CategoriaDados({required this.id, required this.nome});

  final String id;
  final String nome;
}

class PerguntaResposta {
  const PerguntaResposta(this.pergunta, this.resposta);

  final String pergunta;
  final String resposta;
}

abstract final class BancoPerguntas {
  static const List<CategoriaDados> categorias = [
    CategoriaDados(id: 'geo', nome: 'Geografia'),
    CategoriaDados(id: 'mat', nome: 'Matemática'),
    CategoriaDados(id: 'nat', nome: 'Natureza'),
  ];

  static const Map<String, List<PerguntaResposta>> perguntas = {
    'geo': [
      PerguntaResposta('Qual é a capital do Brasil?', 'Brasília.'),
      PerguntaResposta('Qual é a capital da França?', 'Paris.'),
      PerguntaResposta('Qual é a capital do Japão?', 'Tóquio.'),
      PerguntaResposta('Qual é a capital de Portugal?', 'Lisboa.'),
      PerguntaResposta('Qual é a capital da Argentina?', 'Buenos Aires.'),
      PerguntaResposta('Qual é a capital do Chile?', 'Santiago.'),
      PerguntaResposta('Qual é a capital do Canadá?', 'Ottawa.'),
      PerguntaResposta('Qual é a capital da Itália?', 'Roma.'),
    ],
    'mat': [
      PerguntaResposta('Quanto é 7 + 5?', '12.'),
      PerguntaResposta('Quanto é 9 + 8?', '17.'),
      PerguntaResposta('Quanto é 14 - 6?', '8.'),
      PerguntaResposta('Quanto é 20 - 9?', '11.'),
      PerguntaResposta('Quanto é 4 × 6?', '24.'),
      PerguntaResposta('Quanto é 7 × 3?', '21.'),
      PerguntaResposta('Quanto é 32 + 18?', '50.'),
      PerguntaResposta('Quanto é 45 - 17?', '28.'),
    ],
    'nat': [
      PerguntaResposta('Qual é a cor do céu em um dia limpo?', 'Azul.'),
      PerguntaResposta('Quantas patas tem uma aranha?', 'Oito.'),
      PerguntaResposta('Qual é o som típico de um gato?', 'Miau.'),
      PerguntaResposta('Em qual estação as folhas costumam cair?', 'Outono.'),
      PerguntaResposta('Qual é o maior animal terrestre?', 'Elefante-africano.'),
      PerguntaResposta('Qual gás as plantas absorvem?', 'Dióxido de carbono.'),
      PerguntaResposta('A água congela em qual estado?', 'Sólido.'),
      PerguntaResposta('Qual estrela ilumina a Terra durante o dia?', 'O Sol.'),
    ],
  };

  static CategoriaDados categoriaPorId(String id) => categorias.firstWhere(
        (categoria) => categoria.id == id,
        orElse: () => categorias.first,
      );
}
