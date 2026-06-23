import 'package:barcode_app/screen/favorites_screen.dart';
import 'package:barcode_app/l10n/app_strings.dart';
import 'package:barcode_app/screen/history_screen.dart';
import 'package:barcode_app/services/history_service.dart';
import 'package:barcode_app/services/settings_service.dart';
import 'package:barcode_app/theme/app_theme.dart';
import 'package:barcode_app/widgets/responsive_layout.dart';
import 'package:barcode_app/widgets/ui_components.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    final settings = SettingsService.instance;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: GradientBackground(
        child: SafeArea(
          child: ResponsiveLayout(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('appearance'),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedBuilder(
                        animation: settings,
                        builder: (context, _) {
                          return SegmentedButton<ThemeMode>(
                            segments: [
                              ButtonSegment(
                                value: ThemeMode.dark,
                                label: Text(context.tr('theme_dark')),
                                icon: const Icon(Icons.dark_mode),
                              ),
                              ButtonSegment(
                                value: ThemeMode.light,
                                label: Text(context.tr('theme_light')),
                                icon: const Icon(Icons.light_mode),
                              ),
                              ButtonSegment(
                                value: ThemeMode.system,
                                label: Text(context.tr('theme_system')),
                                icon: const Icon(Icons.brightness_auto),
                              ),
                            ],
                            selected: {settings.themeMode},
                            onSelectionChanged: (set) {
                              settings.setThemeMode(set.first);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('language'),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedBuilder(
                        animation: settings,
                        builder: (context, _) {
                          return SegmentedButton<String>(
                            segments: [
                              ButtonSegment(
                                value: 'ar',
                                label: Text(context.tr('lang_ar')),
                              ),
                              ButtonSegment(
                                value: 'en',
                                label: Text(context.tr('lang_en')),
                              ),
                            ],
                            selected: {settings.locale.languageCode},
                            onSelectionChanged: (set) {
                              settings.setLocale(Locale(set.first));
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GlassCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.history_rounded),
                        title: Text(context.tr('manage_history')),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.star_rounded),
                        title: Text(context.tr('favorites')),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(builder: (_) => const FavoritesScreen()),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_sweep_rounded),
                        title: Text(context.tr('clear_history')),
                        onTap: () async {
                          await HistoryService.instance.clearAll();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.tr('history_cleared'))),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GlassCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline_rounded),
                        title: Text(context.tr('app_title')),
                        subtitle: Text(context.tr('version')),
                      ),
                      ListTile(
                        leading: const Icon(Icons.share_rounded),
                        title: Text(context.tr('share_app')),
                        onTap: () => Share.share(context.tr('share_app_text')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
