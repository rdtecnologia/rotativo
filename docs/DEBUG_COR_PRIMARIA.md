# Debug - Cor Primária Não Aplicada

## Problema Identificado

A cor primária definida no arquivo `env/ouroPreto.json` não estava sendo aplicada no aplicativo. O sistema estava carregando a cor do arquivo de configuração da cidade, não do arquivo env.

## Causa Raiz

O sistema de configuração dinâmica carrega as cores do arquivo:
- `assets/config/cities/OuroPreto/OuroPreto.json` (arquivo principal de configuração)
- **NÃO** do arquivo `env/ouroPreto.json` (usado apenas para dart-define-from-file)

## Solução Implementada

### 1. **Atualização do Arquivo de Configuração da Cidade**
```json
// assets/config/cities/OuroPreto/OuroPreto.json
{
  "primaryColor": "#000000"  // Alterado de "#074733" para "#000000"
}
```

### 2. **Logs de Debug Adicionados**

#### DynamicAppConfig
```dart
static Future<String> get primaryColor async {
  final config = await _loadConfig();
  final color = config['primaryColor'] ?? '#074733';
  
  if (kDebugMode) {
    print('🎨 DynamicAppConfig.primaryColor - Loaded color: $color');
    print('🎨 DynamicAppConfig.primaryColor - Config keys: ${config.keys.toList()}');
  }
  
  return color;
}
```

#### Main.dart
```dart
Future<Map<String, dynamic>> _loadAppConfig() async {
  try {
    // Clear cache to ensure fresh config loading
    DynamicAppConfig.clearCache();
    
    final title = await DynamicAppConfig.displayName;
    final primaryColor = await DynamicAppConfig.primaryColor;
    
    if (kDebugMode) {
      print('🎨 Main._loadAppConfig - Title: $title');
      print('🎨 Main._loadAppConfig - Primary Color: $primaryColor');
    }
    
    return {
      'title': title,
      'primaryColor': primaryColor,
    };
  } catch (e) {
    // Error handling...
  }
}
```

#### Build Method
```dart
if (kDebugMode) {
  print('🎨 Main.build - Config loaded: $config');
  print('🎨 Main.build - Primary Color Hex: $primaryColorHex');
}

final primaryColor = ColorUtils.hexToColor(primaryColorHex);

if (kDebugMode) {
  print('🎨 Main.build - Primary Color Object: $primaryColor');
  print('🎨 Main.build - Primary Color Value: ${primaryColor.value.toRadixString(16)}');
}
```

### 3. **Cache Clearing**
Adicionada limpeza de cache para garantir carregamento fresco da configuração:
```dart
// Clear cache to ensure fresh config loading
DynamicAppConfig.clearCache();
```

## Como Testar

### 1. **Verificar Logs**
Execute o aplicativo em modo debug e verifique os logs:
```
🎨 DynamicAppConfig.primaryColor - Loaded color: #000000
🎨 Main._loadAppConfig - Primary Color: #000000
🎨 Main.build - Primary Color Hex: #000000
🎨 Main.build - Primary Color Object: Color(0xff000000)
🎨 Main.build - Primary Color Value: ff000000
```

### 2. **Verificar Interface**
- AppBar deve aparecer em preto
- Botões primários devem ser pretos
- Tema geral deve usar preto como cor primária

### 3. **Hot Restart**
Após fazer mudanças nos arquivos de configuração, faça um **Hot Restart** (não Hot Reload) para garantir que as mudanças sejam aplicadas.

## Arquivos Modificados

1. **`/assets/config/cities/OuroPreto/OuroPreto.json`**
   - Alterado `primaryColor` de `#074733` para `#000000`

2. **`/lib/config/dynamic_app_config.dart`**
   - Adicionados logs de debug no método `primaryColor`
   - Melhorado método `clearCache` com logs

3. **`/lib/main.dart`**
   - Adicionada limpeza de cache antes do carregamento
   - Adicionados logs de debug em `_loadAppConfig`
   - Adicionados logs de debug no método `build`

## Fluxo de Carregamento

1. **App Inicia** → `main()` é chamado
2. **RotativoApp.build()** → `_loadAppConfig()` é chamado
3. **Cache Cleared** → `DynamicAppConfig.clearCache()`
4. **Config Loaded** → `DynamicAppConfig._loadConfig()` carrega `OuroPreto.json`
5. **Color Retrieved** → `DynamicAppConfig.primaryColor` retorna `#000000`
6. **Color Converted** → `ColorUtils.hexToColor()` converte para `Color(0xff000000)`
7. **Theme Applied** → `ColorScheme.fromSeed()` aplica a cor no tema

## Troubleshooting

### Se a cor ainda não aparecer:

1. **Verificar Logs**: Confirme se os logs mostram `#000000`
2. **Hot Restart**: Faça um Hot Restart completo
3. **Cache**: O cache é limpo automaticamente agora
4. **Arquivo Correto**: Confirme que alterou o arquivo correto em `assets/config/cities/`

### Para outras cores:
```json
{
  "primaryColor": "#FF0000"  // Vermelho
  "primaryColor": "#00FF00"  // Verde
  "primaryColor": "#0000FF"  // Azul
  "primaryColor": "#FFA500"  // Laranja
}
```

## Nota Importante

- O arquivo `env/ouroPreto.json` é usado apenas para `dart-define-from-file`
- A cor primária real é carregada de `assets/config/cities/OuroPreto/OuroPreto.json`
- Para builds com `dart-define-from-file`, ambos os arquivos devem ter a mesma cor
