import 'dart:io';

import 'package:barcode_app/models/profile_data.dart';
import 'package:path_provider/path_provider.dart';

class MediaStorage {
  static Future<String> profilesDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/profiles');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  static Future<ProfileData> persistMedia(ProfileData profile) async {
    final path = profile.mediaPath;
    if (path == null || profile.mediaType == ProfileMediaType.none) {
      return profile;
    }

    final source = File(path);
    if (!source.existsSync()) return profile;

    final dir = await profilesDir();
    final fileName = profile.mediaFileName ??
        'media_${DateTime.now().millisecondsSinceEpoch}${_extensionFor(path)}';
    final saved = await source.copy('$dir/$fileName');

    return profile.copyWith(
      mediaPath: saved.path,
      mediaFileName: fileName,
    );
  }

  static String _extensionFor(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '';
    return path.substring(dot);
  }

  static bool mediaExists(ProfileData profile) {
    final path = profile.mediaPath;
    if (path == null) return false;
    return File(path).existsSync();
  }
}
