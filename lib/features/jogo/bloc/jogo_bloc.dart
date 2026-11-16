import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/jogo_repositorio.dart';

abstract class JogoEvento extends Equatable {
  const JogoEvento();

  @override
  List<Object?> get props => const [];
}

class JogoInicializacaoSolicitada extends JogoEvento {
  const JogoInicializacaoSolicitada();
}

class JogoReiniciadoSolicitado extends JogoEvento {
  const JogoReiniciadoSolicitado();
}

class JogoEstado extends Equatable {
  const JogoEstado({
    this.creditos = 100,
    this.nivelHardware = 0,
    this.epocasTreinadas = 0,
    this.quantidadeDados = 0,
    this.carregado = false,
    this.erro,
  });

  final int creditos;
  final int nivelHardware;
  final int epocasTreinadas;
  final int quantidadeDados;
  final bool carregado;
  final String? erro;

  JogoEstado copyWith({
    int? creditos,
    int? nivelHardware,
    int? epocasTreinadas,
    int? quantidadeDados,
    bool? carregado,
    String? erro,
    bool limparErro = false,
  }) {
    return JogoEstado(
      creditos: creditos ?? this.creditos,
      nivelHardware: nivelHardware ?? this.nivelHardware,
      epocasTreinadas: epocasTreinadas ?? this.epocasTreinadas,
      quantidadeDados: quantidadeDados ?? this.quantidadeDados,
      carregado: carregado ?? this.carregado,
      erro: limparErro ? null : (erro ?? this.erro),
    );
  }

  factory JogoEstado.fromJson(Map<String, dynamic> json) {
    return JogoEstado(
      creditos: _inteiro(json['creditos'], 100),
      nivelHardware: _inteiro(json['nivelHardware'], 0),
      epocasTreinadas: _inteiro(json['epocasTreinadas'], 0),
      quantidadeDados: _inteiro(json['quantidadeDados'], 0),
      carregado: true,
    );
  }

  Map<String, dynamic> toJson() => {
        'creditos': creditos,
        'nivelHardware': nivelHardware,
        'epocasTreinadas': epocasTreinadas,
        'quantidadeDados': quantidadeDados,
      };

  static int _inteiro(Object? valor, int padrao) =>
      valor is int ? valor : padrao;

  @override
  List<Object?> get props => [
        creditos,
        nivelHardware,
        epocasTreinadas,
        quantidadeDados,
        carregado,
        erro,
      ];
}

class JogoBloc extends Bloc<JogoEvento, JogoEstado> {
  JogoBloc(this._repositorio) : super(const JogoEstado()) {
    on<JogoInicializacaoSolicitada>(_inicializar);
    on<JogoReiniciadoSolicitado>(_reiniciar);
  }

  final JogoRepositorio _repositorio;

  Future<void> _inicializar(
    JogoInicializacaoSolicitada evento,
    Emitter<JogoEstado> emit,
  ) async {
    try {
      final dados = await _repositorio.carregar();
      emit(dados == null
          ? const JogoEstado(carregado: true)
          : JogoEstado.fromJson(dados));
    } catch (_) {
      emit(const JogoEstado(
        carregado: true,
        erro: 'Não foi possível carregar o progresso salvo.',
      ));
    }
  }

  Future<void> _reiniciar(
    JogoReiniciadoSolicitado evento,
    Emitter<JogoEstado> emit,
  ) async {
    const novoEstado = JogoEstado(carregado: true);
    emit(novoEstado);
    try {
      await _repositorio.limpar();
      await _repositorio.salvar(novoEstado.toJson());
    } catch (_) {
      emit(novoEstado.copyWith(
        erro: 'O jogo reiniciou, mas o progresso não foi salvo.',
      ));
    }
  }
}
