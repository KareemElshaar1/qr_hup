import 'package:barcode_app/models/profile_data.dart';
import 'package:barcode_app/services/cloud_media_service.dart';
import 'package:barcode_app/services/media_storage.dart';

class ProfilePublishService {
  static Future<ProfileData> publish(ProfileData profile) async {
    var saved = await MediaStorage.persistMedia(profile);

    if (saved.mediaType == ProfileMediaType.none || saved.mediaPath == null) {
      return saved;
    }

    final url = await CloudMediaService.upload(saved.mediaPath!);
    return saved.copyWith(mediaUrl: url);
  }
}
