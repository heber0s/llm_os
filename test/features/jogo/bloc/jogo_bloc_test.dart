import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:llm_os/features/jogo/bloc/jogo_bloc.dart';
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
