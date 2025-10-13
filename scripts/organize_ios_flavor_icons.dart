import 'dart:convert';
import 'dart:io';

void main() async {
  // Configurações dos flavors
  final flavors = {
    'Demo': {
      'configPath': 'assets/config/cities/Main/Main.json',
      'defaultColor': '#5A7B97',
    },
    'OuroPreto': {
      'configPath': 'assets/config/cities/OuroPreto/OuroPreto.json',
    },
    'Vicosa': {
      'configPath': 'assets/config/cities/Vicosa/Vicosa.json',
    },
  };

  final iosAssetsPath = 'ios/Runner/Assets.xcassets';

  // Para cada flavor, criar um AppIcon específico
  for (final entry in flavors.entries) {
    final flavorName = entry.key;
    final config = entry.value;

    // Lê a configuração da cidade
    final configFile = File(config['configPath'] as String);
    if (!configFile.existsSync()) {
      continue;
    }

    final configContent = await configFile.readAsString();
    final cityConfig = jsonDecode(configContent) as Map<String, dynamic>;

    // Obtém a cor primária
    final primaryColor = cityConfig['primaryColor'] as String? ??
        config['defaultColor'] as String? ??
        '#5A7B97';

    // Cria o diretório do AppIcon para o flavor
    final appIconPath = '$iosAssetsPath/AppIcon-$flavorName.appiconset';
    await Directory(appIconPath).create(recursive: true);

    // Copia todos os ícones do AppIcon padrão para o novo
    final defaultIconsPath = '$iosAssetsPath/AppIcon.appiconset';
    final defaultIconsDir = Directory(defaultIconsPath);

    if (defaultIconsDir.existsSync()) {
      await for (final file in defaultIconsDir.list()) {
        if (file is File && file.path.endsWith('.png')) {
          final fileName = file.path.split('/').last;
          final destFile = File('$appIconPath/$fileName');
          await file.copy(destFile.path);
        }
      }

      // Copia também o Contents.json
      final contentsFile = File('$defaultIconsPath/Contents.json');
      if (contentsFile.existsSync()) {
        final destContentsFile = File('$appIconPath/Contents.json');
        await contentsFile.copy(destContentsFile.path);
      }
    }
  }
}
