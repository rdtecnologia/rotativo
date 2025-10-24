# 📱 Guia Completo: Arquivos dSYM para Firebase Crashlytics

## 🔍 O que são arquivos dSYM?

**dSYM** (Debug Symbol) são arquivos que contêm informações de debug do seu app iOS. Eles são essenciais para:

- ✅ **Simbolizar crashes** - Converter endereços de memória em nomes de funções legíveis
- ✅ **Stack traces detalhados** - Mostrar exatamente onde o erro ocorreu
- ✅ **Debugging eficiente** - Identificar problemas rapidamente

## 📍 Onde Encontrar os Arquivos dSYM

### 1. **Após Build Flutter (Automático)**
```bash
# Após flutter build ios
ios/build/ios/iphoneos/Runner.app.dSYM
```

### 2. **Via Xcode (Recomendado)**
1. Abra: `ios/Runner.xcworkspace`
2. **Product** → **Archive**
3. **Window** → **Organizer**
4. Selecione seu app → **Download dSYMs**

### 3. **Via Script Automatizado**
```bash
# Gerar e preparar dSYM automaticamente
./scripts/upload_dsym.sh ouroPreto
./scripts/upload_dsym.sh vicosa
```

## 🚀 Como Gerar e Fazer Upload

### **Método 1: Script Automatizado (Recomendado)**

```bash
# Para Ouro Preto
./scripts/upload_dsym.sh ouroPreto

# Para Viçosa  
./scripts/upload_dsym.sh vicosa

# Para Demo
./scripts/upload_dsym.sh demo
```

O script irá:
- ✅ Fazer build do iOS
- ✅ Encontrar o arquivo dSYM
- ✅ Criar arquivo ZIP
- ✅ Dar instruções de upload

### **Método 2: Manual via Xcode**

1. **Abrir Projeto**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Fazer Archive**
   - Selecione o scheme correto (ouroPreto/vicosa)
   - **Product** → **Archive**

3. **Download dSYMs**
   - **Window** → **Organizer**
   - Selecione seu app
   - Clique em **"Download dSYMs"**

4. **Localizar Arquivo**
   - Os dSYMs ficam em: `~/Library/Developer/Xcode/Archives/`
   - Procure pela pasta com data do build

### **Método 3: Via Terminal**

```bash
# Build do iOS
flutter build ios --release --flavor ouroPreto

# Procurar dSYM
find ios/build -name "*.dSYM" -type d

# Criar ZIP
cd ios/build/ios/iphoneos/
zip -r Runner_dSYM.zip Runner.app.dSYM
```

## 📤 Como Fazer Upload no Firebase

### **Passo 1: Acessar Firebase Console**
1. Vá para: https://console.firebase.google.com/
2. Selecione o projeto correto:
   - **Ouro Preto**: `rotativo-ouro-preto`
   - **Viçosa**: `rotativo-vicosa`

### **Passo 2: Ir para Crashlytics**
1. No menu lateral: **Crashlytics**
2. Clique em **"dSYM files"** (ou "Arquivos dSYM")

### **Passo 3: Upload do Arquivo**
1. Clique em **"Fazer upload de arquivos dSYM"**
2. **Arraste e solte** o arquivo `.zip` ou clique em **"Procurar"**
3. Aguarde o processamento

### **Passo 4: Verificar Upload**
- O arquivo deve aparecer na lista
- Status deve ser **"Processado"** ✅

## 🔧 Configuração Automática (Opcional)

### **Firebase CLI Setup**
```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Configurar projeto
firebase use rotativo-ouro-preto
```

### **Upload Automático**
```bash
# Upload direto via CLI
firebase appdistribution:upload-dsym --app com.rotativodigitalouropretord Runner_dSYM.zip
```

## 📋 Checklist de Verificação

### **Antes do Upload**
- [ ] Build feito com `--release`
- [ ] Flavor correto selecionado
- [ ] Arquivo dSYM encontrado
- [ ] Arquivo ZIP criado

### **Após Upload**
- [ ] Arquivo aparece no Firebase Console
- [ ] Status: "Processado"
- [ ] Teste um crash para verificar simbolização

## 🧪 Testando a Simbolização

### **1. Gerar Crash de Teste**
```dart
// Na Debug Page, clique em "Test Error"
await FirebaseCrashlyticsHelper.logError(
  Exception('Teste de simbolização'),
  StackTrace.current,
);
```

### **2. Verificar no Firebase Console**
1. Vá em **Crashlytics** → **Issues**
2. Clique no crash de teste
3. Verifique se o stack trace mostra:
   - ✅ Nomes de funções (não endereços)
   - ✅ Nomes de arquivos `.dart`
   - ✅ Números de linha

### **3. Comparação**

**Sem dSYM:**
```
0x0000000101234567 0x0000000101234567 + 1234567
```

**Com dSYM:**
```
main.dart:45:12  MyWidget.build
```

## ⚠️ Problemas Comuns

### **"dSYM não encontrado"**
```bash
# Verificar se o build foi feito
ls -la ios/build/ios/iphoneos/

# Fazer build novamente
flutter clean
flutter build ios --release --flavor ouroPreto
```

### **"Upload falhou"**
- Verificar se o arquivo é `.zip` ou `.gz`
- Verificar tamanho (deve ser < 100MB)
- Verificar conexão com internet

### **"Simbolização não funciona"**
- Verificar se o dSYM é da mesma versão do crash
- Verificar se o upload foi processado
- Aguardar alguns minutos para processamento

## 📊 Estrutura de Arquivos

```
ios/
├── build/
│   └── ios/
│       └── iphoneos/
│           ├── Runner.app
│           └── Runner.app.dSYM/          # ← Arquivo dSYM
│               ├── Contents/
│               │   └── Info.plist
│               └── Resources/
│                   └── DWARF/
│                       └── Runner        # ← Binário com símbolos
└── Runner.xcworkspace
```

## 🎯 Resumo Rápido

1. **Gerar dSYM**: `./scripts/upload_dsym.sh ouroPreto`
2. **Acessar Firebase**: Console → Projeto → Crashlytics → dSYM files
3. **Upload**: Arrastar arquivo ZIP
4. **Testar**: Gerar crash e verificar simbolização

## 📚 Links Úteis

- [Firebase Crashlytics dSYM](https://firebase.google.com/docs/crashlytics/get-started?platform=ios#upload-dsyms)
- [Xcode dSYM Guide](https://developer.apple.com/documentation/xcode/adding-identifiable-symbol-names-to-a-crash-report)
- [Flutter iOS Build](https://docs.flutter.dev/deployment/ios)

---

**💡 Dica**: Faça upload do dSYM sempre que fizer um novo build para produção!







