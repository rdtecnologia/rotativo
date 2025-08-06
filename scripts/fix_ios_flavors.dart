#!/usr/bin/env dart

import 'dart:io';

/// Script to automatically fix iOS flavors by adding build configurations
class IOSFlavorFixer {
  static const Map<String, String> flavors = {
    'demo': 'Main',
    'patosDeMinas': 'PatosDeMinas',
    'janauba': 'Janauba',
    'conselheiroLafaiete': 'ConselheiroLafaiete',
    'capaoBonito': 'CapaoBonito',
    'joaoMonlevade': 'JoaoMonlevade',
    'itarare': 'Itarare',
    'passos': 'Passos',
    'ribeiraoDasNeves': 'RibeiraoDasNeves',
    'igarape': 'Igarape',
    'ouroPreto': 'OuroPreto',
  };

  static Future<void> fixIOSFlavors() async {
    print('🛠️  Corrigindo configurações de iOS flavors...');
    
    final pbxprojFile = File('ios/Runner.xcodeproj/project.pbxproj');
    
    if (!await pbxprojFile.exists()) {
      print('❌ Arquivo project.pbxproj não encontrado');
      return;
    }

    // Fazer backup
    final backupFile = File('ios/Runner.xcodeproj/project.pbxproj.backup.${DateTime.now().millisecondsSinceEpoch}');
    await pbxprojFile.copy(backupFile.path);
    print('✅ Backup criado: ${backupFile.path}');

    String content = await pbxprojFile.readAsString();

    // Procurar por uma configuração Debug existente para usar como template
    final debugConfigMatch = RegExp(r'(\w+) \/\* Debug \*\/ = \{[^}]+buildSettings = \{[^}]+\};').firstMatch(content);
    final releaseConfigMatch = RegExp(r'(\w+) \/\* Release \*\/ = \{[^}]+buildSettings = \{[^}]+\};').firstMatch(content);
    final profileConfigMatch = RegExp(r'(\w+) \/\* Profile \*\/ = \{[^}]+buildSettings = \{[^}]+\};').firstMatch(content);

    if (debugConfigMatch == null || releaseConfigMatch == null || profileConfigMatch == null) {
      print('❌ Não foi possível encontrar as configurações base');
      return;
    }

    final debugConfigId = debugConfigMatch.group(1)!;
    final releaseConfigId = releaseConfigMatch.group(1)!;
    final profileConfigId = profileConfigMatch.group(1)!;

    print('📋 Encontradas configurações base:');
    print('   Debug: $debugConfigId');
    print('   Release: $releaseConfigId');
    print('   Profile: $profileConfigId');

    // Gerar novos IDs únicos para cada flavor
    final newConfigs = <String>[];
    final configListEntries = <String>[];

    for (final flavor in flavors.keys) {
      // Gerar IDs únicos
      final debugId = '${_generateId()}${flavor}Debug';
      final releaseId = '${_generateId()}${flavor}Release';
      final profileId = '${_generateId()}${flavor}Profile';

      // Adicionar configurações
      newConfigs.addAll([
        _createBuildConfig(debugId, 'Debug-$flavor', 'debug'),
        _createBuildConfig(releaseId, 'Release-$flavor', 'release'),
        _createBuildConfig(profileId, 'Profile-$flavor', 'profile'),
      ]);

      // Adicionar às listas de configuração
      configListEntries.addAll([
        '\t\t\t\t$debugId /* Debug-$flavor */,',
        '\t\t\t\t$releaseId /* Release-$flavor */,',
        '\t\t\t\t$profileId /* Profile-$flavor */,',
      ]);
    }

    // Encontrar onde inserir as novas configurações
    final buildConfigsSectionStart = content.indexOf('/* Begin XCBuildConfiguration section */');
    final buildConfigsSectionEnd = content.indexOf('/* End XCBuildConfiguration section */');

    if (buildConfigsSectionStart == -1 || buildConfigsSectionEnd == -1) {
      print('❌ Não foi possível encontrar a seção XCBuildConfiguration');
      return;
    }

    // Inserir novas configurações
    final beforeConfigs = content.substring(0, buildConfigsSectionEnd);
    final afterConfigs = content.substring(buildConfigsSectionEnd);

    content = beforeConfigs + newConfigs.join('\n') + '\n' + afterConfigs;

    // Encontrar e atualizar as listas de configuração
    final configListRegex = RegExp(r'(\w+) \/\* Debug \*\/ = \{[^}]+\};\s*(\w+) \/\* Profile \*\/ = \{[^}]+\};\s*(\w+) \/\* Release \*\/ = \{[^}]+\};');
    
    content = content.replaceAllMapped(configListRegex, (match) {
      return match.group(0)! + '\n' + configListEntries.join('\n');
    });

    // Salvar o arquivo modificado
    await pbxprojFile.writeAsString(content);

    print('✅ Configurações iOS adicionadas com sucesso!');
    print('');
    print('🎉 Agora você pode usar:');
    for (final flavor in flavors.keys) {
      print('   flutter run --flavor $flavor -d "iPhone Simulator"');
    }
    print('');
    print('📱 Exemplo:');
    print('   flutter run --flavor patosDeMinas -d "iPhone 16 Pro"');
  }

  static String _generateId() {
    // Gerar ID único similar ao Xcode
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return random.substring(random.length - 8).toUpperCase();
  }

  static String _createBuildConfig(String id, String name, String mode) {
    // Extract complex conditional values to avoid string interpolation issues
    final gccPreprocessorDefinitions = mode == 'debug' 
        ? '''(
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"\$(inherited)",
\t\t\t\t)'''
        : '''(
\t\t\t\t\t"\$(inherited)",
\t\t\t\t)''';
    
    return '''
\t\t$id /* $name */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
\t\t\t\tCLANG_CXX_LIBRARY = "libc++";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = ${mode == 'release' ? 'NO' : 'NO'};
\t\t\t\tDEBUG_INFORMATION_FORMAT = ${mode == 'release' ? '"dwarf-with-dsym"' : 'dwarf'};
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = ${mode == 'debug' ? 'YES' : 'NO'};
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = ${mode == 'debug' ? '0' : 'Os'};
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = $gccPreprocessorDefinitions;
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 12.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = ${mode == 'debug' ? 'INCLUDE_SOURCE' : 'NO'};
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = ${mode == 'debug' ? 'YES' : 'NO'};
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t\tFLUTTER_BUILD_MODE = $mode;
\t\t\t};
\t\t\tname = "$name";
\t\t};''';
  }
}

void main() async {
  await IOSFlavorFixer.fixIOSFlavors();
}