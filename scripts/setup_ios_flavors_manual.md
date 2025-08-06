# 🍎 Configuração Manual de iOS Flavors

## ❌ Problema
```bash
flutter run --flavor patosDeMinas -d "iPhone 16 Pro"
# Erro: Flutter expects a build configuration named Debug-patosDeMinas
```

## ✅ Solução Manual (5 minutos)

### 1. Abrir o Projeto no Xcode
```bash
open ios/Runner.xcworkspace
```

### 2. Adicionar Configurações de Build

1. **Selecionar o Projeto**:
   - Clique em "Runner" na lateral esquerda (projeto, não target)
   - Vá na aba "Info"

2. **Duplicar Configurações**:
   Para cada flavor que você quer usar, crie:
   
   **Para patosDeMinas:**
   - Clique no "+" em "Configurations"
   - "Duplicate Debug Configuration" → nomeie "Debug-patosDeMinas"
   - "Duplicate Release Configuration" → nomeie "Release-patosDeMinas"
   - "Duplicate Profile Configuration" → nomeie "Profile-patosDeMinas"

3. **Repetir para outros flavors** (opcional):
   - Debug-janauba, Release-janauba, Profile-janauba
   - Debug-demo, Release-demo, Profile-demo
   - etc.

### 3. Testar
```bash
flutter run --flavor patosDeMinas -d "iPhone 16 Pro"
```

## 🚀 Solução Alternativa (RECOMENDADA)

**Use a abordagem simples que já funciona:**

```bash
# 1. Configurar cidade
dart scripts/build_city.dart patos "Rotativo Patos"

# 2. Executar SEM flavor
flutter run -d "iPhone 16 Pro"
```

## ⚡ Resultado

- ✅ **Android**: `flutter run --flavor patosDeMinas` - Funcionando 100%
- ✅ **iOS Simples**: `flutter run -d "iPhone"` - Funcionando 100%  
- 🔧 **iOS Flavor**: Requer configuração manual no Xcode

## 🎯 Conclusão

Para desenvolvimento rápido, use:
- **Android**: `--flavor` (funcionando)
- **iOS**: Sem `--flavor` (funcionando)

Para produção profissional com flavors iOS completos, configure uma vez no Xcode seguindo os passos acima.