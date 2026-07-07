import 'package:barcode_app/screen/favorites_screen.dart';
import 'package:barcode_app/l10n/app_strings.dart';
import 'package:barcode_app/screen/history_screen.dart';
import 'package:barcode_app/screen/generate_qr_screen.dart';
import 'package:barcode_app/screen/image_qr_screen.dart';
import 'package:barcode_app/screen/pdf_qr_screen.dart';
import 'package:barcode_app/screen/profile_data_screen.dart';
import 'package:barcode_app/screen/scan_screen.dart';
import 'package:barcode_app/screen/settings_screen.dart';
import 'package:barcode_app/theme/app_theme.dart';
import 'package:barcode_app/widgets/dashboard_tile.dart';
import 'package:barcode_app/utils/app_responsive.dart';
import 'package:barcode_app/widgets/responsive_layout.dart';
import 'package:barcode_app/widgets/ui_components.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    final columns = responsiveGridCount(context);
    final aspect = responsiveTileAspect(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(context.tr('app_title')),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ResponsiveLayout(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.h, bottom: 20.h),
                    child: FadeSlideIn(
                      child: TiltWidget(
                        child: GlassCard(
                          padding: EdgeInsets.all(22.w),
                          child: Row(
                            children: [
                              Container(
                              width: 56.w,
                              height: 56.w,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colors.accent.withValues(alpha: 0.25),
                                      colors.accentSecondary.withValues(alpha: 0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(Icons.qr_code_2_rounded, color: colors.accent, size: 30),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('welcome'),
                                      style: TextStyle(
                                        color: colors.textPrimary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.tr('welcome_sub'),
                                      style: TextStyle(color: colors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ResponsiveLayout(
                  padding: EdgeInsets.zero,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: columns,
                          mainAxisSpacing: 14.h,
                          crossAxisSpacing: 14.w,
                          childAspectRatio: aspect,
                          children: [
                            DashboardTile(
                              icon: Icons.qr_code_scanner_rounded,
                              label: context.tr('scan_qr'),
                              subtitle: context.tr('scan_camera_gallery'),
                              color: colors.accent,
                              onTap: () => _open(context, const ScanScreen()),
                            ),
                            DashboardTile(
                              icon: Icons.add_circle_outline_rounded,
                              label: context.tr('generate_qr'),
                              subtitle: context.tr('generate_types'),
                              color: colors.accentSecondary,
                              onTap: () => _open(context, const GenerateQrScreen()),
                            ),
                            DashboardTile(
                              icon: Icons.person_rounded,
                              label: context.tr('my_profile'),
                              subtitle: context.tr('profile_card'),
                              color: const Color(0xFF3FB950),
                              onTap: () => _open(context, const ProfileDataScreen()),
                            ),
                            DashboardTile(
                              icon: Icons.picture_as_pdf_rounded,
                              label: context.tr('pdf_qr'),
                              color: const Color(0xFFFF7B72),
                              onTap: () => _open(context, const PdfQrScreen()),
                            ),
                            DashboardTile(
                              icon: Icons.image_rounded,
                              label: context.tr('image_qr'),
                              color: const Color(0xFFFFA657),
                              onTap: () => _open(context, const ImageQrScreen()),
                            ),
                            DashboardTile(
                              icon: Icons.history_rounded,
                              label: context.tr('history'),
                              subtitle: context.tr('history_sub'),
                              color: const Color(0xFF79C0FF),
                              onTap: () => _open(context, const HistoryScreen()),
                            ),
                            DashboardTile(
                              icon: Icons.star_rounded,
                              label: context.tr('favorites'),
                              color: const Color(0xFFFFD700),
                              onTap: () => _open(context, const FavoritesScreen()),
                            ),
                            DashboardTile(
                              icon: Icons.tune_rounded,
                              label: context.tr('settings'),
                              color: colors.textMuted,
                              onTap: () => _open(context, const SettingsScreen()),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, fadeSlideRoute(screen));
  }
}
