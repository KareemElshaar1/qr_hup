import 'package:barcode_app/models/profile_data.dart';
import 'package:barcode_app/models/qr_record.dart';
import 'package:barcode_app/models/wifi_qr_data.dart';
import 'package:barcode_app/l10n/app_strings.dart';
import 'package:flutter/material.dart';

enum QrContentType {
  text,
  url,
  phone,
  email,
  whatsapp,
  wifi,
  location,
  profile,
  image,
  pdf,
  video,
}

class QrContent {
  const QrContent({
    required this.type,
    required this.raw,
    required this.title,
    this.subtitle,
    this.actionUrl,
    this.imageUrl,
    this.profile,
    this.wifi,
  });

  final QrContentType type;
  final String raw;
  final String title;
  final String? subtitle;
  final String? actionUrl;
  final String? imageUrl;
  final ProfileData? profile;
  final WifiQrData? wifi;

  bool get isOpenableUrl =>
      actionUrl != null &&
      (type == QrContentType.url ||
          type == QrContentType.pdf ||
          type == QrContentType.video ||
          type == QrContentType.whatsapp ||
          type == QrContentType.location);

  QrRecordCategory get category {
    switch (type) {
      case QrContentType.text:
        return QrRecordCategory.text;
      case QrContentType.url:
        return QrRecordCategory.url;
      case QrContentType.phone:
        return QrRecordCategory.phone;
      case QrContentType.email:
        return QrRecordCategory.email;
      case QrContentType.whatsapp:
        return QrRecordCategory.whatsapp;
      case QrContentType.wifi:
        return QrRecordCategory.wifi;
      case QrContentType.location:
        return QrRecordCategory.location;
      case QrContentType.profile:
        return QrRecordCategory.profile;
      case QrContentType.image:
        return QrRecordCategory.image;
      case QrContentType.pdf:
        return QrRecordCategory.pdf;
      case QrContentType.video:
        return QrRecordCategory.video;
    }
  }

  String typeLabel(BuildContext context) {
    final s = AppStrings.of(context);
    switch (type) {
      case QrContentType.text:
        return s.t('type_text');
      case QrContentType.url:
        return s.t('type_url');
      case QrContentType.phone:
        return s.t('type_phone');
      case QrContentType.email:
        return s.t('type_email');
      case QrContentType.whatsapp:
        return s.t('type_whatsapp');
      case QrContentType.wifi:
        return s.t('type_wifi');
      case QrContentType.location:
        return s.t('type_location');
      case QrContentType.profile:
        return s.t('type_profile');
      case QrContentType.image:
        return s.t('type_image');
      case QrContentType.pdf:
        return s.t('type_pdf');
      case QrContentType.video:
        return s.t('type_video');
    }
  }
}
