import 'dart:convert';
import 'dart:io';

/// Script de teste para verificar se as cores estão sendo aplicadas corretamente
void main() async {
  print('🧪 Testando cores iOS com cores bem distintas...\n');

  // Cores de teste bem distintas para verificar o funcionamento
  final testFlavors = {
    'OuroPreto': {
      'configPath': 'assets/config/cities/OuroPreto/OuroPreto.json',
      'testColor': '#FF0000', // Vermelho puro para teste
      'originalColor': '#A5732E', // Cor original
    },
    'Vicosa': {
      'configPath': 'assets/config/cities/Vicosa/Vicosa.json',
      'testColor': '#0000FF', // Azul puro para teste
      'originalColor': '#b61817', // Cor original
    },
  };

  final baseIconPath = 'assets/images/icons/icon.png';
  final iosAssetsPath = 'ios/Runner/Assets.xcassets';

  print('🎨 Usando cores de teste bem distintas:');
  print('   OuroPreto: #FF0000 (vermelho puro)');
  print('   Vicosa: #0000FF (azul puro)\n');

  for (final entry in testFlavors.entries) {
    final flavorName = entry.key;
    final config = entry.value;
    final testColor = config['testColor'] as String;
    final originalColor = config['originalColor'] as String;

    print('📱 Processando $flavorName');
    print('   Cor original: $originalColor');
    print('   Cor de teste: $testColor');

    // Cria o diretório do AppIcon
    final appIconPath = '$iosAssetsPath/AppIcon-$flavorName.appiconset';
    await Directory(appIconPath).create(recursive: true);

    // Cria apenas o ícone principal para teste rápido
    final outputPath = '$appIconPath/Icon-App-1024x1024@1x.png';

    // Gera ícone com cor de teste bem visível
    final magickResult = await Process.run('magick', [
      '-size', '1024x1024',
      'xc:$testColor', // Cor de teste bem distinta
      '(',
      baseIconPath,
      '-resize', '768x768', // 75% do tamanho
      ')',
      '-gravity', 'center',
      '-composite',
      outputPath
    ]);

    if (magickResult.exitCode == 0) {
      print('   ✅ Ícone de teste criado');

      // Verifica o hash
      final hashResult = await Process.run('md5', [outputPath]);
      print('   Hash: ${hashResult.stdout.trim()}');
    } else {
      print('   ❌ Erro: ${magickResult.stderr}');
    }
    print('');
  }

  print('🔍 Verificação final:');
  final ouroPretoPath =
      '$iosAssetsPath/AppIcon-OuroPreto.appiconset/Icon-App-1024x1024@1x.png';
  final vicosaPath =
      '$iosAssetsPath/AppIcon-Vicosa.appiconset/Icon-App-1024x1024@1x.png';

  if (File(ouroPretoPath).existsSync() && File(vicosaPath).existsSync()) {
    final compareResult = await Process.run('md5', [ouroPretoPath, vicosaPath]);
    print(compareResult.stdout);

    if (compareResult.stdout.contains('MD5')) {
      final lines = compareResult.stdout.trim().split('\n');
      if (lines.length >= 2) {
        final hash1 = lines[0].split(' = ')[1];
        final hash2 = lines[1].split(' = ')[1];

        if (hash1 == hash2) {
          print('❌ PROBLEMA: Os ícones são idênticos!');
        } else {
          print('✅ SUCESSO: Os ícones são diferentes!');
        }
      }
    }
  }

  print('\n📝 Próximo passo:');
  print(
      '   Se os ícones de teste ficaram diferentes, o problema são as cores originais.');
  print('   Se ficaram iguais, há problema no processo de geração.');

  // Limpa arquivos de teste
  final testFiles = [
    'test_ouro_preto_color.png',
    'test_vicosa_color.png',
    'color_comparison.png'
  ];
  for (final file in testFiles) {
    final f = File(file);
    if (f.existsSync()) {
      await f.delete();
    }
  }
}


