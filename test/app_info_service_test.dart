import 'package:flutter_test/flutter_test.dart';
import 'package:rotativo/services/app_info_service.dart';

void main() {
  group('AppInfoService', () {
    test('getAppVersion should return a version string', () async {
      final version = await AppInfoService.getAppVersion();
      expect(version, isA<String>());
      expect(version.isNotEmpty, isTrue);
    });

    test('getBuildNumber should return a build number string', () async {
      final buildNumber = await AppInfoService.getBuildNumber();
      expect(buildNumber, isA<String>());
      expect(buildNumber.isNotEmpty, isTrue);
    });

    test('getFullVersion should return version with build number', () async {
      final fullVersion = await AppInfoService.getFullVersion();
      expect(fullVersion, isA<String>());
      expect(fullVersion.contains('+'), isTrue);
    });

    test('getAppName should return app name string', () async {
      final appName = await AppInfoService.getAppName();
      expect(appName, isA<String>());
      expect(appName.isNotEmpty, isTrue);
    });

    test('getDeviceBrand should return a brand string', () async {
      final brand = await AppInfoService.getDeviceBrand();
      expect(brand, isA<String>());
      expect(brand.isNotEmpty, isTrue);
    });

    test('getDeviceModel should return a model string', () async {
      final model = await AppInfoService.getDeviceModel();
      expect(model, isA<String>());
      expect(model.isNotEmpty, isTrue);
    });

    test('getDeviceInfo should return brand and model combined', () async {
      final deviceInfo = await AppInfoService.getDeviceInfo();
      expect(deviceInfo, isA<String>());
      expect(deviceInfo.isNotEmpty, isTrue);
      expect(deviceInfo.contains(' '), isTrue);
    });

    test('getOSVersion should return OS version string', () async {
      final osVersion = await AppInfoService.getOSVersion();
      expect(osVersion, isA<String>());
      expect(osVersion.isNotEmpty, isTrue);
    });
  });
}
