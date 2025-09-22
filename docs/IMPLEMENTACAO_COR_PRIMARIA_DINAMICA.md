# Implementação de Cor Primária Dinâmica

## Objetivo

Implementar um sistema que permite definir a cor primária do aplicativo dinamicamente através de arquivos de configuração, usando o parâmetro `dart-define-from-file` para builds específicos por cidade.

## Arquivos Modificados

### 1. `/env/ouroPreto.json`
```json
{
  "CITY_NAME": "Ouro Preto",
  "FLAVOR": "ouroPreto",
  "primaryColor": "#074733"
}
```

### 2. `/assets/config/cities/OuroPreto/OuroPreto.json`
```json
{
  "$schema": "../schema.json",
  "city": "Ouro Preto",
  "domain": "Ouro Preto",
  "latitude": -20.3875396,
  "longitude": -43.5097469,
  "primaryColor": "#074733",
  // ... resto da configuração
}
```

### 3. `/lib/config/dynamic_app_config.dart`
Adicionado método para obter a cor primária:
```dart
/// Get primary color from config
static Future<String> get primaryColor async {
  final config = await _loadConfig();
  return config['primaryColor'] ?? '#074733'; // Default fallback color
}
```

### 4. `/lib/utils/color_utils.dart` (Novo arquivo)
Utilitário para conversão de cores:
```dart
class ColorUtils {
  /// Convert hex color string to Color object
  static Color hexToColor(String hexString) {
    String hex = hexString.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    int colorValue = int.parse(hex, radix: 16);
    return Color(colorValue);
  }
  
  /// Convert Color to hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
  
  /// Create a ColorScheme from a primary color
  static ColorScheme createColorScheme(Color primaryColor) {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );
  }
}
```

### 5. `/lib/main.dart`
Modificado para usar cor primária dinâmica:
```dart
class RotativoApp extends ConsumerWidget {
  /// Load app configuration including title and primary color
  Future<Map<String, dynamic>> _loadAppConfig() async {
    try {
      final title = await DynamicAppConfig.displayName;
      final primaryColor = await DynamicAppConfig.primaryColor;
      
      return {
        'title': title,
        'primaryColor': primaryColor,
      };
    } catch (e) {
      // Return fallback values
      return {
        'title': 'Rotativo Digital',
        'primaryColor': '#074733',
      };
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadAppConfig(),
      builder: (context, snapshot) {
        final config = snapshot.data ?? {'title': 'Rotativo Digital', 'primaryColor': '#074733'};
        final title = config['title'] as String;
        final primaryColorHex = config['primaryColor'] as String;
        
        // Convert hex color to Color object
        final primaryColor = ColorUtils.hexToColor(primaryColorHex);
        
        return MaterialApp(
          title: title,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          // ... resto da configuração
        );
      },
    );
  }
}
```

## Como Funciona

### 1. **Configuração por Cidade**
- Cada cidade tem seu arquivo de configuração em `/assets/config/cities/[CityName]/[CityName].json`
- O parâmetro `primaryColor` define a cor primária da cidade
- Formato: string hexadecimal (ex: `#074733`)

### 2. **Carregamento Dinâmico**
- O `DynamicAppConfig` carrega a configuração baseada no flavor atual
- O método `primaryColor` retorna a cor definida no arquivo de configuração
- Fallback para `#074733` se não encontrar a cor

### 3. **Aplicação no Tema**
- O `main.dart` carrega a configuração assincronamente
- Converte a string hex em objeto `Color` usando `ColorUtils.hexToColor()`
- Aplica a cor no `ColorScheme.fromSeed()` do Material 3

### 4. **Build com dart-define-from-file**
Para usar com `dart-define-from-file`, configure o arquivo `env/ouroPreto.json`:
```json
{
  "CITY_NAME": "Ouro Preto",
  "FLAVOR": "ouroPreto",
  "primaryColor": "#074733"
}
```

E use no build:
```bash
flutter build apk --dart-define-from-file=env/ouroPreto.json
```

## Benefícios

1. **Flexibilidade**: Cada cidade pode ter sua cor primária única
2. **Manutenibilidade**: Cores centralizadas nos arquivos de configuração
3. **Consistência**: Usa o sistema Material 3 com `ColorScheme.fromSeed()`
4. **Fallback**: Sistema robusto com valores padrão em caso de erro
5. **Performance**: Carregamento assíncrono sem bloquear a UI

## Cores Suportadas

- **Formato**: Hexadecimal com ou sem `#`
- **Exemplos**: `#074733`, `074733`, `#FF0000`, `FF0000`
- **Alpha**: Suporta cores com transparência (8 dígitos)
- **Fallback**: `#074733` (verde escuro padrão)

## Teste

Para testar a implementação:

1. Modifique o valor de `primaryColor` no arquivo de configuração da cidade
2. Rebuild o aplicativo
3. Verifique se a cor primária foi aplicada corretamente
4. Teste com diferentes cores para validar o sistema

## Extensibilidade

O sistema pode ser facilmente estendido para:
- Cores secundárias
- Temas escuros
- Gradientes
- Cores personalizadas por seção do app
