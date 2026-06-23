import 'package:barcode_app/models/wifi_qr_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WifiQrData parses standard WIFI QR string', () {
    const raw = 'WIFI:T:WPA;S:MyHome;P:secret123;H:false;;';
    final wifi = WifiQrData.parse(raw);

    expect(wifi, isNotNull);
    expect(wifi!.ssid, 'MyHome');
    expect(wifi.password, 'secret123');
    expect(wifi.authType, 'WPA');
    expect(wifi.hidden, isFalse);
  });

  test('WifiQrData parses open network', () {
    const raw = 'WIFI:T:nopass;S:CafeFree;P:;H:false;;';
    final wifi = WifiQrData.parse(raw);

    expect(wifi, isNotNull);
    expect(wifi!.ssid, 'CafeFree');
    expect(wifi.isOpen, isTrue);
  });
}
