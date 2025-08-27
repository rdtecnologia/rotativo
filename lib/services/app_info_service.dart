import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class AppInfoService {
  static Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return '1.0.0'; // Fallback version
    }
  }

  static Future<String> getBuildNumber() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.buildNumber;
    } catch (e) {
      return '1'; // Fallback build number
    }
  }

  static Future<String> getFullVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      return '1.0.0+1'; // Fallback full version
    }
  }

  static Future<String> getAppName() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.appName;
    } catch (e) {
      return 'Rotativo'; // Fallback app name
    }
  }

  static Future<String> getDeviceBrand() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.brand.isNotEmpty ? androidInfo.brand : 'Android';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.model.isNotEmpty ? 'Apple' : 'iOS';
      } else if (Platform.isMacOS) {
        return 'Apple';
      } else if (Platform.isWindows) {
        return 'Windows';
      } else if (Platform.isLinux) {
        return 'Linux';
      } else {
        return 'Desconhecido';
      }
    } catch (e) {
      return 'Desconhecido';
    }
  }

  static Future<String> getDeviceModel() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.model.isNotEmpty ? androidInfo.model : 'Android';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.model.isNotEmpty ? iosInfo.model : 'iPhone';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return macInfo.model.isNotEmpty ? macInfo.model : 'Mac';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.productName.isNotEmpty
            ? windowsInfo.productName
            : 'Windows';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return linuxInfo.name.isNotEmpty ? linuxInfo.name : 'Linux';
      } else {
        return 'Desconhecido';
      }
    } catch (e) {
      return 'Desconhecido';
    }
  }

  static Future<String> getDeviceInfo() async {
    try {
      final brand = await getDeviceBrand();
      final model = await getDeviceModel();
      return '$brand $model';
    } catch (e) {
      return 'Dispositivo Desconhecido';
    }
  }

  static Future<String> getOSVersion() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return 'iOS ${iosInfo.systemVersion}';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return 'macOS ${macInfo.osRelease}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return 'Windows ${windowsInfo.buildNumber}';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return '${linuxInfo.name} ${linuxInfo.version}';
      } else {
        return 'Sistema Operacional Desconhecido';
      }
    } catch (e) {
      return 'Sistema Operacional Desconhecido';
    }
  }
}
