import 'dart:convert';
import 'dart:io';

void main() async {
  print('🎨 Organizando ícones por flavor...\n');

  // Configurações dos flavors
  final flavors = {
    'demo': {
      'configPath': 'assets/config/cities/Main/Main.json',
      'defaultColor': '#5A7B97',
    },
    'ouroPreto': {
      'configPath': 'assets/config/cities/OuroPreto/OuroPreto.json',
    },
    'vicosa': {
      'configPath': 'assets/config/cities/Vicosa/Vicosa.json',
    },
  };

  final androidSrcPath = 'android/app/src';

  // Para cada flavor, criar estrutura e copiar ícones
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

    print('   Cor: $primaryColor');

    // Cria a estrutura de diretórios para o flavor
    final flavorResPath = '$androidSrcPath/$flavorName/res';

    // Cria diretórios necessários
    final directories = [
      '$flavorResPath/mipmap-hdpi',
      '$flavorResPath/mipmap-mdpi',
      '$flavorResPath/mipmap-xhdpi',
      '$flavorResPath/mipmap-xxhdpi',
      '$flavorResPath/mipmap-xxxhdpi',
      '$flavorResPath/mipmap-anydpi-v26',
      '$flavorResPath/drawable-hdpi',
      '$flavorResPath/drawable-mdpi',
      '$flavorResPath/drawable-xhdpi',
      '$flavorResPath/drawable-xxhdpi',
      '$flavorResPath/drawable-xxxhdpi',
      '$flavorResPath/values',
    ];

    for (final dir in directories) {
      await Directory(dir).create(recursive: true);
    }

    // Copia os ícones do main para o flavor
    final densities = ['hdpi', 'mdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

    // Copia mipmap icons
    for (final density in densities) {
      final sourceIcon =
          File('$androidSrcPath/main/res/mipmap-$density/ic_launcher.png');
      final destIcon = File('$flavorResPath/mipmap-$density/ic_launcher.png');

      if (sourceIcon.existsSync()) {
        await sourceIcon.copy(destIcon.path);
      }

      final sourceLauncherIcon =
          File('$androidSrcPath/main/res/mipmap-$density/launcher_icon.png');
      final destLauncherIcon =
          File('$flavorResPath/mipmap-$density/launcher_icon.png');

      if (sourceLauncherIcon.existsSync()) {
        await sourceLauncherIcon.copy(destLauncherIcon.path);
      }
    }

    // Copia foreground icons
    for (final density in densities) {
      final sourceForeground = File(
          '$androidSrcPath/main/res/drawable-$density/ic_launcher_foreground.png');
      final destForeground =
          File('$flavorResPath/drawable-$density/ic_launcher_foreground.png');

      if (sourceForeground.existsSync()) {
        await sourceForeground.copy(destForeground.path);
      }
    }

    // Cria o arquivo ic_launcher.xml para adaptive icons
    final icLauncherXml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
''';

    final icLauncherFile =
        File('$flavorResPath/mipmap-anydpi-v26/ic_launcher.xml');
    await icLauncherFile.writeAsString(icLauncherXml);

    // Cria o arquivo colors.xml com a cor específica do flavor
    final colorsXml = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">$primaryColor</color>
</resources>
''';

    final colorsFile = File('$flavorResPath/values/colors.xml');
    await colorsFile.writeAsString(colorsXml);
  }
}
