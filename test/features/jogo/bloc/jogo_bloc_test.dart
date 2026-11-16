import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:llm_os/features/jogo/bloc/jogo_bloc.dart';
import 'package:llm_os/features/jogo/data/dado_treino.dart';
import 'package:llm_os/features/jogo/data/jogo_repositorio.dart';

void main() {
  group('JogoBloc: coleta e auditoria', () {
    test('coleta um lote, audita e remove apenas suspeitos', () async {
      final repositorio = _RepositorioMemoria();
      final bloc = JogoBloc(repositorio, aleatorio: Random(7));

      final carregado = bloc.stream.firstWhere((estado) => estado.carregado);
      bloc.add(const JogoInicializacaoSolicitada());
      await carregado;

      final coletado = bloc.stream.firstWhere((estado) => estado.quantidadeDados == 4);
      bloc.add(const ColetaSolicitada());
      final estadoColetado = await coletado;
      expect(estadoColetado.perguntasUsadas.length, 4);
      expect(estadoColetado.pendentesAuditoria, 4);

      final auditado = bloc.stream.firstWhere(
        (estado) => estado.pendentesAuditoria == 0 && estado.creditos == 90,
      );
      bloc.add(const AuditoriaSolicitada());
      final estadoAuditado = await auditado;
      expect(estadoAuditado.dados.every((dado) => dado.auditado), isTrue);

      final suspeitosRemovidos = bloc.stream.firstWhere(
        (estado) => estado.dados.every((dado) => !(dado.auditado && dado.ruim)),
      );
      bloc.add(const SuspeitosRemovidos());
      final estadoFinal = await suspeitosRemovidos;
      expect(estadoFinal.quantidadeDados, lessThanOrEqualTo(4));
      expect(repositorio.estadoSalvo, isNotNull);

      await bloc.close();
    });

    test('mantém as perguntas usadas após serializar o progresso', () {
      const original = JogoEstado(
        creditos: 90,
        dados: [],
        perguntasUsadas: {'geo|Qual é a capital do Brasil?'},
        carregado: true,
      );

      final restaurado = JogoEstado.fromJson(original.toJson());

      expect(restaurado.creditos, 90);
      expect(restaurado.perguntasUsadas, original.perguntasUsadas);
      expect(restaurado.carregado, isTrue);
    });

    test('treina apenas exemplos aprovados, aplica custo e persiste a época', () async {
      final dados = [
        for (var i = 0; i < 6; i++)
          DadoTreino(
            id: 'ok-$i',
            categoriaId: 'geo',
            categoriaNome: 'Geografia',
            pergunta: 'Pergunta aprovada $i?',
            resposta: 'Resposta $i.',
            auditado: true,
          ),
        const DadoTreino(
          id: 'suspeito',
          categoriaId: 'geo',
          categoriaNome: 'Geografia',
          pergunta: 'Pergunta suspeita?',
          resposta: 'Resposta errada.',
          ruim: true,
          auditado: true,
        ),
        const DadoTreino(
          id: 'novo',
          categoriaId: 'geo',
          categoriaNome: 'Geografia',
          pergunta: 'Pergunta nova?',
          resposta: 'Resposta ainda não auditada.',
        ),
      ];
      final estadoInicial = JogoEstado(
        creditos: 30,
        dados: dados,
        perguntasUsadas: {for (final dado in dados) 'geo|${dado.pergunta}'},
        carregado: true,
      );
      final repositorio = _RepositorioMemoria()..estadoSalvo = estadoInicial.toJson();
      final bloc = JogoBloc(
        repositorio,
        duracaoTreino: const Duration(milliseconds: 10),
        intervaloTreino: const Duration(milliseconds: 1),
      );

      final carregado = bloc.stream.firstWhere((estado) => estado.carregado);
      bloc.add(const JogoInicializacaoSolicitada());
      await carregado;

      final concluido = bloc.stream.firstWhere(
        (estado) => !estado.treinoEmAndamento && estado.epocasTreinadas == 1,
      );
      bloc.add(const TreinoSolicitado());
      final resultado = await concluido;

      expect(resultado.creditos, 24); // 5 + (6 ~/ 4)
      expect(resultado.epocasTreinadas, 1);
      expect(resultado.dados.where((dado) => dado.treinado).length, 6);
      expect(resultado.dados.firstWhere((dado) => dado.id == 'suspeito').treinado, isFalse);
      expect(resultado.dados.firstWhere((dado) => dado.id == 'novo').treinado, isFalse);
      expect(repositorio.estadoSalvo?['epocasTreinadas'], 1);
      expect(repositorio.estadoSalvo?['creditos'], 24);

      await bloc.close();
    });

    test('não inicia treino sem exemplos aprovados auditados', () async {
      const dado = DadoTreino(
        id: 'novo',
        categoriaId: 'geo',
        categoriaNome: 'Geografia',
        pergunta: 'Pergunta nova?',
        resposta: 'Resposta.',
      );
      final inicial = JogoEstado(
        creditos: 30,
        dados: const [dado],
        carregado: true,
      );
      final repositorio = _RepositorioMemoria()..estadoSalvo = inicial.toJson();
      final bloc = JogoBloc(repositorio);

      final carregado = bloc.stream.firstWhere((estado) => estado.carregado);
      bloc.add(const JogoInicializacaoSolicitada());
      await carregado;
      final recusado = bloc.stream.firstWhere(
        (estado) => estado.mensagem?.contains('Audite e aprove') ?? false,
      );
      bloc.add(const TreinoSolicitado());
      final resultado = await recusado;

      expect(resultado.creditos, 30);
      expect(resultado.epocasTreinadas, 0);
      expect(resultado.treinoEmAndamento, isFalse);
      expect(repositorio.estadoSalvo?['creditos'], 30);

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
