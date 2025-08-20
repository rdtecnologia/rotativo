#!/usr/bin/env dart

import 'dart:io';

/// Script to create iOS schemes for each city flavor
class IOSSchemeGenerator {
  static const Map<String, String> cityMappings = {
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

  static const Map<String, String> displayNames = {
    'demo': 'Rotativo',
    'patosDeMinas': 'Rotativo Patos',
    'janauba': 'Rotativo Janaúba',
    'conselheiroLafaiete': 'Rotativo Lafaiete',
    'capaoBonito': 'Rotativo Capão',
    'joaoMonlevade': 'Rotativo Monlevade',
    'itarare': 'Rotativo Itararé',
    'passos': 'Rotativo Passos',
    'ribeiraoDasNeves': 'Rotativo Neves',
    'igarape': 'Rotativo Igarapé',
    'ouroPreto': 'Rotativo Ouro Preto',
  };

  static String generateSchemeXML(
      String flavorName, String displayName, String cityName) {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1510"
   version = "1.3">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "97C146ED1CF9000F007C117D"
               BuildableName = "Runner.app"
               BlueprintName = "Runner"
               ReferencedContainer = "container:Runner.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
      <PreActions>
         <ExecutionAction
            ActionType = "Xcode.IDEStandardExecutionActionsCore.ExecutionActionType.ShellScriptAction">
            <ActionContent
               title = "Copy Google Service for $cityName"
               scriptText = "cd &quot;\${SRCROOT}&quot;&#10;\${SRCROOT}/Scripts/copy_google_service.sh $cityName">
               <EnvironmentBuildable>
                  <BuildableReference
                     BuildableIdentifier = "primary"
                     BlueprintIdentifier = "97C146ED1CF9000F007C117D"
                     BuildableName = "Runner.app"
                     BlueprintName = "Runner"
                     ReferencedContainer = "container:Runner.xcodeproj">
                  </BuildableReference>
               </EnvironmentBuildable>
            </ActionContent>
         </ExecutionAction>
      </PreActions>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      customLLDBInitFile = "\$(SRCROOT)/Flutter/ephemeral/flutter_lldbinit"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <MacroExpansion>
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </MacroExpansion>
      <Testables>
         <TestableReference
            skipped = "NO"
            parallelizable = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "331C8080294A63A400263BE5"
               BuildableName = "RunnerTests.xctest"
               BlueprintName = "RunnerTests"
               ReferencedContainer = "container:Runner.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      customLLDBInitFile = "\$(SRCROOT)/Flutter/ephemeral/flutter_lldbinit"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      enableGPUValidationMode = "1"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
      <EnvironmentVariables>
         <EnvironmentVariable
            key = "FLUTTER_FLAVOR"
            value = "$flavorName"
            isEnabled = "YES">
         </EnvironmentVariable>
         <EnvironmentVariable
            key = "CITY_NAME"
            value = "$cityName"
            isEnabled = "YES">
         </EnvironmentVariable>
      </EnvironmentVariables>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Profile"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>''';
  }

  static Future<void> createSchemes() async {
    final schemesDir = Directory('ios/Runner.xcodeproj/xcshareddata/xcschemes');

    if (!await schemesDir.exists()) {
      await schemesDir.create(recursive: true);
    }

    for (final entry in cityMappings.entries) {
      final flavorName = entry.key;
      final cityName = entry.value;
      final displayName = displayNames[flavorName] ?? 'Rotativo $cityName';

      final schemeContent =
          generateSchemeXML(flavorName, displayName, cityName);
      final schemeFile = File('${schemesDir.path}/$flavorName.xcscheme');

      await schemeFile.writeAsString(schemeContent);
    }
  }
}

void main() async {
  await IOSSchemeGenerator.createSchemes();
}
