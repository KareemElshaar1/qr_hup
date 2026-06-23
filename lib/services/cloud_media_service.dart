import 'dart:io';

import 'package:http/http.dart' as http;

/// يرفع الملفات إلى سحابة عامة ويعيد رابطاً يمكن لأي جهاز فتحه.
class CloudMediaService {
  static const _uploadUrl = 'https://catbox.moe/user/api.php';

  static Future<String> upload(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw CloudMediaException('الملف غير موجود على الجهاز');
    }

    final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl))
      ..fields['reqtype'] = 'fileupload'
      ..files.add(await http.MultipartFile.fromPath('fileToUpload', filePath));

    final streamed = await request.send().timeout(const Duration(minutes: 5));
    final body = (await streamed.stream.bytesToString()).trim();

    if (streamed.statusCode != 200 || !_isValidUrl(body)) {
      throw CloudMediaException('فشل رفع الملف. تحقق من الإنترنت وحاول مرة أخرى');
    }

    return body;
  }

  static bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }
}

class CloudMediaException implements Exception {
  CloudMediaException(this.message);
  final String message;

  @override
  String toString() => message;
}
