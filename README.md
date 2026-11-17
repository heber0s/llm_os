# Atualização do LLM OS: PixelStore e Navegador

Este pacote contém os arquivos completos que foram adicionados ou substituídos na implementação. Não é o repositório inteiro.

## Aplicação

Extraia o conteúdo deste pacote sobre a raiz do clone do projeto, mantendo a estrutura `lib/` e `test/` e permitindo substituir os arquivos existentes.

O pacote:

- conecta a PixelStore ao desktop, com compras persistidas de hardware, SSD, cooler e pacotes de categorias;
- expande o banco de perguntas para Conhecimentos Gerais, Português e Tecnologia, liberadas após a compra;
- conecta ao Navegador as atividades RotuloPay, DigitaJá e DataMarket;
- conserva permanentemente as perguntas já vendidas no DataMarket, mesmo se o exemplo for removido;
- inclui testes para compras, serialização, tarefas de renda e prevenção de revenda.

## Validar no seu computador

Na pasta raiz do clone, execute:

```powershell
flutter pub get
flutter test
flutter run
```

## Limites desta etapa

FreelaNet ainda é uma tela informativa; será implementada na próxima etapa junto com as respostas do ChatAI. Renda passiva e coleta automática do bot também ainda não foram conectadas. O código foi revisado estruturalmente, mas este ambiente não tem Flutter/Dart para executar análise, testes ou build.
