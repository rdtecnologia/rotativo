import 'dart:convert';
import 'dart:io';

/// Script para gerar ícones iOS com cores específicas por flavor
/// Similar ao sistema Android, mas adaptado para iOS
/// Usa ImageMagick para criar ícones compostos (fundo colorido + logo)
void main() async {
  // Configurações dos flavors (apenas os que têm schemes iOS correspondentes)
  final flavors = {
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

  final baseIconPath = 'assets/images/icons/icon_ios.png';
  final baseIconFile = File(baseIconPath);

  if (!baseIconFile.existsSync()) {
    return;
  }

  // Para cada flavor, cria um ícone composto e depois gera os ícones iOS
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
        config['defaultColor'] ??
        '#5A7B97';

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
      continue;
    }

    // Cria o diretório do AppIcon específico para o flavor
    final iosAssetsPath = 'ios/Runner/Assets.xcassets';
    final appIconPath = '$iosAssetsPath/AppIcon-$flavorName.appiconset';
    await Directory(appIconPath).create(recursive: true);

    // Cria o Contents.json para o AppIcon set
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
          "filename": "Icon-App-20x20@1x.png",
          "idiom": "ipad",
          "scale": "1x",
          "size": "20x20"
        },
        {
          "filename": "Icon-App-20x20@2x.png",
          "idiom": "ipad",
          "scale": "2x",
          "size": "20x20"
        },
        {
          "filename": "Icon-App-29x29@1x.png",
          "idiom": "ipad",
          "scale": "1x",
          "size": "29x29"
        },
        {
          "filename": "Icon-App-29x29@2x.png",
          "idiom": "ipad",
          "scale": "2x",
          "size": "29x29"
        },
        {
          "filename": "Icon-App-40x40@1x.png",
          "idiom": "ipad",
          "scale": "1x",
          "size": "40x40"
        },
        {
          "filename": "Icon-App-40x40@2x.png",
          "idiom": "ipad",
          "scale": "2x",
          "size": "40x40"
        },
        {
          "filename": "Icon-App-76x76@1x.png",
          "idiom": "ipad",
          "scale": "1x",
          "size": "76x76"
        },
        {
          "filename": "Icon-App-76x76@2x.png",
          "idiom": "ipad",
          "scale": "2x",
          "size": "76x76"
        },
        {
          "filename": "Icon-App-83.5x83.5@2x.png",
          "idiom": "ipad",
          "scale": "2x",
          "size": "83.5x83.5"
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

    // Tamanhos de ícones iOS necessários
    final iconSizes = [
      {
        'size': '1024x1024',
        'scale': '@1x',
        'filename': 'Icon-App-1024x1024@1x.png'
      },
      // iPhone icons
      {'size': '60x60', 'scale': '@2x', 'filename': 'Icon-App-60x60@2x.png'},
      {'size': '60x60', 'scale': '@3x', 'filename': 'Icon-App-60x60@3x.png'},
      {'size': '40x40', 'scale': '@2x', 'filename': 'Icon-App-40x40@2x.png'},
      {'size': '40x40', 'scale': '@3x', 'filename': 'Icon-App-40x40@3x.png'},
      {'size': '29x29', 'scale': '@2x', 'filename': 'Icon-App-29x29@2x.png'},
      {'size': '29x29', 'scale': '@3x', 'filename': 'Icon-App-29x29@3x.png'},
      {'size': '20x20', 'scale': '@2x', 'filename': 'Icon-App-20x20@2x.png'},
      {'size': '20x20', 'scale': '@3x', 'filename': 'Icon-App-20x20@3x.png'},
      // iPad icons
      {'size': '20x20', 'scale': '@1x', 'filename': 'Icon-App-20x20@1x.png'},
      {'size': '29x29', 'scale': '@1x', 'filename': 'Icon-App-29x29@1x.png'},
      {'size': '40x40', 'scale': '@1x', 'filename': 'Icon-App-40x40@1x.png'},
      {'size': '76x76', 'scale': '@1x', 'filename': 'Icon-App-76x76@1x.png'},
      {'size': '76x76', 'scale': '@2x', 'filename': 'Icon-App-76x76@2x.png'},
      {
        'size': '83.5x83.5',
        'scale': '@2x',
        'filename': 'Icon-App-83.5x83.5@2x.png'
      },
    ];

    // Gera cada tamanho de ícone usando ImageMagick
    for (final iconSize in iconSizes) {
      final size = iconSize['size'] as String;
      final filename = iconSize['filename'] as String;
      final outputPath = '$appIconPath/$filename';

      // Calcula o tamanho real baseado na escala
      final sizeParts = size.split('x');
      final width = double.parse(sizeParts[0]);
      final height = double.parse(sizeParts[1]);

      final scale = iconSize['scale'] as String;
      final scaleMultiplier = scale == '@2x' ? 2 : (scale == '@3x' ? 3 : 1);

      final realWidth = (width * scaleMultiplier).round();
      final realHeight = (height * scaleMultiplier).round();

      // Redimensiona o ícone composto para o tamanho necessário
      final resizeResult = await Process.run('magick',
          [tempIconPath, '-resize', '${realWidth}x$realHeight', outputPath]);

      if (resizeResult.exitCode != 0) {}
    }

    // Remove arquivos temporários
    final tempFile = File(tempIconPath);
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
  }

  // Verifica se os ícones são diferentes
  final iconPaths = [
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
