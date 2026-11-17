import 'package:flutter_test/flutter_test.dart';
import 'package:llm_os/features/chat/domain/busca_exemplos.dart';
import 'package:llm_os/features/jogo/data/dado_treino.dart';

void main() {
  const busca = BuscaExemplos();

  DadoTreino dado({
    String id = '1',
    String pergunta = 'Qual é a capital do Brasil?',
    String resposta = 'Brasília.',
    bool treinado = true,
    bool auditado = true,
    bool ruim = false,
  }) => DadoTreino(
        id: id,
        categoriaId: 'geo',
        categoriaNome: 'Geografia',
        pergunta: pergunta,
        resposta: resposta,
        treinado: treinado,
        auditado: auditado,
        ruim: ruim,
      );

  test('encontra correspondência ignorando acentos e stopwords', () {
    final encontrados = busca.buscar(
      pergunta: 'Diga a capital brasileira',
      dados: [dado(pergunta: 'capital brasileira')],
      limite: 1,
    );
    expect(encontrados, hasLength(1));
    expect(encontrados.single.dado.resposta, 'Brasília.');
    expect(encontrados.single.similaridade, 1);
  });

  test('não usa exemplos não treinados, não auditados ou suspeitos', () {
    final encontrados = busca.buscar(
      pergunta: 'Qual capital do Brasil?',
      dados: [
        dado(id: 'novo', treinado: false),
        dado(id: 'nao-auditado', auditado: false),
        dado(id: 'ruim', ruim: true),
      ],
      limite: 5,
    );
    expect(encontrados, isEmpty);
  });

  test('não confunde perguntas com números diferentes', () {
    final encontrados = busca.buscar(
      pergunta: 'Quanto é a soma simples de 7 unidades no primeiro exercício?',
      dados: [
        dado(
          pergunta: 'Quanto é a soma simples de 6 unidades no primeiro exercício?',
          resposta: '13.',
        ),
      ],
      limite: 3,
    );
    expect(encontrados, isEmpty);
  });

  test('retorna no máximo k exemplos com o mais similar por último', () {
    final encontrados = busca.buscar(
      pergunta: 'capital Brasil cidade',
      dados: [
        dado(id: 'exato', pergunta: 'capital Brasil cidade'),
        dado(id: 'parcial', pergunta: 'capital Brasil cidade resposta'),
        dado(id: 'outro', pergunta: 'capital Brasil cidade pais europa'),
      ],
      limite: 2,
    );
    expect(encontrados, hasLength(2));
    expect(encontrados.last.dado.id, 'exato');
    expect(encontrados.first.similaridade, lessThanOrEqualTo(encontrados.last.similaridade));
  });

  test('RAM aumenta o limite de consulta junto ao nível de hardware', () {
    expect(limiteExemplosConsultados(nivelHardware: 0, nivelRam: 0), 1);
    expect(limiteExemplosConsultados(nivelHardware: 0, nivelRam: 2), 3);
    expect(limiteExemplosConsultados(nivelHardware: 3, nivelRam: 3), 8);
  });
}
