import 'dart:convert';
import 'dart:io';

void main() async {
  // Lista todos os schemes iOS
  final schemesDir = Directory('ios/Runner.xcodeproj/xcshareddata/xcschemes');
  final schemes = await schemesDir
      .list()
      .where((entity) =>
          entity.path.endsWith('.xcscheme') &&
          !entity.path.endsWith('Runner.xcscheme'))
      .map((entity) => entity.path.split('/').last.replaceAll('.xcscheme', ''))
      .toList();

  // Mapeia configurações disponíveis
  final configs = {
    'Main': {
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

  for (final schemeName in schemes) {
    // Capitaliza o primeiro caractere
    final flavorName = schemeName[0].toUpperCase() + schemeName.substring(1);

    // Tenta encontrar uma configuração correspondente
    String primaryColor = '#5A7B97'; // Cor padrão

    // Verifica variações do nome
    final possibleConfigNames = [
      flavorName,
      flavorName.toLowerCase(),
      schemeName,
    ];

    bool configFound = false;
    for (final configName in possibleConfigNames) {
      if (configs.containsKey(configName)) {
        final config = configs[configName]!;
        final configFile = File(config['configPath'] as String);

        if (configFile.existsSync()) {
          final configContent = await configFile.readAsString();
          final cityConfig = jsonDecode(configContent) as Map<String, dynamic>;
          primaryColor = cityConfig['primaryColor'] as String? ??
              config['defaultColor'] as String? ??
              primaryColor;
          configFound = true;
          break;
        }
      }
    }

    if (!configFound) {}

    // Cria o diretório do AppIcon
    final appIconPath = '$iosAssetsPath/AppIcon-$flavorName.appiconset';
    await Directory(appIconPath).create(recursive: true);

    // Copia os ícones do AppIcon padrão se existirem
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

      // Copia o Contents.json
      final contentsFile = File('$defaultIconsPath/Contents.json');
      if (contentsFile.existsSync()) {
        final destContentsFile = File('$appIconPath/Contents.json');
        await contentsFile.copy(destContentsFile.path);
      }
    }
  }
}
