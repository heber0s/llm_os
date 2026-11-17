import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/pixel_theme.dart';
import '../../jogo/bloc/jogo_bloc.dart';
import '../../vagas/cubit/vagas_cubit.dart';
import '../../vagas/domain/vagas.dart';

class NavegadorView extends StatelessWidget {
  const NavegadorView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<JogoBloc, JogoEstado>(
        builder: (context, estado) => DefaultTabController(
          length: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 9),
                child: Row(
                  children: [
                    const Icon(Icons.public, color: PixelTheme.verde),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Text(
                        'NAVEGADOR • REDE DE OPORTUNIDADES',
                        style: TextStyle(color: PixelTheme.texto, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                    Text('${estado.creditos} cr', style: const TextStyle(color: PixelTheme.amarelo, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                color: PixelTheme.preto.withValues(alpha: 0.45),
                child: const Text(
                  'https:// rede-de-oportunidades.local',
                  style: TextStyle(color: PixelTheme.textoSuave, fontSize: 11),
                ),
              ),
              const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'RotuloPay'),
                  Tab(text: 'DigitaJá'),
                  Tab(text: 'DataMarket'),
                  Tab(text: 'FreelaNet'),
                ],
                labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                unselectedLabelStyle: TextStyle(fontSize: 10),
                indicatorColor: PixelTheme.verde,
                labelColor: PixelTheme.verde,
                unselectedLabelColor: PixelTheme.textoSuave,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _RotuloPayTab(estado: estado),
                    _DigitaJaTab(estado: estado),
                    _DataMarketTab(estado: estado),
                    _FreelaNetTab(estado: estado),
                  ],
                ),
              ),
              if (estado.mensagem != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: _StatusBox(texto: estado.mensagem!),
                ),
            ],
          ),
        ),
      );
}

class _RotuloPayTab extends StatelessWidget {
  const _RotuloPayTab({required this.estado});
  final JogoEstado estado;

  @override
  Widget build(BuildContext context) {
    final perguntaAtiva = estado.rotuloPergunta != null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SiteHeading(
          titulo: 'RotuloPay',
          subtitulo: 'Revise respostas de inteligência artificial e receba por cada classificação.',
          cor: PixelTheme.verde,
        ),
        const SizedBox(height: 10),
        _InfoStrip(texto: 'Sequência correta: ${estado.rotuloSequencia} • Acerto +3 cr • 5 acertos seguidos: bônus +10 cr'),
        const SizedBox(height: 14),
        if (!perguntaAtiva)
          _SitePanel(
            child: Column(
              children: [
                const Icon(Icons.fact_check_outlined, size: 40, color: PixelTheme.verde),
                const SizedBox(height: 10),
                const Text('Avalie se a resposta apresentada está correta.', textAlign: TextAlign.center, style: TextStyle(color: PixelTheme.texto)),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => context.read<JogoBloc>().add(const RotuloPayNovaRodadaSolicitada()),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar tarefa'),
                ),
              ],
            ),
          )
        else ...[
          _SitePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('PERGUNTA', style: TextStyle(color: PixelTheme.amarelo, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(estado.rotuloPergunta!, style: const TextStyle(color: PixelTheme.texto, fontWeight: FontWeight.bold, height: 1.4)),
                const SizedBox(height: 13),
                const Text('RESPOSTA DA IA', style: TextStyle(color: PixelTheme.amarelo, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(estado.rotuloResposta!, style: const TextStyle(color: PixelTheme.textoSuave, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<JogoBloc>().add(const RotuloPayRespostaEnviada(false)),
                  icon: const Icon(Icons.close),
                  label: const Text('Incorreta'),
                  style: OutlinedButton.styleFrom(foregroundColor: PixelTheme.vermelho),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.read<JogoBloc>().add(const RotuloPayRespostaEnviada(true)),
                  icon: const Icon(Icons.check),
                  label: const Text('Correta'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DigitaJaTab extends StatefulWidget {
  const _DigitaJaTab({required this.estado});
  final JogoEstado estado;

  @override
  State<_DigitaJaTab> createState() => _DigitaJaTabState();
}

class _DigitaJaTabState extends State<_DigitaJaTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frase = widget.estado.digitaFrase;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SiteHeading(
          titulo: 'DigitaJá',
          subtitulo: 'Digite a frase exatamente como aparece para ganhar créditos.',
          cor: Color(0xFF4F9BFF),
        ),
        const SizedBox(height: 12),
        const _InfoStrip(texto: 'Recompensa: +12 cr por frase correta • sem penalidade por erro'),
        const SizedBox(height: 14),
        if (frase == null)
          Center(
            child: FilledButton.icon(
              onPressed: () => context.read<JogoBloc>().add(const DigitaJaNovaFraseSolicitada()),
              icon: const Icon(Icons.keyboard),
              label: const Text('Começar desafio'),
            ),
          )
        else
          _SitePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('DIGITE ESTA FRASE', style: TextStyle(color: Color(0xFF4F9BFF), fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 9),
                Text(frase, style: const TextStyle(color: PixelTheme.texto, fontSize: 15, height: 1.5)),
                const SizedBox(height: 14),
                TextField(
                  controller: _controller,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Sua resposta',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () {
                      context.read<JogoBloc>().add(DigitaJaRespostaEnviada(_controller.text));
                      _controller.clear();
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar frase'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DataMarketTab extends StatelessWidget {
  const _DataMarketTab({required this.estado});
  final JogoEstado estado;

  @override
  Widget build(BuildContext context) {
    final treinados = estado.dados.where((dado) => dado.treinado).length;
    final novos = estado.dados.where((dado) {
      return dado.treinado && !estado.perguntasVendidas.contains('${dado.categoriaId}|${dado.pergunta}');
    }).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SiteHeading(
          titulo: 'DataMarket',
          subtitulo: 'Venda exemplos treinados para financiar as próximas melhorias.',
          cor: PixelTheme.amarelo,
        ),
        const SizedBox(height: 12),
        const _InfoStrip(texto: 'Exemplo correto: +2 cr • incorreto: −4 cr • pagamento mínimo: 0 cr'),
        const SizedBox(height: 14),
        _SitePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MarketCount(label: 'Exemplos treinados', value: '$treinados'),
              const Divider(color: Colors.white24, height: 20),
              _MarketCount(label: 'Novos para venda', value: '$novos'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: novos > 0
                    ? () => context.read<JogoBloc>().add(const DataMarketVendaSolicitada())
                    : null,
                icon: const Icon(Icons.sell_outlined),
                label: const Text('Vender exemplos disponíveis'),
              ),
              if (estado.dataMarketMensagem != null) ...[
                const SizedBox(height: 12),
                _StatusBox(texto: estado.dataMarketMensagem!),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Cada pergunta só pode ser vendida uma vez, mesmo que o exemplo seja removido depois.',
          style: TextStyle(color: PixelTheme.textoSuave, fontSize: 11, height: 1.4),
        ),
      ],
    );
  }
}

class _FreelaNetTab extends StatefulWidget {
  const _FreelaNetTab({required this.estado});
  final JogoEstado estado;

  @override
  State<_FreelaNetTab> createState() => _FreelaNetTabState();
}

class _FreelaNetTabState extends State<_FreelaNetTab> {
  late final VagasCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = VagasCubit(context.read<JogoBloc>());
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _cubit,
        child: BlocBuilder<VagasCubit, VagasEstado>(
          builder: (context, vagas) => _FreelaNetConteudo(
            jogo: widget.estado,
            vagas: vagas,
          ),
        ),
      );
}

class _FreelaNetConteudo extends StatelessWidget {
  const _FreelaNetConteudo({required this.jogo, required this.vagas});
  final JogoEstado jogo;
  final VagasEstado vagas;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SiteHeading(
            titulo: 'FreelaNet',
            subtitulo: 'Aceite trabalhos e receba conforme o desempenho do seu modelo.',
            cor: PixelTheme.verde,
          ),
          const SizedBox(height: 10),
          const _InfoStrip(
            texto: 'O modelo desta etapa é simulado e responde usando apenas exemplos treinados do seu dataset. Cada vaga tem 45s de intervalo.',
          ),
          if (vagas.mensagem != null) ...[
            const SizedBox(height: 10),
            _StatusBox(texto: vagas.mensagem!),
          ],
          if (vagas.vagaAtiva != null && (vagas.emExecucao || vagas.concluida || vagas.resultados.isNotEmpty)) ...[
            const SizedBox(height: 12),
            _SitePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(vagas.vagaAtiva!.titulo, style: const TextStyle(color: PixelTheme.amarelo, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (vagas.emExecucao) ...[
                    LinearProgressIndicator(value: vagas.total == 0 ? 0 : vagas.processadas / vagas.total),
                    const SizedBox(height: 6),
                    Text('Analisando pergunta ${vagas.processadas} de ${vagas.total}…', style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 11)),
                  ],
                  if (vagas.resultados.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    for (final resultado in vagas.resultados)
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: PixelTheme.preto.withValues(alpha: 0.32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(resultado.pergunta, style: const TextStyle(color: PixelTheme.texto, fontWeight: FontWeight.bold, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text('Modelo: ${resultado.respostaModelo}', style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 11)),
                              Text('Esperado: ${resultado.respostaEsperada}', style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 11)),
                              const SizedBox(height: 3),
                              Text(resultado.correta ? 'CORRETA' : 'INCORRETA', style: TextStyle(color: resultado.correta ? PixelTheme.verde : PixelTheme.vermelho, fontWeight: FontWeight.bold, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          for (final vaga in VagaFreela.todas)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _SitePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.work_outline, color: PixelTheme.amarelo, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(vaga.titulo, style: const TextStyle(color: PixelTheme.texto, fontWeight: FontWeight.bold))),
                        Text('até ${vaga.pagamentoMaximo} cr', style: const TextStyle(color: PixelTheme.amarelo, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(vaga.descricao, style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 11, height: 1.3)),
                    const SizedBox(height: 5),
                    Text('${vaga.quantidadePerguntas} perguntas • ${vaga.hardwareMinimo == 0 ? 'Notebook velho' : CatalogoLoja.nomesHardware[vaga.hardwareMinimo]} necessário', style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 10)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: vagas.emExecucao ? null : () => context.read<VagasCubit>().iniciar(vaga),
                        icon: Icon(jogo.nivelHardware < vaga.hardwareMinimo ? Icons.lock_outline : Icons.play_arrow),
                        label: Text(jogo.nivelHardware < vaga.hardwareMinimo ? 'Hardware insuficiente' : 'Aceitar trabalho'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
}

class _SiteHeading extends StatelessWidget {
  const _SiteHeading({required this.titulo, required this.subtitulo, required this.cor});
  final String titulo;
  final String subtitulo;
  final Color cor;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titulo, style: TextStyle(color: cor, fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 5),
          Text(subtitulo, style: const TextStyle(color: PixelTheme.textoSuave, height: 1.4, fontSize: 12)),
        ],
      );
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.texto});
  final String texto;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        color: PixelTheme.preto.withValues(alpha: 0.4),
        child: Text(texto, style: const TextStyle(color: PixelTheme.amarelo, fontSize: 11, height: 1.4)),
      );
}

class _SitePanel extends StatelessWidget {
  const _SitePanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: PixelTheme.painel,
          border: Border.all(color: PixelTheme.preto, width: 3),
        ),
        child: child,
      );
}

class _MarketCount extends StatelessWidget {
  const _MarketCount({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: PixelTheme.textoSuave))),
          Text(value, style: const TextStyle(color: PixelTheme.amarelo, fontWeight: FontWeight.bold)),
        ],
      );
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({required this.texto});
  final String texto;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: PixelTheme.roxo.withValues(alpha: 0.22),
          border: Border.all(color: PixelTheme.roxo, width: 2),
        ),
        child: Text(texto, style: const TextStyle(color: PixelTheme.texto, fontSize: 11, height: 1.4)),
      );
}
