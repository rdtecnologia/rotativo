import 'dart:io';

/// Script master para configurar todos os ícones por flavor
/// Executa todos os scripts necessários na ordem correta
void main() async {
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
    '6. Criando ícones iOS com cores específicas (NOVO)': () =>
        _runDart('scripts/create_ios_flavored_icons_direct.dart'),
    '7. Criando AppIcons iOS básicos (fallback)': () =>
        _runDart('scripts/organize_ios_flavor_icons.dart'),
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

Future<ProcessResult> _runCommand(String command, List<String> args) async {
  return await Process.run(command, args);
}
