import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/pixel_theme.dart';
import '../features/desktop/cubit/janelas_cubit.dart';
import '../features/chat/view/chat_view.dart';
import '../features/jogo/bloc/jogo_bloc.dart';
import '../features/loja/view/pixel_store_view.dart';
import '../features/navegador/view/navegador_view.dart';
import '../features/treino/view/treina_view.dart';

class LlmOsApp extends StatelessWidget {
  const LlmOsApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'LLM OS',
        debugShowCheckedModeBanner: false,
        theme: PixelTheme.tema,
        home: const DesktopView(),
      );
}

class DesktopView extends StatelessWidget {
  const DesktopView({super.key});

  static const List<_AppInfo> _apps = [
    _AppInfo('treina', 'TreinaAI', Color(0xFF4ADE80), 'DADOS'),
    _AppInfo('chat', 'ChatAI', Color(0xFF4F9BFF), 'CHAT'),
    _AppInfo('navegador', 'Navegador', Color(0xFFFFD166), 'WEB'),
    _AppInfo('loja', 'PixelStore', Color(0xFFFF5C7A), 'LOJA'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JanelasCubit, JanelasEstado>(
      builder: (context, janelas) => LayoutBuilder(
        builder: (context, constraints) {
          final largo = constraints.maxWidth >= 760;
          return Scaffold(
            body: Stack(
              children: [
                const _Wallpaper(),
                if (largo)
                  const Positioned(
                    left: 20,
                    top: 28,
                    bottom: 74,
                    width: 126,
                    child: _AppLauncher(apps: _apps, vertical: true),
                  )
                else
                  const Positioned(
                    left: 10,
                    right: 10,
                    top: 10,
                    height: 88,
                    child: _AppLauncher(apps: _apps, vertical: false),
                  ),
                if (janelas.appAtivo != null)
                  Positioned(
                    left: largo ? 166 : 8,
                    right: largo ? 30 : 8,
                    top: largo ? 30 : 108,
                    bottom: 68,
                    child: _AppWindow(
                      app: _apps.firstWhere(
                        (item) => item.id == janelas.appAtivo,
                      ),
                    ),
                  ),
                if (janelas.menuIniciarAberto)
                  const Positioned(
                    left: 12,
                    bottom: 66,
                    child: _StartMenu(apps: _apps),
                  ),
                const Positioned(left: 0, right: 0, bottom: 0, child: _Taskbar()),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AppInfo {
  const _AppInfo(this.id, this.nome, this.cor, this.sigla);
  final String id;
  final String nome;
  final Color cor;
  final String sigla;
}

class _Wallpaper extends StatelessWidget {
  const _Wallpaper();

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF28164A), PixelTheme.fundo, Color(0xFF120C24)],
          ),
        ),
        child: CustomPaint(
          painter: _StarPainter(),
          child: const SizedBox.expand(),
        ),
      );
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF8E78BC).withValues(alpha: 0.28);
    for (var y = 24.0; y < size.height; y += 52) {
      for (var x = 18.0; x < size.width; x += 61) {
        if (((x.toInt() * 7 + y.toInt() * 3) % 4) == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, 3, 3), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AppLauncher extends StatelessWidget {
  const _AppLauncher({required this.apps, required this.vertical});
  final List<_AppInfo> apps;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final items = apps
        .map((app) => _DesktopIcon(app: app, compact: !vertical))
        .toList();
    if (!vertical) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: PixelTheme.preto.withValues(alpha: 0.5),
          border: Border.all(color: Colors.white12, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 0, 14),
          child: Text('APPS', style: TextStyle(fontSize: 11, color: PixelTheme.textoSuave)),
        ),
        ...items,
      ],
    );
  }
}

class _DesktopIcon extends StatelessWidget {
  const _DesktopIcon({required this.app, this.compact = false});
  final _AppInfo app;
  final bool compact;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: compact ? 0 : 11),
        child: InkWell(
          onTap: () => context.read<JanelasCubit>().abrirApp(app.id),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: compact ? 2 : 4,
              horizontal: 3,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PixelAppIcon(app: app, size: compact ? 32 : 38),
                SizedBox(height: compact ? 3 : 5),
                Text(
                  app.nome,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? 9 : 10,
                    color: PixelTheme.texto,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _PixelAppIcon extends StatelessWidget {
  const _PixelAppIcon({required this.app, required this.size});
  final _AppInfo app;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: PixelTheme.preto,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: PixelTheme.preto, offset: Offset(3, 3))],
        ),
        child: CustomPaint(painter: _IconPainter(app.cor, app.sigla)),
      );
}

class _IconPainter extends CustomPainter {
  const _IconPainter(this.color, this.sigla);
  final Color color;
  final String sigla;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cell = size.width / 5;
    const pixels = <List<int>>[
      [0, 1, 1, 1, 0],
      [1, 0, 1, 0, 1],
      [1, 1, 1, 1, 1],
      [1, 0, 1, 0, 1],
      [0, 1, 1, 1, 0],
    ];
    for (var row = 0; row < pixels.length; row++) {
      for (var col = 0; col < pixels[row].length; col++) {
        if (pixels[row][col] == 1) {
          canvas.drawRect(Rect.fromLTWH(col * cell, row * cell, cell - 1, cell - 1), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.sigla != sigla;
}

class _AppWindow extends StatelessWidget {
  const _AppWindow({required this.app});
  final _AppInfo app;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: PixelTheme.painel,
          border: Border.all(color: PixelTheme.preto, width: 4),
          boxShadow: const [
            BoxShadow(color: PixelTheme.preto, offset: Offset(7, 7), blurRadius: 0),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: PixelTheme.roxo,
              child: Row(
                children: [
                  _PixelAppIcon(app: app, size: 27),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      app.nome.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar janela',
                    onPressed: () => context.read<JanelasCubit>().fecharApp(),
                    icon: const Icon(Icons.close, size: 19),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            Expanded(
              child: switch (app.id) {
                'treina' => const TreinaView(),
                'loja' => const PixelStoreView(),
                'navegador' => const NavegadorView(),
                'chat' => const ChatView(),
                _ => _AppPlaceholder(app: app),
              },
            ),
          ],
        ),
      );
}

class _AppPlaceholder extends StatelessWidget {
  const _AppPlaceholder({required this.app});
  final _AppInfo app;

  @override
  Widget build(BuildContext context) {
    final detalhes = switch (app.id) {
      'treina' => ('CENTRO DE TREINAMENTO', 'Aqui você vai coletar, auditar e organizar exemplos para o seu dataset.'),
      'chat' => ('LABORATÓRIO DE IA', 'Converse com o modelo local e acompanhe quais exemplos ajudam cada resposta.'),
      'navegador' => ('REDE DE OPORTUNIDADES', 'Acesse trabalhos, tarefas rápidas e mercados de dados para ganhar créditos.'),
      _ => ('MELHORE SEU COMPUTADOR', 'Hardware, upgrades e novos pacotes de dados estarão disponíveis nesta loja.'),
    };

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RobotSprite(color: app.cor, size: 100),
              const SizedBox(height: 23),
              Text(
                detalhes.$1,
                textAlign: TextAlign.center,
                style: TextStyle(color: app.cor, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
              const SizedBox(height: 13),
              Text(
                detalhes.$2,
                textAlign: TextAlign.center,
                style: const TextStyle(color: PixelTheme.textoSuave, height: 1.6),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: PixelTheme.preto.withValues(alpha: 0.55),
                  border: Border.all(color: PixelTheme.preto, width: 2),
                ),
                child: const Text(
                  'SISTEMA INICIALIZADO // MÓDULO 01',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: PixelTheme.verde),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'A base visual está pronta. As mecânicas deste app entram nas próximas etapas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: PixelTheme.textoSuave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RobotSprite extends StatelessWidget {
  const _RobotSprite({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _RobotPainter(color)),
      );
}

class _RobotPainter extends CustomPainter {
  const _RobotPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 12;
    final body = Paint()..color = color;
    final dark = Paint()..color = PixelTheme.preto;
    final light = Paint()..color = PixelTheme.amarelo;
    void block(int x, int y, int w, int h, Paint paint) => canvas.drawRect(
          Rect.fromLTWH(x * unit, y * unit, w * unit, h * unit),
          paint,
        );
    block(3, 1, 6, 1, dark);
    block(4, 0, 4, 1, light);
    block(2, 2, 8, 6, dark);
    block(3, 3, 6, 4, body);
    block(4, 4, 1, 1, light);
    block(7, 4, 1, 1, light);
    block(4, 7, 4, 1, dark);
    block(3, 8, 2, 2, dark);
    block(7, 8, 2, 2, dark);
    block(1, 4, 1, 2, light);
    block(10, 4, 1, 2, light);
  }

  @override
  bool shouldRepaint(covariant _RobotPainter oldDelegate) => oldDelegate.color != color;
}

class _Taskbar extends StatelessWidget {
  const _Taskbar();

  @override
  Widget build(BuildContext context) => Container(
        height: 58,
        decoration: BoxDecoration(
          color: PixelTheme.preto.withValues(alpha: 0.96),
          border: const Border(top: BorderSide(color: PixelTheme.roxo, width: 3)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            InkWell(
              onTap: () => context.read<JanelasCubit>().alternarMenuIniciar(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: PixelTheme.roxo,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                ),
                child: const Text('INICIAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: _ActiveAppLabel()),
            BlocBuilder<JogoBloc, JogoEstado>(
              builder: (context, estado) => Row(
                children: [
                  const Icon(Icons.memory, size: 16, color: PixelTheme.verde),
                  const SizedBox(width: 5),
                  const Text('PC 01', style: TextStyle(fontSize: 10, color: PixelTheme.textoSuave)),
                  const SizedBox(width: 12),
                  const Icon(Icons.monetization_on, size: 16, color: PixelTheme.amarelo),
                  const SizedBox(width: 4),
                  Text('${estado.creditos} cr', style: const TextStyle(fontSize: 11, color: PixelTheme.amarelo)),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            const _ClockLabel(),
            const SizedBox(width: 14),
          ],
        ),
      );
}

class _ActiveAppLabel extends StatelessWidget {
  const _ActiveAppLabel();

  @override
  Widget build(BuildContext context) => BlocBuilder<JanelasCubit, JanelasEstado>(
        builder: (context, state) {
          final nomes = {
            'treina': 'TreinaAI',
            'chat': 'ChatAI',
            'navegador': 'Navegador',
            'loja': 'PixelStore',
          };
          final nome = nomes[state.appAtivo];
          if (nome == null) return const SizedBox.shrink();
          return Text(
            '▰ $nome',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: PixelTheme.textoSuave),
          );
        },
      );
}

class _ClockLabel extends StatelessWidget {
  const _ClockLabel();

  @override
  Widget build(BuildContext context) => StreamBuilder<DateTime>(
        stream: Stream<DateTime>.periodic(
          const Duration(seconds: 20),
          (_) => DateTime.now(),
        ),
        initialData: DateTime.now(),
        builder: (context, snapshot) {
          final hora = snapshot.data ?? DateTime.now();
          final texto = '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
          return Text(texto, style: const TextStyle(fontSize: 11, color: PixelTheme.texto));
        },
      );
}

class _StartMenu extends StatelessWidget {
  const _StartMenu({required this.apps});
  final List<_AppInfo> apps;

  @override
  Widget build(BuildContext context) => Container(
        width: 260,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PixelTheme.painel,
          border: Border.all(color: PixelTheme.preto, width: 4),
          boxShadow: const [BoxShadow(color: PixelTheme.preto, offset: Offset(5, 5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('LLM OS // INÍCIO', style: TextStyle(color: PixelTheme.verde, fontSize: 11)),
            const Divider(color: Colors.white24),
            ...apps.map(
              (app) => TextButton.icon(
                onPressed: () => context.read<JanelasCubit>().abrirApp(app.id),
                icon: _PixelAppIcon(app: app, size: 25),
                label: Align(alignment: Alignment.centerLeft, child: Text(app.nome)),
              ),
            ),
            const Divider(color: Colors.white24),
            TextButton.icon(
              onPressed: () => context.read<JogoBloc>().add(const JogoReiniciadoSolicitado()),
              icon: const Icon(Icons.restart_alt, color: PixelTheme.amarelo),
              label: const Align(alignment: Alignment.centerLeft, child: Text('Reiniciar jogo')),
            ),
          ],
        ),
      );
}
