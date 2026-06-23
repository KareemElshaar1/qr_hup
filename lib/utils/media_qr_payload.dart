String buildMediaQrPayload({
  required String header,
  required String fileName,
  required String url,
}) {
  return '''================================
         $header
================================

>> الملف
--------------------------------
الاسم: $fileName
رابط المرفق: $url
''';
}
