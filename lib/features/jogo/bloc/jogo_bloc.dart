import 'dart:async';
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

class TreinoSolicitado extends JogoEvento {
  const TreinoSolicitado();
}

class HardwareCompraSolicitada extends JogoEvento {
  const HardwareCompraSolicitada();
}

class UpgradeCompraSolicitada extends JogoEvento {
  const UpgradeCompraSolicitada(this.upgradeId);
  final String upgradeId;

  @override
  List<Object?> get props => [upgradeId];
}

class PacoteCompraSolicitada extends JogoEvento {
  const PacoteCompraSolicitada(this.categoriaId);
  final String categoriaId;

  @override
  List<Object?> get props => [categoriaId];
}

class RotuloPayNovaRodadaSolicitada extends JogoEvento {
  const RotuloPayNovaRodadaSolicitada();
}

class RotuloPayRespostaEnviada extends JogoEvento {
  const RotuloPayRespostaEnviada(this.julgouCorreta);
  final bool julgouCorreta;

  @override
  List<Object?> get props => [julgouCorreta];
}

class DigitaJaNovaFraseSolicitada extends JogoEvento {
  const DigitaJaNovaFraseSolicitada();
}

class DigitaJaRespostaEnviada extends JogoEvento {
  const DigitaJaRespostaEnviada(this.resposta);
  final String resposta;

  @override
  List<Object?> get props => [resposta];
}

class DataMarketVendaSolicitada extends JogoEvento {
  const DataMarketVendaSolicitada();
}

class RendaPassivaTick extends JogoEvento {
  const RendaPassivaTick();
}

class BotColetaTick extends JogoEvento {
  const BotColetaTick();
}

abstract final class CatalogoLoja {
  static const List<int> precosHardware = [0, 150, 500, 1500];
  static const List<String> nomesHardware = [
    'Notebook velho',
    'GPU de entrada',
    'Workstation',
    'Servidor',
  ];
  static const List<String> modelosHardware = [
    'SmolLM2 135M',
    'SmolLM2 360M',
    'Qwen2.5 0.5B',
    'Qwen2.5 1.5B',
  ];
  static const Map<String, int> precosPacotes = {
    'ger': 120,
    'por': 200,
    'tec': 350,
  };
  static const Map<String, String> nomesPacotes = {
    'ger': 'Conhecimentos gerais',
    'por': 'Português',
    'tec': 'Tecnologia',
  };
  static const int precoBaseSsd = 60;
  static const int precoBaseCooler = 100;
  static const int precoBaseRam = 80;
  static const int precoBaseBot = 200;
  static const int precoBaseInternet = 120;
  static int precoSsd(int nivel) => precoBaseSsd * (nivel + 1);
  static int precoCooler(int nivel) => precoBaseCooler * (nivel + 1);
  static int precoRam(int nivel) => precoBaseRam * (nivel + 1);
  static int precoBot(int nivel) => precoBaseBot * (nivel + 1);
  static int precoInternet(int nivel) => precoBaseInternet * (nivel + 1);
}

abstract final class AtividadesNavegador {
  static const List<String> frasesDigitaJa = [
    'Dados limpos ajudam o modelo a responder melhor.',
    'Um bom conjunto de exemplos vale mais que muitos dados ruins.',
    'Revise cada resposta antes de iniciar o treinamento.',
    'O pequeno robô está aprendendo com cuidado.',
    'Organizar informações é parte importante da inteligência artificial.',
    'Cada melhoria aproxima seu computador do próximo nível.',
    'Perguntas claras ajudam a encontrar respostas úteis.',
    'Treinar com qualidade é melhor do que treinar com pressa.',
  ];
}

class JogoEstado extends Equatable {
  const JogoEstado({
    this.creditos = 100,
    this.nivelHardware = 0,
    this.nivelSsd = 0,
    this.nivelCooler = 0,
    this.nivelRam = 0,
    this.nivelBot = 0,
    this.nivelInternet = 0,
    this.categoriasLiberadas = const {'geo', 'mat', 'nat'},
    this.epocasTreinadas = 0,
    this.dados = const [],
    this.perguntasUsadas = const {},
    this.categoriaSelecionada = 'geo',
    this.carregado = false,
    this.mensagem,
    this.treinoEmAndamento = false,
    this.progressoTreino = 0,
    this.lossTreino = 2.8,
    this.rotuloPergunta,
    this.rotuloResposta,
    this.rotuloRespostaCorreta = false,
    this.rotuloSequencia = 0,
    this.digitaFrase,
    this.dataMarketMensagem,
    this.perguntasVendidas = const {},
  });

  final int creditos;
  final int nivelHardware;
  final int nivelSsd;
  final int nivelCooler;
  final int nivelRam;
  final int nivelBot;
  final int nivelInternet;
  final Set<String> categoriasLiberadas;
  final int epocasTreinadas;
  final List<DadoTreino> dados;
  final Set<String> perguntasUsadas;
  final String categoriaSelecionada;
  final bool carregado;
  final String? mensagem;
  final bool treinoEmAndamento;
  final double progressoTreino;
  final double lossTreino;
  final String? rotuloPergunta;
  final String? rotuloResposta;
  final bool rotuloRespostaCorreta;
  final int rotuloSequencia;
  final String? digitaFrase;
  final String? dataMarketMensagem;
  final Set<String> perguntasVendidas;

  int get quantidadeDados => dados.length;
  int get capacidadeDados => 40 + (nivelSsd * 40);
  int get rendaPassivaPorCiclo {
    const rendasHardware = [1, 3, 6, 12];
    final nivel = nivelHardware.clamp(0, rendasHardware.length - 1).toInt();
    return rendasHardware[nivel] + (nivelInternet * 2);
  }
  int get espacoLivre => capacidadeDados > quantidadeDados
      ? capacidadeDados - quantidadeDados
      : 0;
  int get pendentesAuditoria => dados.where((dado) => !dado.auditado).length;
  int get quantidadeSuspeitos => dados.where((dado) => dado.auditado && dado.ruim).length;

  JogoEstado copyWith({
    int? creditos,
    int? nivelHardware,
    int? nivelSsd,
    int? nivelCooler,
    int? nivelRam,
    int? nivelBot,
    int? nivelInternet,
    Set<String>? categoriasLiberadas,
    int? epocasTreinadas,
    List<DadoTreino>? dados,
    Set<String>? perguntasUsadas,
    String? categoriaSelecionada,
    bool? carregado,
    String? mensagem,
    bool? treinoEmAndamento,
    double? progressoTreino,
    double? lossTreino,
    String? rotuloPergunta,
    String? rotuloResposta,
    bool? rotuloRespostaCorreta,
    int? rotuloSequencia,
    String? digitaFrase,
    String? dataMarketMensagem,
    Set<String>? perguntasVendidas,
    bool limparRotulo = false,
    bool limparMensagem = false,
  }) =>
      JogoEstado(
        creditos: creditos ?? this.creditos,
        nivelHardware: nivelHardware ?? this.nivelHardware,
        nivelSsd: nivelSsd ?? this.nivelSsd,
        nivelCooler: nivelCooler ?? this.nivelCooler,
        nivelRam: nivelRam ?? this.nivelRam,
        nivelBot: nivelBot ?? this.nivelBot,
        nivelInternet: nivelInternet ?? this.nivelInternet,
        categoriasLiberadas: categoriasLiberadas ?? this.categoriasLiberadas,
        epocasTreinadas: epocasTreinadas ?? this.epocasTreinadas,
        dados: dados ?? this.dados,
        perguntasUsadas: perguntasUsadas ?? this.perguntasUsadas,
        categoriaSelecionada: categoriaSelecionada ?? this.categoriaSelecionada,
        carregado: carregado ?? this.carregado,
        mensagem: limparMensagem ? null : (mensagem ?? this.mensagem),
        treinoEmAndamento: treinoEmAndamento ?? this.treinoEmAndamento,
        progressoTreino: progressoTreino ?? this.progressoTreino,
        lossTreino: lossTreino ?? this.lossTreino,
        rotuloPergunta: limparRotulo ? null : (rotuloPergunta ?? this.rotuloPergunta),
        rotuloResposta: limparRotulo ? null : (rotuloResposta ?? this.rotuloResposta),
        rotuloRespostaCorreta: rotuloRespostaCorreta ?? this.rotuloRespostaCorreta,
        rotuloSequencia: rotuloSequencia ?? this.rotuloSequencia,
        digitaFrase: digitaFrase ?? this.digitaFrase,
        dataMarketMensagem: dataMarketMensagem ?? this.dataMarketMensagem,
        perguntasVendidas: perguntasVendidas ?? this.perguntasVendidas,
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
      nivelSsd: _inteiro(json['nivelSsd'], 0),
      nivelCooler: _inteiro(json['nivelCooler'], 0),
      nivelRam: _inteiro(json['nivelRam'], 0),
      nivelBot: _inteiro(json['nivelBot'], 0),
      nivelInternet: _inteiro(json['nivelInternet'], 0),
      rotuloSequencia: _inteiro(json['rotuloSequencia'], 0),
      categoriasLiberadas: json['categoriasLiberadas'] is List
          ? (json['categoriasLiberadas'] as List).whereType<String>().toSet()
          : const {'geo', 'mat', 'nat'},
      perguntasVendidas: json['perguntasVendidas'] is List
          ? (json['perguntasVendidas'] as List).whereType<String>().toSet()
          : const {},
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
        'nivelSsd': nivelSsd,
        'nivelCooler': nivelCooler,
        'nivelRam': nivelRam,
        'nivelBot': nivelBot,
        'nivelInternet': nivelInternet,
        'categoriasLiberadas': categoriasLiberadas.toList(growable: false),
        'perguntasVendidas': perguntasVendidas.toList(growable: false),
        'rotuloSequencia': rotuloSequencia,
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
        nivelSsd,
        nivelCooler,
        nivelRam,
        nivelBot,
        nivelInternet,
        categoriasLiberadas,
        rotuloPergunta,
        rotuloResposta,
        rotuloRespostaCorreta,
        rotuloSequencia,
        digitaFrase,
        dataMarketMensagem,
        perguntasVendidas,
        epocasTreinadas,
        dados,
        perguntasUsadas,
        categoriaSelecionada,
        carregado,
        mensagem,
        treinoEmAndamento,
        progressoTreino,
        lossTreino,
      ];
}

class JogoBloc extends Bloc<JogoEvento, JogoEstado> {
  JogoBloc(
    this._repositorio, {
    Random? aleatorio,
    Duration duracaoTreino = const Duration(seconds: 10),
    Duration intervaloTreino = const Duration(milliseconds: 200),
    Duration intervaloRenda = const Duration(seconds: 10),
    Duration intervaloBot = const Duration(seconds: 20),
  })  : _aleatorio = aleatorio ?? Random(),
        _duracaoTreino = duracaoTreino,
        _intervaloTreino = intervaloTreino,
        _intervaloRenda = intervaloRenda,
        _intervaloBot = intervaloBot,
        super(const JogoEstado()) {
    on<JogoInicializacaoSolicitada>(_inicializar);
    on<JogoReiniciadoSolicitado>(_reiniciar);
    on<CategoriaColetaSelecionada>(_selecionarCategoria);
    on<ColetaSolicitada>(_coletar);
    on<AuditoriaSolicitada>(_auditar);
    on<SuspeitosRemovidos>(_removerSuspeitos);
    on<DadoRemovido>(_removerDado);
    on<TreinoSolicitado>(_treinar);
    on<HardwareCompraSolicitada>(_comprarHardware);
    on<UpgradeCompraSolicitada>(_comprarUpgrade);
    on<PacoteCompraSolicitada>(_comprarPacote);
    on<RotuloPayNovaRodadaSolicitada>(_novaRodadaRotulo);
    on<RotuloPayRespostaEnviada>(_responderRotulo);
    on<DigitaJaNovaFraseSolicitada>(_novaFraseDigita);
    on<DigitaJaRespostaEnviada>(_responderDigita);
    on<DataMarketVendaSolicitada>(_venderNoDataMarket);
    on<RendaPassivaTick>(_tickRenda);
    on<BotColetaTick>(_tickBot);
    _timerRenda = Timer.periodic(_intervaloRenda, (_) {
      if (!isClosed) add(const RendaPassivaTick());
    });
    _timerBot = Timer.periodic(_intervaloBot, (_) {
      if (!isClosed) add(const BotColetaTick());
    });
  }

  final JogoRepositorio _repositorio;
  final Random _aleatorio;
  final Duration _duracaoTreino;
  final Duration _intervaloTreino;
  final Duration _intervaloRenda;
  final Duration _intervaloBot;
  late final Timer _timerRenda;
  late final Timer _timerBot;
  int _sequenciaId = 0;

  @override
  Future<void> close() {
    _timerRenda.cancel();
    _timerBot.cancel();
    return super.close();
  }

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
    if (_bloquearDuranteTreino(emit)) return;
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
    if (_bloquearDuranteTreino(emit)) return;
    if (!BancoPerguntas.perguntas.containsKey(evento.categoriaId) ||
        !state.categoriasLiberadas.contains(evento.categoriaId)) {
      await _publicar(state.copyWith(mensagem: 'Esse pacote de dados ainda não foi liberado.'), emit);
      return;
    }
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
    if (_bloquearDuranteTreino(emit)) return;
    if (!state.categoriasLiberadas.contains(state.categoriaSelecionada)) {
      await _publicar(state.copyWith(mensagem: 'Libere esse pacote na PixelStore antes de coletar.'), emit);
      return;
    }
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
    if (_bloquearDuranteTreino(emit)) return;
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
    if (_bloquearDuranteTreino(emit)) return;
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
    if (_bloquearDuranteTreino(emit)) return;
    final dados = state.dados.where((dado) => dado.id != evento.dadoId).toList(growable: false);
    if (dados.length == state.dados.length) return;
    await _publicar(
      state.copyWith(dados: dados, mensagem: 'Exemplo removido do dataset.'),
      emit,
    );
  }

  bool _bloquearDuranteTreino(Emitter<JogoEstado> emit) {
    if (!state.treinoEmAndamento) return false;
    emit(state.copyWith(mensagem: 'Aguarde o treino terminar antes de alterar o dataset.'));
    return true;
  }

  Future<void> _treinar(
    TreinoSolicitado evento,
    Emitter<JogoEstado> emit,
  ) async {
    if (state.treinoEmAndamento) return;

    final dadosAprovados = state.dados
        .where((dado) => dado.auditado && !dado.ruim && !dado.treinado)
        .toList(growable: false);
    if (dadosAprovados.isEmpty) {
      await _publicar(
        state.copyWith(mensagem: 'Audite e aprove exemplos antes de iniciar o treino.'),
        emit,
      );
      return;
    }

    final custo = 5 + dadosAprovados.length ~/ 4;
    if (state.creditos < custo) {
      await _publicar(
        state.copyWith(mensagem: 'O treino custa $custo créditos; saldo insuficiente.'),
        emit,
      );
      return;
    }

    final idsTreinados = dadosAprovados.map((dado) => dado.id).toSet();
    emit(state.copyWith(
      treinoEmAndamento: true,
      progressoTreino: 0,
      lossTreino: 2.8,
      mensagem: 'Treino iniciado com ${dadosAprovados.length} exemplo(s) aprovados.',
    ));

    const duracoesPorHardware = [10, 7, 5, 3];
    final nivel = state.nivelHardware.clamp(0, duracoesPorHardware.length - 1).toInt();
    final duracaoBase = _duracaoTreino == const Duration(seconds: 10)
        ? Duration(seconds: duracoesPorHardware[nivel])
        : _duracaoTreino;
    final duracaoEfetiva = Duration(
      milliseconds: max(1, (duracaoBase.inMilliseconds * pow(0.85, state.nivelCooler)).round()),
    );
    final intervaloMs = max(1, _intervaloTreino.inMilliseconds);
    final passos = max(1, (duracaoEfetiva.inMilliseconds / intervaloMs).ceil());
    final atrasoMs = max(1, (duracaoEfetiva.inMilliseconds / passos).ceil());
    for (var passo = 1; passo <= passos; passo++) {
      await Future<void>.delayed(Duration(milliseconds: atrasoMs));
      if (isClosed) return;
      final progresso = passo / passos;
      emit(state.copyWith(
        treinoEmAndamento: true,
        progressoTreino: progresso,
        lossTreino: 2.8 - (2.5 * progresso),
        limparMensagem: true,
      ));
    }

    final dadosAtualizados = state.dados
        .map((dado) => idsTreinados.contains(dado.id)
            ? dado.copyWith(treinado: true)
            : dado)
        .toList(growable: false);
    await _publicar(
      state.copyWith(
        creditos: state.creditos - custo,
        epocasTreinadas: state.epocasTreinadas + 1,
        dados: dadosAtualizados,
        treinoEmAndamento: false,
        progressoTreino: 1,
        lossTreino: 0.3,
        mensagem: 'Treino concluído! ${idsTreinados.length} exemplo(s) aprovado(s) incorporado(s).',
      ),
      emit,
    );
  }

  Future<void> _comprarHardware(
    HardwareCompraSolicitada evento,
    Emitter<JogoEstado> emit,
  ) async {
    if (_bloquearDuranteTreino(emit)) return;
    final proximoNivel = state.nivelHardware + 1;
    if (proximoNivel >= CatalogoLoja.precosHardware.length) {
      await _publicar(state.copyWith(mensagem: 'Você já possui o melhor hardware disponível.'), emit);
      return;
    }
    final custo = CatalogoLoja.precosHardware[proximoNivel];
    if (state.creditos < custo) {
      await _publicar(state.copyWith(mensagem: 'Hardware custa $custo créditos; saldo insuficiente.'), emit);
      return;
    }
    await _publicar(
      state.copyWith(
        nivelHardware: proximoNivel,
        creditos: state.creditos - custo,
        mensagem: '${CatalogoLoja.nomesHardware[proximoNivel]} adquirido! Modelo: ${CatalogoLoja.modelosHardware[proximoNivel]}.',
      ),
      emit,
    );
  }

  Future<void> _comprarUpgrade(
    UpgradeCompraSolicitada evento,
    Emitter<JogoEstado> emit,
  ) async {
    if (_bloquearDuranteTreino(emit)) return;
    final nivelAtual = switch (evento.upgradeId) {
      'ssd' => state.nivelSsd,
      'cooler' => state.nivelCooler,
      'ram' => state.nivelRam,
      'bot' => state.nivelBot,
      'internet' => state.nivelInternet,
      _ => null,
    };
    final nivelMaximo = switch (evento.upgradeId) {
      'ssd' => 6,
      'cooler' => 4,
      'ram' => 3,
      'bot' => 3,
      'internet' => 5,
      _ => 0,
    };
    if (nivelAtual == null) {
      await _publicar(state.copyWith(mensagem: 'Upgrade não encontrado.'), emit);
      return;
    }
    if (nivelAtual >= nivelMaximo) {
      await _publicar(state.copyWith(mensagem: 'Esse upgrade já está no nível máximo.'), emit);
      return;
    }
    final custo = switch (evento.upgradeId) {
      'ssd' => CatalogoLoja.precoSsd(nivelAtual),
      'cooler' => CatalogoLoja.precoCooler(nivelAtual),
      'ram' => CatalogoLoja.precoRam(nivelAtual),
      'bot' => CatalogoLoja.precoBot(nivelAtual),
      _ => CatalogoLoja.precoInternet(nivelAtual),
    };
    if (state.creditos < custo) {
      await _publicar(state.copyWith(mensagem: 'Upgrade custa $custo créditos; saldo insuficiente.'), emit);
      return;
    }
    final novoNivel = nivelAtual + 1;
    final atualizado = switch (evento.upgradeId) {
      'ssd' => state.copyWith(nivelSsd: novoNivel),
      'cooler' => state.copyWith(nivelCooler: novoNivel),
      'ram' => state.copyWith(nivelRam: novoNivel),
      'bot' => state.copyWith(nivelBot: novoNivel),
      _ => state.copyWith(nivelInternet: novoNivel),
    };
    final descricao = switch (evento.upgradeId) {
      'ssd' => 'Capacidade do dataset: ${atualizado.capacidadeDados} exemplos.',
      'cooler' => 'O próximo treino será mais rápido.',
      'ram' => 'Seu modelo poderá consultar ${1 + atualizado.nivelRam} exemplo(s) por resposta.',
      'bot' => 'O bot coletará ${atualizado.nivelBot} exemplo(s) a cada 20 segundos.',
      _ => 'Renda passiva agora: ${atualizado.rendaPassivaPorCiclo} cr a cada 10 segundos.',
    };
    await _publicar(
      atualizado.copyWith(
        creditos: state.creditos - custo,
        mensagem: '${evento.upgradeId.toUpperCase()} aprimorado para nível $novoNivel. $descricao',
      ),
      emit,
    );
  }

  Future<void> _comprarPacote(
    PacoteCompraSolicitada evento,
    Emitter<JogoEstado> emit,
  ) async {
    if (_bloquearDuranteTreino(emit)) return;
    final custo = CatalogoLoja.precosPacotes[evento.categoriaId];
    final nome = CatalogoLoja.nomesPacotes[evento.categoriaId];
    if (custo == null || nome == null || !BancoPerguntas.perguntas.containsKey(evento.categoriaId)) {
      await _publicar(state.copyWith(mensagem: 'Pacote de dados indisponível.'), emit);
      return;
    }
    if (state.categoriasLiberadas.contains(evento.categoriaId)) {
      await _publicar(state.copyWith(mensagem: 'Esse pacote já está liberado.'), emit);
      return;
    }
    if (state.creditos < custo) {
      await _publicar(state.copyWith(mensagem: 'Pacote custa $custo créditos; saldo insuficiente.'), emit);
      return;
    }
    await _publicar(
      state.copyWith(
        creditos: state.creditos - custo,
        categoriasLiberadas: {...state.categoriasLiberadas, evento.categoriaId},
        mensagem: 'Pacote "$nome" liberado. Já pode coletar exemplos no TreinaAI.',
      ),
      emit,
    );
  }

  void _novaRodadaRotulo(
    RotuloPayNovaRodadaSolicitada evento,
    Emitter<JogoEstado> emit,
  ) {
    final pools = BancoPerguntas.perguntas.entries
        .where((entrada) => state.categoriasLiberadas.contains(entrada.key))
        .expand((entrada) => entrada.value.map((par) => (entrada.key, par)))
        .toList(growable: false);
    if (pools.isEmpty) {
      emit(state.copyWith(mensagem: 'Não há perguntas disponíveis para avaliar.'));
      return;
    }
    final item = pools[_aleatorio.nextInt(pools.length)];
    final correta = _aleatorio.nextBool();
    final resposta = correta
        ? item.$2.resposta
        : _respostaIncorreta(item.$1, item.$2);
    emit(state.copyWith(
      rotuloPergunta: item.$2.pergunta,
      rotuloResposta: resposta,
      rotuloRespostaCorreta: correta,
      limparMensagem: true,
    ));
  }

  Future<void> _responderRotulo(
    RotuloPayRespostaEnviada evento,
    Emitter<JogoEstado> emit,
  ) async {
    if (state.rotuloPergunta == null || state.rotuloResposta == null) {
      emit(state.copyWith(mensagem: 'Gere uma tarefa do RotuloPay primeiro.'));
      return;
    }
    final acertou = evento.julgouCorreta == state.rotuloRespostaCorreta;
    final sequencia = acertou ? state.rotuloSequencia + 1 : 0;
    final premioSequencia = acertou && sequencia % 5 == 0 ? 10 : 0;
    final variacao = acertou ? 3 + premioSequencia : -2;
    final creditos = (state.creditos + variacao).clamp(0, 1 << 30).toInt();
    await _publicar(
      state.copyWith(
        creditos: creditos,
        rotuloSequencia: sequencia,
        limparRotulo: true,
        mensagem: acertou
            ? premioSequencia > 0
                ? 'Classificação correta! +3 créditos e bônus de sequência +10.'
                : 'Classificação correta! +3 créditos.'
            : 'Classificação incorreta. −2 créditos e sequência reiniciada.',
      ),
      emit,
    );
  }

  void _novaFraseDigita(
    DigitaJaNovaFraseSolicitada evento,
    Emitter<JogoEstado> emit,
  ) {
    final indice = _aleatorio.nextInt(AtividadesNavegador.frasesDigitaJa.length);
    emit(state.copyWith(
      digitaFrase: AtividadesNavegador.frasesDigitaJa[indice],
      limparMensagem: true,
    ));
  }

  Future<void> _responderDigita(
    DigitaJaRespostaEnviada evento,
    Emitter<JogoEstado> emit,
  ) async {
    final frase = state.digitaFrase;
    if (frase == null) {
      emit(state.copyWith(mensagem: 'Gere uma frase do DigitaJá primeiro.'));
      return;
    }
    final correto = _normalizarTexto(evento.resposta) == _normalizarTexto(frase);
    final novosCreditos = state.creditos + (correto ? 12 : 0);
    final novaFrase = AtividadesNavegador.frasesDigitaJa[
      _aleatorio.nextInt(AtividadesNavegador.frasesDigitaJa.length)
    ];
    await _publicar(
      state.copyWith(
        creditos: novosCreditos,
        digitaFrase: novaFrase,
        mensagem: correto
            ? 'Muito bem! Frase digitada corretamente: +12 créditos.'
            : 'A frase não corresponde. Tente a próxima; não houve perda de créditos.',
      ),
      emit,
    );
  }

  String _normalizarTexto(String texto) {
    const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const para = 'aaaaaeeeeiiiiooooouuuuc';
    var normalizado = texto.toLowerCase();
    for (var i = 0; i < de.length; i++) {
      normalizado = normalizado.replaceAll(de[i], para[i]);
    }
    return normalizado
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _venderNoDataMarket(
    DataMarketVendaSolicitada evento,
    Emitter<JogoEstado> emit,
  ) async {
    final disponiveis = state.dados.where((dado) {
      final chave = '${dado.categoriaId}|${dado.pergunta}';
      return dado.treinado && !state.perguntasVendidas.contains(chave);
    }).toList(growable: false);
    if (disponiveis.isEmpty) {
      await _publicar(
        state.copyWith(dataMarketMensagem: 'Não há exemplos treinados novos para vender.'),
        emit,
      );
      return;
    }
    var saldo = 0;
    for (final dado in disponiveis) {
      saldo += dado.ruim ? -4 : 2;
    }
    saldo = saldo < 0 ? 0 : saldo;
    final vendidas = {
      ...state.perguntasVendidas,
      for (final dado in disponiveis) '${dado.categoriaId}|${dado.pergunta}',
    };
    final dados = state.dados.map((dado) {
      return disponiveis.any((item) => item.id == dado.id)
          ? dado.copyWith(vendido: true)
          : dado;
    }).toList(growable: false);
    final corretos = disponiveis.where((dado) => !dado.ruim).length;
    final incorretos = disponiveis.length - corretos;
    await _publicar(
      state.copyWith(
        creditos: state.creditos + saldo,
        dados: dados,
        perguntasVendidas: vendidas,
        dataMarketMensagem: 'Venda concluída: $corretos corretos, $incorretos incorretos. +$saldo créditos.',
      ),
      emit,
    );
  }

  Future<void> _tickRenda(
    RendaPassivaTick evento,
    Emitter<JogoEstado> emit,
  ) async {
    if (!state.carregado) return;
    final novosCreditos = state.creditos + state.rendaPassivaPorCiclo;
    await _publicar(state.copyWith(creditos: novosCreditos), emit);
  }

  Future<void> _tickBot(
    BotColetaTick evento,
    Emitter<JogoEstado> emit,
  ) async {
    if (!state.carregado || state.treinoEmAndamento || state.nivelBot <= 0) return;
    if (state.espacoLivre <= 0 || !state.categoriasLiberadas.contains(state.categoriaSelecionada)) return;

    final categoriaId = state.categoriaSelecionada;
    final categoria = BancoPerguntas.categoriaPorId(categoriaId);
    final livres = (BancoPerguntas.perguntas[categoriaId] ?? const <PerguntaResposta>[])
        .where((item) => !state.perguntasUsadas.contains('$categoriaId|${item.pergunta}'))
        .toList();
    final quantidade = min(state.nivelBot, min(state.espacoLivre, livres.length)).toInt();
    if (quantidade <= 0) return;

    final dados = [...state.dados];
    final usadas = {...state.perguntasUsadas};
    for (var indice = 0; indice < quantidade; indice++) {
      final pergunta = livres.removeAt(_aleatorio.nextInt(livres.length));
      final ruim = _aleatorio.nextDouble() < 0.30;
      final resposta = ruim ? _respostaIncorreta(categoriaId, pergunta) : pergunta.resposta;
      usadas.add('$categoriaId|${pergunta.pergunta}');
      dados.insert(
        0,
        DadoTreino(
          id: '${DateTime.now().microsecondsSinceEpoch}_${_sequenciaId++}',
          categoriaId: categoriaId,
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
        mensagem: 'Bot coletor adicionou $quantidade exemplo(s) de ${categoria.nome}.',
      ),
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
