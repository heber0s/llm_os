import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/pixel_theme.dart';
import '../../jogo/bloc/jogo_bloc.dart';
import '../cubit/chat_cubit.dart';
import '../data/servico_llm.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    _chatCubit = ChatCubit(context.read<JogoBloc>());
  }

  @override
  void dispose() {
    _chatCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _chatCubit,
        child: const _ChatInterface(),
      );
}

class _ChatInterface extends StatefulWidget {
  const _ChatInterface();

  @override
  State<_ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<_ChatInterface> {
  final TextEditingController _entrada = TextEditingController();
  final ScrollController _rolagem = ScrollController();

  @override
  void dispose() {
    _entrada.dispose();
    _rolagem.dispose();
    super.dispose();
  }

  void _enviar() {
    final texto = _entrada.text;
    if (texto.trim().isEmpty) return;
    _entrada.clear();
    context.read<ChatCubit>().enviar(texto);
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<ChatCubit, ChatEstado>(
        listener: (context, estado) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_rolagem.hasClients) {
              _rolagem.animateTo(
                0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
              );
            }
          });
        },
        builder: (context, estado) {
          final cubit = context.read<ChatCubit>();
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CabecalhoChat(pensando: estado.pensando),
                if (estado.aviso != null) ...[
                  const SizedBox(height: 8),
                  _AvisoChat(texto: estado.aviso!),
                ],
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: PixelTheme.preto.withValues(alpha: 0.3),
                      border: Border.all(color: PixelTheme.preto, width: 2),
                    ),
                    child: estado.mensagens.isEmpty
                        ? const _ChatVazio()
                        : ListView.builder(
                            controller: _rolagem,
                            reverse: true,
                            padding: const EdgeInsets.all(10),
                            itemCount: estado.mensagens.length,
                            itemBuilder: (context, indice) => _MensagemBubble(
                              mensagem: estado.mensagens[
                                estado.mensagens.length - 1 - indice
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                _TemperaturaControl(
                  valor: estado.temperatura,
                  aoAlterar: cubit.definirTemperatura,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _entrada,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _enviar(),
                        decoration: const InputDecoration(
                          hintText: 'Pergunte ao modelo...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: estado.pensando ? null : _enviar,
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14)),
                        child: estado.pensando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
}

class _CabecalhoChat extends StatelessWidget {
  const _CabecalhoChat({required this.pensando});
  final bool pensando;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: PixelTheme.preto.withValues(alpha: 0.32),
          border: Border.all(color: PixelTheme.preto, width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.smart_toy_outlined, color: PixelTheme.verde, size: 24),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('MODELO DE TESTE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  Text(
                    pensando ? 'Pensando...' : 'Pronto • Respostas baseadas no dataset treinado',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ChatVazio extends StatelessWidget {
  const _ChatVazio();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.forum_outlined, color: PixelTheme.roxo, size: 34),
              SizedBox(height: 8),
              Text('Converse com seu modelo', textAlign: TextAlign.center,
                  style: TextStyle(color: PixelTheme.texto, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                'Treine exemplos aprovados no TreinaAI. O ChatAI consulta os mais parecidos para responder.',
                textAlign: TextAlign.center,
                style: TextStyle(color: PixelTheme.textoSuave, fontSize: 11, height: 1.4),
              ),
            ],
          ),
        ),
      );
}

class _MensagemBubble extends StatelessWidget {
  const _MensagemBubble({required this.mensagem});
  final MensagemChat mensagem;

  @override
  Widget build(BuildContext context) {
    final cor = mensagem.usuario ? PixelTheme.roxo : PixelTheme.painel;
    final alinhamento = mensagem.usuario ? Alignment.centerRight : Alignment.centerLeft;
    return Align(
      alignment: alinhamento,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        child: Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cor,
            border: Border.all(color: PixelTheme.preto, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mensagem.usuario ? 'VOCÊ' : 'MODELO',
                style: TextStyle(
                  color: mensagem.usuario ? PixelTheme.amarelo : PixelTheme.verde,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(mensagem.texto, style: const TextStyle(color: PixelTheme.texto, height: 1.4)),
              if (!mensagem.usuario)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Exemplos consultados: ${mensagem.exemplosConsultados}',
                    style: const TextStyle(color: PixelTheme.textoSuave, fontSize: 9),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemperaturaControl extends StatelessWidget {
  const _TemperaturaControl({required this.valor, required this.aoAlterar});
  final double valor;
  final ValueChanged<double> aoAlterar;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: PixelTheme.preto.withValues(alpha: 0.26),
          border: Border.all(color: PixelTheme.preto, width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.thermostat, color: PixelTheme.amarelo, size: 17),
            const SizedBox(width: 6),
            const Text('Temperatura', style: TextStyle(color: PixelTheme.textoSuave, fontSize: 10)),
            Expanded(
              child: Slider(
                value: valor,
                min: 0,
                max: 1,
                divisions: 10,
                label: valor.toStringAsFixed(1),
                onChanged: aoAlterar,
              ),
            ),
            SizedBox(
              width: 28,
              child: Text(valor.toStringAsFixed(1), textAlign: TextAlign.end,
                  style: const TextStyle(color: PixelTheme.amarelo, fontSize: 10)),
            ),
          ],
        ),
      );
}

class _AvisoChat extends StatelessWidget {
  const _AvisoChat({required this.texto});
  final String texto;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: PixelTheme.vermelho.withValues(alpha: 0.16),
          border: Border.all(color: PixelTheme.vermelho, width: 2),
        ),
        child: Text(texto, style: const TextStyle(color: PixelTheme.texto, fontSize: 11)),
      );
}
