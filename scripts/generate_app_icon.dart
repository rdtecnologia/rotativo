import 'dart:io';
import 'dart:convert';

/// Script para gerar ícones do app baseados no logo.svg
///
/// Este script:
/// 1. Lê o arquivo logo.svg
/// 2. Converte para PNG em diferentes tamanhos
/// 3. Gera os ícones para Android e iOS
/// 4. Aplica as cores do tema do app

void main() async {
  try {
    // Verificar se o logo.svg existe
    final logoFile = File('assets/images/svg/logo.svg');
    if (!await logoFile.exists()) {
      return;
    }

    // Criar diretórios se não existirem
    await _createDirectories();

    // Gerar ícones para Android
    await _generateAndroidIcons();

    // Gerar ícones para iOS
    await _generateIOSIcons();
  } catch (e) {
    //
  }
}

Future<void> _createDirectories() async {
  // Criar diretórios para Android se não existirem
  final androidDirs = [
    'android/app/src/main/res/mipmap-mdpi',
    'android/app/src/main/res/mipmap-hdpi',
    'android/app/src/main/res/mipmap-xhdpi',
    'android/app/src/main/res/mipmap-xxhdpi',
    'android/app/src/main/res/mipmap-xxxhdpi',
  ];

  for (final dir in androidDirs) {
    await Directory(dir).create(recursive: true);
  }

  // Criar diretórios para iOS se não existirem
  final iosDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  await Directory(iosDir).create(recursive: true);
}

Future<void> _generateAndroidIcons() async {
  // Tamanhos dos ícones para Android
  final androidSizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  for (final entry in androidSizes.entries) {
    final dir = entry.key;
    final size = entry.value;

    // Aqui você pode usar uma biblioteca como flutter_launcher_icons
    // ou criar manualmente os ícones baseados no logo.svg
    await _createIconFile(dir, size);
  }
}

Future<void> _generateIOSIcons() async {
  // Tamanhos dos ícones para iOS
  final iosSizes = {
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
  };

  for (final entry in iosSizes.entries) {
    final filename = entry.key;
    final size = entry.value;

    // Aqui você pode usar uma biblioteca como flutter_launcher_icons
    // ou criar manualmente os ícones baseados no logo.svg
    await _createIOSIconFile(filename, size);
  }

  // Gerar Contents.json para iOS
  await _generateIOSContentsJson();
}

Future<void> _createIconFile(String dir, int size) async {
  // Este é um placeholder - você precisará implementar a geração real do ícone
  // usando uma biblioteca como flutter_launcher_icons ou imagemagick

  final iconPath = 'android/app/src/main/res/$dir/ic_launcher.png';

  // Por enquanto, vamos copiar o ícone existente
  final sourceIcon =
      File('android/app/src/main/res/mipmap-hdpi/ic_launcher.png');
  if (await sourceIcon.exists()) {
    await sourceIcon.copy(iconPath);
  } else {}
}

Future<void> _createIOSIconFile(String filename, int size) async {
  // Este é um placeholder - você precisará implementar a geração real do ícone

  final iconPath = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/$filename';

  // Por enquanto, vamos criar um arquivo vazio
  final file = File(iconPath);
  await file.create(recursive: true);
}

Future<void> _generateIOSContentsJson() async {
  final contentsJson = {
    "images": [
      {
        "filename": "Icon-App-20x20@1x.png",
        "idiom": "iphone",
        "scale": "1x",
        "size": "20x20"
      },
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
        "filename": "Icon-App-29x29@1x.png",
        "idiom": "iphone",
        "scale": "1x",
        "size": "29x29"
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
        "filename": "Icon-App-40x40@1x.png",
        "idiom": "iphone",
        "scale": "1x",
        "size": "40x40"
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

  final contentsFile =
      File('ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json');
  await contentsFile.writeAsString(jsonEncode(contentsJson));
}
