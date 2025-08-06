# 🚀 Guia VS Code: Flutter Flavors por Cidade

## 📋 **Configurações Criadas**

### ✅ **Arquivos VS Code:**
- `.vscode/launch.json` - Configurações de debug/run
- `.vscode/tasks.json` - Tasks para build e configuração
- `VSCODE_FLAVORS_GUIDE.md` - Este guia

## 🎯 **Como Usar**

### **1. 🏗️ Executar Apps por Cidade (Android)**

**No VS Code:**
1. Pressione `F5` ou `Ctrl+Shift+D` (Debug)
2. Selecione uma configuração:
   - `🐎 Patos de Minas - Android Debug`
   - `🌾 Janaúba - Android Debug`  
   - `💰 Ouro Preto - Android Debug`
   - etc.
3. Clique em "Start Debugging" ▶️

**Disponíveis:**
- ✅ **11 cidades** em modo Debug
- ✅ **11 cidades** em modo Release  
- ✅ **Configuração custom** com seleção de device/flavor

### **2. 🍎 Executar Apps iOS (Configuração Simples)**

**Passo 1:** Configure a cidade
- Pressione `Ctrl+Shift+P` → "Tasks: Run Task"
- Selecione: `🐎 Configurar Patos de Minas` (ou outra cidade)

**Passo 2:** Execute o app
- Use: `🍎 iOS Debug - Configuração Simples`
- Ou terminal: `flutter run -d "iPhone Simulator"`

### **3. 📦 Build de Produção**

**Via Tasks:**
- `Ctrl+Shift+P` → "Tasks: Run Task"
- Selecione:
  - `📱 Build Android APK (com flavor)`
  - `📦 Build Android Bundle (com flavor)`  
  - `🍎 Build iOS (configuração simples)`

## 🎨 **Configurações Disponíveis**

### 🚀 **Debug Configurations:**

| Emoji | Cidade | Flavor Android | Comando |
|-------|--------|----------------|---------|
| 🏛️ | Demo | `demo` | F5 → Demo - Android Debug |
| 🐎 | Patos de Minas | `patosDeMinas` | F5 → Patos de Minas - Android Debug |
| 🌾 | Janaúba | `janauba` | F5 → Janaúba - Android Debug |
| ⛪ | Conselheiro Lafaiete | `conselheiroLafaiete` | F5 → Conselheiro Lafaiete - Android Debug |
| 🌺 | Capão Bonito | `capaoBonito` | F5 → Capão Bonito - Android Debug |
| 🏭 | João Monlevade | `joaoMonlevade` | F5 → João Monlevade - Android Debug |
| 🌄 | Itararé | `itarare` | F5 → Itararé - Android Debug |
| 🎭 | Passos | `passos` | F5 → Passos - Android Debug |
| 🌊 | Ribeirão das Neves | `ribeiraoDasNeves` | F5 → Ribeirão das Neves - Android Debug |
| 🌸 | Igarapé | `igarape` | F5 → Igarapé - Android Debug |
| 💰 | Ouro Preto | `ouroPreto` | F5 → Ouro Preto - Android Debug |

### 🛠️ **Tasks Disponíveis:**

| Categoria | Task | Descrição |
|-----------|------|-----------|
| **🏗️ Config** | `🐎 Configurar Patos de Minas` | Configura app para Patos de Minas |
| **🏗️ Config** | `💰 Configurar Ouro Preto` | Configura app para Ouro Preto |
| **📦 Build** | `📱 Build Android APK` | Build APK com flavor selecionado |
| **📦 Build** | `📦 Build Android Bundle` | Build Bundle para Play Store |
| **📦 Build** | `🍎 Build iOS` | Build iOS (configuração simples) |
| **🧹 Utils** | `🧹 Flutter Clean` | Limpa projeto Flutter |
| **🧹 Utils** | `📥 Flutter Pub Get` | Baixa dependências |
| **🔧 Debug** | `🔍 Listar Devices` | Lista devices conectados |
| **🔧 Debug** | `⚕️ Flutter Doctor` | Verifica instalação Flutter |

## 🎯 **Fluxo de Trabalho Recomendado**

### **Para Android:**
```
1. F5 → Selecionar cidade → ▶️ Start Debugging
2. App roda direto com flavor correto ✅
```

### **Para iOS:**
```
1. Ctrl+Shift+P → Tasks → 🐎 Configurar Patos de Minas
2. F5 → 🍎 iOS Debug - Configuração Simples → ▶️ Start Debugging
3. App roda com configuração da cidade ✅
```

### **Para Build de Produção:**
```
1. Ctrl+Shift+P → Tasks → 📱 Build Android APK
2. Selecionar flavor → Enter
3. APK gerado em build/app/outputs/ ✅
```

## 🚨 **Troubleshooting**

### **❌ Erro: "Task assemblePatosDebug is ambiguous"**
**Solução:** Use o nome completo do flavor: `patosDeMinas` em vez de `patos`

### **❌ Erro iOS: "Flutter expects build configuration named Debug-patosDeMinas"**
**Solução:** Use a configuração simples iOS ou configure Xcode manualmente

### **❌ Erro: "FAQ type cast"**
**Solução:** Execute task de configuração da cidade primeiro

## 🎉 **Resultado Final**

✅ **11 cidades configuradas**  
✅ **22 configurações Android** (Debug + Release)  
✅ **2 configurações iOS** (Debug + Release)  
✅ **11 tasks de configuração de cidade**  
✅ **7 tasks de build e utils**  

**Total: 42+ configurações prontas para uso! 🚀**

---

### 📝 **Exemplo Prático:**

1. **Quero testar Patos de Minas no Android:**
   - `F5` → `🐎 Patos de Minas - Android Debug` → ▶️

2. **Quero testar Ouro Preto no iOS:**
   - `Ctrl+Shift+P` → "Tasks" → `💰 Configurar Ouro Preto`
   - `F5` → `🍎 iOS Debug - Configuração Simples` → ▶️

3. **Quero fazer build de produção:**
   - `Ctrl+Shift+P` → "Tasks" → `📱 Build Android APK`
   - Selecionar flavor → Enter → APK pronto! 📦