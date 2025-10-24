# Implementação: Lembrar meu CPF

## Data
24 de outubro de 2025

## Resumo
Implementação de funcionalidade "Lembrar meu CPF" na tela de login que permite ao usuário salvar seu CPF para preenchimento automático em próximos logins.

## Arquivos Criados

### 1. Provider: `lib/providers/remember_cpf_provider.dart`
- **Estado**: `RememberCpfState` com propriedades:
  - `rememberCpf`: bool - indica se o checkbox está marcado
  - `savedCpf`: String? - CPF salvo (se houver)

- **Notifier**: `RememberCpfNotifier` com métodos:
  - `initialize()`: Carrega preferências salvas do secure storage
  - `toggleRememberCpf(bool value)`: Alterna o estado do checkbox
  - `saveCpf(String cpf)`: Salva o CPF no secure storage
  - `clearCpf()`: Limpa o CPF salvo (disponível para uso futuro)

## Arquivos Modificados

### 1. Service: `lib/services/auth_service.dart`
Adicionados os seguintes métodos para gerenciar a funcionalidade:

- **Constantes adicionadas**:
  - `_rememberCpfKey`: chave para armazenar preferência
  - `_savedCpfKey`: chave para armazenar CPF

- **Métodos adicionados**:
  - `setRememberCpfPreference(bool remember)`: Salva preferência no secure storage
  - `getRememberCpfPreference()`: Obtém preferência salva
  - `saveCpf(String cpf)`: Salva CPF no secure storage
  - `getSavedCpf()`: Obtém CPF salvo
  - `clearSavedCpf()`: Limpa CPF salvo

### 2. Widget: `lib/screens/auth/login_widgets/login_form_widget.dart`
- Convertido de `ConsumerWidget` para `ConsumerStatefulWidget` para gerenciar estado local
- Adicionado método `initState()` que inicializa o provider de "Lembrar CPF"
- Adicionado método `_initializeRememberCpf()` que:
  - Carrega as preferências salvas
  - Preenche o campo CPF automaticamente se o checkbox estiver marcado
- Adicionado checkbox "Lembrar meu CPF" abaixo do campo CPF com:
  - Checkbox interativo
  - Label clicável que também alterna o checkbox
  - Integração com o provider

### 3. Screen: `lib/screens/auth/login_screen.dart`
- Importado `remember_cpf_provider`
- Modificado método `_handleLogin()` para salvar o CPF após login bem-sucedido:
  - Verifica se o checkbox está marcado
  - Salva o CPF no secure storage se estiver marcado
  - O CPF é salvo apenas após login bem-sucedido

## Funcionalidades Implementadas

### 1. Checkbox "Lembrar meu CPF"
- Posicionado logo abaixo do campo CPF
- Estado persistido no secure storage
- Label clicável para melhor usabilidade

### 2. Salvamento do CPF
- CPF é salvo no secure storage quando:
  - Usuário faz login com sucesso
  - Checkbox "Lembrar meu CPF" está marcado
- CPF não é removido do storage quando usuário desmarca o checkbox

### 3. Preenchimento Automático
- Ao abrir a tela de login:
  - Verifica se checkbox estava marcado
  - Se sim, carrega o CPF salvo
  - Preenche automaticamente o campo CPF

### 4. Comportamento ao Desmarcar
- Quando usuário desmarca o checkbox:
  - A preferência é atualizada
  - O CPF NÃO é removido do storage
  - Na próxima abertura, o campo CPF não será preenchido
  - Se usuário marcar novamente, o CPF salvo anteriormente será usado

## Segurança
- Todos os dados são armazenados usando `FlutterSecureStorage`
- CPF é armazenado de forma criptografada
- Preferências são armazenadas separadamente do CPF para maior controle

## Fluxo de Uso

1. **Primeiro Login**:
   - Usuário digita CPF e senha
   - Marca checkbox "Lembrar meu CPF"
   - Faz login
   - CPF é salvo no secure storage

2. **Próximo Login**:
   - Tela de login é aberta
   - Campo CPF é preenchido automaticamente
   - Checkbox aparece marcado
   - Usuário só precisa digitar a senha

3. **Desmarcando o Checkbox**:
   - Usuário desmarca "Lembrar meu CPF"
   - Preferência é atualizada
   - CPF permanece salvo (mas não será mostrado)
   - Na próxima abertura, campo CPF estará vazio

4. **Marcando Novamente**:
   - Usuário marca "Lembrar meu CPF"
   - No próximo login, CPF salvo anteriormente será usado

## Integração com Biometria
A funcionalidade coexiste com a autenticação biométrica existente:
- CPF salvo pode ser usado tanto para login tradicional quanto biométrico
- Não há conflito entre as funcionalidades
- São sistemas independentes que podem ser usados em conjunto

## Testing
Para testar a funcionalidade:
1. Execute o app
2. Na tela de login, marque "Lembrar meu CPF"
3. Faça login normalmente
4. Feche e abra o app novamente
5. Verifique se o CPF foi preenchido automaticamente
6. Desmarque o checkbox
7. Feche e abra o app
8. Verifique se o campo CPF está vazio
