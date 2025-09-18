# Debug de Notificações Agendadas - Guia de Investigação

## Problema Atual

As notificações pararam de aparecer imediatamente ao fazer configurações (✅ resolvido), mas agora não estão aparecendo quando chega no tempo de vencimento.

## Ferramentas de Debug Implementadas

### 1. **Logs Detalhados de Agendamento**

#### No `local_notification_service.dart`:
```dart
// Logs detalhados durante o agendamento
debugPrint('🔔 Tentando agendar notificação:');
debugPrint('  - ID: $notificationId');
debugPrint('  - Placa: $licensePlate');
debugPrint('  - Horário atual: ${DateTime.now()}');
debugPrint('  - Horário da notificação: $notificationTime');
debugPrint('  - Timezone local: ${tz.local}');
debugPrint('  - TZDateTime: ${tz.TZDateTime.from(notificationTime, tz.local)}');
```

### 2. **Verificação de Notificações Pendentes**

```dart
// Verifica se a notificação foi realmente agendada
final pendingNotifications = await _notifications.pendingNotificationRequests();
final scheduledNotification = pendingNotifications.where((n) => n.id == notificationId).isNotEmpty 
    ? pendingNotifications.where((n) => n.id == notificationId).first 
    : null;
if (scheduledNotification != null) {
  debugPrint('✅ Confirmado: Notificação ID $notificationId está na lista de pendentes');
} else {
  debugPrint('❌ PROBLEMA: Notificação ID $notificationId NÃO foi encontrada na lista de pendentes!');
}
```

### 3. **Método de Debug de Notificações Pendentes**

```dart
/// Lista e exibe todas as notificações pendentes para debug
Future<void> debugPendingNotifications() async {
  try {
    final pendingNotifications = await _notifications.pendingNotificationRequests();
    debugPrint('🔔 === NOTIFICAÇÕES PENDENTES ===');
    debugPrint('📊 Total: ${pendingNotifications.length}');
    
    if (pendingNotifications.isEmpty) {
      debugPrint('❌ Nenhuma notificação pendente encontrada!');
    } else {
      for (final notification in pendingNotifications) {
        debugPrint('📋 ID: ${notification.id}');
        debugPrint('   Título: ${notification.title}');
        debugPrint('   Corpo: ${notification.body}');
        debugPrint('   Payload: ${notification.payload}');
        debugPrint('   ---');
      }
    }
    debugPrint('🔔 === FIM DA LISTA ===');
  } catch (e) {
    debugPrint('❌ Erro ao listar notificações pendentes: $e');
  }
}
```

### 4. **Teste Simples de Notificação**

```dart
/// Teste simples de notificação agendada (funciona em iOS e Android)
Future<void> testSimpleScheduledNotification({int secondsFromNow = 30}) async {
  debugPrint('🧪 === TESTE SIMPLES DE NOTIFICAÇÃO AGENDADA ===');
  debugPrint('⏰ Agendando notificação para $secondsFromNow segundos...');
  
  final scheduledTime = DateTime.now().add(Duration(seconds: secondsFromNow));
  final notificationId = 999999;
  
  debugPrint('📅 Horário atual: ${DateTime.now()}');
  debugPrint('📅 Horário agendado: $scheduledTime');
  debugPrint('🆔 ID da notificação: $notificationId');
  
  // ... código de agendamento ...
  
  debugPrint('🔔 Aguarde $secondsFromNow segundos para ver a notificação...');
}
```

### 5. **Captura de Erros Detalhada**

```dart
} catch (e) {
  debugPrint('❌ ERRO CRÍTICO ao agendar notificação para $licensePlate:');
  debugPrint('  - Tipo do erro: ${e.runtimeType}');
  debugPrint('  - Mensagem: ${e.toString()}');
  debugPrint('  - Stack trace: ${StackTrace.current}');
  
  // Re-lança o erro para investigação
  rethrow;
}
```

## Como Usar as Ferramentas de Debug

### 1. **Teste Básico de Funcionamento**

```dart
// No código do app, chame:
final notificationService = LocalNotificationService();
await notificationService.testSimpleScheduledNotification(secondsFromNow: 30);

// Aguarde 30 segundos e veja se a notificação aparece
```

### 2. **Verificar Notificações Pendentes**

```dart
final notificationService = LocalNotificationService();
await notificationService.debugPendingNotifications();

// Ou através do serviço de estacionamento:
final parkingService = ParkingNotificationService();
await parkingService.debugAllPendingNotifications();
```

### 3. **Testar com Estacionamento Real**

```dart
final parkingService = ParkingNotificationService();
await parkingService.testNotificationTiming(
  licensePlate: 'TEST123',
  minutesFromNow: 5, // Expira em 5 minutos
  reminderMinutes: 2, // Notifica 2 minutos antes
);
// Deve aparecer em 3 minutos (5 - 2)
```

## Possíveis Causas do Problema

### 1. **Problemas de Timezone**
- O `tz.TZDateTime.from()` pode estar criando horários incorretos
- Verificar se o timezone está configurado corretamente

### 2. **Permissões Insuficientes**
- iOS pode precisar de permissões adicionais para notificações agendadas
- Android pode precisar de permissão de alarme exato

### 3. **Configuração de Canal (Android)**
- Canal de notificação pode estar mal configurado
- Importância do canal pode estar baixa

### 4. **Problemas de Background (iOS)**
- iOS pode estar limitando notificações em background
- Configurações do Info.plist podem estar incorretas

### 5. **ID de Notificação Duplicado**
- IDs duplicados podem estar cancelando notificações anteriores
- Verificar se a geração de ID está correta

## Passos para Investigação

### Passo 1: Verificar se o Agendamento Funciona
```dart
// Teste simples de 30 segundos
await notificationService.testSimpleScheduledNotification(secondsFromNow: 30);
```

### Passo 2: Verificar Notificações Pendentes
```dart
// Após agendar, verificar se aparece na lista
await notificationService.debugPendingNotifications();
```

### Passo 3: Verificar Logs de Erro
- Procurar por mensagens de erro nos logs
- Verificar se há exceções sendo lançadas

### Passo 4: Testar em Diferentes Tempos
```dart
// Teste com tempos diferentes
await notificationService.testSimpleScheduledNotification(secondsFromNow: 10); // 10 segundos
await notificationService.testSimpleScheduledNotification(secondsFromNow: 60); // 1 minuto
await notificationService.testSimpleScheduledNotification(secondsFromNow: 300); // 5 minutos
```

### Passo 5: Verificar Configurações do Sistema
- **iOS**: Verificar se notificações estão habilitadas nas Configurações
- **Android**: Verificar se o app tem permissão de alarme exato
- Verificar se o dispositivo não está em modo "Não Perturbe"

## Logs Esperados

### Sucesso no Agendamento:
```
🔔 Tentando agendar notificação:
  - ID: 123456
  - Placa: ABC1234
  - Horário atual: 2024-01-15 14:30:00.000
  - Horário da notificação: 2024-01-15 14:35:00.000
  - Timezone local: America/Sao_Paulo
  - TZDateTime: 2024-01-15 14:35:00.000-0300
✅ Notificação agendada com sucesso!
✅ Confirmado: Notificação ID 123456 está na lista de pendentes
```

### Problema no Agendamento:
```
🔔 Tentando agendar notificação:
  - ID: 123456
  - Placa: ABC1234
❌ ERRO CRÍTICO ao agendar notificação para ABC1234:
  - Tipo do erro: SomeException
  - Mensagem: Detailed error message
❌ PROBLEMA: Notificação ID 123456 NÃO foi encontrada na lista de pendentes!
```

## Próximos Passos

1. **Execute os testes** com as ferramentas implementadas
2. **Analise os logs** para identificar onde está falhando
3. **Verifique permissões** do sistema
4. **Teste em dispositivo real** se estiver usando emulador
5. **Compare comportamento** entre iOS e Android

Com essas ferramentas, devemos conseguir identificar exatamente onde está o problema e corrigi-lo.







