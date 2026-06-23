import 'package:barcode_app/models/wifi_qr_data.dart';
import 'package:barcode_app/l10n/app_strings.dart';
import 'package:barcode_app/models/qr_content.dart';
import 'package:barcode_app/screen/profile_view_screen.dart';
import 'package:barcode_app/services/history_service.dart';
import 'package:barcode_app/services/qr_action_service.dart';
import 'package:barcode_app/services/wifi_connect_service.dart';
import 'package:barcode_app/theme/app_theme.dart';
import 'package:barcode_app/utils/app_responsive.dart';
import 'package:barcode_app/widgets/responsive_layout.dart';
import 'package:barcode_app/widgets/ui_components.dart';
import 'package:flutter/material.dart';

class ScanResultScreen extends StatefulWidget {
  const ScanResultScreen({
    super.key,
    required this.content,
    this.recordId,
    this.autoOpenLink = true,
  });

  final QrContent content;
  final String? recordId;
  final bool autoOpenLink;

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  bool _opened = false;
  bool _connectingWifi = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleAutoActions());
  }

  Future<void> _handleAutoActions() async {
    if (!mounted || _opened) return;
    final content = widget.content;

    if (content.imageUrl != null || content.type == QrContentType.wifi) return;

    if (!widget.autoOpenLink || content.actionUrl == null) return;

    final shouldOpen = switch (content.type) {
      QrContentType.url ||
      QrContentType.pdf ||
      QrContentType.location ||
      QrContentType.whatsapp ||
      QrContentType.phone ||
      QrContentType.email =>
        true,
      _ => false,
    };

    if (shouldOpen) {
      _opened = true;
      await QrActionService.openContent(content);
    }
  }

  Future<void> _connectWifi() async {
    final wifi = widget.content.wifi;
    if (wifi == null || _connectingWifi) return;

    setState(() => _connectingWifi = true);
    final result = await QrActionService.connectWifi(wifi);
    if (!mounted) return;
    setState(() => _connectingWifi = false);

    final message = switch (result) {
      WifiConnectResult.success => context.tr('wifi_connected'),
      WifiConnectResult.permissionDenied => context.tr('wifi_permission'),
      WifiConnectResult.unsupported || WifiConnectResult.failed => context.tr('wifi_failed'),
    };

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleFavorite() async {
    final id = widget.recordId;
    if (id == null) return;
    await HistoryService.instance.toggleFavorite(id);
    if (mounted) setState(() {});
  }

  bool get _isFavorite {
    final id = widget.recordId;
    if (id == null) return false;
    return HistoryService.instance.records
        .any((record) => record.id == id && record.isFavorite);
  }

  Future<void> _openLink() async {
    final url = widget.content.actionUrl;
    if (url == null) return;
    await QrActionService.openUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    final content = widget.content;
    final wifi = content.wifi;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${context.tr('scan_result')} — ${content.typeLabel(context)}'),
        actions: [
          if (widget.recordId != null)
            IconButton(
              onPressed: _toggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: _isFavorite ? Colors.amber : null,
              ),
            ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: ResponsiveLayout(
            child: ListView(
              padding: EdgeInsets.fromLTRB(0, 12.h, 0, 24.h),
              children: [
                if (content.imageUrl != null) ...[
                  FadeSlideIn(child: _ImagePreview(url: content.imageUrl!)),
                  SizedBox(height: 16.h),
                ],
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                content.typeLabel(context),
                                style: TextStyle(
                                  color: colors.accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          content.title,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (wifi != null) ...[
                          SizedBox(height: 12.h),
                          _WifiDetails(wifi: wifi),
                        ] else if (content.subtitle != null) ...[
                          const SizedBox(height: 8),
                          _TappableContent(
                            text: content.subtitle!,
                            isLink: content.isOpenableUrl,
                            onTap: content.isOpenableUrl ? _openLink : null,
                          ),
                        ],
                        if (content.isOpenableUrl && content.actionUrl != null) ...[
                          const SizedBox(height: 12),
                          _TappableContent(
                            text: content.actionUrl!,
                            isLink: true,
                            onTap: _openLink,
                            hint: context.tr('tap_to_open'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (content.type == QrContentType.profile && content.profile != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          fadeSlideRoute(
                            ProfileViewScreen(profile: content.profile!),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_rounded),
                      label: Text(context.tr('view_profile')),
                    ),
                  ),
                if (wifi != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton.icon(
                      onPressed: _connectingWifi ? null : _connectWifi,
                      icon: _connectingWifi
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.wifi_rounded),
                      label: Text(
                        _connectingWifi
                            ? context.tr('wifi_connecting')
                            : context.tr('connect_wifi'),
                      ),
                    ),
                  ),
                if (content.isOpenableUrl && content.imageUrl == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton.icon(
                      onPressed: _openLink,
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text(context.tr('open_link')),
                    ),
                  ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ActionChip(
                      icon: Icons.copy_rounded,
                      label: context.tr('copy'),
                      onTap: () async {
                        await QrActionService.copy(content.raw);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.tr('copied'))),
                          );
                        }
                      },
                    ),
                    _ActionChip(
                      icon: Icons.share_rounded,
                      label: context.tr('share'),
                      onTap: () => QrActionService.share(content.raw),
                    ),
                    if (content.type == QrContentType.phone)
                      _ActionChip(
                        icon: Icons.call_rounded,
                        label: context.tr('call'),
                        onTap: () => QrActionService.openContent(content),
                      ),
                    if (content.type == QrContentType.email)
                      _ActionChip(
                        icon: Icons.email_rounded,
                        label: context.tr('email'),
                        onTap: () => QrActionService.openContent(content),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WifiDetails extends StatelessWidget {
  const _WifiDetails({required this.wifi});

  final WifiQrData wifi;

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${context.tr('wifi_ssid')}: ${wifi.ssid}',
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          wifi.isOpen
              ? context.tr('wifi_open')
              : '${context.tr('wifi_password')}: ${wifi.password ?? '••••••••'}',
          style: TextStyle(color: colors.textMuted),
        ),
      ],
    );
  }
}

class _TappableContent extends StatelessWidget {
  const _TappableContent({
    required this.text,
    required this.isLink,
    this.onTap,
    this.hint,
  });

  final String text;
  final bool isLink;
  final VoidCallback? onTap;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hint != null) ...[
          Text(hint!, style: TextStyle(color: colors.accent, fontSize: 12.sp)),
          const SizedBox(height: 4),
        ],
        Text(
          text,
          style: TextStyle(
            color: isLink ? colors.accent : colors.textMuted,
            height: 1.5,
            decoration: isLink ? TextDecoration.underline : null,
            decorationColor: colors.accent.withValues(alpha: 0.6),
          ),
        ),
      ],
    );

    if (!isLink || onTap == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: child,
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => QrActionService.openUrl(url),
        borderRadius: BorderRadius.circular(22),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: colorsOf(context).surfaceLight,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    color: colorsOf(context).accent,
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: colorsOf(context).surfaceLight,
                alignment: Alignment.center,
                child: Icon(Icons.broken_image_outlined, color: colorsOf(context).textMuted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    return ActionChip(
      avatar: Icon(icon, size: 18, color: colors.accent),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: colors.surfaceLight.withValues(alpha: 0.6),
      side: BorderSide(color: colors.accent.withValues(alpha: 0.25)),
    );
  }
}
