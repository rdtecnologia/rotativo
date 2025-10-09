import 'dart:convert';
import 'dart:io';

/// Script para gerar ícones iOS com cores aplicadas diretamente no ícone
/// Similar ao comportamento do Android onde a cor primária é visível no ícone
void main() async {
  print('🎨 Gerando ícones iOS com cores aplicadas diretamente...\n');

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
    print('⚠️  ImageMagick não encontrado. Tentando instalar...');
    print('   Execute: brew install imagemagick');
    print('   Ou continue sem modificação de cores (apenas background)');
  }

  final baseIconPath = 'assets/images/icons/icon.png';
  final baseIconFile = File(baseIconPath);

  if (!baseIconFile.existsSync()) {
    print('❌ Ícone base não encontrado: $baseIconPath');
    return;
  }

  // Para cada flavor, gera ícones com cores específicas
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

    // Cria um ícone temporário com a cor aplicada
    final tempIconPath = 'temp_icon_$flavorName.png';

    if (hasImageMagick) {
      // Usa ImageMagick para aplicar a cor no ícone
      // Cria um ícone com fundo colorido e o ícone original sobreposto
      final magickResult = await Process.run('magick', [
        baseIconPath,
        '(',
        '-clone',
        '0',
        '-fill',
        primaryColor,
        '-colorize',
        '100%',
        ')',
        '(',
        '-clone',
        '0',
        '-alpha',
        'extract',
        ')',
        '-compose',
        'over',
        '-composite',
        tempIconPath
      ]);

      if (magickResult.exitCode != 0) {
        print(
            '   ⚠️  Erro ao aplicar cor com ImageMagick: ${magickResult.stderr}');
        // Fallback: copia o ícone original
        await baseIconFile.copy(tempIconPath);
      } else {
        print('   ✅ Cor aplicada ao ícone');
      }
    } else {
      // Fallback: usa o ícone original
      await baseIconFile.copy(tempIconPath);
      print('   ⚠️  Usando ícone original (sem modificação de cor)');
    }

    // Cria configuração do flutter_launcher_icons para este flavor
    final iconConfigFile =
        File('flutter_launcher_icons_colored_$flavorName.yaml');
    final iconConfig = '''
flutter_launcher_icons:
  android: false
  ios: true
  image_path: "$tempIconPath"
  
  # iOS - Configurações específicas
  remove_alpha_ios: false
  ios_padding: 15
  
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
      'flutter_launcher_icons_colored_$flavorName.yaml'
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
        File('flutter_launcher_icons_colored_$flavorName.yaml');
    if (configTempFile.existsSync()) {
      await configTempFile.delete();
    }

    print('   🧹 Arquivos temporários removidos\n');
  }

  print('✨ Processo concluído!');
  print('\n📝 Resumo:');
  if (hasImageMagick) {
    print('   • Ícones iOS gerados com cores aplicadas diretamente');
    print('   • Cada flavor tem sua cor primária visível no ícone');
  } else {
    print('   • Ícones iOS gerados (instale ImageMagick para aplicar cores)');
    print('   • Para instalar: brew install imagemagick');
  }
  print('   • Sistema de cópia automática mantido');
  print('\n🧪 Para testar:');
  print('   flutter run --flavor ouroPreto -d ios');
  print('   flutter run --flavor vicosa -d ios');
  print('   flutter run --flavor main -d ios');
}

