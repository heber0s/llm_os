import 'package:flutter_test/flutter_test.dart';
import 'package:llm_os/features/jogo/bloc/jogo_bloc.dart';
import 'package:llm_os/features/jogo/data/jogo_repositorio.dart';

void main() {
  test('registra o pagamento do FreelaNet e persiste o cooldown', () async {
    final repositorio = _RepositorioEmMemoria(const JogoEstado(carregado: true).toJson());
    final bloc = JogoBloc(
      repositorio,
      intervaloRenda: const Duration(days: 1),
      intervaloBot: const Duration(days: 1),
    );
    addTearDown(bloc.close);

    final inicializacao = bloc.stream.firstWhere((estado) => estado.carregado);
    bloc.add(const JogoInicializacaoSolicitada());
    await inicializacao;

    final concluidaEm = DateTime.now().millisecondsSinceEpoch;
    final pagamento = bloc.stream.firstWhere((estado) => estado.creditos == 118);
    bloc.add(VagaConcluidaRegistrada(
      vagaId: 'suporte',
      pagamento: 18,
      concluidaEmMs: concluidaEm,
    ));
    final atualizado = await pagamento;

    expect(atualizado.cooldownsVagas['suporte'], concluidaEm);
    expect(JogoEstado.fromJson(atualizado.toJson()).cooldownsVagas['suporte'], concluidaEm);
  });
}

class _RepositorioEmMemoria implements JogoRepositorio {
  _RepositorioEmMemoria(this.dados);
  Map<String, dynamic>? dados;

  @override
  Future<Map<String, dynamic>?> carregar() async => dados;

  @override
  Future<void> salvar(Map<String, dynamic> novosDados) async {
    dados = Map<String, dynamic>.from(novosDados);
  }

  @override
  Future<void> limpar() async {
    dados = null;
  }
}
