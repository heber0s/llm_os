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
    CategoriaDados(id: 'ger', nome: 'Conhecimentos gerais'),
    CategoriaDados(id: 'por', nome: 'Português'),
    CategoriaDados(id: 'tec', nome: 'Tecnologia'),
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
    'ger': [
      PerguntaResposta('Quantos dias tem uma semana?', 'Sete.'),
      PerguntaResposta('Quantos meses tem um ano?', 'Doze.'),
      PerguntaResposta('Qual planeta é conhecido como planeta vermelho?', 'Marte.'),
      PerguntaResposta('Qual é a forma de uma bola?', 'Esfera.'),
      PerguntaResposta('Quantas horas tem um dia?', 'Vinte e quatro.'),
    ],
    'por': [
      PerguntaResposta('Qual é o plural de pão?', 'Pães.'),
      PerguntaResposta('Qual é o feminino de ator?', 'Atriz.'),
      PerguntaResposta('Qual é o contrário de claro?', 'Escuro.'),
      PerguntaResposta('Qual é o plural de animal?', 'Animais.'),
      PerguntaResposta('Qual é o contrário de rápido?', 'Devagar.'),
    ],
    'tec': [
      PerguntaResposta('O que significa CPU?', 'Unidade Central de Processamento.'),
      PerguntaResposta('O que significa IA?', 'Inteligência Artificial.'),
      PerguntaResposta('Em programação, o que é uma variável?', 'Um espaço nomeado que armazena um valor.'),
      PerguntaResposta('O que é um algoritmo?', 'Uma sequência de instruções para resolver um problema.'),
      PerguntaResposta('O que significa HTML?', 'Linguagem de Marcação de Hipertexto.'),
    ],
  };

  static CategoriaDados categoriaPorId(String id) => categorias.firstWhere(
        (categoria) => categoria.id == id,
        orElse: () => categorias.first,
      );
}
