import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:llm_os/features/jogo/bloc/jogo_bloc.dart';
import 'package:llm_os/features/jogo/data/dado_treino.dart';
import 'package:llm_os/features/jogo/data/jogo_repositorio.dart';

void main() {
  group('Atividades do Navegador', () {
    test('RotuloPay paga pela avaliação correta e registra sequência', () async {
      const inicial = JogoEstado(creditos: 10);
      final repositorio = _RepositorioMemoria()..estadoSalvo = inicial.toJson();
      final bloc = JogoBloc(repositorio, aleatorio: Random(4));
      final carregado = bloc.stream.firstWhere((estado) => estado.carregado);
      bloc.add(const JogoInicializacaoSolicitada());
      await carregado;

      final rodada = bloc.stream.firstWhere((estado) => estado.rotuloPergunta != null);
      bloc.add(const RotuloPayNovaRodadaSolicitada());
      final tarefa = await rodada;
      final avaliada = bloc.stream.firstWhere((estado) => estado.creditos == 13);
      bloc.add(RotuloPayRespostaEnviada(tarefa.rotuloRespostaCorreta));
      final resultado = await avaliada;

      expect(resultado.rotuloSequencia, 1);
      expect(resultado.rotuloPergunta, isNull);
      expect(repositorio.estadoSalvo?['creditos'], 13);
      await bloc.close();
    });

    test('DigitaJá aceita acentos e caixa diferentes e paga 12 créditos', () async {
      const inicial = JogoEstado(creditos: 5);
      final repositorio = _RepositorioMemoria()..estadoSalvo = inicial.toJson();
      final bloc = JogoBloc(repositorio, aleatorio: Random(9));
      final carregado = bloc.stream.firstWhere((estado) => estado.carregado);
      bloc.add(const JogoInicializacaoSolicitada());
      await carregado;

      final frasePronta = bloc.stream.firstWhere((estado) => estado.digitaFrase != null);
      bloc.add(const DigitaJaNovaFraseSolicitada());
      final desafio = await frasePronta;
      final respondido = bloc.stream.firstWhere((estado) => estado.creditos == 17);
      bloc.add(DigitaJaRespostaEnviada(desafio.digitaFrase!.toUpperCase()));
      final resultado = await respondido;

      expect(resultado.creditos, 17);
      expect(resultado.mensagem, contains('+12 créditos'));
      await bloc.close();
    });

    test('DataMarket paga e impede vender novamente as mesmas perguntas', () async {
      final dados = [
        const DadoTreino(
          id: 'bom', categoriaId: 'geo', categoriaNome: 'Geografia',
          pergunta: 'Qual é a capital do Brasil?', resposta: 'Brasília.', treinado: true,
        ),
        const DadoTreino(
          id: 'ruim', categoriaId: 'mat', categoriaNome: 'Matemática',
          pergunta: 'Quanto é 7 + 5?', resposta: '15.', treinado: true, ruim: true,
        ),
      ];
      final inicial = JogoEstado(
        creditos: 20,
        dados: dados,
        perguntasUsadas: {for (final dado in dados) '${dado.categoriaId}|${dado.pergunta}'},
        carregado: true,
      );
      final repositorio = _RepositorioMemoria()..estadoSalvo = inicial.toJson();
      final bloc = JogoBloc(repositorio);
      final carregado = bloc.stream.firstWhere((estado) => estado.carregado);
      bloc.add(const JogoInicializacaoSolicitada());
      await carregado;

      final vendido = bloc.stream.firstWhere((estado) => estado.perguntasVendidas.length == 2);
      bloc.add(const DataMarketVendaSolicitada());
      final resultado = await vendido;
      expect(resultado.creditos, 20); // +2 e -4, com pagamento mínimo zero.

      final mensagemFinal = bloc.stream.firstWhere(
        (estado) => estado.dataMarketMensagem?.contains('Não há exemplos') ?? false,
      );
      bloc.add(const DataMarketVendaSolicitada());
      final segundoResultado = await mensagemFinal;
      expect(segundoResultado.creditos, 20);
      expect(repositorio.estadoSalvo?['perguntasVendidas'], hasLength(2));
      await bloc.close();
    });
  });
}

class _RepositorioMemoria implements JogoRepositorio {
  Map<String, dynamic>? estadoSalvo;

  @override
  Future<Map<String, dynamic>?> carregar() async => estadoSalvo;

  @override
  Future<void> salvar(Map<String, dynamic> dados) async {
    estadoSalvo = Map<String, dynamic>.from(dados);
  }

  @override
  Future<void> limpar() async {
    estadoSalvo = null;
  }
}
