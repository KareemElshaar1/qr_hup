import 'dart:io';

import 'package:barcode_app/l10n/app_strings.dart';
import 'package:barcode_app/models/profile_data.dart';
import 'package:barcode_app/services/media_storage.dart';
import 'package:barcode_app/theme/app_theme.dart';
import 'package:barcode_app/utils/app_responsive.dart';
import 'package:barcode_app/widgets/responsive_layout.dart';
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

    final colors = colorsOf(context);

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: Text(
          profile.fullName.isEmpty
              ? context.tr('profile_view_title')
              : profile.fullName,
        ),

        bottom: TabBar(
          controller: _tabController,

          indicatorColor: colors.accent,

          labelColor: colors.accent,

          unselectedLabelColor: colors.textMuted,

          tabs: [
            Tab(text: context.tr('personal_tab')),

            Tab(text: context.tr('social_tab')),
          ],
        ),
      ),

      body: GradientBackground(
        child: SafeArea(
          child: ResponsiveLayout(
            padding: EdgeInsets.zero,

            child: Column(
              children: [
                if (widget.showBarcode) ...[
                  SizedBox(height: 8.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),

                    child: GlassCard(
                      child: Column(
                        children: [
                          Text(
                            context.tr('your_barcode'),

                            style: TextStyle(
                              color: colors.textPrimary,

                              fontWeight: FontWeight.w700,

                              fontSize: 16.sp,
                            ),
                          ),

                          SizedBox(height: 14.h),

                          Container(
                            padding: EdgeInsets.all(14.w),

                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius: BorderRadius.circular(16.r),
                            ),

                            child: BarcodeWidget(
                              barcode: Barcode.qrCode(
                                errorCorrectLevel:
                                    BarcodeQRCorrectionLevel.high,
                              ),

                              data: profile.toBarcodePayload(),

                              width: 220.w,

                              height: 220.w,
                            ),
                          ),

                          SizedBox(height: 10.h),

                          Text(
                            context.tr('barcode_share_hint'),

                            style: TextStyle(
                              color: colors.textMuted,

                              fontSize: 12.sp,
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
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),

      children: [
        if (profile.mediaType != ProfileMediaType.none) ...[
          GlassCard(child: _MediaPreview(profile: profile)),

          SizedBox(height: 16.h),
        ],

        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              _InfoRow(label: context.tr('full_name'), value: profile.fullName),

              _InfoRow(label: context.tr('job_title'), value: profile.jobTitle),

              _InfoRow(label: context.tr('email_label'), value: profile.email),

              _InfoRow(label: context.tr('notes_label'), value: profile.notes),
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
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),

      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              _InfoRow(label: context.tr('facebook'), value: profile.facebook),

              _InfoRow(
                label: context.tr('instagram'),
                value: profile.instagram,
              ),
              _InfoRow(label: context.tr('whatsapp'), value: profile.whatsapp),
              _InfoRow(label: context.tr('telegram'), value: profile.telegram),
              _InfoRow(label: context.tr('twitter'), value: profile.twitter),
              _InfoRow(label: context.tr('youtube'), value: profile.youtube),
              _InfoRow(label: context.tr('tiktok'), value: profile.tiktok),

              _InfoRow(label: context.tr('linkedin'), value: profile.linkedin),

              _InfoRow(label: context.tr('phone_label'), value: profile.phone),

              _InfoRow(
                label: context.tr('phone2_label'),
                value: profile.phone2,
              ),

              _InfoRow(
                label: context.tr('address_label'),
                value: profile.address,
              ),
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

    final colors = colorsOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            label,

            style: TextStyle(color: colors.textMuted, fontSize: 13.sp),
          ),

          SizedBox(height: 4.h),

          Text(
            value,

            style: TextStyle(
              color: colors.textPrimary,

              fontSize: 16.sp,

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
        ).showSnackBar(SnackBar(content: Text(context.tr('link_open_failed'))));
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
      final colors = colorsOf(context);

      return Column(
        children: [
          Icon(
            _iconForType(profile.mediaType),

            size: 42.sp,

            color: colors.textMuted,
          ),

          SizedBox(height: 10.h),

          Text(
            profile.mediaFileName ?? context.tr('attached_file'),

            style: TextStyle(color: colors.textPrimary, fontSize: 14.sp),

            textAlign: TextAlign.center,
          ),

          SizedBox(height: 6.h),

          Text(
            context.tr('media_unavailable'),

            style: TextStyle(color: colors.textMuted, fontSize: 13.sp),

            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return _buildLocalPreview(context);
  }

  Widget _buildRemotePreview(BuildContext context, String url) {
    final colors = colorsOf(context);

    if (profile.mediaType == ProfileMediaType.image || _looksLikeImage(url)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),

            child: Image.network(
              url,

              height: 220.h,

              width: double.infinity,

              fit: BoxFit.cover,

              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return Container(
                  height: 220.h,

                  alignment: Alignment.center,

                  color: colors.surfaceLight,

                  child: CircularProgressIndicator(color: colors.accent),
                );
              },

              errorBuilder: (context, error, stackTrace) =>
                  _remoteFallback(context, url),
            ),
          ),

          SizedBox(height: 10.h),

          OutlinedButton.icon(
            onPressed: () => _openRemote(context),

            icon: Icon(Icons.open_in_new_rounded, size: 18.sp),

            label: Text(context.tr('open_image')),
          ),
        ],
      );
    }

    return _remoteFallback(context, url);
  }

  Widget _remoteFallback(BuildContext context, String url) {
    final colors = colorsOf(context);

    return Container(
      padding: EdgeInsets.all(18.w),

      decoration: BoxDecoration(
        color: colors.surfaceLight.withValues(alpha: 0.55),

        borderRadius: BorderRadius.circular(16.r),
      ),

      child: Column(
        children: [
          Icon(
            profile.mediaType == ProfileMediaType.video
                ? Icons.videocam_rounded
                : Icons.insert_drive_file_rounded,

            color: colors.accent,

            size: 36.sp,
          ),

          SizedBox(height: 10.h),

          Text(
            profile.mediaFileName ?? context.tr('cloud_attachment'),

            style: TextStyle(
              color: colors.textPrimary,

              fontWeight: FontWeight.w700,

              fontSize: 14.sp,
            ),

            textAlign: TextAlign.center,
          ),

          SizedBox(height: 12.h),

          ElevatedButton.icon(
            onPressed: () => _openRemote(context),

            icon: Icon(Icons.cloud_download_rounded, size: 18.sp),

            label: Text(
              profile.mediaType == ProfileMediaType.video
                  ? context.tr('open_video')
                  : context.tr('open_file'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalPreview(BuildContext context) {
    final colors = colorsOf(context);

    switch (profile.mediaType) {
      case ProfileMediaType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.r),

          child: Image.file(
            File(profile.mediaPath!),

            height: 220.h,

            width: double.infinity,

            fit: BoxFit.cover,
          ),
        );

      case ProfileMediaType.video:
      case ProfileMediaType.file:
        return Container(
          padding: EdgeInsets.all(18.w),

          decoration: BoxDecoration(
            color: colors.surfaceLight.withValues(alpha: 0.55),

            borderRadius: BorderRadius.circular(16.r),
          ),

          child: Row(
            children: [
              Container(
                width: 56.w,

                height: 56.w,

                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.15),

                  borderRadius: BorderRadius.circular(14.r),
                ),

                child: Icon(
                  profile.mediaType == ProfileMediaType.video
                      ? Icons.videocam_rounded
                      : Icons.insert_drive_file_rounded,

                  color: colors.accent,

                  size: 28.sp,
                ),
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      profile.mediaFileName ?? context.tr('attached_file'),

                      style: TextStyle(
                        color: colors.textPrimary,

                        fontWeight: FontWeight.w700,

                        fontSize: 14.sp,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      profile.mediaType == ProfileMediaType.video
                          ? context.tr('video_saved_local')
                          : context.tr('file_saved_local'),

                      style: TextStyle(
                        color: colors.textMuted,

                        fontSize: 13.sp,
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
