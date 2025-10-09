import 'dart:convert';
import 'dart:io';

/// Script para gerar ícones iOS com comportamento similar ao Android adaptive icons
/// Cria ícones com fundo colorido + foreground, igual ao Android
void main() async {
  print('🍎 Gerando ícones iOS com comportamento similar ao Android...\n');

  // Configurações dos flavors
  final flavors = {
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

  // Verifica se ImageMagick está disponível
  final magickCheck = await Process.run('which', ['magick']);
  final hasImageMagick = magickCheck.exitCode == 0;

  if (!hasImageMagick) {
    print('❌ ImageMagick é necessário para esta solução.');
    print('   Execute: brew install imagemagick');
    return;
  }

  final baseIconPath = 'assets/images/icons/icon.png';
  final baseIconFile = File(baseIconPath);

  if (!baseIconFile.existsSync()) {
    print('❌ Ícone base não encontrado: $baseIconPath');
    return;
  }

  print(
      '📋 Estratégia: Criar ícones compostos (fundo colorido + ícone original)');
  print(
      '   Similar ao adaptive_icon_background + adaptive_icon_foreground do Android\n');

  // Para cada flavor, cria um ícone composto
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

    // Cria um ícone composto temporário (fundo colorido + ícone original)
    final tempIconPath = 'temp_adaptive_icon_$flavorName.png';

    // Usa ImageMagick para criar um ícone similar ao adaptive icon do Android
    // 1. Cria um fundo colorido
    // 2. Redimensiona o ícone original para ser menor (como foreground)
    // 3. Centraliza o ícone sobre o fundo colorido
    final magickResult = await Process.run('magick', [
      '-size', '1024x1024',
      'xc:$primaryColor', // Cria fundo colorido
      '(',
      baseIconPath,
      '-resize', '768x768', // Redimensiona o ícone (75% do tamanho total)
      ')',
      '-gravity', 'center',
      '-composite', // Centraliza o ícone sobre o fundo
      tempIconPath
    ]);

    if (magickResult.exitCode != 0) {
      print('   ❌ Erro ao criar ícone composto: ${magickResult.stderr}');
      continue;
    }

    print('   ✅ Ícone composto criado (fundo colorido + ícone)');

    // Cria configuração do flutter_launcher_icons para este flavor
    final iconConfigFile =
        File('flutter_launcher_icons_adaptive_$flavorName.yaml');
    final iconConfig = '''
flutter_launcher_icons:
  android: false
  ios: true
  image_path: "$tempIconPath"
  
  # iOS - Configurações básicas (sem background_color_ios pois já está no ícone)
  remove_alpha_ios: false
  ios_padding: 0  # Sem padding adicional pois já está calculado
  
  # Define o nome do AppIcon específico para o flavor
  ios_app_icon_name: "AppIcon-$flavorName"
''';

    await iconConfigFile.writeAsString(iconConfig);

    // Gera os ícones iOS
    print('   🔄 Gerando ícones iOS...');
    final result = await Process.run('dart', [
      'run',
      'flutter_launcher_icons',
      '-f',
      'flutter_launcher_icons_adaptive_$flavorName.yaml'
    ]);

    if (result.exitCode == 0) {
      print('   ✅ Ícones iOS gerados com sucesso');
    } else {
      print('   ⚠️  Erro ao gerar ícones: ${result.stderr}');
    }

    // Remove arquivos temporários
    final tempFile = File(tempIconPath);
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }

    final configTempFile =
        File('flutter_launcher_icons_adaptive_$flavorName.yaml');
    if (configTempFile.existsSync()) {
      await configTempFile.delete();
    }

    print('   🧹 Arquivos temporários removidos\n');
  }

  print('✨ Processo concluído!');
  print('\n📝 Resumo:');
  print('   • Ícones iOS gerados com comportamento similar ao Android');
  print('   • Fundo colorido + ícone original centralizado');
  print('   • Cada flavor tem sua cor primária visível');
  print('   • Sistema de cópia automática mantido');
  print('\n🔍 Verificação:');
  print('   Os ícones agora devem ter hashes diferentes:');

  // Verifica se os ícones são diferentes
  final iconPaths = [
    'ios/Runner/Assets.xcassets/AppIcon-Main.appiconset/Icon-App-1024x1024@1x.png',
    'ios/Runner/Assets.xcassets/AppIcon-OuroPreto.appiconset/Icon-App-1024x1024@1x.png',
    'ios/Runner/Assets.xcassets/AppIcon-Vicosa.appiconset/Icon-App-1024x1024@1x.png',
  ];

  for (final iconPath in iconPaths) {
    final file = File(iconPath);
    if (file.existsSync()) {
      final result = await Process.run('md5', [iconPath]);
      print('   ${iconPath.split('/').last}: ${result.stdout.trim()}');
    }
  }

  print('\n🧪 Para testar:');
  print('   flutter run --flavor ouroPreto -d ios');
  print('   flutter run --flavor vicosa -d ios');
  print('   flutter run --flavor main -d ios');
}

