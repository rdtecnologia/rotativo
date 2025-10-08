# 🎨 Scripts de Geração de Ícones por Flavor

## 🚀 Uso Rápido

Execute o script master para configurar tudo automaticamente:

```bash
dart scripts/setup_flavor_icons.dart
```

Este script executará todos os passos necessários para configurar os ícones com cores específicas para cada flavor.

## 📋 Scripts Individuais

Se preferir executar manualmente ou precisar atualizar apenas uma parte:

### 1. Android

```bash
# Gera configurações e ícones
dart scripts/generate_flavored_icons.dart
dart run flutter_launcher_icons -f flutter_launcher_icons_Main.yaml

# Organiza por flavor
dart scripts/organize_flavor_icons.dart
```

### 2. iOS

```bash
# Cria AppIcons
dart scripts/organize_ios_flavor_icons.dart
dart scripts/generate_all_flavor_appicons.dart

# Configura Xcode
python3 scripts/update_ios_appicons.py
python3 scripts/add_appicon_preactions.py
```

## 📖 Documentação Completa

Para mais detalhes, veja: `docs/FLAVOR_ICONS_SETUP.md`

## 🎯 Arquivos Importantes

- `icon_tr.png`: Imagem base com fundo transparente
- Configurações de cidades: `assets/config/cities/[Cidade]/[Cidade].json`
- Cor de fundo definida em: `primaryColor` no JSON

## ⚡ Adicionar Novo Flavor

1. Crie o arquivo JSON em `assets/config/cities/[NomeCidade]/[NomeCidade].json`
2. Defina a `primaryColor` no JSON
3. Execute: `dart scripts/setup_flavor_icons.dart`
4. Teste!

## 🐛 Resolução de Problemas

### Ícone não atualiza no device

```bash
flutter clean
flutter run --flavor [nome_flavor]
```

### iOS: Ícone errado

```bash
cd ios && pod deintegrate && pod install
flutter clean
```

### Android: Cor de fundo incorreta

Verifique: `android/app/src/[flavor]/res/values/colors.xml`

## 📞 Suporte

Para dúvidas ou problemas, consulte a documentação completa em `docs/FLAVOR_ICONS_SETUP.md`.

