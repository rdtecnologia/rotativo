#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Script to copy the correct GoogleService-Info.plist based on flavor
/// This should be run during iOS build process
void main(List<String> args) {
  if (args.isEmpty) {
    print('❌ Usage: dart copy_ios_firebase_config.dart <flavor>');
    print('   Available flavors: vicosa, ouroPreto, demo');
    exit(1);
  }

  final flavor = args[0].toLowerCase();
  print('🍎 Copying iOS Firebase config for flavor: $flavor');

  try {
    copyFirebaseConfig(flavor);
    print('✅ iOS Firebase config copied successfully');
  } catch (e, stackTrace) {
    print('❌ Error copying iOS Firebase config: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

void copyFirebaseConfig(String flavor) {
  // Map flavor to city directory
  final cityDirectory = mapFlavorToCityDirectory(flavor);

  // Source path in assets
  final sourcePath =
      'assets/config/cities/$cityDirectory/GoogleService-Info.plist';

  // Destination path in iOS project
  final destPath = 'ios/Runner/GoogleService-Info.plist';

  print('📂 Source: $sourcePath');
  print('📂 Destination: $destPath');

  // Check if source file exists
  final sourceFile = File(sourcePath);
  if (!sourceFile.existsSync()) {
    throw Exception('Source file not found: $sourcePath');
  }

  // Create destination directory if it doesn't exist
  final destFile = File(destPath);
  final destDir = destFile.parent;
  if (!destDir.existsSync()) {
    destDir.createSync(recursive: true);
  }

  // Copy the file
  sourceFile.copySync(destPath);

  print('✅ Copied $sourcePath to $destPath');

  // Verify the copy
  if (!destFile.existsSync()) {
    throw Exception('Failed to copy file to destination');
  }

  // Log the configuration details
  logConfigurationDetails(destPath, flavor);
}

String mapFlavorToCityDirectory(String flavor) {
  switch (flavor.toLowerCase()) {
    case 'vicosa':
      return 'Vicosa';
    case 'ouropreto':
      return 'OuroPreto';
    case 'demo':
      return 'Main';
    default:
      print('⚠️  Unknown flavor: $flavor, using Main configuration');
      return 'Main';
  }
}

void logConfigurationDetails(String plistPath, String flavor) {
  try {
    final file = File(plistPath);
    final content = file.readAsStringSync();

    // Extract key information from plist
    final projectId = extractPlistValue(content, 'PROJECT_ID');
    final bundleId = extractPlistValue(content, 'BUNDLE_ID');
    final appId = extractPlistValue(content, 'GOOGLE_APP_ID');

    print('📋 Configuration details:');
    print('   Flavor: $flavor');
    print('   Project ID: $projectId');
    print('   Bundle ID: $bundleId');
    print('   App ID: $appId');
  } catch (e) {
    print('⚠️  Could not read configuration details: $e');
  }
}

String? extractPlistValue(String plistContent, String key) {
  final regex = RegExp('<key>$key</key>\\s*<string>([^<]+)</string>');
  final match = regex.firstMatch(plistContent);
  return match?.group(1);
}
