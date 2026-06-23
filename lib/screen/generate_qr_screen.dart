import 'package:barcode_app/l10n/app_strings.dart';
import 'package:barcode_app/models/qr_record.dart';
import 'package:barcode_app/services/history_service.dart';
import 'package:barcode_app/theme/app_theme.dart';
import 'package:barcode_app/utils/app_responsive.dart';
import 'package:barcode_app/widgets/qr_preview_card.dart';
import 'package:barcode_app/widgets/responsive_layout.dart';
import 'package:barcode_app/widgets/ui_components.dart';
import 'package:flutter/material.dart';

enum GenerateQrType {
  text(Icons.text_fields_rounded),
  url(Icons.link_rounded),
  phone(Icons.phone_rounded),
  email(Icons.email_rounded),
  whatsapp(Icons.chat_rounded),
  wifi(Icons.wifi_rounded),
  location(Icons.location_on_rounded);

  const GenerateQrType(this.icon);
  final IconData icon;

  String labelKey() => switch (this) {
        GenerateQrType.text => 'gen_type_text',
        GenerateQrType.url => 'gen_type_url',
        GenerateQrType.phone => 'gen_type_phone',
        GenerateQrType.email => 'gen_type_email',
        GenerateQrType.whatsapp => 'gen_type_whatsapp',
        GenerateQrType.wifi => 'gen_type_wifi',
        GenerateQrType.location => 'gen_type_location',
      };
}

class GenerateQrScreen extends StatefulWidget {
  const GenerateQrScreen({super.key});

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  GenerateQrType _type = GenerateQrType.text;
  final _main = TextEditingController();
  final _wifiPass = TextEditingController();
  final _wifiEncryption = TextEditingController(text: 'WPA');
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  String _payload = '';

  @override
  void initState() {
    super.initState();
    _main.addListener(_updatePayload);
    _wifiPass.addListener(_updatePayload);
    _wifiEncryption.addListener(_updatePayload);
    _lat.addListener(_updatePayload);
    _lng.addListener(_updatePayload);
  }

  @override
  void dispose() {
    _main.dispose();
    _wifiPass.dispose();
    _wifiEncryption.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  void _updatePayload() {
    setState(() => _payload = _buildPayload());
  }

  String _buildPayload() {
    final value = _main.text.trim();
    switch (_type) {
      case GenerateQrType.text:
        return value;
      case GenerateQrType.url:
        if (value.isEmpty) return '';
        return value.startsWith('http') ? value : 'https://$value';
      case GenerateQrType.phone:
        if (value.isEmpty) return '';
        return value.startsWith('tel:') ? value : 'tel:$value';
      case GenerateQrType.email:
        if (value.isEmpty) return '';
        return value.startsWith('mailto:') ? value : 'mailto:$value';
      case GenerateQrType.whatsapp:
        if (value.isEmpty) return '';
        final digits = value.replaceAll(RegExp(r'\D'), '');
        return 'https://wa.me/$digits';
      case GenerateQrType.wifi:
        if (value.isEmpty) return '';
        final enc = _wifiEncryption.text.trim().isEmpty ? 'WPA' : _wifiEncryption.text.trim();
        final pass = _wifiPass.text;
        return 'WIFI:T:$enc;S:$value;P:$pass;;';
      case GenerateQrType.location:
        final lat = _lat.text.trim();
        final lng = _lng.text.trim();
        if (lat.isEmpty || lng.isEmpty) return '';
        return 'geo:$lat,$lng';
    }
  }

  QrRecordCategory _categoryForType() {
    return switch (_type) {
      GenerateQrType.text => QrRecordCategory.text,
      GenerateQrType.url => QrRecordCategory.url,
      GenerateQrType.phone => QrRecordCategory.phone,
      GenerateQrType.email => QrRecordCategory.email,
      GenerateQrType.whatsapp => QrRecordCategory.whatsapp,
      GenerateQrType.wifi => QrRecordCategory.wifi,
      GenerateQrType.location => QrRecordCategory.location,
    };
  }

  Future<void> _saveToHistory() async {
    if (_payload.isEmpty) return;
    await HistoryService.instance.addGenerated(
      title: 'QR ${context.tr(_type.labelKey())}',
      content: _payload,
      category: _categoryForType(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('saved_to_history'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(context.tr('generate_qr_title'))),
      body: GradientBackground(
        child: SafeArea(
          child: ResponsiveLayout(
            child: ListView(
              padding: EdgeInsets.fromLTRB(0, 12.h, 0, 24.h),
              children: [
                GlassCard(
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: GenerateQrType.values.map((type) {
                      final selected = _type == type;
                      return ChoiceChip(
                        selected: selected,
                        label: Text(context.tr(type.labelKey())),
                        avatar: Icon(type.icon, size: 18.sp),
                        onSelected: (_) {
                          setState(() => _type = type);
                          _updatePayload();
                        },
                        selectedColor: colors.accent.withValues(alpha: 0.2),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16.h),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ..._fieldsForType(),
                      SizedBox(height: 8.h),
                      OutlinedButton.icon(
                        onPressed: _payload.isEmpty ? null : _saveToHistory,
                        icon: const Icon(Icons.save_rounded),
                        label: Text(context.tr('save_to_history')),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                GlassCard(
                  child: QrPreviewCard(
                    data: _payload,
                    title: context.tr('live_preview'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _fieldsForType() {
    switch (_type) {
      case GenerateQrType.text:
        return [_field(_main, context.tr('hint_text'), maxLines: 4)];
      case GenerateQrType.url:
        return [_field(_main, context.tr('hint_url'))];
      case GenerateQrType.phone:
        return [_field(_main, context.tr('hint_phone'), keyboard: TextInputType.phone)];
      case GenerateQrType.email:
        return [_field(_main, context.tr('hint_email'), keyboard: TextInputType.emailAddress)];
      case GenerateQrType.whatsapp:
        return [_field(_main, context.tr('hint_whatsapp'), keyboard: TextInputType.phone)];
      case GenerateQrType.wifi:
        return [
          _field(_main, context.tr('hint_wifi_ssid')),
          SizedBox(height: 12.h),
          _field(_wifiPass, context.tr('hint_wifi_pass'), obscure: true),
          SizedBox(height: 12.h),
          _field(_wifiEncryption, context.tr('hint_wifi_enc')),
        ];
      case GenerateQrType.location:
        return [
          _field(_lat, context.tr('hint_latitude'), keyboard: const TextInputType.numberWithOptions(decimal: true)),
          SizedBox(height: 12.h),
          _field(_lng, context.tr('hint_longitude'), keyboard: const TextInputType.numberWithOptions(decimal: true)),
        ];
    }
  }

  Widget _field(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboard,
    bool obscure = false,
  }) {
    final colors = colorsOf(context);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      obscureText: obscure,
      style: TextStyle(color: colors.textPrimary, fontSize: 14.sp),
      cursorColor: colors.accent,
      decoration: InputDecoration(hintText: hint),
    );
  }
}
