import 'dart:io';

/// Script para otimizar a proporção dos ícones
/// Ajusta as configurações para manter a mesma proporção visual dos outros apps
void main() async {
  final flavors = ['Main', 'OuroPreto', 'Vicosa'];

  for (final flavor in flavors) {
    final configFile = File('flutter_launcher_icons_$flavor.yaml');
    if (!configFile.existsSync()) {
      continue;
    }

    // Lê o arquivo atual
    var content = await configFile.readAsString();

    // Ajusta configurações para melhor proporção
    content = content.replaceAll('adaptive_icon_foreground_padding: 20',
        'adaptive_icon_foreground_padding: 15');

    content = content.replaceAll('ios_padding: 20', 'ios_padding: 15');

    // Adiciona configuração de min_sdk se não existir
    if (!content.contains('min_sdk_android:')) {
      content = content.replaceFirst(
          'android: true', 'android: true\n  min_sdk_android: 21');
    }

    // Salva o arquivo otimizado
    await configFile.writeAsString(content);

    // Gera os ícones otimizados
    final result = await Process.run('dart', [
      'run',
      'flutter_launcher_icons',
      '-f',
      'flutter_launcher_icons_$flavor.yaml'
    ]);

    if (result.exitCode == 0) {
    } else {}
  }

  // Organiza novamente os ícones Android
  final organizeResult =
      await Process.run('dart', ['scripts/organize_flavor_icons.dart']);

  if (organizeResult.exitCode == 0) {
  } else {}
}
