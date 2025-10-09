# Solução: Ícones iOS com Cores por Flavor

## Problema
No Android, o aplicativo já tinha ícones dinâmicos que mudavam de cor baseado na cidade/flavor usando `adaptive_icon_background` + `adaptive_icon_foreground`. No iOS, isso não funcionava da mesma forma - os ícones permaneciam idênticos independente do flavor.

## Solução Implementada

### Como Funciona no Android
```yaml
# Android - Funciona perfeitamente
adaptive_icon_background: "#A5732E"  # Cor de fundo
adaptive_icon_foreground: "assets/images/icons/icon.png"  # Ícone transparente
```

### Problema no iOS
```yaml
# iOS - NÃO funcionava como esperado
background_color_ios: "#A5732E"  # Apenas cor de fundo, não visível
```

O `background_color_ios` do `flutter_launcher_icons` não produz o mesmo efeito visual que o `adaptive_icon_background` do Android.

### Solução Final
Criamos um script que gera ícones iOS manualmente com o mesmo comportamento do Android:

1. **Fundo colorido**: Usa a cor primária da cidade
2. **Ícone centralizado**: Coloca o ícone original (75% do tamanho) sobre o fundo colorido
3. **Todos os tamanhos**: Gera todos os tamanhos necessários para iOS

## Scripts Criados

### 1. `create_ios_flavored_icons_direct.dart`
Script principal que cria os ícones iOS com cores específicas:

```bash
dart scripts/create_ios_flavored_icons_direct.dart
```

**O que faz:**
- Lê as configurações de cada cidade (`primaryColor`)
- Cria ícones compostos usando ImageMagick
- Gera todos os tamanhos iOS necessários
- Cria `AppIcon-[Flavor].appiconset` para cada cidade

### 2. `setup_ios_flavored_icons.dart`
Script master que executa todo o processo:

```bash
dart scripts/setup_ios_flavored_icons.dart
```

## Cores Configuradas

| Flavor | Cor | Descrição |
|--------|-----|-----------|
| Main | `#5A7B97` | Azul padrão |
| OuroPreto | `#A5732E` | Dourado |
| Vicosa | `#b61817` | Vermelho |

## Como Testar

```bash
# Teste cada flavor
flutter run --flavor main -d ios
flutter run --flavor ouroPreto -d ios  
flutter run --flavor vicosa -d ios
```

## Verificação
Os ícones agora têm hashes diferentes, confirmando que cada flavor tem sua cor específica:

```bash
md5 ios/Runner/Assets.xcassets/AppIcon-*.appiconset/Icon-App-1024x1024@1x.png
```

## Sistema de Cópia Automática
O sistema existente de cópia automática (`copy_appicon.sh`) continua funcionando:
- Durante o build, o script copia o `AppIcon-[Flavor]` correto para `AppIcon`
- Isso garante que o ícone correto seja usado para cada flavor

## Dependências
- **ImageMagick**: Necessário para criar os ícones compostos
  ```bash
  brew install imagemagick
  ```

## Resultado Final
✅ **iOS agora tem o mesmo comportamento do Android**
- Ícones com fundo colorido baseado na cor primária da cidade
- Cada flavor mostra sua cor específica no ícone
- Sistema automático de troca de ícones mantido
- Compatível com todos os tamanhos iOS

## Comparação: Antes vs Depois

### Antes
- Todos os ícones iOS idênticos
- Apenas o `background_color_ios` (não visível)
- Comportamento diferente do Android

### Depois  
- Cada flavor tem ícone com sua cor específica
- Fundo colorido + ícone original centralizado
- Comportamento idêntico ao Android
- Troca automática baseada no flavor

