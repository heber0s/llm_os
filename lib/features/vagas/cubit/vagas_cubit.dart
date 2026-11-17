import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../chat/data/servico_llm.dart';
import '../../chat/domain/busca_exemplos.dart';
import '../../jogo/bloc/jogo_bloc.dart';
import '../domain/corretor_vagas.dart';
import '../domain/vagas.dart';

class ResultadoPerguntaVaga extends Equatable {
  const ResultadoPerguntaVaga({
    required this.pergunta,
    required this.respostaModelo,
    required this.respostaEsperada,
    required this.correta,
  });

  final String pergunta;
  final String respostaModelo;
  final String respostaEsperada;
  final bool correta;

  @override
  List<Object?> get props => [pergunta, respostaModelo, respostaEsperada, correta];
}

class VagasEstado extends Equatable {
  const VagasEstado({
    this.vagaAtiva,
    this.emExecucao = false,
    this.concluida = false,
    this.processadas = 0,
    this.total = 0,
    this.acertos = 0,
    this.pagamento = 0,
    this.resultados = const [],
    this.mensagem,
  });

  final VagaFreela? vagaAtiva;
  final bool emExecucao;
  final bool concluida;
  final int processadas;
  final int total;
  final int acertos;
  final int pagamento;
  final List<ResultadoPerguntaVaga> resultados;
  final String? mensagem;

  @override
  List<Object?> get props => [vagaAtiva, emExecucao, concluida, processadas, total, acertos, pagamento, resultados, mensagem];
}

class VagasCubit extends Cubit<VagasEstado> {
  VagasCubit(
    this._jogoBloc, {
    ServicoLlm servico = const ServicoLlmSimulado(),
    BuscaExemplos busca = const BuscaExemplos(),
    CorretorVagas corretor = const CorretorVagas(),
    Random? aleatorio,
    DateTime Function()? agora,
  })  : _servico = servico,
        _busca = busca,
        _corretor = corretor,
        _aleatorio = aleatorio ?? Random(),
        _agora = agora ?? DateTime.now,
        super(const VagasEstado());

  final JogoBloc _jogoBloc;
  final ServicoLlm _servico;
  final BuscaExemplos _busca;
  final CorretorVagas _corretor;
  final Random _aleatorio;
  final DateTime Function() _agora;

  Future<void> iniciar(VagaFreela vaga) async {
    if (state.emExecucao) return;
    final jogo = _jogoBloc.state;
    if (!jogo.carregado) {
      emit(VagasEstado(vagaAtiva: vaga, mensagem: 'Aguarde o carregamento do progresso do jogo.'));
      return;
    }
    if (jogo.nivelHardware < vaga.hardwareMinimo) {
      emit(VagasEstado(
        vagaAtiva: vaga,
        mensagem: 'Esta vaga exige ${CatalogoLoja.nomesHardware[vaga.hardwareMinimo]}.',
      ));
      return;
    }

    final agora = _agora();
    final ultimaConclusaoMs = jogo.cooldownsVagas[vaga.id];
    if (ultimaConclusaoMs != null) {
      final restante = const Duration(seconds: 45) - agora.difference(DateTime.fromMillisecondsSinceEpoch(ultimaConclusaoMs));
      if (restante > Duration.zero) {
        emit(VagasEstado(
          vagaAtiva: vaga,
          mensagem: 'Esta vaga volta a ficar disponível em ${restante.inSeconds + (restante.inMilliseconds % 1000 == 0 ? 0 : 1)}s.',
        ));
        return;
      }
    }

    final perguntas = sortearPerguntasVaga(vaga: vaga, aleatorio: _aleatorio);
    if (perguntas.isEmpty) {
      emit(VagasEstado(vagaAtiva: vaga, mensagem: 'Não há perguntas disponíveis para esta vaga.'));
      return;
    }

    final resultados = <ResultadoPerguntaVaga>[];
    emit(VagasEstado(vagaAtiva: vaga, emExecucao: true, total: perguntas.length));
    try {
      final limite = limiteExemplosConsultados(
        nivelHardware: jogo.nivelHardware,
        nivelRam: jogo.nivelRam,
      );
      for (final pergunta in perguntas) {
        final exemplos = _busca.buscar(
          pergunta: pergunta.pergunta,
          dados: jogo.dados,
          limite: limite,
        );
        final resposta = await _servico.responder(
          pergunta: pergunta.pergunta,
          exemplos: exemplos,
          temperatura: 0,
          maxTokens: 28,
        );
        final correta = _corretor.avaliar(
          respostaEsperada: pergunta.respostaEsperada,
          respostaModelo: resposta,
        );
        resultados.add(ResultadoPerguntaVaga(
          pergunta: pergunta.pergunta,
          respostaModelo: resposta,
          respostaEsperada: pergunta.respostaEsperada,
          correta: correta,
        ));
        if (isClosed) return;
        emit(VagasEstado(
          vagaAtiva: vaga,
          emExecucao: true,
          processadas: resultados.length,
          total: perguntas.length,
          acertos: resultados.where((item) => item.correta).length,
          resultados: List.unmodifiable(resultados),
        ));
      }

      final acertos = resultados.where((item) => item.correta).length;
      final pagamento = (vaga.pagamentoMaximo * acertos / resultados.length).round();
      final concluidaEm = _agora();
      _jogoBloc.add(VagaConcluidaRegistrada(
        vagaId: vaga.id,
        pagamento: pagamento,
        concluidaEmMs: concluidaEm.millisecondsSinceEpoch,
      ));
      emit(VagasEstado(
        vagaAtiva: vaga,
        concluida: true,
        processadas: resultados.length,
        total: perguntas.length,
        acertos: acertos,
        pagamento: pagamento,
        resultados: List.unmodifiable(resultados),
        mensagem: 'Trabalho concluído: $acertos/${resultados.length} acertos. Pagamento proporcional: $pagamento cr.',
      ));
    } catch (erro) {
      emit(VagasEstado(
        vagaAtiva: vaga,
        processadas: resultados.length,
        total: perguntas.length,
        acertos: resultados.where((item) => item.correta).length,
        resultados: List.unmodifiable(resultados),
        mensagem: 'O trabalho foi interrompido e não gerou pagamento: $erro',
      ));
    }
  }
}
