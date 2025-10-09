import 'dart:io';

/// Script master para configurar ícones iOS com cores específicas por flavor
/// Implementa o mesmo comportamento do Android para iOS
void main() async {
  print('🚀 Configurando ícones iOS com cores por flavor...\n');
  print('=' * 60);

  final steps = <String, Future<ProcessResult> Function()>{
    '1. Criando ícones iOS com cores específicas': () =>
        _runDart('scripts/create_ios_flavored_icons_direct.dart'),
    '2. Verificando sistema de cópia automática': () => _checkCopyScript(),
    '3. Atualizando configurações do Xcode (opcional)': () =>
        _runPython('scripts/update_ios_appicons.py'),
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
        print('\n⚠️  Passo concluído com avisos:');
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
    print('\n🎉 Configuração iOS concluída com sucesso!');
    print('\n📱 Agora o iOS tem o mesmo comportamento do Android:');
    print('   • Ícones com fundo colorido baseado na cor primária da cidade');
    print('   • Cada flavor tem sua cor específica visível no ícone');
    print('   • Sistema de cópia automática configurado');
    print('\n🎨 Cores configuradas:');
    print('   • Main: #5A7B97 (azul padrão)');
    print('   • OuroPreto: #A5732E (dourado)');
    print('   • Vicosa: #b61817 (vermelho)');
    print('\n🚀 Para testar:');
    print('   flutter run --flavor main -d ios');
    print('   flutter run --flavor ouroPreto -d ios');
    print('   flutter run --flavor vicosa -d ios');
    print('\n📝 Nota: O ícone será automaticamente trocado baseado no flavor!');
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

Future<ProcessResult> _checkCopyScript() async {
  final scriptFile = File('ios/Scripts/copy_appicon.sh');
  if (scriptFile.existsSync()) {
    print('✅ Script de cópia automática encontrado: ${scriptFile.path}');
    return ProcessResult(0, 0, 'Script encontrado', '');
  } else {
    print('⚠️  Script de cópia não encontrado. Sistema manual será usado.');
    return ProcessResult(1, 1, '', 'Script não encontrado');
  }
}


