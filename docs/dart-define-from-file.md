# Configuração Dart Define From File

Este projeto agora suporta configurações de ambiente usando `--dart-define-from-file` para cada cidade.

## 📁 Arquivos de Ambiente

Os arquivos de ambiente estão localizados em `env/` e contêm as seguintes variáveis:

- `CITY_NAME`: Nome da cidade a ser exibido na tela
- `FLAVOR`: Flavor correspondente

### Cidades Disponíveis

| Arquivo | Cidade | Flavor |
|---------|--------|--------|
| `env/demo.json` | Demonstração | demo |
| `env/patosDeMinas.json` | Patos de Minas | patosDeMinas |
| `env/janauba.json` | Janaúba | janauba |
| `env/conselheiroLafaiete.json` | Conselheiro Lafaiete | conselheiroLafaiete |
| `env/capaoBonito.json` | Capão Bonito | capaoBonito |
| `env/joaoMonlevade.json` | João Monlevade | joaoMonlevade |
| `env/itarare.json` | Itararé | itarare |
| `env/passos.json` | Passos | passos |
| `env/ribeiraoDasNeves.json` | Ribeirão das Neves | ribeiraoDasNeves |
| `env/igarape.json` | Igarapé | igarape |
| `env/ouroPreto.json` | Ouro Preto | ouroPreto |

## 🚀 Uso no VS Code

**TODAS as configurações do VS Code agora incluem automaticamente o `--dart-define-from-file`!**

Você pode usar qualquer configuração existente:

### 🏙️ Android Debug:
- 🏛️ Demo - Android Debug
- 🐎 Patos de Minas - Android Debug  
- 🌾 Janaúba - Android Debug
- ⛪ Conselheiro Lafaiete - Android Debug
- ... e todas as outras cidades

### 📱 Android Release:
- 🏛️ Demo - Android Release
- 🐎 Patos de Minas - Android Release
- 🌾 Janaúba - Android Release
- ... e todas as outras cidades

### 🔧 Custom Device:
- A configuração "Custom Device" também foi atualizada para usar automaticamente o arquivo de ambiente correspondente ao flavor selecionado

## 💻 Uso na Linha de Comando

```bash
# Executar com ambiente específico
flutter run --dart-define-from-file=env/demo.json --flavor=demo

# Executar testes com ambiente
flutter test --dart-define-from-file=env/patosDeMinas.json

# Build com ambiente
flutter build apk --dart-define-from-file=env/janauba.json --flavor=janauba
```

## 🔧 Uso no Código

```dart
import 'package:rotativo/config/environment.dart';

void main() {
  // Obter o nome da cidade
  String cityName = Environment.cityName;
  
  // Obter o flavor
  String flavor = Environment.flavor;
  
  // Verificar se está configurado
  bool isConfigured = Environment.isConfigured;
  
  // Obter informações de exibição
  String info = Environment.displayInfo;
  
  print('Executando para: $cityName');
}
```

## ✅ Testes

Para testar se as configurações estão funcionando:

```bash
flutter test --dart-define-from-file=env/demo.json test/environment_test.dart
```

## 📝 Exemplo de Arquivo de Ambiente

```json
{
  "CITY_NAME": "Patos de Minas",
  "FLAVOR": "patosDeMinas"
}
```