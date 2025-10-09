import 'dart:convert';
import 'dart:io';

/// Script para melhorar as cores iOS com maior contraste visual
void main() async {
  print('🎨 Melhorando cores iOS para maior contraste visual...\n');

  // Cores originais e versões melhoradas
  final flavorColors = {
    'Main': {
      'configPath': 'assets/config/cities/Main/Main.json',
      'originalColor': '#5A7B97',
      'enhancedColor': '#4A6B87', // Azul mais escuro
    },
    'OuroPreto': {
      'configPath': 'assets/config/cities/OuroPreto/OuroPreto.json',
      'originalColor': '#A5732E',
      'enhancedColor': '#D4941E', // Dourado mais vibrante e claro
    },
    'Vicosa': {
      'configPath': 'assets/config/cities/Vicosa/Vicosa.json',
      'originalColor': '#b61817',
      'enhancedColor': '#C41E3A', // Vermelho mais vibrante
    },
  };

  final baseIconPath = 'assets/images/icons/icon.png';
  final iosAssetsPath = 'ios/Runner/Assets.xcassets';

  print('🎯 Cores melhoradas para maior contraste:');
  for (final entry in flavorColors.entries) {
    final flavorName = entry.key;
    final config = entry.value;
    print(
        '   $flavorName: ${config['originalColor']} → ${config['enhancedColor']}');
  }
  print('');

  // Tamanhos de ícones iOS principais
  final iconSizes = [
    {
      'size': '1024x1024',
      'scale': '@1x',
      'filename': 'Icon-App-1024x1024@1x.png'
    },
    {'size': '60x60', 'scale': '@2x', 'filename': 'Icon-App-60x60@2x.png'},
    {'size': '60x60', 'scale': '@3x', 'filename': 'Icon-App-60x60@3x.png'},
    {'size': '40x40', 'scale': '@2x', 'filename': 'Icon-App-40x40@2x.png'},
    {'size': '40x40', 'scale': '@3x', 'filename': 'Icon-App-40x40@3x.png'},
    {'size': '29x29', 'scale': '@2x', 'filename': 'Icon-App-29x29@2x.png'},
    {'size': '29x29', 'scale': '@3x', 'filename': 'Icon-App-29x29@3x.png'},
    {'size': '20x20', 'scale': '@2x', 'filename': 'Icon-App-20x20@2x.png'},
    {'size': '20x20', 'scale': '@3x', 'filename': 'Icon-App-20x20@3x.png'},
  ];

  for (final entry in flavorColors.entries) {
    final flavorName = entry.key;
    final config = entry.value;
    final enhancedColor = config['enhancedColor'] as String;

    print('📱 Processando $flavorName com cor melhorada: $enhancedColor');

    // Remove o AppIcon existente
    final appIconPath = '$iosAssetsPath/AppIcon-$flavorName.appiconset';
    final appIconDir = Directory(appIconPath);
    if (appIconDir.existsSync()) {
      await appIconDir.delete(recursive: true);
    }
    await appIconDir.create(recursive: true);

    // Cria o Contents.json
    final contentsJson = {
      "images": [
        {
          "filename": "Icon-App-20x20@2x.png",
          "idiom": "iphone",
          "scale": "2x",
          "size": "20x20"
        },
        {
          "filename": "Icon-App-20x20@3x.png",
          "idiom": "iphone",
          "scale": "3x",
          "size": "20x20"
        },
        {
          "filename": "Icon-App-29x29@2x.png",
          "idiom": "iphone",
          "scale": "2x",
          "size": "29x29"
        },
        {
          "filename": "Icon-App-29x29@3x.png",
          "idiom": "iphone",
          "scale": "3x",
          "size": "29x29"
        },
        {
          "filename": "Icon-App-40x40@2x.png",
          "idiom": "iphone",
          "scale": "2x",
          "size": "40x40"
        },
        {
          "filename": "Icon-App-40x40@3x.png",
          "idiom": "iphone",
          "scale": "3x",
          "size": "40x40"
        },
        {
          "filename": "Icon-App-60x60@2x.png",
          "idiom": "iphone",
          "scale": "2x",
          "size": "60x60"
        },
        {
          "filename": "Icon-App-60x60@3x.png",
          "idiom": "iphone",
          "scale": "3x",
          "size": "60x60"
        },
        {
          "filename": "Icon-App-1024x1024@1x.png",
          "idiom": "ios-marketing",
          "scale": "1x",
          "size": "1024x1024"
        }
      ],
      "info": {"author": "xcode", "version": 1}
    };

    final contentsFile = File('$appIconPath/Contents.json');
    await contentsFile.writeAsString(jsonEncode(contentsJson));

    // Gera cada tamanho de ícone
    for (final iconSize in iconSizes) {
      final size = iconSize['size'] as String;
      final filename = iconSize['filename'] as String;
      final outputPath = '$appIconPath/$filename';

      final sizeParts = size.split('x');
      final width = int.parse(sizeParts[0]);
      final height = int.parse(sizeParts[1]);

      final scale = iconSize['scale'] as String;
      final scaleMultiplier = scale == '@2x' ? 2 : (scale == '@3x' ? 3 : 1);

      final realWidth = width * scaleMultiplier;
      final realHeight = height * scaleMultiplier;

      // Cria ícone com fundo colorido melhorado
      final magickResult = await Process.run('magick', [
        '-size', '${realWidth}x$realHeight',
        'xc:$enhancedColor', // Cor melhorada
        '(',
        baseIconPath,
        '-resize',
        '${(realWidth * 0.75).round()}x${(realHeight * 0.75).round()}',
        ')',
        '-gravity', 'center',
        '-composite',
        outputPath
      ]);

      if (magickResult.exitCode != 0) {
        print('   ❌ Erro ao criar $filename: ${magickResult.stderr}');
      }
    }

    print('   ✅ AppIcon-$flavorName.appiconset criado com cor melhorada\n');
  }

  print('✨ Processo concluído!');
  print('\n🔍 Verificação das cores melhoradas:');

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

  print('\n📱 Agora as cores devem ser mais distintas visualmente!');
  print('   • Main: Azul mais escuro');
  print('   • OuroPreto: Dourado mais vibrante e claro');
  print('   • Vicosa: Vermelho mais vibrante');

  print('\n🧪 Para testar:');
  print('   flutter run --flavor main -d ios');
  print('   flutter run --flavor ouroPreto -d ios');
  print('   flutter run --flavor vicosa -d ios');
}


