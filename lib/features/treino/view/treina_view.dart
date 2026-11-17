import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/pixel_theme.dart';
import '../../jogo/bloc/jogo_bloc.dart';
import '../../jogo/data/banco_perguntas.dart';
import '../../jogo/data/dado_treino.dart';

class TreinaView extends StatelessWidget {
  const TreinaView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<JogoBloc, JogoEstado>(
        builder: (context, estado) {
          final jogo = context.read<JogoBloc>();
          final quantidadeCorreta = estado.dados
              .where((dado) => dado.auditado && !dado.ruim)
              .length;
          final treinaveis = estado.dados
              .where((dado) => dado.auditado && !dado.ruim && !dado.treinado)
              .length;
          final custoTreino = 5 + treinaveis ~/ 4;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'CENTRO DE TREINAMENTO',
                      style: TextStyle(
                        color: PixelTheme.verde,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Monte um dataset confiável. Respostas incorretas podem prejudicar o modelo.',
                      style: TextStyle(color: PixelTheme.textoSuave, height: 1.45),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _ResumoCard(
                          titulo: 'DATASET',
                          valor: '${estado.quantidadeDados}/${estado.capacidadeDados}',
                          cor: PixelTheme.verde,
                        ),
                        _ResumoCard(
                          titulo: 'PENDENTES',
                          valor: '${estado.pendentesAuditoria}',
                          cor: PixelTheme.amarelo,
                        ),
                        _ResumoCard(
                          titulo: 'SUSPEITOS',
                          valor: '${estado.quantidadeSuspeitos}',
                          cor: PixelTheme.vermelho,
                        ),
                        _ResumoCard(
                          titulo: 'CRÉDITOS',
                          valor: '${estado.creditos} cr',
                          cor: PixelTheme.amarelo,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: PixelTheme.preto.withValues(alpha: 0.32),
                        border: Border.all(color: PixelTheme.preto, width: 3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'COLETA DE DADOS',
                            style: TextStyle(color: PixelTheme.texto, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            initialValue: estado.categoriaSelecionada,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Categoria',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: BancoPerguntas.categorias
                                .where((categoria) => estado.categoriasLiberadas.contains(categoria.id))
                                .map(
                                  (categoria) => DropdownMenuItem<String>(
                                    value: categoria.id,
                                    child: Text(categoria.nome),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: estado.carregado
                                ? (id) {
                                    if (id != null) {
                                      jogo.add(CategoriaColetaSelecionada(id));
                                    }
                                  }
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Lote atual: até ${[4, 6, 8, 12][estado.nivelHardware.clamp(0, 3).toInt()]} exemplos • Erro aleatório: 30% • Auditoria: 10 cr',
                            style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              FilledButton.icon(
                                onPressed: estado.carregado && estado.espacoLivre > 0
                                    ? () => jogo.add(const ColetaSolicitada())
                                    : null,
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text('Coletar exemplos'),
                              ),
                              OutlinedButton.icon(
                                onPressed: estado.carregado && estado.pendentesAuditoria > 0
                                    ? () => jogo.add(const AuditoriaSolicitada())
                                    : null,
                                icon: const Icon(Icons.fact_check_outlined, size: 18),
                                label: const Text('Auditar • 10 cr'),
                              ),
                              OutlinedButton.icon(
                                onPressed: estado.carregado && estado.quantidadeSuspeitos > 0
                                    ? () => jogo.add(const SuspeitosRemovidos())
                                    : null,
                                icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                                label: const Text('Remover suspeitos'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Exemplos aprovados prontos: $treinaveis • custo do treino: $custoTreino cr',
                            style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: estado.carregado &&
                                    !estado.treinoEmAndamento &&
                                    treinaveis > 0 &&
                                    estado.creditos >= custoTreino
                                ? () => jogo.add(const TreinoSolicitado())
                                : null,
                            icon: Icon(estado.treinoEmAndamento ? Icons.memory : Icons.play_arrow),
                            label: Text(estado.treinoEmAndamento
                                ? 'Treinando modelo…'
                                : 'Treinar modelo • $custoTreino cr'),
                          ),
                          if (estado.treinoEmAndamento) ...[
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: estado.progressoTreino,
                              minHeight: 10,
                              color: PixelTheme.verde,
                              backgroundColor: PixelTheme.preto,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Época ${estado.epocasTreinadas + 1} • ${(estado.progressoTreino * 100).round()}% • loss ${estado.lossTreino.toStringAsFixed(2)}',
                              style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (estado.mensagem != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: PixelTheme.roxo.withValues(alpha: 0.28),
                          border: Border.all(color: PixelTheme.roxo, width: 2),
                        ),
                        child: Text(estado.mensagem!, style: const TextStyle(color: PixelTheme.texto)),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'EXEMPLOS DO DATASET',
                            style: TextStyle(color: PixelTheme.texto, fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(
                          '$quantidadeCorreta aprovados',
                          style: const TextStyle(color: PixelTheme.verde, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (estado.dados.isEmpty)
                      const _DatasetVazio()
                    else
                      ...estado.dados.map(
                        (dado) => _DadoCard(
                          dado: dado,
                          aoRemover: () => jogo.add(DadoRemovido(dado.id)),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

class _ResumoCard extends StatelessWidget {
  const _ResumoCard({required this.titulo, required this.valor, required this.cor});

  final String titulo;
  final String valor;
  final Color cor;

  @override
  Widget build(BuildContext context) => Container(
        width: 138,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: PixelTheme.preto.withValues(alpha: 0.32),
          border: Border.all(color: PixelTheme.preto, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 10)),
            const SizedBox(height: 4),
            Text(valor, style: TextStyle(color: cor, fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
      );
}

class _DadoCard extends StatelessWidget {
  const _DadoCard({required this.dado, required this.aoRemover});

  final DadoTreino dado;
  final VoidCallback aoRemover;

  @override
  Widget build(BuildContext context) {
    final Color statusCor;
    final String status;
    if (!dado.auditado) {
      statusCor = PixelTheme.amarelo;
      status = 'NOVO';
    } else if (dado.ruim) {
      statusCor = PixelTheme.vermelho;
      status = 'SUSPEITO';
    } else if (dado.treinado) {
      statusCor = PixelTheme.verde;
      status = 'TREINADO';
    } else {
      statusCor = const Color(0xFF4F9BFF);
      status = 'APROVADO';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PixelTheme.painel,
        border: Border.all(color: dado.auditado && dado.ruim ? PixelTheme.vermelho : PixelTheme.preto, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dado.categoriaNome.toUpperCase(),
                  style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 10, letterSpacing: 0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                color: statusCor.withValues(alpha: 0.16),
                child: Text(status, style: TextStyle(color: statusCor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                tooltip: 'Remover exemplo',
                onPressed: aoRemover,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 18, color: PixelTheme.textoSuave),
              ),
            ],
          ),
          Text(dado.pergunta, style: const TextStyle(color: PixelTheme.texto, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            dado.resposta,
            style: TextStyle(
              color: dado.auditado && dado.ruim ? PixelTheme.vermelho : PixelTheme.textoSuave,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatasetVazio extends StatelessWidget {
  const _DatasetVazio();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        decoration: BoxDecoration(
          color: PixelTheme.preto.withValues(alpha: 0.25),
          border: Border.all(color: PixelTheme.preto, width: 2),
        ),
        child: const Column(
          children: [
            Icon(Icons.storage_outlined, color: PixelTheme.textoSuave, size: 30),
            SizedBox(height: 8),
            Text('Seu dataset ainda está vazio.', style: TextStyle(color: PixelTheme.texto)),
            SizedBox(height: 4),
            Text(
              'Escolha uma categoria e colete o primeiro lote de exemplos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PixelTheme.textoSuave, fontSize: 12),
            ),
          ],
        ),
      );
}
