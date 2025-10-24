# Firebase Debug Mode - Solução para Envio de Relatórios

## 🔍 Problema Identificado

O Crashlytics estava com coleta automática de dados **DESABILITADA** em modo debug:
```
D FirebaseCrashlytics: Crashlytics automatic data collection DISABLED by API.
D FirebaseCrashlytics: Automatic data collection is disabled.
D FirebaseCrashlytics: Waiting for send/deleteUnsentReports to be called.
```

### Por que isso acontecia?

A configuração original desabilitava o Crashlytics em modo debug:
```dart
await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);
```

Isso significa:
- **Release mode**: Crashlytics ATIVO ✅
- **Debug mode**: Crashlytics INATIVO ❌

## ✅ Solução Implementada

### 1. Habilitação Permanente do Crashlytics

Alteramos a configuração para sempre habilitar o Crashlytics:

```dart
// Sempre habilita coleta de crashes (mesmo em debug para testes)
await _crashlytics!.setCrashlyticsCollectionEnabled(true);
```

### 2. Métodos para Forçar Envio de Relatórios

Adicionados novos métodos no `FirebaseService`:

```dart
/// Forçar envio de relatórios não enviados
Future<void> sendUnsentReports()

/// Verificar se há relatórios não enviados
Future<bool> checkForUnsentReports()
```

### 3. Botão "Force Send Reports" na Debug Page

Novo botão roxo que:
- ✅ Verifica se há relatórios pendentes
- 📤 Força o envio imediato dos relatórios
- 💬 Mostra feedback ao usuário

## 🎯 Como Testar Agora

### Passo 1: Hot Restart o App
```bash
# No terminal ou no IDE
flutter clean
flutter run --flavor ouroPreto
```

### Passo 2: Acesse a Debug Page
- Navegue até a página de debug do app

### Passo 3: Teste o Crashlytics
1. Clique em **"Test Error"** (botão laranja)
2. Clique em **"Test Log"** (botão laranja)
3. Clique em **"Test API Error"** (botão vermelho)

### Passo 4: Force Send Reports
1. Clique em **"Force Send Reports"** (botão roxo)
2. Aguarde a confirmação no SnackBar

### Passo 5: Verifique no Firebase Console
1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Selecione o projeto **Rotativo Ouro Preto**
3. Vá em **Crashlytics** → **Issues**
4. Os erros de teste devem aparecer em alguns minutos

## 📊 Verificação via Logcat

Para monitorar o envio em tempo real:

```bash
adb logcat -s FirebaseCrashlytics
```

Você deve ver:
```
D FirebaseCrashlytics: disk worker: log non-fatal event to persistence
I FirebaseCrashlytics: Sending report to: https://reports.crashlytics.com/...
D FirebaseCrashlytics: Report successfully sent
```

## 🔄 Comportamento Esperado

### Antes da Correção
```
❌ Crashlytics desabilitado em debug
❌ Relatórios ficam em espera
❌ Necessário deleteUnsentReports() ou sendUnsentReports()
```

### Depois da Correção
```
✅ Crashlytics sempre habilitado
✅ Relatórios enviados automaticamente
✅ Botão para forçar envio disponível
```

## 📝 Logs de Sucesso

Quando funcionando corretamente, você verá:

```
I FirebaseCrashlytics: Initializing Firebase Crashlytics 19.4.4
D FirebaseCrashlytics: Crashlytics automatic data collection ENABLED
D FirebaseCrashlytics: Successfully configured exception handler
D FirebaseCrashlytics: Opening a new session with ID...
D FirebaseCrashlytics: disk worker: log non-fatal event to persistence
📤 Unsent Crashlytics reports sent
```

## ⚠️ Importante

### Para Produção
O Crashlytics agora está sempre habilitado. Se você quiser desabilitar em debug no futuro, altere:

```dart
// No arquivo: lib/services/firebase_service.dart
await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);
```

### Analytics
O Analytics continua funcionando normalmente em todos os modos. Não requer configuração especial.

## 🧪 Testes Disponíveis na Debug Page

| Botão | Cor | Função | O que Testa |
|-------|-----|--------|-------------|
| Test Analytics | Azul | Envia evento customizado | Analytics Events |
| Test Screen | Azul | Envia screen view | Screen Tracking |
| Test Error | Laranja | Envia erro não-fatal | Crashlytics Errors |
| Test Log | Laranja | Envia log | Crashlytics Logging |
| Test API Error | Vermelho | Simula erro de API | Custom Error Keys |
| Set User Properties | Verde | Define propriedades | User Properties |
| **Force Send Reports** | **Roxo** | **Força envio** | **Report Delivery** |

## 🎉 Resultado Final

Agora os testes na Debug Page funcionam corretamente e os dados são enviados para o Firebase Console, permitindo validação completa da integração do Firebase com flavors!







