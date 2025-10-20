#!/usr/bin/env dart

import 'dart:io';

/// Enhanced build script that includes Firebase configuration setup
void main(List<String> args) {
  if (args.isEmpty) {
    print(
        '❌ Usage: dart build_with_firebase.dart <flavor> [platform] [build_type]');
    print('   Flavors: vicosa, ouroPreto, demo');
    print('   Platforms: android, ios, all (default: all)');
    print('   Build types: debug, release (default: debug)');
    print('');
    print('Examples:');
    print('   dart build_with_firebase.dart vicosa android release');
    print('   dart build_with_firebase.dart ouroPreto ios debug');
    print('   dart build_with_firebase.dart demo');
    exit(1);
  }

  final flavor = args[0].toLowerCase();
  final platform = args.length > 1 ? args[1].toLowerCase() : 'all';
  final buildType = args.length > 2 ? args[2].toLowerCase() : 'debug';

  print('🚀 Building with Firebase configuration');
  print('   Flavor: $flavor');
  print('   Platform: $platform');
  print('   Build Type: $buildType');

  try {
    // Step 1: Copy Firebase configurations
    setupFirebaseConfigurations(flavor);

    // Step 2: Build the app
    buildApp(flavor, platform, buildType);

    print('✅ Build completed successfully!');
  } catch (e, stackTrace) {
    print('❌ Build failed: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

void setupFirebaseConfigurations(String flavor) {
  print('\n📋 Setting up Firebase configurations...');

  // Copy iOS Firebase configuration
  print('🍎 Copying iOS Firebase configuration...');
  final iosResult = Process.runSync(
    'dart',
    ['scripts/copy_ios_firebase_config.dart', flavor],
  );

  if (iosResult.exitCode != 0) {
    print('⚠️  iOS Firebase config copy failed: ${iosResult.stderr}');
    print('Continuing with build...');
  } else {
    print('✅ iOS Firebase configuration copied');
  }

  // Android configurations are handled automatically by flavor structure
  print('🤖 Android Firebase configurations are handled by flavor structure');
}

void buildApp(String flavor, String platform, String buildType) {
  print('\n🔨 Building application...');

  if (platform == 'android' || platform == 'all') {
    buildAndroid(flavor, buildType);
  }

  if (platform == 'ios' || platform == 'all') {
    buildIOS(flavor, buildType);
  }
}

void buildAndroid(String flavor, String buildType) {
  print('\n🤖 Building Android...');

  final List<String> commands = [];

  if (buildType == 'release') {
    // Build APK and AAB for release
    commands.addAll([
      'flutter build apk --flavor $flavor --release',
      'flutter build appbundle --flavor $flavor --release',
    ]);
  } else {
    // Build APK for debug
    commands.add('flutter build apk --flavor $flavor --debug');
  }

  for (final command in commands) {
    print('🚀 Running: $command');
    final result = Process.runSync(
      'flutter',
      command.split(' ').skip(1).toList(),
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw Exception('Android build failed: ${result.stderr}');
    }

    print('✅ Android build completed: $command');
  }
}

void buildIOS(String flavor, String buildType) {
  print('\n🍎 Building iOS...');

  // Check if running on macOS
  if (!Platform.isMacOS) {
    print('⚠️  iOS build skipped: Not running on macOS');
    return;
  }

  final List<String> commands = [];

  if (buildType == 'release') {
    commands.add('flutter build ios --release');
  } else {
    commands.add('flutter build ios --debug');
  }

  for (final command in commands) {
    print('🚀 Running: $command');
    final result = Process.runSync(
      'flutter',
      command.split(' ').skip(1).toList(),
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw Exception('iOS build failed: ${result.stderr}');
    }

    print('✅ iOS build completed: $command');
  }
}

void printBuildSummary(String flavor, String platform, String buildType) {
  print('\n📊 Build Summary');
  print('================');
  print('Flavor: $flavor');
  print('Platform: $platform');
  print('Build Type: $buildType');
  print('Firebase: ✅ Configured');

  if (platform == 'android' || platform == 'all') {
    print('\n🤖 Android Outputs:');
    if (buildType == 'release') {
      print('   📱 APK: build/app/outputs/flutter-apk/app-$flavor-release.apk');
      print(
          '   📦 AAB: build/app/outputs/bundle/${flavor}Release/app-$flavor-release.aab');
    } else {
      print('   📱 APK: build/app/outputs/flutter-apk/app-$flavor-debug.apk');
    }
  }

  if (platform == 'ios' || platform == 'all') {
    print('\n🍎 iOS Outputs:');
    print('   📱 App: build/ios/iphoneos/Runner.app');
  }

  print('\n🔥 Firebase Configuration:');
  print('   📊 Analytics: Enabled');
  print('   💥 Crashlytics: Enabled');
  print('   🏷️  Flavor-specific configs: Applied');
}
