import 'package:equatable/equatable.dart';

class DadoTreino extends Equatable {
  const DadoTreino({
    required this.id,
    required this.categoriaId,
    required this.categoriaNome,
    required this.pergunta,
    required this.resposta,
    this.ruim = false,
    this.auditado = false,
    this.treinado = false,
    this.vendido = false,
  });

  final String id;
  final String categoriaId;
  final String categoriaNome;
  final String pergunta;
  final String resposta;
  final bool ruim;
  final bool auditado;
  final bool treinado;
  final bool vendido;

  DadoTreino copyWith({
    bool? ruim,
    bool? auditado,
    bool? treinado,
    bool? vendido,
  }) =>
      DadoTreino(
        id: id,
        categoriaId: categoriaId,
        categoriaNome: categoriaNome,
        pergunta: pergunta,
        resposta: resposta,
        ruim: ruim ?? this.ruim,
        auditado: auditado ?? this.auditado,
        treinado: treinado ?? this.treinado,
        vendido: vendido ?? this.vendido,
      );

  factory DadoTreino.fromJson(Map<String, dynamic> json) => DadoTreino(
        id: json['id'] as String? ?? '',
        categoriaId: json['categoriaId'] as String? ?? 'geo',
        categoriaNome: json['categoriaNome'] as String? ?? 'Geografia',
        pergunta: json['pergunta'] as String? ?? '',
        resposta: json['resposta'] as String? ?? '',
        ruim: json['ruim'] as bool? ?? false,
        auditado: json['auditado'] as bool? ?? false,
        treinado: json['treinado'] as bool? ?? false,
        vendido: json['vendido'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoriaId': categoriaId,
        'categoriaNome': categoriaNome,
        'pergunta': pergunta,
        'resposta': resposta,
        'ruim': ruim,
        'auditado': auditado,
        'treinado': treinado,
        'vendido': vendido,
      };

  @override
  List<Object?> get props => [
        id,
        categoriaId,
        categoriaNome,
        pergunta,
        resposta,
        ruim,
        auditado,
        treinado,
        vendido,
      ];
}
