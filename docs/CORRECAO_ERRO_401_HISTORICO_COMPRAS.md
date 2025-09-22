# Correção do Erro 401 no Histórico de Compras

## Problema Identificado

No aplicativo build release, ao acessar o histórico de compras pela primeira vez, ocorria um erro 401 (Unauthorized). O erro desaparecia ao clicar em "Tentar novamente", indicando um problema de timing na autenticação.

## Causa Raiz

O erro acontecia porque:

1. **Timing de Autenticação**: A primeira requisição ao histórico era feita antes do token de autenticação estar completamente carregado e validado
2. **Falta de Validação Prévia**: Não havia verificação se o token estava disponível antes de fazer a requisição
3. **Ausência de Retry Automático**: Não havia mecanismo para tentar novamente automaticamente em caso de erro de autenticação

## Solução Implementada

### 1. Validação Prévia de Autenticação (`HistoryService`)

```dart
/// Ensure authentication is ready before making requests
static Future<void> _ensureAuthenticationReady() async {
  try {
    // Wait for token to be available
    final token = await AuthService.getStoredToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token de autenticação não disponível');
    }
    
    // Wait for user to be available
    final user = await AuthService.getStoredUser();
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }
    
    // Small delay to ensure everything is properly initialized
    await Future.delayed(const Duration(milliseconds: 100));
    
  } catch (e) {
    throw Exception('Autenticação não está pronta. Faça login novamente.');
  }
}
```

### 2. Retry Automático (`HistoryProvider`)

```dart
// Handle retry logic for authentication errors
if ((e.toString().contains('401') || 
     e.toString().contains('Token de autenticação não disponível') ||
     e.toString().contains('Usuário não autenticado')) && 
    retryCount < 2) {
  
  // Wait a bit before retrying
  await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
  
  // Retry the request
  return loadOrders(
    refresh: refresh,
    filters: filters,
    retryCount: retryCount + 1,
  );
}
```

### 3. Mensagens de Erro Amigáveis

```dart
// Provide user-friendly error messages
String errorMessage;
if (e.toString().contains('401')) {
  errorMessage = 'Erro de autenticação. Faça login novamente.';
} else if (e.toString().contains('Token de autenticação não disponível')) {
  errorMessage = 'Sessão expirada. Faça login novamente.';
} else if (e.toString().contains('Usuário não autenticado')) {
  errorMessage = 'Usuário não autenticado. Faça login novamente.';
} else {
  errorMessage = 'Erro ao carregar histórico de compras: ${e.toString()}';
}
```

## Benefícios da Solução

1. **Eliminação do Erro 401**: A validação prévia garante que o token esteja disponível antes da requisição
2. **Retry Automático**: Em caso de falha de autenticação, o sistema tenta automaticamente até 2 vezes
3. **Melhor UX**: Mensagens de erro mais claras e amigáveis para o usuário
4. **Logs Detalhados**: Melhor debugging em modo desenvolvimento
5. **Robustez**: Sistema mais resiliente a problemas temporários de autenticação

## Arquivos Modificados

- `lib/services/history_service.dart`
  - Adicionado método `_ensureAuthenticationReady()`
  - Chamada de validação antes da requisição

- `lib/providers/history_provider.dart`
  - Adicionado parâmetro `retryCount` no método `loadOrders()`
  - Implementado retry automático para erros de autenticação
  - Melhorado tratamento de mensagens de erro

## Teste

Para testar a correção:

1. Faça login no aplicativo
2. Acesse o histórico de compras
3. Verifique se não há mais erro 401 no primeiro acesso
4. Se ainda houver erro, o sistema deve tentar automaticamente

## Considerações Técnicas

- O retry tem um delay progressivo (500ms, 1000ms) para evitar sobrecarga
- Máximo de 2 tentativas automáticas para evitar loops infinitos
- Validação tanto do token quanto do usuário para garantir autenticação completa
- Logs detalhados apenas em modo debug para não impactar performance
