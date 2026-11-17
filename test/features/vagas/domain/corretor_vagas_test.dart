import 'package:flutter_test/flutter_test.dart';
import 'package:llm_os/features/vagas/domain/corretor_vagas.dart';

void main() {
  const corretor = CorretorVagas();

  group('CorretorVagas', () {
    test('exige todos os números da resposta esperada', () {
      expect(corretor.avaliar(respostaEsperada: 'O resultado é 24.', respostaModelo: '24'), isTrue);
      expect(corretor.avaliar(respostaEsperada: 'O resultado é 24.', respostaModelo: 'O resultado é 42.'), isFalse);
    });

    test('aceita metade ou mais das palavras-chave ignorando acentos', () {
      expect(corretor.avaliar(respostaEsperada: 'Dióxido de carbono.', respostaModelo: 'Dioxido carbono'), isTrue);
      expect(corretor.avaliar(respostaEsperada: 'Dióxido de carbono.', respostaModelo: 'Carbono azul'), isFalse);
    });

    test('normaliza vírgula e ponto decimal', () {
      expect(corretor.avaliar(respostaEsperada: '3,5', respostaModelo: '3.5'), isTrue);
    });
  });
}
