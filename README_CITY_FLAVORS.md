# Rotativo Digital - Configuração por Cidade (Flavors)

Este projeto Flutter implementa um sistema de flavors (sabores) que permite compilar diferentes versões do aplicativo para cada cidade, similar ao sistema implementado no aplicativo React Native.

## 📁 Estrutura do Projeto

```
rotativo/
├── assets/config/cities/           # Configurações por cidade
│   ├── Main/                       # Configuração principal
│   ├── PatosDeMinas/              # Patos de Minas
│   ├── Janauba/                   # Janaúba
│   ├── ConselheiroLafaiete/       # Conselheiro Lafaiete
│   ├── CapaoBonito/               # Capão Bonito
│   ├── JoaoMonlevade/             # João Monlevade
│   ├── Itarare/                   # Itararé
│   ├── Passos/                    # Passos
│   ├── RibeiraoDasNeves/          # Ribeirão das Neves
│   ├── Igarape/                   # Igarapé
│   ├── OuroPreto/                 # Ouro Preto
│   └── schema.json                # Schema de validação
├── android/app/src/               # Flavors Android
│   ├── main/google-services.json
│   ├── patosDeMinas/google-services.json
│   └── [outros flavors]/google-services.json
├── ios/config/cities/             # Configurações iOS
│   ├── GoogleService-Info-Main.plist
│   ├── GoogleService-Info-PatosDeMinas.plist
│   └── [outros]/GoogleService-Info-*.plist
├── scripts/build_city.dart       # Script de build por cidade
└── lib/config/                    # Configurações Dart
    ├── city_config.dart          # Loader de configurações
    └── generated/app_config.dart # Configuração gerada
```

## 🛠️ Como Usar

### 1. Configurar uma Cidade

Execute o script de build para gerar as configurações específicas de uma cidade:

```bash
# Sintaxe
dart scripts/build_city.dart <cidade> [nome_exibicao]

# Exemplos
dart scripts/build_city.dart patos "Rotativo Patos"
dart scripts/build_city.dart main "Rotativo"
dart scripts/build_city.dart janauba "Rotativo Janaúba"
```

### 2. Cidades Disponíveis

| Chave       | Cidade                |
|-------------|----------------------|
| `main`      | Demonstração         |
| `patos`     | Patos de Minas       |
| `janauba`   | Janaúba              |
| `lafaiete`  | Conselheiro Lafaiete |
| `capao`     | Capão Bonito         |
| `monlevade` | João Monlevade       |
| `itarare`   | Itararé              |
| `passos`    | Passos               |
| `neves`     | Ribeirão das Neves   |
| `igarape`   | Igarapé              |
| `ouropreto` | Ouro Preto           |

### 3. Build Android

```bash
# APK
flutter build apk --flavor <cidade> --release

# App Bundle (Google Play)
flutter build appbundle --flavor <cidade> --release

# Exemplos
flutter build apk --flavor patos --release
flutter build appbundle --flavor main --release
```

### 4. Build iOS

Para iOS, existem duas abordagens:

#### Opção A: Build Simples (Recomendado)
```bash
# 1. Configurar cidade
dart scripts/build_city.dart patos "Rotativo Patos"

# 2. Build sem flavor (usa configuração gerada)
flutter build ios --release
flutter run -d "iPhone Simulator"
```

#### Opção B: Build com Schemes (Avançado)
```bash
# 1. Criar schemes (executar uma vez)
dart scripts/create_ios_schemes.dart

# 2. Usar schemes específicos no Xcode
# Abra: ios/Runner.xcworkspace
# Selecione o scheme desejado (ex: patosDeMinas)
# Build and Run do Xcode
```

⚠️ **Nota iOS**: O comando `flutter run --flavor` para iOS requer configurações de build customizadas no Xcode. 

**✅ Solução Implementada**: Foi criado um script que gera schemes iOS automaticamente:
```bash
# Execute uma vez para criar todos os schemes
dart scripts/create_ios_schemes.dart
```

Após executar o script, você pode:
- Usar `flutter run -d "iPhone Simulator"` (sem flavor - usa configuração gerada)
- Ou abrir `ios/Runner.xcworkspace` no Xcode e selecionar o scheme desejado

**Para usar flavors completos no iOS via comando**: seria necessário criar configurações de build personalizadas no Xcode (Debug-patosDeMinas, Release-patosDeMinas, etc.). Por simplicidade, recomendamos a Opção A.

## 📱 Configurações por Cidade

Cada cidade possui:

### Arquivos de Configuração
- `<Cidade>.json` - Configuração principal (preços, coordenadas, FAQ, etc.)
- `google-services.json` - Firebase Android
- `GoogleService-Info.plist` - Firebase iOS

### Configurações Incluídas
- **Identificadores**: `androidPackage`, `iosPackage`
- **Localização**: `latitude`, `longitude`
- **Produtos**: Lista de produtos disponíveis
- **Tipos de Veículo**: Carro, Moto, etc.
- **Regras de Estacionamento**: Preços e tempos por tipo de veículo
- **FAQ**: Perguntas frequentes específicas da cidade
- **Links**: Download, termos de uso
- **Contato**: WhatsApp, ChatBot

## 🔧 Scripts Disponíveis

### Script Principal: `build_city.dart`

```bash
# Mostrar ajuda
dart scripts/build_city.dart

# Configurar cidade
dart scripts/build_city.dart <cidade> [nome_exibicao]
```

Este script:
1. Carrega a configuração JSON da cidade
2. Gera o arquivo `lib/config/generated/app_config.dart`
3. Exibe instruções de build

### Script iOS: `copy_google_service.sh`

Script auxiliar para copiar o GoogleService-Info.plist correto no iOS:

```bash
./ios/Scripts/copy_google_service.sh <cidade>
```

## 📝 Uso no Código

Após executar o script de build, use a configuração gerada:

```dart
import 'package:rotativo/config/generated/app_config.dart';

// Acessar configurações
String cityName = AppConfig.cityName;
String displayName = AppConfig.displayName;
double latitude = AppConfig.latitude;
List<int> products = AppConfig.products;
Map<String, dynamic> parkingRules = AppConfig.parkingRules;

// Exemplo de uso
Text('Bem-vindo ao ${AppConfig.displayName}'),
Text('Cidade: ${AppConfig.cityName}'),
```

## 🔄 Adicionando Nova Cidade

1. Crie o diretório: `assets/config/cities/NovaCidade/`
2. Adicione os arquivos:
   - `NovaCidade.json` (baseado no schema.json)
   - `google-services.json`
   - `GoogleService-Info.plist`
3. Atualize o `cityMappings` em `scripts/build_city.dart`
4. Adicione o flavor no `android/app/build.gradle.kts`
5. Atualize o `pubspec.yaml` com o novo asset

## 🚀 Build de Produção

### Android
```bash
# 1. Configurar cidade
dart scripts/build_city.dart patos "Rotativo Patos"

# 2. Build para produção
flutter build appbundle --flavor patos --release

# 3. Arquivo gerado em: build/app/outputs/bundle/patosRelease/
```

### iOS
```bash
# 1. Configurar cidade
dart scripts/build_city.dart patos "Rotativo Patos"

# 2. Build para produção
flutter build ios --release

# 3. Abrir no Xcode para upload
open ios/Runner.xcworkspace
```

## ⚠️ Notas Importantes

1. **Arquivo Gerado**: `lib/config/generated/app_config.dart` é gerado automaticamente - não edite manualmente
2. **Google Services**: Cada flavor Android tem seu próprio `google-services.json`
3. **iOS Schemes**: Para automação completa no iOS, configure schemes personalizados no Xcode
4. **Assets**: Todas as configurações de cidade estão incluídas como assets no app final

## 🔍 Troubleshooting

### Erro: "City not found"
Verifique se a cidade existe no `cityMappings` do `build_city.dart`

### Erro: "Configuration file not found"
Certifique-se de que existe o arquivo `<Cidade>.json` no diretório correto

### Build Android falha
Verifique se:
- O flavor está definido no `build.gradle.kts`
- Existe o `google-services.json` para o flavor
- O `applicationId` está correto

### Build iOS falha
- Execute o script de configuração antes do build
- Verifique se o `GoogleService-Info.plist` existe
- Limpe o projeto: `flutter clean && flutter pub get`