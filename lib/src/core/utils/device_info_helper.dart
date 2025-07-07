// lib/src/core/utils/device_info_helper.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoHelper {
  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Android ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios_device';
    }
    
    return 'unknown_device';
  }

  static Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return '${androidInfo.brand} ${androidInfo.model}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return '${iosInfo.name} (${iosInfo.model})';
    }
    
    return 'Unknown Device';
  }

  static Future<String> getOSVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return 'Android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return 'iOS ${iosInfo.systemVersion}';
    }
    
    return 'Unknown OS';
  }

  static String getDeviceType() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    }
    return 'unknown';
  }
}