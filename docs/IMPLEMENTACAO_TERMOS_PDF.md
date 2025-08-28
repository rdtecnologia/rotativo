# Implementação da Visualização de PDF dos Termos e Condições

## Resumo da Implementação

Foi implementada a funcionalidade para visualizar os termos e condições em PDF na tela de cadastro de usuário, utilizando o visualizador de PDF existente que já era usado para boletos.

## Mudanças Realizadas

### 1. Arquivo Modificado
- `lib/screens/auth/register_screen.dart`

### 2. Imports Adicionados
```dart
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
```

### 3. Funcionalidade Implementada

#### Método `_openTerms()` Modificado
- **Antes**: Mostrava apenas um diálogo com o link dos termos
- **Depois**: Abre o PDF dos termos usando o visualizador interno `SfPdfViewer.network`

#### Método `_launchUrl()` Adicionado
- Permite abrir o PDF no navegador externo como fallback
- Trata erros de abertura de URLs

### 4. Características do Visualizador de PDF

O visualizador implementado inclui:
- **Navegação**: Controles de paginação e scroll
- **Zoom**: Zoom com duplo toque
- **Seleção de texto**: Permite copiar texto do PDF
- **Navegação por hiperlinks**: Suporte a links internos do PDF
- **Barra de ações**: Botão para fechar e abrir no navegador

### 5. Tratamento de Erros

A implementação inclui fallbacks robustos:
1. **Primeira tentativa**: Visualizador interno de PDF
2. **Segunda tentativa**: Abertura no navegador externo
3. **Fallback final**: Mensagem de erro amigável

## Configuração dos Termos por Cidade

Cada cidade tem sua própria configuração de termos no arquivo JSON:
```json
{
  "termsLink": "http://www.rotativodigital.com.br/wp-content/uploads/2019/10/termos-de-uso-monlevade.pdf"
}
```

### Cidades Configuradas
- **Main/Demo**: Termos de uso Monlevade
- **Patos de Minas**: Termos de uso Patos
- **Janauba**: Termos de uso Faixa Azul Janauba
- **Conselheiro Lafaiete**: Termos de uso Lafaiete
- **Capão Bonito**: Termos de uso Capão
- **João Monlevade**: Termos de uso Monlevade
- **Itararé**: Termos de uso Itararé
- **Passos**: Termos de uso Passos
- **Ribeirão das Neves**: Termos de uso Ribeirão das Neves
- **Igarapé**: Termos de uso Igarapé
- **Ouro Preto**: Termos de uso Rotativo Ouro Preto

## Como Funciona

1. **Usuário clica** no link "termos e condições"
2. **Sistema carrega** a URL dos termos da configuração da cidade
3. **PDF é exibido** no visualizador interno
4. **Usuário pode**:
   - Navegar pelas páginas
   - Fazer zoom
   - Selecionar e copiar texto
   - Abrir no navegador externo
   - Fechar e voltar ao cadastro

## Benefícios da Implementação

1. **Experiência do usuário melhorada**: Visualização direta no app
2. **Consistência**: Usa o mesmo visualizador dos boletos
3. **Fallbacks robustos**: Funciona mesmo com problemas de rede
4. **Configuração flexível**: Cada cidade pode ter seus próprios termos
5. **Acessibilidade**: Suporte a zoom e seleção de texto

## Dependências Utilizadas

- `syncfusion_flutter_pdfviewer`: Visualizador de PDF
- `url_launcher`: Abertura de URLs externas

## Testes

Foram criados testes para verificar:
- Presença do link dos termos
- Funcionalidade do checkbox de aceite
- Validação do formulário
- Interação com os termos

## Conclusão

A implementação está completa e funcional, proporcionando uma experiência de usuário superior ao permitir a visualização direta dos termos e condições em PDF dentro do aplicativo, mantendo a consistência com outras funcionalidades existentes.
