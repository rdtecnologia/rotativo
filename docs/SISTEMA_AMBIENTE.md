# Sistema de Ambiente - Rotativo Digital

## 🎯 Visão Geral

O sistema de ambiente permite que o aplicativo funcione com diferentes configurações de API (desenvolvimento, produção, offline) e mostra visualmente em qual ambiente o app está rodando quando em modo debug.

## 🏗️ Arquitetura

### 1. **Environment Provider** (`lib/providers/environment_provider.dart`)
- Gerencia o estado do ambiente de forma reativa usando Riverpod
- Permite mudança de ambiente em tempo real
- Fornece informações sobre o ambiente atual (cor, nome, etc.)

### 2. **Environment Config** (`lib/config/environment.dart`)
- Define as configurações de API para cada ambiente
- Gerencia endpoints para dev, prod e offline
- Configuração estática centralizada

### 3. **Environment Indicator** (`lib/widgets/environment_indicator.dart`)
- Widget visual que mostra o ambiente atual
- Só é exibido em modo debug
- Cores diferentes para cada ambiente:
  - 🟠 **DEV**: Laranja
  - 🟢 **PROD**: Verde  
  - ⚫ **OFFLINE**: Cinza

## 🔧 Configuração

### Ambiente Padrão
O app inicia automaticamente com o ambiente **DEV** configurado em `main.dart`:

```dart
void _initializeApp() {
  Environment.setEnvironment('dev'); // Ambiente padrão
  Environment.printCurrentConfig();
}
```

### Endpoints por Ambiente

| Ambiente | Register | Autentica | Transaciona | Voucher |
|----------|----------|-----------|-------------|---------|
| **DEV** | https://cadastrah.timob.com.br | https://autenticah.timob.com.br | https://transacionah.timob.com.br | https://voucherh.timob.com.br |
| **PROD** | https://cadastra.timob.com.br | https://autentica.timob.com.br | https://transaciona.timob.com.br | https://voucher.timob.com.br |
| **OFFLINE** | http://localhost:8080 | http://localhost:8081 | http://localhost:8082 | http://localhost:8083 |

## 🎨 Interface do Usuário

### Indicador na Tela Home
- **Localização**: Topo direito da tela home (apenas em debug)
- **Visualização**: Badge colorido com nome do ambiente e ícone
- **Atualização**: Automática quando o ambiente é alterado

### Tela de Debug
- **Acesso**: Botão de bug na tela home (apenas em debug)
- **Funcionalidades**:
  - Visualização do ambiente atual
  - Botões para trocar entre ambientes
  - Informações detalhadas de configuração
  - Status das APIs

## 🔄 Mudança de Ambiente

### Via Tela de Debug
1. Acesse a tela de debug (botão de bug)
2. Use os botões DEV/PROD/OFFLINE
3. Confirme a mudança
4. **Reinicie o app** para aplicar as mudanças

### Via Código
```dart
// Usando o provider
final envNotifier = ref.read(environmentProvider.notifier);
envNotifier.setEnvironment('prod');

// Usando a classe Environment diretamente
Environment.setEnvironment('prod');
```

## 🧪 Testes

### Executar Testes
```bash
flutter test test/environment_provider_test.dart
```

### Cobertura de Testes
- ✅ Inicialização do provider
- ✅ Mudança de ambiente
- ✅ Cores dos indicadores
- ✅ Nomes dos ambientes
- ✅ Verificações de ambiente
- ✅ Ambientes disponíveis

## 🚀 Uso em Produção

### Modo Release
- O indicador de ambiente **não é exibido**
- O app funciona normalmente com a configuração definida
- Não há impacto na performance

### Modo Debug
- Indicador de ambiente visível
- Tela de debug acessível
- Logs detalhados de configuração

## 🔍 Monitoramento

### Logs de Configuração
```dart
Environment.printCurrentConfig();
```

### Estado do Provider
```dart
final envState = ref.watch(environmentProvider);
print('Ambiente atual: ${envState.currentEnvironment}');
```

## 📱 Compatibilidade

- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ Desktop

## 🛠️ Manutenção

### Adicionar Novo Ambiente
1. Adicionar configuração em `Environment._apiConfigs`
2. Atualizar cores e nomes no provider
3. Adicionar testes para o novo ambiente
4. Atualizar documentação

### Modificar Endpoints
1. Editar `lib/config/environment.dart`
2. Verificar conectividade
3. Testar funcionalidades
4. Atualizar documentação

## 🎯 Benefícios

1. **Desenvolvimento Seguro**: Separação clara entre ambientes
2. **Debug Visual**: Identificação rápida do ambiente atual
3. **Flexibilidade**: Mudança de ambiente sem recompilação
4. **Manutenibilidade**: Código organizado e testável
5. **UX**: Interface clara para desenvolvedores
