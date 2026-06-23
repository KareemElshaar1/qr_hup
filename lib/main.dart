import 'package:barcode_app/l10n/app_strings.dart';
import 'package:barcode_app/screen/home_screen.dart';
import 'package:barcode_app/services/history_service.dart';
import 'package:barcode_app/services/settings_service.dart';
import 'package:barcode_app/theme/app_theme.dart';
import 'package:barcode_app/utils/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HistoryService.instance.init();
  await SettingsService.instance.init();
  runApp(
    appScreenUtilBuilder((context, child) => const QrHubApp()),
  );
}

class QrHubApp extends StatelessWidget {
  const QrHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        final settings = SettingsService.instance;
        return MaterialApp(
          title: 'QR Hub',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const HomeScreen(),
        );
      },
    );
  }
}
