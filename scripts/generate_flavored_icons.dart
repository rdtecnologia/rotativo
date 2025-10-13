import 'dart:convert';
import 'dart:io';

void main() async {
  // Mapeia os flavors e suas configurações
  final flavors = {
    'Main': {
      'configPath': 'assets/config/cities/Main/Main.json',
      'defaultColor': '#5A7B97', // Cor padrão caso não esteja definida
    },
    'OuroPreto': {
      'configPath': 'assets/config/cities/OuroPreto/OuroPreto.json',
    },
    'Vicosa': {
      'configPath': 'assets/config/cities/Vicosa/Vicosa.json',
    },
  };

  // Para cada flavor, cria um arquivo de configuração do flutter_launcher_icons
  for (final entry in flavors.entries) {
    final flavorName = entry.key;
    final config = entry.value;

    // Lê o arquivo de configuração da cidade
    final configFile = File(config['configPath'] as String);
    if (!configFile.existsSync()) {
      continue;
    }

    final configContent = await configFile.readAsString();
    final cityConfig = jsonDecode(configContent) as Map<String, dynamic>;

    // Obtém a cor primária ou usa a cor padrão
    final primaryColor = cityConfig['primaryColor'] as String? ??
        config['defaultColor'] as String? ??
        '#5A7B97';

    // Cria o arquivo de configuração para o flutter_launcher_icons
    final iconConfigFile = File('flutter_launcher_icons_$flavorName.yaml');
    final iconConfig = '''
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/icons/icon.png"
  min_sdk_android: 21
  
  # Android - Ícone adaptativo com cor de fundo
  adaptive_icon_background: "$primaryColor"
  adaptive_icon_foreground: "assets/images/icons/icon.png"
  
  # Android - Padding para manter proporção
  adaptive_icon_foreground_padding: 20
  
  # iOS
  remove_alpha_ios: false
  background_color_ios: "$primaryColor"
  
  # iOS - Configurações para manter proporção
  ios_padding: 20
  
  # Web
  web:
    generate: true
    image_path: "assets/images/icons/icon.png"
    background_color: "$primaryColor"
    theme_color: "$primaryColor"
  
  # Windows
  windows:
    generate: true
    image_path: "assets/images/icons/icon.png"
    icon_size: 48
''';

    await iconConfigFile.writeAsString(iconConfig);
  }
}
