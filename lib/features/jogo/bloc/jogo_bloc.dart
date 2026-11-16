import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/banco_perguntas.dart';
import '../data/dado_treino.dart';
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

class CategoriaColetaSelecionada extends JogoEvento {
  const CategoriaColetaSelecionada(this.categoriaId);
  final String categoriaId;

  @override
  List<Object?> get props => [categoriaId];
}

class ColetaSolicitada extends JogoEvento {
  const ColetaSolicitada();
}

class AuditoriaSolicitada extends JogoEvento {
  const AuditoriaSolicitada();
}

class SuspeitosRemovidos extends JogoEvento {
  const SuspeitosRemovidos();
}

class DadoRemovido extends JogoEvento {
  const DadoRemovido(this.dadoId);
  final String dadoId;

  @override
  List<Object?> get props => [dadoId];
}

class JogoEstado extends Equatable {
  const JogoEstado({
    this.creditos = 100,
    this.nivelHardware = 0,
    this.epocasTreinadas = 0,
    this.dados = const [],
    this.perguntasUsadas = const {},
    this.categoriaSelecionada = 'geo',
    this.carregado = false,
    this.mensagem,
  });

  final int creditos;
  final int nivelHardware;
  final int epocasTreinadas;
  final List<DadoTreino> dados;
  final Set<String> perguntasUsadas;
  final String categoriaSelecionada;
  final bool carregado;
  final String? mensagem;

  int get quantidadeDados => dados.length;
  int get capacidadeDados => 40;
  int get espacoLivre => capacidadeDados > quantidadeDados
      ? capacidadeDados - quantidadeDados
      : 0;
  int get pendentesAuditoria => dados.where((dado) => !dado.auditado).length;
  int get quantidadeSuspeitos => dados.where((dado) => dado.auditado && dado.ruim).length;

  JogoEstado copyWith({
    int? creditos,
    int? nivelHardware,
    int? epocasTreinadas,
    List<DadoTreino>? dados,
    Set<String>? perguntasUsadas,
    String? categoriaSelecionada,
    bool? carregado,
    String? mensagem,
    bool limparMensagem = false,
  }) =>
      JogoEstado(
        creditos: creditos ?? this.creditos,
        nivelHardware: nivelHardware ?? this.nivelHardware,
        epocasTreinadas: epocasTreinadas ?? this.epocasTreinadas,
        dados: dados ?? this.dados,
        perguntasUsadas: perguntasUsadas ?? this.perguntasUsadas,
        categoriaSelecionada: categoriaSelecionada ?? this.categoriaSelecionada,
        carregado: carregado ?? this.carregado,
        mensagem: limparMensagem ? null : (mensagem ?? this.mensagem),
      );

  factory JogoEstado.fromJson(Map<String, dynamic> json) {
    final listaDados = json['dados'];
    final dados = listaDados is List
        ? listaDados
            .whereType<Map>()
            .map((item) => DadoTreino.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false)
        : const <DadoTreino>[];
    final listaUsadas = json['perguntasUsadas'];
    final usadas = listaUsadas is List
        ? listaUsadas.whereType<String>().toSet()
        : <String>{
            for (final dado in dados) '${dado.categoriaId}|${dado.pergunta}',
          };

    return JogoEstado(
      creditos: _inteiro(json['creditos'], 100),
      nivelHardware: _inteiro(json['nivelHardware'], 0),
      epocasTreinadas: _inteiro(json['epocasTreinadas'], 0),
      dados: dados,
      perguntasUsadas: usadas,
      categoriaSelecionada: json['categoriaSelecionada'] as String? ?? 'geo',
      carregado: true,
    );
  }

  Map<String, dynamic> toJson() => {
        'creditos': creditos,
        'nivelHardware': nivelHardware,
        'epocasTreinadas': epocasTreinadas,
        'dados': dados.map((dado) => dado.toJson()).toList(growable: false),
        'perguntasUsadas': perguntasUsadas.toList(growable: false),
        'categoriaSelecionada': categoriaSelecionada,
      };

  static int _inteiro(Object? valor, int padrao) => valor is int ? valor : padrao;

  @override
  List<Object?> get props => [
        creditos,
        nivelHardware,
        epocasTreinadas,
        dados,
        perguntasUsadas,
        categoriaSelecionada,
        carregado,
        mensagem,
      ];
}

class JogoBloc extends Bloc<JogoEvento, JogoEstado> {
  JogoBloc(this._repositorio, {Random? aleatorio})
      : _aleatorio = aleatorio ?? Random(),
        super(const JogoEstado()) {
    on<JogoInicializacaoSolicitada>(_inicializar);
    on<JogoReiniciadoSolicitado>(_reiniciar);
    on<CategoriaColetaSelecionada>(_selecionarCategoria);
    on<ColetaSolicitada>(_coletar);
    on<AuditoriaSolicitada>(_auditar);
    on<SuspeitosRemovidos>(_removerSuspeitos);
    on<DadoRemovido>(_removerDado);
  }

  final JogoRepositorio _repositorio;
  final Random _aleatorio;
  int _sequenciaId = 0;

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
        mensagem: 'Não foi possível carregar o progresso salvo.',
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
        mensagem: 'O jogo reiniciou, mas o progresso não foi salvo.',
      ));
    }
  }

  Future<void> _selecionarCategoria(
    CategoriaColetaSelecionada evento,
    Emitter<JogoEstado> emit,
  ) async {
    if (!BancoPerguntas.perguntas.containsKey(evento.categoriaId)) return;
    await _publicar(
      state.copyWith(
        categoriaSelecionada: evento.categoriaId,
        limparMensagem: true,
      ),
      emit,
    );
  }

  Future<void> _coletar(
    ColetaSolicitada evento,
    Emitter<JogoEstado> emit,
  ) async {
    final pool = BancoPerguntas.perguntas[state.categoriaSelecionada] ?? const [];
    final categoria = BancoPerguntas.categoriaPorId(state.categoriaSelecionada);
    final livres = pool
        .where((item) =>
            !state.perguntasUsadas.contains('${categoria.id}|${item.pergunta}'))
        .toList();
    final vagas = state.espacoLivre;
    if (vagas == 0) {
      await _publicar(state.copyWith(mensagem: 'O dataset está cheio. Remova exemplos para liberar espaço.'), emit);
      return;
    }
    if (livres.isEmpty) {
      await _publicar(state.copyWith(mensagem: 'Você já coletou todas as perguntas desta categoria.'), emit);
      return;
    }

    const lotesPorHardware = [4, 6, 8, 12];
    final indiceHardware = state.nivelHardware.clamp(0, lotesPorHardware.length - 1).toInt();
    final lote = lotesPorHardware[indiceHardware];
    final quantidade = min(lote, min(vagas, livres.length)).toInt();
    final dados = [...state.dados];
    final usadas = {...state.perguntasUsadas};
    for (var indice = 0; indice < quantidade; indice++) {
      final pergunta = livres.removeAt(_aleatorio.nextInt(livres.length));
      final ruim = _aleatorio.nextDouble() < 0.30;
      final resposta = ruim ? _respostaIncorreta(categoria.id, pergunta) : pergunta.resposta;
      usadas.add('${categoria.id}|${pergunta.pergunta}');
      dados.insert(
        0,
        DadoTreino(
          id: '${DateTime.now().microsecondsSinceEpoch}_${_sequenciaId++}',
          categoriaId: categoria.id,
          categoriaNome: categoria.nome,
          pergunta: pergunta.pergunta,
          resposta: resposta,
          ruim: ruim,
        ),
      );
    }

    await _publicar(
      state.copyWith(
        dados: dados,
        perguntasUsadas: usadas,
        mensagem: 'Coleta concluída: $quantidade exemplo(s) adicionado(s). Audite antes de treinar.',
      ),
      emit,
    );
  }

  String _respostaIncorreta(String categoriaId, PerguntaResposta pergunta) {
    if (categoriaId == 'mat') {
      final numero = int.tryParse(pergunta.resposta.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
      final variacao = _aleatorio.nextInt(3) + 1;
      final sinal = _aleatorio.nextBool() ? variacao : -variacao;
      return '${numero + sinal}.';
    }
    final alternativas = (BancoPerguntas.perguntas[categoriaId] ?? const [])
        .where((item) => item.resposta != pergunta.resposta)
        .toList();
    if (alternativas.isEmpty) return 'Não sei.';
    return alternativas[_aleatorio.nextInt(alternativas.length)].resposta;
  }

  Future<void> _auditar(
    AuditoriaSolicitada evento,
    Emitter<JogoEstado> emit,
  ) async {
    if (state.dados.isEmpty) {
      await _publicar(state.copyWith(mensagem: 'Colete alguns exemplos antes de auditar.'), emit);
      return;
    }
    if (state.pendentesAuditoria == 0) {
      await _publicar(state.copyWith(mensagem: 'Todos os exemplos já foram auditados.'), emit);
      return;
    }
    const custo = 10;
    if (state.creditos < custo) {
      await _publicar(state.copyWith(mensagem: 'Auditoria custa 10 créditos; saldo insuficiente.'), emit);
      return;
    }

    final dados = state.dados
        .map((dado) => dado.copyWith(auditado: true))
        .toList(growable: false);
    final suspeitos = dados.where((dado) => dado.ruim).length;
    await _publicar(
      state.copyWith(
        creditos: state.creditos - custo,
        dados: dados,
        mensagem: suspeitos == 0
            ? 'Auditoria concluída: nenhum exemplo suspeito encontrado.'
            : 'Auditoria concluída: $suspeitos exemplo(s) suspeito(s). Você pode removê-los.',
      ),
      emit,
    );
  }

  Future<void> _removerSuspeitos(
    SuspeitosRemovidos evento,
    Emitter<JogoEstado> emit,
  ) async {
    final suspeitos = state.quantidadeSuspeitos;
    if (suspeitos == 0) {
      await _publicar(state.copyWith(mensagem: 'Não há suspeitos auditados para remover.'), emit);
      return;
    }
    final dados = state.dados
        .where((dado) => !(dado.auditado && dado.ruim))
        .toList(growable: false);
    await _publicar(
      state.copyWith(
        dados: dados,
        mensagem: '$suspeitos exemplo(s) suspeito(s) removido(s). As perguntas não serão coletadas novamente.',
      ),
      emit,
    );
  }

  Future<void> _removerDado(
    DadoRemovido evento,
    Emitter<JogoEstado> emit,
  ) async {
    final dados = state.dados.where((dado) => dado.id != evento.dadoId).toList(growable: false);
    if (dados.length == state.dados.length) return;
    await _publicar(
      state.copyWith(dados: dados, mensagem: 'Exemplo removido do dataset.'),
      emit,
    );
  }

  Future<void> _publicar(JogoEstado novoEstado, Emitter<JogoEstado> emit) async {
    emit(novoEstado);
    try {
      await _repositorio.salvar(novoEstado.toJson());
    } catch (_) {
      emit(novoEstado.copyWith(mensagem: 'Alteração aplicada, mas não foi possível salvar o progresso.'));
    }
  }
}
