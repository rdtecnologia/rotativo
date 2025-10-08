# Configuração de Ícones por Flavor

## 📱 Visão Geral

Este documento descreve como o sistema de ícones dinâmicos por flavor foi implementado no projeto Rotativo.

## 🎨 Características

- **Ícones com cores personalizadas**: Cada flavor tem seu próprio ícone com cor de fundo específica
- **Imagem transparente**: Usa `icon_tr.png` com fundo transparente para permitir cores de fundo
- **Android**: Ícones adaptativos com cores por flavor
- **iOS**: AppIcons específicos por scheme/flavor
- **Automação completa**: Scripts automatizam todo o processo

## 📂 Estrutura de Arquivos

### Android
```
android/app/src/
├── main/res/
│   ├── mipmap-*/        # Ícones padrão
│   ├── drawable-*/      # Foreground icons
│   └── values/colors.xml
├── ouroPreto/res/
│   ├── mipmap-*/        # Ícones OuroPreto
│   ├── drawable-*/
│   └── values/colors.xml  # Cor: #b61817
└── vicosa/res/
    └── ... (similar)
```

### iOS
```
ios/Runner/Assets.xcassets/
├── AppIcon.appiconset/           # Padrão
├── AppIcon-OuroPreto.appiconset/ # Cor: #b61817
├── AppIcon-Vicosa.appiconset/
├── AppIcon-Demo.appiconset/      # Cor: #5A7B97
└── ... (outros flavors)
```

## 🔧 Scripts Disponíveis

### 1. Geração Inicial dos Ícones

```bash
# Gera arquivos de configuração do flutter_launcher_icons
dart scripts/generate_flavored_icons.dart

# Gera os ícones usando flutter_launcher_icons
dart run flutter_launcher_icons -f flutter_launcher_icons_Main.yaml
dart run flutter_launcher_icons -f flutter_launcher_icons_OuroPreto.yaml
dart run flutter_launcher_icons -f flutter_launcher_icons_Vicosa.yaml
```

### 2. Organização Android

```bash
# Organiza ícones por flavor no Android
dart scripts/organize_flavor_icons.dart
```

### 3. Configuração iOS

```bash
# Cria AppIcons para todos os flavors iOS
dart scripts/organize_ios_flavor_icons.dart
dart scripts/generate_all_flavor_appicons.dart

# Atualiza project.pbxproj para configurações existentes
python3 scripts/update_ios_appicons.py

# Adiciona PreActions aos schemes
python3 scripts/add_appicon_preactions.py
```

### 4. Script Master (Recomendado)

```bash
# Executa todo o processo de uma vez
dart scripts/setup_flavor_icons.dart
```

## 🎯 Como Funciona

### Android

1. **Ícones Adaptativos**: Usa XML com referência a cor de fundo
2. **Estrutura por Flavor**: Cada flavor tem sua pasta `res/` com:
   - `values/colors.xml`: Define a cor de fundo
   - `mipmap-*/`: Ícones em várias densidades
   - `drawable-*/`: Foreground icons
3. **Build**: Android automaticamente usa os recursos do flavor correto

### iOS

1. **AppIcon Sets**: Cada flavor tem seu próprio `.appiconset`
2. **PreActions**: Schemes têm scripts que copiam o AppIcon correto antes do build
3. **Script `copy_appicon.sh`**: Copia AppIcon-[Flavor] para AppIcon padrão
4. **Build Configurations**: Para OuroPreto, usa configurações específicas no Xcode

## 🆕 Adicionar Novo Flavor

### 1. Criar Configuração da Cidade

```json
// assets/config/cities/NovaCidade/NovaCidade.json
{
  "$schema": "../schema.json",
  "city": "Nova Cidade",
  "primaryColor": "#FF0000",  // Sua cor aqui
  ...
}
```

### 2. Android

```bash
# O script organize_flavor_icons.dart criará automaticamente
# a estrutura necessária se você adicionar a configuração
dart scripts/organize_flavor_icons.dart
```

### 3. iOS

```bash
# Cria o AppIcon para o novo flavor
dart scripts/generate_all_flavor_appicons.dart

# Se tiver um novo scheme, adiciona PreAction
python3 scripts/add_appicon_preactions.py
```

## 🎨 Cores Configuradas

| Flavor | Cor de Fundo | Código |
|--------|--------------|--------|
| Demo/Main | Azul | #5A7B97 |
| OuroPreto | Vermelho | #b61817 |
| Vicosa | Vermelho | #b61817 |
| Outros | Azul (padrão) | #5A7B97 |

## 🧪 Testar

```bash
# Android
flutter run --flavor demo -d android
flutter run --flavor ouroPreto -d android
flutter run --flavor vicosa -d android

# iOS
flutter run --flavor main -d ios
flutter run --flavor ouroPreto -d ios
```

## 🔄 Atualizar Ícone Base

Se você precisar atualizar a imagem `icon_tr.png`:

1. Substitua o arquivo: `assets/images/icon_tr.png`
2. Execute o script master:
   ```bash
   dart scripts/setup_flavor_icons.dart
   ```

## ⚠️ Problemas Conhecidos

### iOS não mostra o ícone correto

**Solução**: Limpe o cache do iOS
```bash
flutter clean
cd ios && pod deintegrate && pod install
```

### Android não atualiza o ícone

**Solução**: Desinstale e reinstale o app
```bash
flutter clean
flutter run --flavor [flavor_name]
```

## 📝 Manutenção

- Os scripts estão em `scripts/`
- Documentação adicional em `docs/`
- Ícones base em `assets/images/`
- Configurações em `assets/config/cities/`

## 🤝 Contribuindo

Ao adicionar novos flavors:
1. Crie a configuração JSON da cidade
2. Execute os scripts de geração
3. Teste em ambas as plataformas
4. Documente mudanças neste arquivo

