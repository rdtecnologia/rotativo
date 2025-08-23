# Widgets da Tela de Recuperação de Senha

Esta pasta contém os widgets específicos da tela de recuperação de senha (`ForgotPasswordScreen`), organizados de forma modular para melhor manutenção e reutilização.

## Estrutura dos Widgets

### `ForgotPasswordLogo`
- **Arquivo**: `forgot_password_logo.dart`
- **Descrição**: Widget que exibe o ícone de recuperação de senha com estilo circular e sombra
- **Responsabilidades**:
  - Renderizar o ícone de `lock_reset`
  - Aplicar decoração com bordas arredondadas e sombra
  - Definir dimensões padronizadas (120x120)

### `ForgotPasswordTitle`
- **Arquivo**: `forgot_password_title.dart`
- **Descrição**: Widget que exibe o título "ESQUECI MINHA SENHA"
- **Responsabilidades**:
  - Renderizar o título com estilo padronizado
  - Aplicar formatação de texto (tamanho, peso, cor)
  - Centralizar o texto

### `ForgotPasswordForm`
- **Arquivo**: `forgot_password_form.dart`
- **Descrição**: Widget que contém o formulário completo de recuperação de senha
- **Responsabilidades**:
  - Renderizar o card do formulário
  - Gerenciar o campo de CPF com validação e formatação
  - Exibir o botão de envio com estado de loading
  - Mostrar texto informativo sobre o processo
- **Parâmetros**:
  - `formKey`: Chave global do formulário
  - `initialCPF`: CPF inicial opcional
  - `onSubmit`: Callback para envio do formulário
  - `isLoading`: Estado de carregamento

### `ForgotPasswordActions`
- **Arquivo**: `forgot_password_actions.dart`
- **Descrição**: Widget que contém as ações secundárias da tela
- **Responsabilidades**:
  - Botão "Voltar ao Login"
  - Botão "Problemas? Fale conosco!"
  - Gerenciar ação de contato com suporte
- **Parâmetros**:
  - `onBackToLogin`: Callback para voltar ao login

## Arquivo de Exportação

### `forgot_widgets.dart`
- **Descrição**: Arquivo que exporta todos os widgets da pasta
- **Uso**: Permite importar todos os widgets com uma única linha
- **Exemplo**:
  ```dart
  import 'forgot_widgets/forgot_widgets.dart';
  ```

## Benefícios da Refatoração

1. **Modularidade**: Cada widget tem uma responsabilidade específica
2. **Reutilização**: Widgets podem ser reutilizados em outras telas se necessário
3. **Manutenção**: Mais fácil de manter e testar individualmente
4. **Legibilidade**: Código principal mais limpo e focado na lógica de negócio
5. **Testabilidade**: Cada widget pode ser testado isoladamente

## Como Usar

```dart
import 'forgot_widgets/forgot_widgets.dart';

// Na tela principal
Column(
  children: [
    const ForgotPasswordLogo(),
    const ForgotPasswordTitle(),
    ForgotPasswordForm(
      formKey: _formKey,
      initialCPF: widget.initialCPF,
      onSubmit: _handleSubmit,
      isLoading: authState.isLoading,
    ),
    ForgotPasswordActions(
      onBackToLogin: () => Navigator.of(context).pop(),
    ),
  ],
)
```
