import 'dart:convert';
import 'dart:io';

/// Script para criar ícones iOS com cores específicas usando abordagem direta
/// Funciona exatamente como o Android: cria ícones com fundo colorido + ícone original
void main() async {
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
    return;
  }

  final baseIconPath = 'assets/images/icons/icon.png';
  final baseIconFile = File(baseIconPath);

  if (!baseIconFile.existsSync()) {
    return;
  }

  final iosAssetsPath = 'ios/Runner/Assets.xcassets';

  // Tamanhos de ícones iOS
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

  // Para cada flavor, cria os ícones manualmente
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

    // Cria o diretório do AppIcon
    final appIconPath = '$iosAssetsPath/AppIcon-$flavorName.appiconset';
    await Directory(appIconPath).create(recursive: true);

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

      // Calcula o tamanho real baseado na escala
      final sizeParts = size.split('x');
      final width = int.parse(sizeParts[0]);
      final height = int.parse(sizeParts[1]);

      final scale = iconSize['scale'] as String;
      final scaleMultiplier = scale == '@2x' ? 2 : (scale == '@3x' ? 3 : 1);

      final realWidth = width * scaleMultiplier;
      final realHeight = height * scaleMultiplier;

      // Cria ícone com fundo colorido + ícone original centralizado
      final magickResult = await Process.run('magick', [
        '-size', '${realWidth}x$realHeight',
        'xc:$primaryColor', // Fundo colorido
        '(',
        baseIconPath,
        '-resize',
        '${(realWidth * 0.75).round()}x${(realHeight * 0.75).round()}', // 75% do tamanho
        ')',
        '-gravity', 'center',
        '-composite', // Centraliza o ícone
        outputPath
      ]);

      if (magickResult.exitCode != 0) {}
    }
  }

  final iconPaths = [
    'ios/Runner/Assets.xcassets/AppIcon-Main.appiconset/Icon-App-1024x1024@1x.png',
    'ios/Runner/Assets.xcassets/AppIcon-OuroPreto.appiconset/Icon-App-1024x1024@1x.png',
    'ios/Runner/Assets.xcassets/AppIcon-Vicosa.appiconset/Icon-App-1024x1024@1x.png',
  ];

  for (final iconPath in iconPaths) {
    final file = File(iconPath);
    if (file.existsSync()) {
      final result = await Process.run('md5', [iconPath]);
    }
  }
}
