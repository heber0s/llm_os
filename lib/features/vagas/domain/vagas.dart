import 'dart:math';

import '../../jogo/data/banco_perguntas.dart';

class VagaFreela {
  const VagaFreela({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categorias,
    required this.quantidadePerguntas,
    required this.pagamentoMaximo,
    required this.hardwareMinimo,
  });

  final String id;
  final String titulo;
  final String descricao;
  final List<String> categorias;
  final int quantidadePerguntas;
  final int pagamentoMaximo;
  final int hardwareMinimo;

  static const List<VagaFreela> todas = [
    VagaFreela(id: 'suporte', titulo: 'Suporte ao cliente', descricao: 'Responda dúvidas rápidas de geografia.', categorias: ['geo'], quantidadePerguntas: 5, pagamentoMaximo: 30, hardwareMinimo: 0),
    VagaFreela(id: 'contas', titulo: 'Contas rápidas', descricao: 'Resolva operações matemáticas simples.', categorias: ['mat'], quantidadePerguntas: 5, pagamentoMaximo: 30, hardwareMinimo: 0),
    VagaFreela(id: 'natureza', titulo: 'Quiz da Natureza', descricao: 'Responda perguntas de ciências naturais.', categorias: ['nat'], quantidadePerguntas: 5, pagamentoMaximo: 30, hardwareMinimo: 0),
    VagaFreela(id: 'geral', titulo: 'Atendimento geral', descricao: 'Ajude clientes com conhecimentos gerais.', categorias: ['ger'], quantidadePerguntas: 6, pagamentoMaximo: 60, hardwareMinimo: 1),
    VagaFreela(id: 'revisor', titulo: 'Revisor de textos', descricao: 'Responda questões de português.', categorias: ['por'], quantidadePerguntas: 6, pagamentoMaximo: 70, hardwareMinimo: 1),
    VagaFreela(id: 'helpdesk', titulo: 'Helpdesk de TI', descricao: 'Resolva dúvidas básicas de tecnologia.', categorias: ['tec'], quantidadePerguntas: 6, pagamentoMaximo: 90, hardwareMinimo: 2),
    VagaFreela(id: 'maratona', titulo: 'Maratona de perguntas', descricao: 'Um conjunto variado de perguntas.', categorias: ['geo', 'mat', 'nat', 'ger', 'por', 'tec'], quantidadePerguntas: 10, pagamentoMaximo: 200, hardwareMinimo: 2),
    VagaFreela(id: 'corporativo', titulo: 'Contrato corporativo', descricao: 'Um contrato longo com perguntas variadas.', categorias: ['geo', 'mat', 'nat', 'ger', 'por', 'tec'], quantidadePerguntas: 15, pagamentoMaximo: 500, hardwareMinimo: 3),
  ];
}

class PerguntaVaga {
  const PerguntaVaga({required this.categoriaId, required this.pergunta, required this.respostaEsperada});

  final String categoriaId;
  final String pergunta;
  final String respostaEsperada;
}

List<PerguntaVaga> sortearPerguntasVaga({
  required VagaFreela vaga,
  required Random aleatorio,
}) {
  final pool = <PerguntaVaga>[];
  for (final categoriaId in vaga.categorias) {
    for (final par in BancoPerguntas.perguntas[categoriaId] ?? const <PerguntaResposta>[]) {
      pool.add(PerguntaVaga(categoriaId: categoriaId, pergunta: par.pergunta, respostaEsperada: par.resposta));
    }
  }
  pool.shuffle(aleatorio);
  return pool.take(vaga.quantidadePerguntas).toList(growable: false);
}
