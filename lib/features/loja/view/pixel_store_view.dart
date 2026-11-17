import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/pixel_theme.dart';
import '../../jogo/bloc/jogo_bloc.dart';

class PixelStoreView extends StatelessWidget {
  const PixelStoreView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<JogoBloc, JogoEstado>(
        builder: (context, estado) => DefaultTabController(
          length: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'PIXELSTORE',
                      style: TextStyle(
                        color: PixelTheme.verde,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Saldo disponível: ${estado.creditos} créditos',
                      style: const TextStyle(color: PixelTheme.amarelo),
                    ),
                  ],
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: 'HARDWARE'),
                  Tab(text: 'UPGRADES'),
                  Tab(text: 'DATASETS'),
                ],
                labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                unselectedLabelStyle: TextStyle(fontSize: 9),
                indicatorColor: PixelTheme.verde,
                labelColor: PixelTheme.verde,
                unselectedLabelColor: PixelTheme.textoSuave,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _HardwareTab(estado: estado),
                    _UpgradesTab(estado: estado),
                    _DatasetsTab(estado: estado),
                  ],
                ),
              ),
              if (estado.mensagem != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PixelTheme.roxo.withValues(alpha: 0.25),
                      border: Border.all(color: PixelTheme.roxo, width: 2),
                    ),
                    child: Text(
                      estado.mensagem!,
                      style: const TextStyle(color: PixelTheme.texto, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}

class _HardwareTab extends StatelessWidget {
  const _HardwareTab({required this.estado});
  final JogoEstado estado;

  static const _detalhes = [
    '1 exemplo consultado • lote de coleta 4 • treino 10 s',
    '3 exemplos consultados • lote de coleta 6 • treino 7 s',
    '4 exemplos consultados • lote de coleta 8 • treino 5 s',
    '5 exemplos consultados • lote de coleta 12 • treino 3 s',
  ];

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const _SectionIntro(
            title: 'MÁQUINAS',
            description: 'O próximo equipamento precisa ser comprado em ordem.',
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < CatalogoLoja.nomesHardware.length; index++)
            _StoreCard(
              title: CatalogoLoja.nomesHardware[index],
              subtitle: CatalogoLoja.modelosHardware[index],
              description: _detalhes[index],
              accent: index <= estado.nivelHardware ? PixelTheme.verde : PixelTheme.amarelo,
              status: index < estado.nivelHardware
                  ? 'SUBSTITUÍDO'
                  : index == estado.nivelHardware
                      ? 'EM USO'
                      : index == estado.nivelHardware + 1
                          ? '${CatalogoLoja.precosHardware[index]} cr'
                          : 'BLOQUEADO',
              actionLabel: index == estado.nivelHardware + 1 ? 'Comprar' : null,
              actionEnabled: estado.carregado &&
                  !estado.treinoEmAndamento &&
                  index == estado.nivelHardware + 1 &&
                  estado.creditos >= CatalogoLoja.precosHardware[index],
              onPressed: index == estado.nivelHardware + 1
                  ? () => context.read<JogoBloc>().add(const HardwareCompraSolicitada())
                  : null,
            ),
        ],
      );
}

class _UpgradesTab extends StatelessWidget {
  const _UpgradesTab({required this.estado});
  final JogoEstado estado;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const _SectionIntro(
            title: 'APRIMORAMENTOS',
            description: 'Melhore a capacidade do dataset e reduza o tempo de treino.',
          ),
          const SizedBox(height: 10),
          _StoreCard(
            title: 'SSD',
            subtitle: 'Nível ${estado.nivelSsd}/6',
            description: '+40 espaços no dataset por nível. Capacidade atual: ${estado.capacidadeDados}.',
            accent: PixelTheme.verde,
            status: estado.nivelSsd >= 6 ? 'MAX' : '${CatalogoLoja.precoSsd(estado.nivelSsd)} cr',
            actionLabel: estado.nivelSsd >= 6 ? null : 'Aprimorar',
            actionEnabled: estado.carregado &&
                !estado.treinoEmAndamento &&
                estado.nivelSsd < 6 &&
                estado.creditos >= CatalogoLoja.precoSsd(estado.nivelSsd),
            onPressed: () => context.read<JogoBloc>().add(const UpgradeCompraSolicitada('ssd')),
          ),
          _StoreCard(
            title: 'Cooler',
            subtitle: 'Nível ${estado.nivelCooler}/4',
            description: 'Cada nível reduz em 15% o tempo do treino simulado.',
            accent: const Color(0xFF4F9BFF),
            status: estado.nivelCooler >= 4 ? 'MAX' : '${CatalogoLoja.precoCooler(estado.nivelCooler)} cr',
            actionLabel: estado.nivelCooler >= 4 ? null : 'Aprimorar',
            actionEnabled: estado.carregado &&
                !estado.treinoEmAndamento &&
                estado.nivelCooler < 4 &&
                estado.creditos >= CatalogoLoja.precoCooler(estado.nivelCooler),
            onPressed: () => context.read<JogoBloc>().add(const UpgradeCompraSolicitada('cooler')),
          ),
          const SizedBox(height: 4),
          const Text(
            'Outros componentes serão adicionados junto com as mecânicas que utilizam seus efeitos.',
            style: TextStyle(color: PixelTheme.textoSuave, fontSize: 11, height: 1.4),
          ),
        ],
      );
}

class _DatasetsTab extends StatelessWidget {
  const _DatasetsTab({required this.estado});
  final JogoEstado estado;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const _SectionIntro(
            title: 'PACOTES DE DADOS',
            description: 'Compre novas categorias para ampliar o dataset de treinamento.',
          ),
          const SizedBox(height: 10),
          for (final id in CatalogoLoja.precosPacotes.keys)
            _StoreCard(
              title: CatalogoLoja.nomesPacotes[id]!,
              subtitle: 'Pacote de perguntas e respostas',
              description: switch (id) {
                'ger' => 'Calendário, planetas, formas e conhecimentos básicos.',
                'por' => 'Vocabulário, opostos, plurais e formas das palavras.',
                _ => 'Conceitos de programação, computadores e inteligência artificial.',
              },
              accent: PixelTheme.amarelo,
              status: estado.categoriasLiberadas.contains(id)
                  ? 'LIBERADO'
                  : '${CatalogoLoja.precosPacotes[id]} cr',
              actionLabel: estado.categoriasLiberadas.contains(id) ? null : 'Desbloquear',
              actionEnabled: estado.carregado &&
                  !estado.treinoEmAndamento &&
                  !estado.categoriasLiberadas.contains(id) &&
                  estado.creditos >= CatalogoLoja.precosPacotes[id]!,
              onPressed: () => context.read<JogoBloc>().add(PacoteCompraSolicitada(id)),
            ),
        ],
      );
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({required this.title, required this.description});
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(color: PixelTheme.texto, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 12)),
        ],
      );
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.accent,
    required this.status,
    required this.actionEnabled,
    this.actionLabel,
    this.onPressed,
  });

  final String title;
  final String subtitle;
  final String description;
  final Color accent;
  final String status;
  final String? actionLabel;
  final bool actionEnabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PixelTheme.preto.withValues(alpha: 0.32),
          border: Border.all(color: PixelTheme.preto, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(status, style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 12, height: 1.35)),
            if (actionLabel != null) ...[
              const SizedBox(height: 9),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: actionEnabled ? onPressed : null,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      );
}
