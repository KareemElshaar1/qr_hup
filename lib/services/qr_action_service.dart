import 'package:barcode_app/models/qr_content.dart';
import 'package:barcode_app/models/wifi_qr_data.dart';
import 'package:barcode_app/services/wifi_connect_service.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QrActionService {
  static Future<void> openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> openContent(QrContent content) async {
    final url = content.actionUrl;
    if (url == null || url.isEmpty) return;
    await openUrl(url);
  }

  static Future<WifiConnectResult> connectWifi(WifiQrData wifi) {
    return WifiConnectService.connect(wifi);
  }

  static Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> share(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  static Future<void> saveBytesToGallery(List<int> bytes, {String name = 'qr_code'}) async {
    await Gal.putImageBytes(
      bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
      name: name,
    );
  }
}
