import 'dart:io';

/// Script master para configurar ícones iOS com cores específicas por flavor
/// Implementa o mesmo comportamento do Android para iOS
void main() async {
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

    try {
      final result = await stepFunction();

      if (result.exitCode == 0) {
        successCount++;
      } else {
        if (result.stderr.toString().isNotEmpty) {}
        failCount++;
      }
    } catch (e) {
      failCount++;
    }
  }

  if (failCount == 0) {
  } else {}
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
    return ProcessResult(0, 0, 'Script encontrado', '');
  } else {
    return ProcessResult(1, 1, '', 'Script não encontrado');
  }
}
