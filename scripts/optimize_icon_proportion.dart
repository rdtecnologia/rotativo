import 'dart:io';

/// Script para otimizar a proporção dos ícones
/// Ajusta as configurações para manter a mesma proporção visual dos outros apps
void main() async {
  print('🎯 Otimizando proporção dos ícones...\n');

  final flavors = ['Main', 'OuroPreto', 'Vicosa'];

  for (final flavor in flavors) {
    print('📱 Otimizando $flavor...');

    final configFile = File('flutter_launcher_icons_$flavor.yaml');
    if (!configFile.existsSync()) {
      print('   ⚠️  Arquivo de configuração não encontrado');
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

    print('   ✅ Configurações otimizadas');

    // Gera os ícones otimizados
    print('   🔄 Regenerando ícones...');
    final result = await Process.run('dart', [
      'run',
      'flutter_launcher_icons',
      '-f',
      'flutter_launcher_icons_$flavor.yaml'
    ]);

    if (result.exitCode == 0) {
      print('   ✅ Ícones regenerados com sucesso\n');
    } else {
      print('   ⚠️  Erro ao regenerar ícones: ${result.stderr}\n');
    }
  }

  // Organiza novamente os ícones Android
  print('🔄 Organizando ícones Android...');
  final organizeResult =
      await Process.run('dart', ['scripts/organize_flavor_icons.dart']);

  if (organizeResult.exitCode == 0) {
    print('✅ Organização concluída!\n');
  } else {
    print('⚠️  Erro na organização: ${organizeResult.stderr}\n');
  }

  print('🎉 Otimização de proporção concluída!');
  print('\n📝 Dicas para melhor proporção:');
  print('   • Certifique-se de que a imagem icon_tr.png tenha padding interno');
  print('   • A imagem deve ter elementos centrais que não serão cortados');
  print('   • Teste em devices reais para verificar o resultado');
  print('\n🧪 Para testar:');
  print('   flutter run --flavor demo -d android');
  print('   flutter run --flavor ouroPreto -d android');
}
