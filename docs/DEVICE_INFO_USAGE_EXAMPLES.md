# Exemplos de Uso das Informações do Dispositivo

## Visão Geral

Este documento mostra como usar as informações do dispositivo em diferentes partes do aplicativo Flutter.

## Exemplos Básicos

### 1. Exibir Informações do Dispositivo em um Widget

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_info_provider.dart';

class DeviceInfoWidget extends ConsumerWidget {
  const DeviceInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceInfo = ref.watch(deviceInfoProvider);
    
    return deviceInfo.when(
      data: (info) => Card(
        child: ListTile(
          leading: const Icon(Icons.phone_android),
          title: const Text('Dispositivo'),
          subtitle: Text(info),
        ),
      ),
      loading: () => const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Carregando...'),
        ),
      ),
      error: (_, __) => const Card(
        child: ListTile(
          leading: Icon(Icons.error),
          title: Text('Erro ao carregar'),
        ),
      ),
    );
  }
}
```

### 2. Usar em um Dialog de Suporte

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_info_provider.dart';

class SupportDialog extends ConsumerWidget {
  const SupportDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Informações para Suporte'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('App', ref.watch(appVersionProvider)),
          _buildInfoRow('Dispositivo', ref.watch(deviceInfoProvider)),
          _buildInfoRow('Sistema', ref.watch(osVersionProvider)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, AsyncValue<String> value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: value.when(
              data: (data) => Text(data),
              loading: () => const Text('...'),
              error: (_, __) => const Text('N/A'),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. Enviar Informações para API de Suporte

```dart
import '../services/app_info_service.dart';

class SupportService {
  static Future<Map<String, String>> getDeviceInfoForSupport() async {
    try {
      final appVersion = await AppInfoService.getAppVersion();
      final deviceInfo = await AppInfoService.getDeviceInfo();
      final osVersion = await AppInfoService.getOSVersion();
      
      return {
        'app_version': appVersion,
        'device_info': deviceInfo,
        'os_version': osVersion,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'Erro ao obter informações do dispositivo',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
  
  static Future<void> sendSupportRequest(String message) async {
    final deviceInfo = await getDeviceInfoForSupport();
    
    // Adicionar mensagem do usuário
    deviceInfo['user_message'] = message;
    
    // Enviar para API
    // await apiService.sendSupportRequest(deviceInfo);
  }
}
```

### 4. Widget de Debug para Desenvolvedores

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_info_provider.dart';

class DebugInfoWidget extends ConsumerWidget {
  const DebugInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExpansionTile(
      title: const Text('Informações de Debug'),
      children: [
        _buildInfoTile('Versão do App', ref.watch(appVersionProvider)),
        _buildInfoTile('Build Number', ref.watch(appBuildNumberProvider)),
        _buildInfoTile('Marca', ref.watch(deviceBrandProvider)),
        _buildInfoTile('Modelo', ref.watch(deviceModelProvider)),
        _buildInfoTile('Sistema', ref.watch(osVersionProvider)),
      ],
    );
  }

  Widget _buildInfoTile(String label, AsyncValue<String> value) {
    return ListTile(
      title: Text(label),
      subtitle: value.when(
        data: (data) => Text(data),
        loading: () => const Text('Carregando...'),
        error: (_, __) => const Text('Erro'),
      ),
    );
  }
}
```

### 5. Usar em Logs de Erro

```dart
import '../services/app_info_service.dart';

class ErrorLogger {
  static Future<void> logError(String error, StackTrace stackTrace) async {
    try {
      final deviceInfo = await AppInfoService.getDeviceInfo();
      final appVersion = await AppInfoService.getAppVersion();
      final osVersion = await AppInfoService.getOSVersion();
      
      final logEntry = {
        'error': error,
        'stack_trace': stackTrace.toString(),
        'device_info': deviceInfo,
        'app_version': appVersion,
        'os_version': osVersion,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Salvar log localmente ou enviar para serviço de monitoramento
      print('Error Log: $logEntry');
    } catch (e) {
      print('Erro ao gerar log: $e');
    }
  }
}
```

## Casos de Uso Comuns

### 1. **Suporte ao Cliente**
- Incluir informações do dispositivo em tickets de suporte
- Facilitar diagnóstico de problemas específicos da plataforma

### 2. **Analytics e Monitoramento**
- Rastrear uso por tipo de dispositivo
- Identificar problemas específicos de plataforma

### 3. **Debug e Desenvolvimento**
- Mostrar informações técnicas para desenvolvedores
- Facilitar testes em diferentes dispositivos

### 4. **Personalização da Interface**
- Adaptar UI baseado no tipo de dispositivo
- Mostrar funcionalidades específicas da plataforma

### 5. **Relatórios de Qualidade**
- Coletar métricas de performance por dispositivo
- Identificar dispositivos com problemas

## Considerações de Privacidade

⚠️ **Importante**: Sempre considere a privacidade do usuário ao coletar informações do dispositivo:

- **Informações Seguras**: Marca, modelo e versão do SO são geralmente seguras
- **Evitar**: Informações que possam identificar o usuário
- **Transparência**: Informe ao usuário quais dados estão sendo coletados
- **Consentimento**: Obtenha permissão quando necessário

## Boas Práticas

1. **Tratamento de Erros**: Sempre use try-catch ao obter informações do dispositivo
2. **Fallbacks**: Forneça valores padrão quando as informações não estiverem disponíveis
3. **Performance**: As informações do dispositivo são obtidas de forma assíncrona
4. **Cache**: Considere cachear informações que não mudam durante a sessão
5. **Testes**: Teste em diferentes dispositivos e plataformas
