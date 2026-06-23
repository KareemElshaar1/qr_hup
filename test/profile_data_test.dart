import 'package:barcode_app/models/profile_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ProfileData barcode payload is readable formatted text', () {
    const profile = ProfileData(
      fullName: 'أحمد محمد',
      jobTitle: 'مهندس برمجيات',
      phone: '01012345678',
      facebook: 'facebook.com/ahmed',
      instagram: '@ahmed',
    );

    final payload = profile.toBarcodePayload();

    expect(payload, contains('بطاقة شخصية'));
    expect(payload, contains('الاسم: أحمد محمد'));
    expect(payload, contains('الوظيفة: مهندس برمجيات'));
    expect(payload, contains('رقم التليفون: 01012345678'));
    expect(payload, contains('فيسبوك: facebook.com/ahmed'));
    expect(payload, isNot(contains('"type"')));
    expect(payload, isNot(startsWith('{')));
  });

  test('ProfileData includes cloud media url in barcode payload', () {
    const profile = ProfileData(
      fullName: 'سارة',
      mediaType: ProfileMediaType.image,
      mediaFileName: 'photo.jpg',
      mediaUrl: 'https://files.catbox.moe/abc.jpg',
    );

    final payload = profile.toBarcodePayload();
    final parsed = ProfileData.tryParse(payload);

    expect(payload, contains('رابط المرفق: https://files.catbox.moe/abc.jpg'));
    expect(parsed?.mediaUrl, 'https://files.catbox.moe/abc.jpg');
    expect(parsed?.mediaType, ProfileMediaType.image);
  });

  test('ProfileData parses formatted barcode payload', () {
    const profile = ProfileData(
      fullName: 'أحمد محمد',
      phone: '01012345678',
      facebook: 'facebook.com/ahmed',
      address: 'القاهرة، مصر',
    );

    final parsed = ProfileData.tryParse(profile.toBarcodePayload());

    expect(parsed, isNotNull);
    expect(parsed!.fullName, 'أحمد محمد');
    expect(parsed.phone, '01012345678');
    expect(parsed.facebook, 'facebook.com/ahmed');
    expect(parsed.address, 'القاهرة، مصر');
  });

  test('ProfileData still parses legacy JSON payload', () {
    const json = '''
{"type":"profile","v":1,"fullName":"سارة","phone":"01100000000","facebook":"","instagram":"","linkedin":"","jobTitle":"","email":"","notes":"","phone2":"","address":"","mediaType":"none"}
''';

    final parsed = ProfileData.tryParse(json);

    expect(parsed, isNotNull);
    expect(parsed!.fullName, 'سارة');
    expect(parsed.phone, '01100000000');
  });

  test('ProfileData.tryParse returns null for unrelated plain text', () {
    expect(ProfileData.tryParse('hello world'), isNull);
  });
}
