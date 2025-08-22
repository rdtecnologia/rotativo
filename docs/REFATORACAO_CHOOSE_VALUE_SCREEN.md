# Refatoração da ChooseValueScreen - Substituição de setState por Riverpod

## Resumo das Mudanças

Esta refatoração substitui o uso de `setState` por gerenciamento de estado usando Riverpod na tela `ChooseValueScreen`, otimizando o build apenas dos widgets necessários e não da tela inteira.

## Arquivos Criados/Modificados

### 1. Novo Provider: `lib/providers/choose_value_provider.dart`
- **Estado**: `ChooseValueState` com campos para validação e valor customizado
- **Notifier**: `ChooseValueNotifier` que gerencia as mudanças de estado
- **Provider**: `chooseValueProvider` exposto para uso na aplicação

### 2. Novo Widget: `lib/widgets/custom_value_section.dart`
- **Widget separado** para a seção de valor customizado
- **ConsumerStatefulWidget** que observa apenas o provider necessário
- **Rebuild otimizado** apenas quando o estado do valor customizado muda

### 3. Tela Refatorada: `lib/screens/purchase/choose_value_screen.dart`
- **Removidos todos os `setState`**
- **Substituídos por observação do provider** via `ref.watch(chooseValueProvider)`
- **Widget separado** para a seção de valor customizado
- **Build otimizado** da tela principal

## Benefícios da Refatoração

### 1. Performance
- **Build seletivo**: Apenas o widget `CustomValueSection` é reconstruído quando o valor muda
- **Tela principal estável**: A tela `ChooseValueScreen` não é reconstruída desnecessariamente
- **Estado isolado**: O estado do valor customizado é gerenciado independentemente

### 2. Manutenibilidade
- **Separação de responsabilidades**: Cada widget tem sua responsabilidade específica
- **Código mais limpo**: Lógica de estado separada da lógica de UI
- **Reutilização**: O widget `CustomValueSection` pode ser reutilizado em outras telas

### 3. Arquitetura
- **Padrão Riverpod**: Seguindo as melhores práticas de gerenciamento de estado
- **Imutabilidade**: Estado imutável com `copyWith` para atualizações
- **Testabilidade**: Providers podem ser facilmente testados isoladamente

## Como Funciona

### 1. Fluxo de Estado
```
TextFormField.onChanged → _onTextChanged() → Provider.updateCustomValue() → 
StateNotifier.state = newState → Widget rebuild (apenas CustomValueSection)
```

### 2. Observação de Estado
- **Tela principal**: Observa apenas `cityConfigProvider` e `parkingRulesProvider`
- **Seção customizada**: Observa apenas `chooseValueProvider`
- **Rebuilds isolados**: Mudanças em um provider não afetam outros widgets

### 3. Validação em Tempo Real
- **Validação automática**: Cada mudança no campo de texto dispara validação
- **Estado reativo**: UI atualiza automaticamente baseada na validação
- **Feedback visual**: Cores e mensagens mudam conforme o estado

## Estrutura do Provider

```dart
class ChooseValueState {
  final bool isCustomValueValid;
  final double? customValue;
  final String customValueText;
  
  // copyWith para atualizações imutáveis
}

class ChooseValueNotifier extends StateNotifier<ChooseValueState> {
  void updateCustomValue(String text) {
    // Lógica de validação e atualização de estado
  }
  
  void reset() {
    // Reset do estado
  }
}
```

## Uso na Tela

```dart
// Na tela principal
CustomValueSection(
  onPurchase: () => _purchaseCustomValue(context, ref),
)

// No widget customizado
final chooseValueState = ref.watch(chooseValueProvider);
// UI reativa baseada no estado
```

## Considerações de Performance

### Antes (com setState)
- **Tela inteira rebuild**: Qualquer mudança no valor customizado causava rebuild da tela completa
- **Widgets desnecessários**: Todos os widgets eram reconstruídos mesmo sem mudanças

### Depois (com Riverpod)
- **Build seletivo**: Apenas `CustomValueSection` é reconstruído quando necessário
- **Tela estável**: `ChooseValueScreen` mantém seu estado e não é reconstruída
- **Otimização automática**: Riverpod gerencia automaticamente quando rebuilds são necessários

## Testes

- **Provider isolado**: `ChooseValueNotifier` pode ser testado independentemente
- **Widget isolado**: `CustomValueSection` pode ser testado com mocks do provider
- **Tela principal**: `ChooseValueScreen` pode ser testada com providers mockados

## Próximos Passos

1. **Testes unitários** para o provider e widget
2. **Testes de integração** para a tela completa
3. **Aplicar padrão similar** em outras telas que usam `setState`
4. **Monitoramento de performance** para validar melhorias
