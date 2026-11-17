import 'package:flutter_test/flutter_test.dart';
import 'package:llm_os/features/jogo/bloc/jogo_bloc.dart';
import 'package:llm_os/features/jogo/data/jogo_repositorio.dart';

void main() {
  group('JogoBloc: PixelStore', () {
    test('compra hardware em ordem e desconta os créditos', () async {
      final repositorio = _RepositorioMemoria();
      final bloc = JogoBloc(repositorio);
      final carregado = bloc.stream.firstWhere((estado) => estado.carregado);
      bloc.add(const JogoInicializacaoSolicitada());
      await carregado;

      final comprado = bloc.stream.firstWhere((estado) => estado.nivelHardware == 1);
      bloc.add(const HardwareCompraSolicitada());
      final resultado = await comprado;

      expect(resultado.creditos, 100 - CatalogoLoja.precosHardware[1]);
      expect(resultado.nivelHardware, 1);
      expect(repositorio.estadoSalvo?['nivelHardware'], 1);
      await bloc.close();
    });

    test('bloqueia uma compra sem saldo suficiente', () async {
      final bloc = JogoBloc(_RepositorioMemoria());
      final carregado = bloc.stream.firstWhere((estado) => estado.carregado);
      bloc.add(const JogoInicializacaoSolicitada());
      await carregado;

      final recusado = bloc.stream.firstWhere(
        (estado) => estado.mensagem?.contains('saldo insuficiente') ?? false,
      );
      bloc.add(const HardwareCompraSolicitada());
      final resultado = await recusado;

      expect(resultado.nivelHardware, 0);
      expect(resultado.creditos, 100);
      await bloc.close();
    });

    test('SSD aumenta espaço e pacote comprado libera categoria', () async {
      const estadoInicial = JogoEstado(creditos: 300);
      final repositorio = _RepositorioMemoria()..estadoSalvo = estadoInicial.toJson();
      final bloc = JogoBloc(repositorio);
      final carregado = bloc.stream.firstWhere((estado) => estado.carregado);
      bloc.add(const JogoInicializacaoSolicitada());
      await carregado;

      final ssdPronto = bloc.stream.firstWhere((estado) => estado.nivelSsd == 1);
      bloc.add(const UpgradeCompraSolicitada('ssd'));
      final comSsd = await ssdPronto;
      expect(comSsd.capacidadeDados, 80);
      expect(comSsd.creditos, 240);

      final pacotePronto = bloc.stream.firstWhere(
        (estado) => estado.categoriasLiberadas.contains('ger'),
      );
      bloc.add(const PacoteCompraSolicitada('ger'));
      final comPacote = await pacotePronto;
      expect(comPacote.creditos, 120);
      expect(repositorio.estadoSalvo?['categoriasLiberadas'], contains('ger'));
      await bloc.close();
    });

    test('mantém upgrades e pacotes liberados ao serializar', () {
      const original = JogoEstado(
        creditos: 25,
        nivelHardware: 2,
        nivelSsd: 3,
        nivelCooler: 1,
        categoriasLiberadas: {'geo', 'mat', 'nat', 'ger'},
      );

      final restaurado = JogoEstado.fromJson(original.toJson());

      expect(restaurado.nivelHardware, 2);
      expect(restaurado.nivelSsd, 3);
      expect(restaurado.nivelCooler, 1);
      expect(restaurado.capacidadeDados, 160);
      expect(restaurado.categoriasLiberadas, contains('ger'));
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
