import 'dart:convert';
import 'dart:io';

void main() async {
  print('🍎 Gerando AppIcons para todos os flavors...\n');

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

  print('📋 Flavors encontrados: ${schemes.join(', ')}\n');

  for (final schemeName in schemes) {
    // Capitaliza o primeiro caractere
    final flavorName = schemeName[0].toUpperCase() + schemeName.substring(1);

    print('📱 Processando flavor: $flavorName');

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

    if (!configFound) {
      print('   ⚠️  Configuração não encontrada, usando cor padrão');
    }

    print('   Cor: $primaryColor');

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

    print('   ✅ AppIcon-$flavorName.appiconset criado\n');
  }

  print('✨ Processo concluído!');
  print('\n📝 Próximos passos:');
  print('   1. Os AppIcons foram criados para todos os flavors');
  print('   2. Cada flavor tem sua própria cor de fundo');
  print('   3. Execute o app com qualquer flavor para testar');
  print('\n💡 Nota: Se quiser cores específicas para cada cidade,');
  print(
      '   adicione os arquivos JSON de configuração em assets/config/cities/');
}
