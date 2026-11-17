import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:llm_os/features/jogo/bloc/jogo_bloc.dart';
import 'package:llm_os/features/jogo/data/dado_treino.dart';
import 'package:llm_os/features/jogo/data/jogo_repositorio.dart';

void main() {
  group('JogoBloc: renda passiva e bot coletor', () {
    test('concede renda do hardware e da internet a cada ciclo', () async {
      const inicial = JogoEstado(
        creditos: 20,
        nivelHardware: 2,
        nivelInternet: 3,
        carregado: true,
      );
      final repo = _RepositorioMemoria()..estadoSalvo = inicial.toJson();
      final bloc = JogoBloc(
        repo,
        intervaloRenda: const Duration(days: 1),
        intervaloBot: const Duration(days: 1),
      );
      final carregado = bloc.stream.firstWhere((estado) => estado.carregado);
      bloc.add(const JogoInicializacaoSolicitada());
      await carregado;

      final proximoSaldo = bloc.stream.firstWhere((estado) => estado.creditos == 32);
      bloc.add(const RendaPassivaTick());
      final resultado = await proximoSaldo;

      expect(resultado.rendaPassivaPorCiclo, 12); // 6 do hardware + 6 da internet.
      expect(repo.estadoSalvo?['creditos'], 32);
      await bloc.close();
    });

    test('bot coleta a quantidade do nível e não repete perguntas', () async {
      const inicial = JogoEstado(
        creditos: 900,
        nivelBot: 2,
        categoriaSelecionada: 'geo',
        carregado: true,
      );
      final repo = _RepositorioMemoria()..estadoSalvo = inicial.toJson();
      final bloc = JogoBloc(
        repo,
        aleatorio: Random(3),
        intervaloRenda: const Duration(days: 1),
        intervaloBot: const Duration(days: 1),
      );
      final carregado = bloc.stream.firstWhere((estado) => estado.carregado);
      bloc.add(const JogoInicializacaoSolicitada());
      await carregado;

      final coletado = bloc.stream.firstWhere((estado) => estado.dados.length == 2);
      bloc.add(const BotColetaTick());
      final resultado = await coletado;

      expect(resultado.dados, hasLength(2));
      expect(resultado.perguntasUsadas, hasLength(2));
      expect(resultado.dados.every((dado) => dado.categoriaId == 'geo'), isTrue);
      expect(resultado.dados.every((dado) => !dado.auditado && !dado.treinado), isTrue);
      expect(repo.estadoSalvo?['perguntasUsadas'], hasLength(2));

      final proximoBot = bloc.stream.firstWhere(
        (estado) => estado.dados.length == 4 && estado.perguntasUsadas.length == 4,
      );
      bloc.add(const BotColetaTick());
      final rodada2 = await proximoBot;
      expect(rodada2.dados.map((dado) => dado.pergunta).toSet(), hasLength(4));
      await bloc.close();
    });

    test('bot limita a coleta ao espaço livre e não coleta no nível zero', () async {
      final dados = List<DadoTreino>.generate(
        39,
        (indice) => DadoTreino(
          id: 'existente-$indice',
          categoriaId: 'geo',
          categoriaNome: 'Geografia',
          pergunta: 'Pergunta anterior $indice?',
          resposta: 'Resposta $indice.',
        ),
      );
      final usadas = {for (final dado in dados) 'geo|${dado.pergunta}'};
      final quaseCheio = JogoEstado(
        creditos: 900,
        nivelBot: 3,
        categoriaSelecionada: 'geo',
        dados: dados,
        perguntasUsadas: usadas,
        carregado: true,
      );
      final repo = _RepositorioMemoria()..estadoSalvo = quaseCheio.toJson();
      final bloc = JogoBloc(
        repo,
        intervaloRenda: const Duration(days: 1),
        intervaloBot: const Duration(days: 1),
      );
      final carregado = bloc.stream.firstWhere((estado) => estado.carregado);
      bloc.add(const JogoInicializacaoSolicitada());
      await carregado;

      final coletado = bloc.stream.firstWhere((estado) => estado.dados.length == 40);
      bloc.add(const BotColetaTick());
      final resultado = await coletado;
      expect(resultado.espacoLivre, 0);
      expect(resultado.perguntasUsadas.length, 40);

      final semBot = JogoBloc(
        _RepositorioMemoria()..estadoSalvo = const JogoEstado(carregado: true).toJson(),
        intervaloRenda: const Duration(days: 1),
        intervaloBot: const Duration(days: 1),
      );
      final pronto = semBot.stream.firstWhere((estado) => estado.carregado);
      semBot.add(const JogoInicializacaoSolicitada());
      await pronto;
      semBot.add(const BotColetaTick());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(semBot.state.dados, isEmpty);
      await bloc.close();
      await semBot.close();
    });

    test('compra RAM, bot e internet com preços progressivos', () async {
      const inicial = JogoEstado(creditos: 500, carregado: true);
      final repo = _RepositorioMemoria()..estadoSalvo = inicial.toJson();
      final bloc = JogoBloc(
        repo,
        intervaloRenda: const Duration(days: 1),
        intervaloBot: const Duration(days: 1),
      );
      final carregado = bloc.stream.firstWhere((estado) => estado.carregado);
      bloc.add(const JogoInicializacaoSolicitada());
      await carregado;

      final ramPronta = bloc.stream.firstWhere((estado) => estado.nivelRam == 1);
      bloc.add(const UpgradeCompraSolicitada('ram'));
      final comRam = await ramPronta;
      expect(comRam.creditos, 420);

      final botPronto = bloc.stream.firstWhere((estado) => estado.nivelBot == 1);
      bloc.add(const UpgradeCompraSolicitada('bot'));
      final comBot = await botPronto;
      expect(comBot.creditos, 220);

      final internetPronta = bloc.stream.firstWhere((estado) => estado.nivelInternet == 1);
      bloc.add(const UpgradeCompraSolicitada('internet'));
      final comInternet = await internetPronta;
      expect(comInternet.creditos, 100);
      expect(comInternet.rendaPassivaPorCiclo, 3);
      expect(repo.estadoSalvo?['nivelRam'], 1);
      expect(repo.estadoSalvo?['nivelBot'], 1);
      expect(repo.estadoSalvo?['nivelInternet'], 1);
      await bloc.close();
    });

    test('persiste níveis de RAM, bot e internet', () {
      const original = JogoEstado(
        nivelRam: 2,
        nivelBot: 3,
        nivelInternet: 4,
      );
      final restaurado = JogoEstado.fromJson(original.toJson());
      expect(restaurado.nivelRam, 2);
      expect(restaurado.nivelBot, 3);
      expect(restaurado.nivelInternet, 4);
      expect(restaurado.rendaPassivaPorCiclo, 9);
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
