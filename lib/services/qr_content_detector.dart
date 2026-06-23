import 'package:barcode_app/models/profile_data.dart';
import 'package:barcode_app/models/qr_content.dart';
import 'package:barcode_app/models/wifi_qr_data.dart';

class QrContentDetector {
  static QrContent analyze(String raw) {
    final trimmed = raw.trim();
    final profile = ProfileData.tryParse(trimmed);

    if (profile != null) {
      final imageUrl = profile.mediaType == ProfileMediaType.image
          ? profile.mediaUrl
          : (_isImageUrl(profile.mediaUrl) ? profile.mediaUrl : null);
      return QrContent(
        type: QrContentType.profile,
        raw: trimmed,
        title: profile.fullName.isEmpty ? 'بروفايل شخصي' : profile.fullName,
        subtitle: profile.jobTitle.isEmpty ? profile.phone : profile.jobTitle,
        actionUrl: profile.mediaUrl,
        imageUrl: imageUrl,
        profile: profile,
      );
    }

    if (trimmed.toUpperCase().startsWith('WIFI:')) {
      final wifi = WifiQrData.parse(trimmed);
      return QrContent(
        type: QrContentType.wifi,
        raw: trimmed,
        title: wifi?.ssid ?? 'WiFi',
        subtitle: wifi?.isOpen == true ? null : '••••••••',
        wifi: wifi,
      );
    }

    if (trimmed.startsWith('geo:')) {
      return QrContent(
        type: QrContentType.location,
        raw: trimmed,
        title: 'إحداثيات موقع',
        subtitle: trimmed.replaceFirst('geo:', ''),
        actionUrl: 'https://maps.google.com/?q=${trimmed.replaceFirst('geo:', '')}',
      );
    }

    if (trimmed.startsWith('tel:')) {
      final phone = trimmed.replaceFirst('tel:', '');
      return QrContent(
        type: QrContentType.phone,
        raw: trimmed,
        title: phone,
        subtitle: 'اضغط للاتصال',
        actionUrl: trimmed,
      );
    }

    if (trimmed.startsWith('mailto:')) {
      final email = trimmed.replaceFirst('mailto:', '').split('?').first;
      return QrContent(
        type: QrContentType.email,
        raw: trimmed,
        title: email,
        subtitle: 'اضغط لإرسال بريد',
        actionUrl: trimmed,
      );
    }

    if (trimmed.contains('wa.me/') || trimmed.contains('whatsapp.com')) {
      return QrContent(
        type: QrContentType.whatsapp,
        raw: trimmed,
        title: 'واتساب',
        subtitle: trimmed,
        actionUrl: trimmed.startsWith('http') ? trimmed : 'https://$trimmed',
      );
    }

    final mediaUrl = _extractMediaUrl(trimmed);
    if (mediaUrl != null) {
      if (trimmed.contains('صورة') || _isImageUrl(mediaUrl)) {
        return QrContent(
          type: QrContentType.image,
          raw: trimmed,
          title: 'صورة',
          subtitle: mediaUrl,
          actionUrl: mediaUrl,
          imageUrl: mediaUrl,
        );
      }
      if (trimmed.contains('PDF') || _isPdfUrl(mediaUrl)) {
        return QrContent(
          type: QrContentType.pdf,
          raw: trimmed,
          title: 'ملف PDF',
          subtitle: mediaUrl,
          actionUrl: mediaUrl,
        );
      }
    }

    if (_isImageUrl(trimmed)) {
      return QrContent(
        type: QrContentType.image,
        raw: trimmed,
        title: 'صورة',
        subtitle: trimmed,
        actionUrl: trimmed,
        imageUrl: trimmed,
      );
    }

    if (_isPdfUrl(trimmed)) {
      return QrContent(
        type: QrContentType.pdf,
        raw: trimmed,
        title: 'ملف PDF',
        subtitle: trimmed,
        actionUrl: trimmed,
      );
    }

    if (_isHttpUrl(trimmed)) {
      return QrContent(
        type: QrContentType.url,
        raw: trimmed,
        title: 'رابط',
        subtitle: trimmed,
        actionUrl: trimmed,
      );
    }

    return QrContent(
      type: QrContentType.text,
      raw: trimmed,
      title: 'نص',
      subtitle: trimmed.length > 120 ? '${trimmed.substring(0, 120)}...' : trimmed,
    );
  }

  static String? _extractMediaUrl(String text) {
    const label = 'رابط المرفق:';
    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith(label)) {
        return trimmed.substring(label.length).trim();
      }
    }
    return null;
  }

  static bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  static bool _isImageUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    final lower = value.toLowerCase().split('?').first;
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.bmp');
  }

  static bool _isPdfUrl(String value) {
    return value.toLowerCase().split('?').first.endsWith('.pdf');
  }
}
