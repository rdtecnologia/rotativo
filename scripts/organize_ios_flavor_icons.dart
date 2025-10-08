import 'dart:convert';
import 'dart:io';

void main() async {
  print('🍎 Configurando ícones iOS por flavor...\n');

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

    print('📱 Processando flavor: $flavorName');

    // Lê a configuração da cidade
    final configFile = File(config['configPath'] as String);
    if (!configFile.existsSync()) {
      print('   ⚠️  Arquivo de configuração não encontrado');
      continue;
    }

    final configContent = await configFile.readAsString();
    final cityConfig = jsonDecode(configContent) as Map<String, dynamic>;

    // Obtém a cor primária
    final primaryColor = cityConfig['primaryColor'] as String? ??
        config['defaultColor'] as String? ??
        '#5A7B97';

    print('   Cor: $primaryColor');

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

    print('   ✅ AppIcon-$flavorName.appiconset criado\n');
  }

  print('✨ Processo iOS concluído!');
  print('\n📝 Próximos passos:');
  print('   1. Abra o Xcode: open ios/Runner.xcworkspace');
  print('   2. Para cada configuração (Demo, OuroPreto, Vicosa):');
  print('      • Selecione o target Runner');
  print('      • Vá em Build Settings');
  print('      • Busque por "Asset Catalog App Icon Set Name"');
  print('      • Configure para usar AppIcon-[Flavor] para cada configuração');
  print(
      '\nOu execute o script de automação do Xcode que será criado a seguir...');
}
