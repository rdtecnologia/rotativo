# Como testar a autenticação

## Para executar o app com uma cidade específica:

### 📱 **Mobile (recomendado - sem CORS):**
```bash
# Exemplo: Ouro Preto - Android
flutter run --dart-define=CITY_NAME="Ouro Preto" --dart-define=FLAVOR=ouroPreto -d emulator-5554

# Exemplo: Ouro Preto - iOS  
flutter run --dart-define=CITY_NAME="Ouro Preto" --dart-define=FLAVOR=ouroPreto -d "iPhone 16 Pro"

# Exemplo: Patos de Minas  
flutter run --dart-define=CITY_NAME="Patos de Minas" --dart-define=FLAVOR=patosDeMinas -d emulator-5554

# Exemplo: Demo/Main
flutter run --dart-define=CITY_NAME="Demonstração" --dart-define=FLAVOR=demo -d emulator-5554
```

### 🌐 **Web (com limitações de CORS):**
```bash
# Web - terá problemas de CORS com APIs externas
flutter run --dart-define=CITY_NAME="Ouro Preto" --dart-define=FLAVOR=ouroPreto -d chrome

# Para resolver CORS na web:
# 1. Use emulador mobile (recomendado)
# 2. Chrome com CORS desabilitado:
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --disable-web-security --user-data-dir="/tmp/chrome_dev"
```

## Fluxo de autenticação implementado:

### 🔐 **Novo Fluxo Tradicional:**

1. **Tela de Login**: 
   - Campo CPF e Senha sempre visíveis
   - Botão "Entrar" para fazer login direto
   - Link "Não tem conta? Cadastre-se" → vai para registro

2. **Tela de Registro**: 
   - Formulário completo: CPF, Nome, Email, Telefone, Senha
   - Checkbox para aceitar termos de uso
   - Link "Já tem conta? Faça login" → volta para login

3. **Tela de Recuperação de Senha**: 
   - Digite o CPF para receber instruções por email
   - Acessível pelo link "Esqueceu sua senha?" na tela de login

4. **Armazenamento Seguro**: 
   - Token e dados do usuário salvos com Flutter Secure Storage
   - Login automático na próxima abertura do app

### 🎯 **Experiência do Usuário:**
- **Login direto**: CPF + Senha → Entrar
- **Novo usuário**: "Cadastre-se" → Preenche dados → Entra automaticamente
- **Esqueceu senha**: Link na tela de login → Recuperação por email

## APIs utilizadas (mesmo do app React):

- **Produção**: https://autentica.timob.com.br, https://cadastra.timob.com.br
- **Desenvolvimento**: https://autenticah.timob.com.br, https://cadastrah.timob.com.br

## Configuração por cidade:

- Cada cidade tem suas configurações em `assets/config/cities/[CidadeName]/`
- O header `Domain` é enviado nas requisições baseado na cidade compilada
- As URLs das APIs são as mesmas, mas o domínio diferencia os dados

## Debug:

- Use a tela de Debug (ícone bug) para ver:
  - Configurações da cidade
  - Estado da autenticação
  - Dados do usuário logado
  - Token (primeiros 20 caracteres)

## Logging de API:

- **Console de Debug**: Todas as requisições e respostas são logadas no console quando em modo debug
- **Informações mostradas**:
  - Headers da requisição (incluindo Domain, Authorization)
  - Body da requisição (dados enviados)
  - Status code da resposta
  - Body da resposta (dados recebidos)
  - Tempo de resposta
  - Erros de rede/timeout

- **Como visualizar**:
  ```bash
  flutter run --dart-define=CITY_NAME="Ouro Preto" --dart-define=FLAVOR=ouroPreto
  # Logs aparecerão no console durante uso das APIs
  ```

- **Exemplo de log**:
  ```
  ┌─────────────────────────────────────────────────────────────
  │ POST /driver/check/12345678901
  │ https://cadastra.timob.com.br/driver/check/12345678901
  │ Headers: {Domain: Ouro Preto, Authorization: Jwt eyJ...}
  │ ⚡ 234ms
  │ Status: 200 OK
  │ Response: {"action": "login", "message": "CPF encontrado"}
  └─────────────────────────────────────────────────────────────
  ```