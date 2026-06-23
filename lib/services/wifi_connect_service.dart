import 'dart:io';

import 'package:barcode_app/models/wifi_qr_data.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WifiConnectService {
  static Future<WifiConnectResult> connect(WifiQrData wifi) async {
    if (kIsWeb) {
      return WifiConnectResult.unsupported;
    }

    if (Platform.isAndroid) {
      final location = await Permission.locationWhenInUse.request();
      if (!location.isGranted) {
        return WifiConnectResult.permissionDenied;
      }
    }

    try {
      final security = _mapSecurity(wifi.authType);
      final connected = await WiFiForIoTPlugin.connect(
        wifi.ssid,
        password: wifi.isOpen ? null : wifi.password,
        security: security,
        withInternet: true,
        joinOnce: false,
      );

      if (connected == true) {
        return WifiConnectResult.success;
      }
      return WifiConnectResult.failed;
    } catch (_) {
      return WifiConnectResult.failed;
    }
  }

  static NetworkSecurity _mapSecurity(String authType) {
    switch (authType.toUpperCase()) {
      case 'WEP':
        return NetworkSecurity.WEP;
      case 'NOPASS':
      case 'NONE':
        return NetworkSecurity.NONE;
      default:
        return NetworkSecurity.WPA;
    }
  }
}

enum WifiConnectResult {
  success,
  failed,
  permissionDenied,
  unsupported,
}
