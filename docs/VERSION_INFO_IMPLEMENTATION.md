# Implementação da Versão do Aplicativo

## Visão Geral

Esta implementação permite obter dinamicamente a versão do aplicativo Flutter e exibi-la na tela de Configurações, além de fornecer uma tela detalhada com informações completas sobre o app.

## Arquivos Criados/Modificados

### 1. Serviço de Informações do App (`lib/services/app_info_service.dart`)
- **Função**: Fornece métodos para obter informações do aplicativo e dispositivo
- **Métodos do App**:
  - `getAppVersion()`: Retorna a versão do app (ex: "0.1.0")
  - `getBuildNumber()`: Retorna o número do build (ex: "1")
  - `getFullVersion()`: Retorna versão completa (ex: "0.1.0+1")
  - `getAppName()`: Retorna o nome do aplicativo
- **Métodos do Dispositivo**:
  - `getDeviceBrand()`: Retorna a marca do dispositivo (ex: "Samsung", "Apple")
  - `getDeviceModel()`: Retorna o modelo do dispositivo (ex: "Galaxy S21", "iPhone 15")
  - `getDeviceInfo()`: Retorna marca e modelo combinados
  - `getOSVersion()`: Retorna a versão do sistema operacional

### 2. Provider de Informações do App (`lib/providers/app_info_provider.dart`)
- **Função**: Gerenciar o estado das informações do app e dispositivo usando Riverpod
- **Providers do App**:
  - `appVersionProvider`: Versão do app
  - `appBuildNumberProvider`: Número do build
  - `appFullVersionProvider`: Versão completa
  - `appNameProvider`: Nome do app
- **Providers do Dispositivo**:
  - `deviceBrandProvider`: Marca do dispositivo
  - `deviceModelProvider`: Modelo do dispositivo
  - `deviceInfoProvider`: Informações completas do dispositivo
  - `osVersionProvider`: Versão do sistema operacional

### 3. Tela de Detalhes da Versão (`lib/screens/settings/app_version_screen.dart`)
- **Função**: Exibir informações detalhadas sobre o aplicativo e dispositivo
- **Seções**:
  - Informações da versão
  - Informações do dispositivo (marca, modelo, SO)
  - Descrição do app
  - Informações de desenvolvimento
  - Copyright

### 4. Tela de Configurações Atualizada (`lib/screens/settings/settings_screen.dart`)
- **Modificação**: Integração com o provider de versão
- **Funcionalidade**: Exibe versão dinâmica e permite navegação para detalhes

## Dependências Adicionadas

```yaml
dependencies:
  package_info_plus: ^8.0.2
  device_info_plus: ^11.5.0
```

## Como Funciona

1. **Obtenção da Versão**: O `package_info_plus` lê automaticamente a versão do `pubspec.yaml`
2. **Gerenciamento de Estado**: Riverpod gerencia o estado assíncrono das informações
3. **Interface do Usuário**: A versão é exibida dinamicamente na tela de configurações
4. **Navegação**: Ao tocar na versão, o usuário é levado para uma tela detalhada

## Uso

### Na Tela de Configurações
```dart
Consumer(
  builder: (context, ref, child) {
    final versionAsync = ref.watch(appVersionProvider);
    
    return versionAsync.when(
      data: (version) => Text(version),
      loading: () => Text('Carregando...'),
      error: (_, __) => Text('1.0.0'),
    );
  },
)
```

### Para Obter Informações Programaticamente
```dart
// Informações do App
final version = await AppInfoService.getAppVersion();
final fullVersion = await AppInfoService.getFullVersion();
final appName = await AppInfoService.getAppName();

// Informações do Dispositivo
final brand = await AppInfoService.getDeviceBrand();
final model = await AppInfoService.getDeviceModel();
final deviceInfo = await AppInfoService.getDeviceInfo();
final osVersion = await AppInfoService.getOSVersion();
```

## Benefícios

1. **Atualização Automática**: A versão é sempre atualizada quando o `pubspec.yaml` é modificado
2. **Informações do Dispositivo**: Acesso a marca, modelo e sistema operacional em tempo real
3. **Fallback Seguro**: Em caso de erro, valores padrão são exibidos
4. **Interface Responsiva**: Estados de loading e erro são tratados adequadamente
5. **Reutilização**: O serviço pode ser usado em outras partes do app
6. **Testabilidade**: Código testável com mocks quando necessário
7. **Multiplataforma**: Suporte para Android, iOS, macOS, Windows e Linux

## Manutenção

- **Atualizar Versão**: Modifique o campo `version` no `pubspec.yaml`
- **Adicionar Informações**: Estenda o `AppInfoService` com novos métodos
- **Personalizar Interface**: Modifique a `AppVersionScreen` para incluir novas seções

## Testes

Os testes estão localizados em `test/app_info_service_test.dart` e verificam:
- Retorno de strings válidas para informações do app
- Formato correto da versão completa
- Retorno de strings válidas para informações do dispositivo
- Combinação correta de marca e modelo
- Tratamento de erros

Execute com: `flutter test test/app_info_service_test.dart`
