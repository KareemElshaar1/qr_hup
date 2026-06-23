import 'package:barcode_app/models/profile_data.dart';
import 'package:barcode_app/screen/profile_data_screen.dart';
import 'package:barcode_app/screen/profile_view_screen.dart';
import 'package:barcode_app/screen/scan_screen.dart';
import 'package:barcode_app/theme/app_theme.dart';
import 'package:barcode_app/widgets/ui_components.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String? _data;
  late final AnimationController _barcodeController;
  late final Animation<double> _barcodeScale;

  @override
  void initState() {
    super.initState();
    _barcodeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _barcodeScale = CurvedAnimation(
      parent: _barcodeController,
      curve: Curves.easeOutBack,
    );
  }

  void _generate() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك اكتب الداتا أولاً')),
      );
      return;
    }
    setState(() => _data = text);
    _barcodeController.forward(from: 0);
  }

  void _clear() {
    setState(() {
      _controller.clear();
      _data = null;
    });
  }

  Future<void> _openScanner() async {
    final result = await Navigator.push<String>(
      context,
      fadeSlideRoute(const ScanScreen()),
    );
    if (!mounted || result == null) return;

    final profile = ProfileData.tryParse(result);
    if (profile != null) {
      await Navigator.push<void>(
        context,
        fadeSlideRoute(ProfileViewScreen(profile: profile)),
      );
      return;
    }

    setState(() {
      _controller.text = result;
      _data = result;
    });
    _barcodeController.forward(from: 0);
  }

  Future<void> _openProfileEditor() async {
    await Navigator.push<void>(
      context,
      fadeSlideRoute(const ProfileDataScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Section: small reusable header used to label each card/section
  // ---------------------------------------------------------------------
  Widget _sectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('إنشاء ومسح الباركود'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---------------- Hero header ----------------
                FadeSlideIn(
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 28,
                    ),
                    child: Column(
                      children: [
                        const PulseIcon(icon: Icons.qr_code_scanner_rounded),
                        const SizedBox(height: 18),
                        Text(
                          'باركود',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'اكتب البيانات أو امسح باركود جاهز — النتيجة تظهر فوراً',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------- Input section ----------------
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionHeader(
                          icon: Icons.edit_note_rounded,
                          title: 'إنشاء باركود يدوي',
                          subtitle: 'اكتب أي نص أو كود وحوّله لباركود فوراً',
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _controller,
                          maxLines: 3,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'اكتب الداتا هنا',
                            hintText: 'مثال: اسم المنتج، كود، رقم...',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _generate,
                                icon: const Icon(Icons.auto_awesome_rounded),
                                label: const Text('عرض الباركود'),
                              ),
                            ),
                            if (_data != null && _data!.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: _clear,
                                tooltip: 'مسح',
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textMuted,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      AppColors.textMuted.withValues(alpha: 0.08),
                                  shape: const CircleBorder(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ---------------- Result section ----------------
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.94, end: 1).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: _data != null && _data!.isNotEmpty
                      ? FadeSlideIn(
                          key: ValueKey(_data),
                          delay: const Duration(milliseconds: 80),
                          child: ScaleTransition(
                            scale: _barcodeScale,
                            child: GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: AppColors.accent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'الباركود جاهز',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          Clipboard.setData(
                                            ClipboardData(text: _data!),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('تم النسخ'),
                                            ),
                                          );
                                        },
                                        tooltip: 'نسخ النص',
                                        icon: const Icon(
                                          Icons.copy_rounded,
                                          size: 18,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.accent
                                              .withValues(alpha: 0.15),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: BarcodeWidget(
                                      barcode: Barcode.code128(),
                                      data: _data!,
                                      width: double.infinity,
                                      height: 120,
                                      drawText: true,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.textMuted
                                          .withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _data!,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
                ),

                const SizedBox(height: 28),

                // ---------------- Divider with label ----------------
                FadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.textMuted.withValues(alpha: 0.25),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'أو',
                          style: TextStyle(
                            color: AppColors.textMuted.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.textMuted.withValues(alpha: 0.25),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ---------------- Actions section ----------------
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionHeader(
                          icon: Icons.badge_rounded,
                          title: 'البطاقة الشخصية',
                          subtitle:
                              'أدخل بياناتك مرة واحدة، وحوّلها لباركود منظم يقدر أي شخص يقرأه',
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: _openProfileEditor,
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: const Text('إدخال بياناتي الشخصية'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 240),
                  child: OutlinedButton.icon(
                    onPressed: _openScanner,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text(('مسح باركود بالكاميرا')),
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