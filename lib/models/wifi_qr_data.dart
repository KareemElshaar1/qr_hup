class WifiQrData {
  const WifiQrData({
    required this.ssid,
    this.password,
    this.authType = 'WPA',
    this.hidden = false,
  });

  final String ssid;
  final String? password;
  final String authType;
  final bool hidden;

  bool get isOpen => authType.toUpperCase() == 'NOPASS' || (password?.isEmpty ?? true);

  static WifiQrData? parse(String raw) {
    final trimmed = raw.trim();
    if (!trimmed.toUpperCase().startsWith('WIFI:')) return null;

    var body = trimmed.substring(5);
    if (body.endsWith(';')) body = body.substring(0, body.length - 1);

    String? ssid;
    String? password;
    var authType = 'WPA';
    var hidden = false;

    for (final segment in body.split(';')) {
      if (segment.isEmpty) continue;
      final colon = segment.indexOf(':');
      if (colon <= 0) continue;
      final key = segment.substring(0, colon);
      final value = _unescape(segment.substring(colon + 1));
      switch (key) {
        case 'S':
          ssid = value;
        case 'P':
          password = value;
        case 'T':
          authType = value.isEmpty ? 'NOPASS' : value;
        case 'H':
          hidden = value.toLowerCase() == 'true';
      }
    }

    if (ssid == null || ssid.isEmpty) return null;
    return WifiQrData(
      ssid: ssid,
      password: password,
      authType: authType,
      hidden: hidden,
    );
  }

  static String _unescape(String value) {
    return value
        .replaceAll(r'\;', ';')
        .replaceAll(r'\:', ':')
        .replaceAll(r'\\', r'\')
        .replaceAll(r'\"', '"');
  }
}
