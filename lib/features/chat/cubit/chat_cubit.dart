import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../jogo/bloc/jogo_bloc.dart';
import '../data/servico_llm.dart';
import '../domain/busca_exemplos.dart';

class ChatEstado extends Equatable {
  const ChatEstado({
    this.mensagens = const [],
    this.temperatura = 0.2,
    this.pensando = false,
    this.aviso,
  });

  final List<MensagemChat> mensagens;
  final double temperatura;
  final bool pensando;
  final String? aviso;

  ChatEstado copyWith({
    List<MensagemChat>? mensagens,
    double? temperatura,
    bool? pensando,
    String? aviso,
    bool limparAviso = false,
  }) =>
      ChatEstado(
        mensagens: mensagens ?? this.mensagens,
        temperatura: temperatura ?? this.temperatura,
        pensando: pensando ?? this.pensando,
        aviso: limparAviso ? null : (aviso ?? this.aviso),
      );

  @override
  List<Object?> get props => [mensagens, temperatura, pensando, aviso];
}

class ChatCubit extends Cubit<ChatEstado> {
  ChatCubit(
    this._jogoBloc, {
    ServicoLlm servico = const ServicoLlmSimulado(),
    BuscaExemplos busca = const BuscaExemplos(),
  })  : _servico = servico,
        _busca = busca,
        super(const ChatEstado());

  final JogoBloc _jogoBloc;
  final ServicoLlm _servico;
  final BuscaExemplos _busca;

  void definirTemperatura(double valor) {
    emit(state.copyWith(temperatura: valor.clamp(0, 1).toDouble(), limparAviso: true));
  }

  Future<void> enviar(String texto) async {
    final pergunta = texto.trim();
    if (pergunta.isEmpty || state.pensando) return;
    final jogo = _jogoBloc.state;
    final limite = limiteExemplosConsultados(
      nivelHardware: jogo.nivelHardware,
      nivelRam: jogo.nivelRam,
    );
    final exemplos = _busca.buscar(
      pergunta: pergunta,
      dados: jogo.dados,
      limite: limite,
    );
    final historico = [...state.mensagens, MensagemChat(texto: pergunta, usuario: true)];
    emit(state.copyWith(mensagens: historico, pensando: true, limparAviso: true));

    try {
      final resposta = await _servico.responder(
        pergunta: pergunta,
        exemplos: exemplos,
        temperatura: state.temperatura,
        maxTokens: 60,
      );
      emit(state.copyWith(
        mensagens: [
          ...historico,
          MensagemChat(
            texto: resposta,
            usuario: false,
            exemplosConsultados: exemplos.length,
          ),
        ],
        pensando: false,
      ));
    } catch (erro) {
      emit(state.copyWith(
        mensagens: [
          ...historico,
          const MensagemChat(
            texto: 'Não foi possível gerar uma resposta. Tente novamente.',
            usuario: false,
          ),
        ],
        pensando: false,
        aviso: 'Falha no serviço de resposta: $erro',
      ));
    }
  }
}
