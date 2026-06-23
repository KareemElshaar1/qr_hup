import 'package:barcode_app/main.dart';
import 'package:barcode_app/services/history_service.dart';
import 'package:barcode_app/services/settings_service.dart';
import 'package:barcode_app/utils/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows QR Hub home dashboard', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    WidgetsFlutterBinding.ensureInitialized();
    await HistoryService.instance.init();
    await SettingsService.instance.init();

    await tester.pumpWidget(
      appScreenUtilBuilder((context, child) => const QrHubApp()),
    );
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('QR Hub'), findsOneWidget);
    expect(find.text('مسح QR'), findsOneWidget);
    expect(find.text('إنشاء QR'), findsOneWidget);
    expect(find.text('بروفايلي'), findsOneWidget);
  });
}
