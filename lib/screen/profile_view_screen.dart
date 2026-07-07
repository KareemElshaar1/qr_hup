import 'dart:io';

import 'package:barcode_app/models/profile_data.dart';
import 'package:barcode_app/services/media_storage.dart';
import 'package:barcode_app/theme/app_theme.dart';
import 'package:barcode_app/widgets/ui_components.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({
    super.key,
    required this.profile,
    this.showBarcode = false,
  });

  final ProfileData profile;
  final bool showBarcode;

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          profile.fullName.isEmpty ? 'بيانات البروفايل' : profile.fullName,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'البيانات الشخصية'),
            Tab(text: 'وسائل التواصل'),
          ],
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              if (widget.showBarcode) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassCard(
                    child: Column(
                      children: [
                        const Text(
                          'باركود بياناتك',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: BarcodeWidget(
                            barcode: Barcode.qrCode(
                              errorCorrectLevel: BarcodeQRCorrectionLevel.high,
                            ),
                            data: profile.toBarcodePayload(),
                            width: 220,
                            height: 220,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'يمكن لأي شخص مسح هذا الباركود — البيانات والمرفقات تظهر على أي جهاز',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _PersonalTab(profile: profile),
                    _SocialTab(profile: profile),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonalTab extends StatelessWidget {
  const _PersonalTab({required this.profile});

  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (profile.mediaType != ProfileMediaType.none) ...[
          GlassCard(child: _MediaPreview(profile: profile)),
          const SizedBox(height: 16),
        ],
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoRow(label: 'الاسم الكامل', value: profile.fullName),
              _InfoRow(label: 'الوظيفة', value: profile.jobTitle),
              _InfoRow(label: 'البريد الإلكتروني', value: profile.email),
              _InfoRow(label: 'ملاحظات', value: profile.notes),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialTab extends StatelessWidget {
  const _SocialTab({required this.profile});

  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoRow(label: 'فيسبوك', value: profile.facebook),
              _InfoRow(label: 'إنستجرام', value: profile.instagram),
              _InfoRow(label: 'لينكدإن', value: profile.linkedin),
              _InfoRow(label: 'رقم التليفون', value: profile.phone),
              _InfoRow(label: 'رقم تليفون آخر', value: profile.phone2),
              _InfoRow(label: 'العنوان', value: profile.address),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.profile});

  final ProfileData profile;

  Future<void> _openRemote(BuildContext context) async {
    final url = profile.mediaUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remoteUrl = profile.mediaUrl;
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return _buildRemotePreview(context, remoteUrl);
    }

    final exists = MediaStorage.mediaExists(profile);
    if (!exists) {
      return Column(
        children: [
          Icon(
            _iconForType(profile.mediaType),
            size: 42,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 10),
          Text(
            profile.mediaFileName ?? 'ملف مرفق',
            style: const TextStyle(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'الملف غير متاح — أنشئ باركود جديد مع اتصال إنترنت',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return _buildLocalPreview();
  }

  Widget _buildRemotePreview(BuildContext context, String url) {
    if (profile.mediaType == ProfileMediaType.image || _looksLikeImage(url)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              url,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 220,
                  alignment: Alignment.center,
                  color: AppColors.surfaceLight,
                  child: const CircularProgressIndicator(
                    color: AppColors.accent,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  _remoteFallback(context, url),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _openRemote(context),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('فتح الصورة'),
          ),
        ],
      );
    }

    return _remoteFallback(context, url);
  }

  Widget _remoteFallback(BuildContext context, String url) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            profile.mediaType == ProfileMediaType.video
                ? Icons.videocam_rounded
                : Icons.insert_drive_file_rounded,
            color: AppColors.accent,
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            profile.mediaFileName ?? 'مرفق سحابي',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _openRemote(context),
            icon: const Icon(Icons.cloud_download_rounded),
            label: Text(
              profile.mediaType == ProfileMediaType.video
                  ? 'فتح الفيديو'
                  : 'فتح الملف',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalPreview() {
    switch (profile.mediaType) {
      case ProfileMediaType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(profile.mediaPath!),
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      case ProfileMediaType.video:
      case ProfileMediaType.file:
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  profile.mediaType == ProfileMediaType.video
                      ? Icons.videocam_rounded
                      : Icons.insert_drive_file_rounded,
                  color: AppColors.accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.mediaFileName ?? 'ملف مرفق',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.mediaType == ProfileMediaType.video
                          ? 'فيديو محفوظ على الجهاز'
                          : 'ملف محفوظ على الجهاز',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case ProfileMediaType.none:
        return const SizedBox.shrink();
    }
  }

  bool _looksLikeImage(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  IconData _iconForType(ProfileMediaType type) {
    switch (type) {
      case ProfileMediaType.image:
        return Icons.image_not_supported_outlined;
      case ProfileMediaType.video:
        return Icons.videocam_off_outlined;
      case ProfileMediaType.file:
        return Icons.insert_drive_file_outlined;
      case ProfileMediaType.none:
        return Icons.block;
    }
  }
}
