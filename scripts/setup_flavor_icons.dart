import 'dart:io';

/// Script master para configurar todos os ícones por flavor
/// Executa todos os scripts necessários na ordem correta
void main() async {
  print('🚀 Iniciando configuração completa de ícones por flavor...\n');
  print('=' * 60);

  final steps = <String, Future<ProcessResult> Function()>{
    '1. Gerando configurações do flutter_launcher_icons': () =>
        _runDart('scripts/generate_flavored_icons.dart'),
    '2. Gerando ícones com flutter_launcher_icons (Main)': () => _runCommand(
            'dart', [
          'run',
          'flutter_launcher_icons',
          '-f',
          'flutter_launcher_icons_Main.yaml'
        ]),
    '3. Gerando ícones com flutter_launcher_icons (OuroPreto)': () =>
        _runCommand('dart', [
          'run',
          'flutter_launcher_icons',
          '-f',
          'flutter_launcher_icons_OuroPreto.yaml'
        ]),
    '4. Gerando ícones com flutter_launcher_icons (Vicosa)': () => _runCommand(
            'dart', [
          'run',
          'flutter_launcher_icons',
          '-f',
          'flutter_launcher_icons_Vicosa.yaml'
        ]),
    '5. Organizando ícones Android por flavor': () =>
        _runDart('scripts/organize_flavor_icons.dart'),
    '6. Criando AppIcons iOS básicos': () =>
        _runDart('scripts/organize_ios_flavor_icons.dart'),
    '7. Gerando AppIcons para todos os flavors iOS': () =>
        _runDart('scripts/generate_all_flavor_appicons.dart'),
    '8. Atualizando configurações do Xcode': () =>
        _runPython('scripts/update_ios_appicons.py'),
    '9. Adicionando PreActions aos schemes iOS': () =>
        _runPython('scripts/add_appicon_preactions.py'),
  };

  var successCount = 0;
  var failCount = 0;

  for (final entry in steps.entries) {
    final stepName = entry.key;
    final stepFunction = entry.value;

    print('\n' + '=' * 60);
    print('📋 $stepName');
    print('=' * 60);

    try {
      final result = await stepFunction();

      if (result.exitCode == 0) {
        print('\n✅ Passo concluído com sucesso!');
        successCount++;
      } else {
        print('\n⚠️  Passo concluído com avisos/erros:');
        if (result.stderr.toString().isNotEmpty) {
          print(result.stderr);
        }
        failCount++;
      }
    } catch (e) {
      print('\n❌ Erro no passo: $e');
      failCount++;
    }
  }

  print('\n' + '=' * 60);
  print('📊 RESUMO');
  print('=' * 60);
  print('✅ Passos bem-sucedidos: $successCount/${steps.length}');
  print('⚠️  Passos com erros: $failCount/${steps.length}');

  if (failCount == 0) {
    print('\n🎉 Configuração completa concluída com sucesso!');
    print('\n🚀 Próximos passos:');
    print('   1. Teste em Android:');
    print('      flutter run --flavor demo -d android');
    print('      flutter run --flavor ouroPreto -d android');
    print('      flutter run --flavor vicosa -d android');
    print('');
    print('   2. Teste em iOS:');
    print('      flutter run --flavor main -d ios');
    print('      flutter run --flavor ouroPreto -d ios');
    print('');
    print('   3. Verifique a documentação:');
    print('      docs/FLAVOR_ICONS_SETUP.md');
  } else {
    print('\n⚠️  Alguns passos falharam. Revise os erros acima.');
    print('   Você pode executar os scripts individuais manualmente.');
  }

  print('\n' + '=' * 60);
}

Future<ProcessResult> _runDart(String scriptPath) async {
  return await Process.run('dart', [scriptPath]);
}

Future<ProcessResult> _runPython(String scriptPath) async {
  return await Process.run('python3', [scriptPath]);
}

Future<ProcessResult> _runCommand(String command, List<String> args) async {
  return await Process.run(command, args);
}
