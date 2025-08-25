# Sistema de Atualização de Tempo das Ativações

## Visão Geral

Este documento descreve o sistema otimizado de atualização de tempo das ativações de estacionamento, que foi redesenhado para:

- **Atualizar a cada minuto** (não mais a cada segundo)
- **Disponibilizar globalmente** para todo o app
- **Suportar notificações** de proximidade de vencimento
- **Otimizar a performance** removendo rebuilds desnecessários

## Providers Disponíveis

### 1. `timeUpdateProvider`
Provider global que atualiza a cada minuto e pode ser usado por qualquer parte do app.

```dart
class MinhaTela extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa mudanças no tempo global
    final currentTime = ref.watch(timeUpdateProvider);
    
    return Text('Última atualização: $currentTime');
  }
}
```

### 2. `expiringSoonActivationsProvider`
Provider que retorna ativações que expiram em 15 minutos ou menos.

```dart
class NotificacoesWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiringSoon = ref.watch(expiringSoonActivationsProvider);
    
    return Column(
      children: expiringSoon.map((activation) => 
        Text('${activation.licensePlate} expira em ${activation.remainingMinutes}min')
      ).toList(),
    );
  }
}
```

### 3. `recentlyExpiredActivationsProvider`
Provider que retorna ativações que expiraram há 5 minutos ou menos.

```dart
class AtivacoesExpiradasWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyExpired = ref.watch(recentlyExpiredActivationsProvider);
    
    return Column(
      children: recentlyExpired.map((activation) => 
        Text('${activation.licensePlate} expirou!')
      ).toList(),
    );
  }
}
```

## Sistema de Notificações

### Monitor Automático
O `ActivationNotificationMonitor` é automaticamente incluído na `HomePage` e monitora:

- **Ativações próximas de expirar** (≤ 15 min): Notificação laranja
- **Ativações que expiraram** (≤ 5 min atrás): Notificação vermelha

### Uso Manual
Para usar notificações em outras telas:

```dart
import '../services/notification_service.dart';

// Mostrar notificação de proximidade de vencimento
UseActivationNotifications.showExpiringSoon(
  context, 
  'ABC1234', 
  10
);

// Mostrar notificação de expiração
UseActivationNotifications.showExpired(
  context, 
  'ABC1234'
);
```

## Como Funciona

### 1. Timer Principal
- **Frequência**: A cada minuto
- **Função**: Atualiza dados das ativações e remove as expiradas
- **Performance**: Otimizado para não impactar a UI

### 2. Atualização da UI
- **Trigger**: Mudanças no `timeUpdateProvider`
- **Frequência**: A cada minuto (sincronizado com o timer principal)
- **Escopo**: Apenas widgets que observam o provider

### 3. Notificações
- **Automáticas**: Via `ActivationNotificationMonitor`
- **Manuais**: Via `UseActivationNotifications`
- **Contexto**: Baseado no estado atual das ativações

## Benefícios da Nova Implementação

### Performance
- ✅ **Sem timer de 1 segundo** - Reduz rebuilds desnecessários
- ✅ **Atualização sincronizada** - Todos os timers atualizam juntos
- ✅ **Rebuilds otimizados** - Apenas quando necessário

### Funcionalidade
- ✅ **Notificações automáticas** - Proximidade de vencimento
- ✅ **Disponível globalmente** - Qualquer tela pode usar
- ✅ **Sistema unificado** - Um timer para todo o app

### Manutenibilidade
- ✅ **Código limpo** - Sem timers duplicados
- ✅ **Fácil de estender** - Novos providers podem ser adicionados
- ✅ **Bem documentado** - Exemplos de uso incluídos

## Exemplo de Implementação Completa

```dart
class MinhaTela extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa tempo global
    final currentTime = ref.watch(timeUpdateProvider);
    
    // Observa ativações próximas de expirar
    final expiringSoon = ref.watch(expiringSoonActivationsProvider);
    
    // Observa ativações que expiraram
    final recentlyExpired = ref.watch(recentlyExpiredActivationsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Última atualização: ${currentTime.hour}:${currentTime.minute}'),
      ),
      body: Column(
        children: [
          // Lista de ativações próximas de expirar
          if (expiringSoon.isNotEmpty) ...[
            Text('Expirando em breve:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...expiringSoon.map((activation) => 
              ListTile(
                title: Text(activation.licensePlate),
                subtitle: Text('Expira em ${activation.remainingMinutes} minutos'),
                trailing: Icon(Icons.warning, color: Colors.orange),
              )
            ),
          ],
          
          // Lista de ativações que expiraram
          if (recentlyExpired.isNotEmpty) ...[
            Text('Expiradas recentemente:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...recentlyExpired.map((activation) => 
              ListTile(
                title: Text(activation.licensePlate),
                subtitle: Text('Expirada'),
                trailing: Icon(Icons.error, color: Colors.red),
              )
            ),
          ],
        ],
      ),
    );
  }
}
```

## Migração

### Antes (Timer de 1 segundo)
```dart
// ❌ Desnecessário e pesado
Timer.periodic(const Duration(seconds: 1), (timer) {
  setState(() {}); // Força rebuild a cada segundo
});
```

### Depois (Timer de 1 minuto)
```dart
// ✅ Otimizado e eficiente
ref.watch(timeUpdateProvider); // Atualiza a cada minuto
```

## Conclusão

O novo sistema oferece:

1. **Melhor performance** - Sem rebuilds desnecessários
2. **Funcionalidade expandida** - Notificações automáticas
3. **Disponibilidade global** - Qualquer tela pode usar
4. **Código mais limpo** - Sem duplicação de timers
5. **Fácil manutenção** - Sistema centralizado e bem documentado

Para usar, basta observar os providers relevantes em seus widgets. O sistema funcionará automaticamente em segundo plano.
