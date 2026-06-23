import 'dart:convert';

enum ProfileMediaType { none, image, video, file }

class ProfileData {
  const ProfileData({
    this.whatsapp = '',
    this.telegram = '',
    this.twitter = '',
    this.youtube = '',
    this.tiktok = '',
    this.fullName = '',
    this.jobTitle = '',
    this.email = '',
    this.notes = '',
    this.facebook = '',
    this.linkedin = '',
    this.instagram = '',
    this.phone = '',
    this.phone2 = '',
    this.address = '',
    this.mediaType = ProfileMediaType.none,
    this.mediaPath,
    this.mediaFileName,
    this.mediaUrl,
  });

  final String fullName;
  final String jobTitle;
  final String email;
  final String notes;
  final String facebook;
  final String whatsapp;
  final String telegram;
  final String twitter;
  final String youtube;
  final String tiktok;

  final String linkedin;
  final String instagram;

  final String phone;
  final String phone2;
  final String address;
  final ProfileMediaType mediaType;
  final String? mediaPath;
  final String? mediaFileName;
  final String? mediaUrl;

  static const _labelFullName = 'الاسم';
  static const _labelJobTitle = 'الوظيفة';
  static const _labelEmail = 'البريد الإلكتروني';
  static const _labelNotes = 'ملاحظات';
  static const _labelFacebook = 'فيسبوك';
  static const _labelWhatsapp = 'واتساب';
  static const _labelTelegram = 'تليغرام';
  static const _labelTwitter = 'تويتر';
  static const _labelYoutube = 'يوتيوب';
  static const _labelTiktok = 'تيكتوك';
  static const _labelLinkedin = 'لينكدإن';
  static const _labelInstagram = 'إنستجرام';
  static const _labelPhone = 'رقم التليفون';

  static const _labelPhone2 = 'رقم تليفون آخر';
  static const _labelAddress = 'العنوان';
  static const _labelAttachment = 'مرفق';
  static const _labelMediaUrl = 'رابط المرفق';

  static const _fieldLabels = <String, String>{
    'fullName': _labelFullName,
    'jobTitle': _labelJobTitle,
    'email': _labelEmail,
    'notes': _labelNotes,
    'facebook': _labelFacebook,
    'linkedin': _labelLinkedin,
    'whatsapp': _labelWhatsapp,
    'telegram': _labelTelegram,
    'twitter': _labelTwitter,
    'youtube': _labelYoutube,
    'tiktok': _labelTiktok,
    'instagram': _labelInstagram,
    'phone': _labelPhone,
    'phone2': _labelPhone2,
    'address': _labelAddress,
  };

  bool get hasPersonalInfo =>
      fullName.isNotEmpty ||
      jobTitle.isNotEmpty ||
      email.isNotEmpty ||
      notes.isNotEmpty ||
      mediaType != ProfileMediaType.none ||
      (mediaUrl?.isNotEmpty ?? false);

  bool get hasSocialInfo =>
      facebook.isNotEmpty ||
      linkedin.isNotEmpty ||
      instagram.isNotEmpty ||
      phone.isNotEmpty ||
      phone2.isNotEmpty ||
      address.isNotEmpty;

  bool get isEmpty => !hasPersonalInfo && !hasSocialInfo;

  ProfileData copyWith({
    String? fullName,
    String? jobTitle,
    String? whatsapp,
    String? telegram,
    String? twitter,
    String? youtube,
    String? tiktok,
    String? email,
    String? notes,
    String? facebook,
    String? linkedin,
    String? instagram,
    String? phone,
    String? phone2,
    String? address,
    ProfileMediaType? mediaType,
    String? mediaPath,
    String? mediaFileName,
    String? mediaUrl,
    bool clearMedia = false,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      facebook: facebook ?? this.facebook,
      linkedin: linkedin ?? this.linkedin,
      instagram: instagram ?? this.instagram,
      whatsapp: whatsapp ?? this.whatsapp,
      telegram: telegram ?? this.telegram,
      twitter: twitter ?? this.twitter,
      youtube: youtube ?? this.youtube,
      tiktok: tiktok ?? this.tiktok,
      phone: phone ?? this.phone,
      phone2: phone2 ?? this.phone2,
      address: address ?? this.address,
      mediaType: clearMedia
          ? ProfileMediaType.none
          : (mediaType ?? this.mediaType),
      mediaPath: clearMedia ? null : (mediaPath ?? this.mediaPath),
      mediaFileName: clearMedia ? null : (mediaFileName ?? this.mediaFileName),
      mediaUrl: clearMedia ? null : (mediaUrl ?? this.mediaUrl),
    );
  }

  /// نص منظم يظهر مرتباً في أي تطبيق QR على أي جهاز.
  String toBarcodePayload() {
    final lines = <String>[
      '================================',
      '         بطاقة شخصية',
      '================================',
      '',
    ];

    void addSection(String title, List<(String label, String value)> fields) {
      final filled = fields
          .where((field) => field.$2.trim().isNotEmpty)
          .toList();
      if (filled.isEmpty) return;
      lines.add('>> $title');
      lines.add('--------------------------------');
      for (final (label, value) in filled) {
        lines.add('$label: ${value.trim()}');
      }
      lines.add('');
    }

    addSection('البيانات الشخصية', [
      (_labelFullName, fullName),
      (_labelJobTitle, jobTitle),
      (_labelEmail, email),
      (_labelNotes, notes),
    ]);

    if (mediaType != ProfileMediaType.none &&
        ((mediaFileName?.isNotEmpty ?? false) ||
            (mediaUrl?.isNotEmpty ?? false))) {
      lines.add('>> مرفقات');
      lines.add('--------------------------------');
      if (mediaFileName?.isNotEmpty ?? false) {
        lines.add('$_labelAttachment: ${_mediaTypeLabel()} — $mediaFileName');
      }
      if (mediaUrl?.isNotEmpty ?? false) {
        lines.add('$_labelMediaUrl: $mediaUrl');
      }
      lines.add('');
    }

    addSection('وسائل التواصل', [
      (_labelFacebook, facebook),
      (_labelInstagram, instagram),
      (_labelLinkedin, linkedin),
      (_labelWhatsapp, whatsapp),
      (_labelTelegram, telegram),
      (_labelTwitter, twitter),
      (_labelYoutube, youtube),
      (_labelTiktok, tiktok),
      (_labelPhone, phone),
      (_labelPhone2, phone2),
      (_labelAddress, address),
    ]);

    return lines.join('\n').trimRight();
  }

  String _mediaTypeLabel() {
    switch (mediaType) {
      case ProfileMediaType.image:
        return 'صورة';
      case ProfileMediaType.video:
        return 'فيديو';
      case ProfileMediaType.file:
        return 'ملف';
      case ProfileMediaType.none:
        return '';
    }
  }

  static ProfileData? tryParse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('{')) {
      return _fromJson(trimmed);
    }
    if (trimmed.contains('BEGIN:VCARD')) {
      return _fromVCard(trimmed);
    }

    return _fromFormattedText(trimmed);
  }

  static ProfileData? _fromFormattedText(String raw) {
    final values = <String, String>{};

    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || _isDecorationLine(trimmed)) continue;

      for (final entry in _fieldLabels.entries) {
        final label = entry.value;
        if (trimmed.startsWith('$label:')) {
          values[entry.key] = trimmed.substring(label.length + 1).trim();
          break;
        }
      }

      if (trimmed.startsWith('$_labelAttachment:')) {
        final attachment = trimmed
            .substring(_labelAttachment.length + 1)
            .trim();
        values['attachment'] = attachment;
      }
      if (trimmed.startsWith('$_labelMediaUrl:')) {
        values['mediaUrl'] = trimmed
            .substring(_labelMediaUrl.length + 1)
            .trim();
      }
    }

    if (values.isEmpty) return null;

    ProfileMediaType mediaType = ProfileMediaType.none;
    String? mediaFileName;
    String? mediaUrl = values['mediaUrl'];
    final attachment = values['attachment'];
    if (attachment != null) {
      if (attachment.contains('صورة')) {
        mediaType = ProfileMediaType.image;
      } else if (attachment.contains('فيديو')) {
        mediaType = ProfileMediaType.video;
      } else if (attachment.contains('ملف')) {
        mediaType = ProfileMediaType.file;
      }
      final parts = attachment.split('—');
      if (parts.length > 1) {
        mediaFileName = parts.sublist(1).join('—').trim();
      }
    }

    if (mediaType == ProfileMediaType.none && mediaUrl != null) {
      mediaType = _mediaTypeFromUrl(mediaUrl);
    }

    final profile = ProfileData(
      fullName: values['fullName'] ?? '',
      jobTitle: values['jobTitle'] ?? '',
      email: values['email'] ?? '',
      notes: values['notes'] ?? '',
      facebook: values['facebook'] ?? '',
      linkedin: values['linkedin'] ?? '',
      whatsapp: values['whatsapp'] ?? '',
      telegram: values['telegram'] ?? '',
      twitter: values['twitter'] ?? '',
      youtube: values['youtube'] ?? '',
      tiktok: values['tiktok'] ?? '',
      instagram: values['instagram'] ?? '',
      phone: values['phone'] ?? '',

      phone2: values['phone2'] ?? '',
      address: values['address'] ?? '',
      mediaType: mediaType,
      mediaFileName: mediaFileName,
      mediaUrl: mediaUrl,
    );

    return profile.isEmpty ? null : profile;
  }

  static bool _isDecorationLine(String line) {
    if (line.startsWith('>>')) return true;
    if (line.startsWith('==')) return true;
    if (line.startsWith('--')) return true;
    if (line == 'بطاقة شخصية') return true;
    return false;
  }

  static ProfileData? _fromJson(String raw) {
    try {
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) return null;
      if (map['type'] != 'profile') return null;
      return ProfileData.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static ProfileData? _fromVCard(String raw) {
    final fields = <String, List<String>>{};
    var currentKey = '';

    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.contains(':') &&
          !trimmed.startsWith(' ') &&
          !trimmed.startsWith('\t')) {
        final colon = trimmed.indexOf(':');
        currentKey = trimmed.substring(0, colon).split(';').first.toUpperCase();
        final value = trimmed.substring(colon + 1).trim();
        fields.putIfAbsent(currentKey, () => []).add(_unescapeVCard(value));
      } else if (currentKey.isNotEmpty) {
        fields[currentKey]!.last += trimmed;
      }
    }

    String first(String key) => fields[key]?.firstOrNull ?? '';

    final urls = fields['URL'] ?? const [];
    final notes = first('NOTE');

    return ProfileData(
      fullName: first('FN'),
      jobTitle: first('TITLE'),
      email: first('EMAIL'),
      notes: notes,
      phone: fields['TEL']?.firstOrNull ?? '',
      phone2: fields['TEL'] != null && fields['TEL']!.length > 1
          ? fields['TEL']![1]
          : '',
      address: _parseVCardAddress(first('ADR')),

      facebook: urls.isNotEmpty ? urls[0] : '',
      instagram: urls.length > 1 ? urls[1] : '',
      linkedin: urls.length > 2 ? urls[2] : '',

      // FIX: each field should NOT reuse TEL blindly
      whatsapp: fields['TEL']?.firstOrNull ?? '',
      telegram: fields['TEL']?.firstOrNull ?? '',
      twitter:
          fields['X-TWITTER']?.firstOrNull ?? fields['TEL']?.firstOrNull ?? '',
      youtube: fields['URL-YOUTUBE']?.firstOrNull ?? '',
      tiktok: fields['URL-TIKTOK']?.firstOrNull ?? '',
    );
  }

  static String _unescapeVCard(String value) {
    return value
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\,', ',')
        .replaceAll(r'\;', ';')
        .replaceAll(r'\\', r'\');
  }

  static String _parseVCardAddress(String adr) {
    final parts = adr.split(';').where((part) => part.trim().isNotEmpty);
    return parts.join('، ');
  }

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      fullName: json['fullName'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
      email: json['email'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      facebook: json['facebook'] as String? ?? '',
      linkedin: json['linkedin'] as String? ?? '',
      instagram: json['instagram'] as String? ?? '',
      whatsapp: json['whatsapp'] as String? ?? '',
      telegram: json['telegram'] as String? ?? '',
      twitter: json['twitter'] as String? ?? '',
      youtube: json['youtube'] as String? ?? '',
      tiktok: json['tiktok'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      phone2: json['phone2'] as String? ?? '',
      address: json['address'] as String? ?? '',
      mediaType: _mediaTypeFromString(json['mediaType'] as String?),
      mediaPath: json['mediaPath'] as String?,
      mediaFileName: json['mediaFileName'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
    );
  }

  static ProfileMediaType _mediaTypeFromUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp')) {
      return ProfileMediaType.image;
    }
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm')) {
      return ProfileMediaType.video;
    }
    return ProfileMediaType.file;
  }

  static ProfileMediaType _mediaTypeFromString(String? value) {
    return ProfileMediaType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ProfileMediaType.none,
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
