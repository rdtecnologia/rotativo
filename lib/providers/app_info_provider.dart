import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_info_service.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  return await AppInfoService.getAppVersion();
});

final appBuildNumberProvider = FutureProvider<String>((ref) async {
  return await AppInfoService.getBuildNumber();
});

final appFullVersionProvider = FutureProvider<String>((ref) async {
  return await AppInfoService.getFullVersion();
});

final appNameProvider = FutureProvider<String>((ref) async {
  return await AppInfoService.getAppName();
});

final deviceBrandProvider = FutureProvider<String>((ref) async {
  return await AppInfoService.getDeviceBrand();
});

final deviceModelProvider = FutureProvider<String>((ref) async {
  return await AppInfoService.getDeviceModel();
});

final deviceInfoProvider = FutureProvider<String>((ref) async {
  return await AppInfoService.getDeviceInfo();
});

final osVersionProvider = FutureProvider<String>((ref) async {
  return await AppInfoService.getOSVersion();
});
