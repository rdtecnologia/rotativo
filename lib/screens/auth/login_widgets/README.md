# Refatoração da Tela de Login

## Estrutura dos Widgets

A tela de login foi refatorada e dividida em widgets menores para melhor organização e manutenibilidade. Todos os widgets estão localizados na pasta `lib/screens/auth/login_widgets/`.

## Widgets Criados

### 1. `AppLogoWidget`
- **Arquivo**: `app_logo_widget.dart`
- **Responsabilidade**: Exibe o logo do aplicativo e o nome da cidade dinamicamente
- **Características**: 
  - Usa `FutureBuilder` para carregar o nome da cidade
  - Container circular com sombra
  - Ícone de estacionamento

### 2. `BiometricLoginWidget`
- **Arquivo**: `biometric_login_widget.dart`
- **Responsabilidade**: Interface e lógica para login biométrico
- **Características**:
  - Verifica credenciais armazenadas
  - Realiza autenticação biométrica
  - Exibe feedback de sucesso/erro
  - Navega para tela principal após login bem-sucedido

### 3. `BiometricSectionWidget`
- **Arquivo**: `biometric_section_widget.dart`
- **Responsabilidade**: Coordena a exibição da seção biométrica
- **Características**:
  - Monitora se biometria está habilitada
  - Controla visibilidade dos elementos biométricos
  - Inclui divisor "ou" e botão de alternância

### 4. `OrDividerWidget`
- **Arquivo**: `or_divider_widget.dart`
- **Responsabilidade**: Linha divisória com texto "ou"
- **Características**:
  - Simples e reutilizável
  - Estilo consistente com o tema

### 5. `LoginToggleButtonWidget`
- **Arquivo**: `login_toggle_button_widget.dart`
- **Responsabilidade**: Botão para alternar entre login tradicional e biométrico
- **Características**:
  - Adapta texto e ícone baseado no estado atual
  - Integra com o provider de estado da tela de login

### 6. `LoginFormWidget`
- **Arquivo**: `login_form_widget.dart`
- **Responsabilidade**: Formulário de login tradicional (CPF/senha)
- **Características**:
  - Campos de CPF e senha com validação
  - Botão de login com indicador de carregamento
  - Link para cadastro
  - Formatação automática do CPF

### 7. `LoginFormSectionWidget`
- **Arquivo**: `login_form_section_widget.dart`
- **Responsabilidade**: Coordena a seção do formulário de login
- **Características**:
  - Controla visibilidade do formulário
  - Inclui link "Esqueceu sua senha?"
  - Gerencia botão de alternância para biometria

### 8. `ForgotPasswordLinkWidget`
- **Arquivo**: `forgot_password_link_widget.dart`
- **Responsabilidade**: Link para recuperação de senha
- **Características**:
  - Navegação para tela de recuperação
  - Estilo consistente

## Arquivo de Índice

### `login_widgets.dart`
- **Responsabilidade**: Exporta todos os widgets para facilitar importações
- **Uso**: `import 'login_widgets/login_widgets.dart'`

## Benefícios da Refatoração

1. **Separação de Responsabilidades**: Cada widget tem uma função específica e bem definida
2. **Reutilização**: Widgets podem ser reutilizados em outras partes do app
3. **Manutenibilidade**: Mais fácil para localizar e corrigir problemas
4. **Testabilidade**: Widgets menores são mais fáceis de testar individualmente
5. **Legibilidade**: Código principal muito mais limpo e fácil de entender
6. **Escalabilidade**: Fácil adicionar novos recursos sem impactar outros componentes

## Arquivo Principal

O `login_screen.dart` agora tem apenas:
- Lógica de negócio (autenticação)
- Estrutura principal do layout
- Coordenação entre os widgets
- Reduzido de ~510 linhas para ~101 linhas (80% de redução)

## Estado e Providers

Os widgets utilizam os mesmos providers existentes:
- `authProvider`: Para autenticação
- `loginScreenProvider`: Para estado da tela
- `biometricEnabledProvider`: Para verificar se biometria está ativa
- `showLoginCardProvider`: Para controlar visibilidade do formulário
