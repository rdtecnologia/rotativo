# Providers do Rotativo

Este diretório contém todos os providers da aplicação usando Riverpod para gerenciamento de estado.

## RegisterFormProvider

O `RegisterFormProvider` gerencia o estado do formulário de registro, incluindo:

### Funcionalidades

- **Gerenciamento do checkbox de termos**: Controla se o usuário aceitou os termos de uso
- **Validação de formulário**: Valida se todos os campos obrigatórios foram preenchidos
- **Tratamento de erros**: Gerencia erros de validação e exibe mensagens apropriadas
- **Estado reativo**: Atualiza automaticamente a UI quando o estado muda

### Como usar

```dart
// Em um ConsumerWidget ou ConsumerStatefulWidget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar o estado
    final registerFormState = ref.watch(registerFormProvider);
    
    // Acessar o notifier para ações
    final registerFormNotifier = ref.read(registerFormProvider.notifier);
    
    return Column(
      children: [
        // Checkbox dos termos
        Checkbox(
          value: registerFormState.acceptTerms,
          onChanged: (value) {
            registerFormNotifier.setAcceptTerms(value ?? false);
          },
        ),
        
        // Exibir erro de validação
        if (registerFormState.hasValidationError)
          Text(registerFormState.validationError!),
          
        // Botão de envio
        ElevatedButton(
          onPressed: registerFormState.isFormValid ? _submit : null,
          child: Text('Enviar'),
        ),
      ],
    );
  }
}
```

### Providers disponíveis

- `registerFormProvider`: Provider principal que expõe o estado
- `registerFormKeyProvider`: Provider para a chave do formulário
- `registerFormNotifierProvider`: Provider para acessar o notifier diretamente

### Métodos do Notifier

- `setAcceptTerms(bool value)`: Define se os termos foram aceitos
- `toggleAcceptTerms()`: Alterna o estado dos termos
- `validateForm(GlobalKey<FormBuilderState> formKey)`: Valida o formulário completo
- `reset()`: Limpa o estado do formulário
- `setValidationError(String? error)`: Define um erro de validação
- `clearValidationError()`: Limpa o erro de validação

### Estado

O `RegisterFormState` contém:

- `acceptTerms`: Se os termos foram aceitos
- `validationError`: Mensagem de erro de validação (se houver)
- `hasValidationError`: Getter para verificar se há erro
- `isFormValid`: Getter para verificar se o formulário está válido

## Vantagens do Riverpod

1. **Estado centralizado**: Todo o estado do formulário está em um local
2. **Reatividade**: A UI se atualiza automaticamente quando o estado muda
3. **Testabilidade**: Fácil de testar isoladamente
4. **Reutilização**: O provider pode ser usado em múltiplas telas
5. **Performance**: Apenas os widgets que dependem do estado são reconstruídos
6. **Debugging**: Fácil de debugar com ferramentas como Riverpod Inspector
