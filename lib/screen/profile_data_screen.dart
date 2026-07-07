import 'dart:io';

import 'package:barcode_app/l10n/app_strings.dart';
import 'package:barcode_app/models/profile_data.dart';
import 'package:barcode_app/screen/profile_view_screen.dart';
import 'package:barcode_app/services/cloud_media_service.dart';
import 'package:barcode_app/services/profile_publish_service.dart';
import 'package:barcode_app/theme/app_theme.dart';
import 'package:barcode_app/utils/app_responsive.dart';
import 'package:barcode_app/widgets/responsive_layout.dart';
import 'package:barcode_app/widgets/ui_components.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileDataScreen extends StatefulWidget {
  const ProfileDataScreen({super.key});

  @override
  State<ProfileDataScreen> createState() => _ProfileDataScreenState();
}

class _ProfileDataScreenState extends State<ProfileDataScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _fullName = TextEditingController();
  final _jobTitle = TextEditingController();
  final _email = TextEditingController();
  final _notes = TextEditingController();
  final _facebook = TextEditingController();
  final _linkedin = TextEditingController();
  final _instagram = TextEditingController();
  final _phone = TextEditingController();
  final _phone2 = TextEditingController();
  final _address = TextEditingController();
  final _whatsapp = TextEditingController();
  final _telegram = TextEditingController();
  final _twitter = TextEditingController();
  final _youtube = TextEditingController();
  final _tiktok = TextEditingController();

  ProfileMediaType _mediaType = ProfileMediaType.none;
  String? _mediaPath;
  String? _mediaFileName;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullName.dispose();
    _jobTitle.dispose();
    _email.dispose();
    _notes.dispose();
    _facebook.dispose();
    _linkedin.dispose();
    _instagram.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    _telegram.dispose();
    _twitter.dispose();
    _youtube.dispose();
    _tiktok.dispose();
    _phone2.dispose();
    _address.dispose();
    super.dispose();
  }

  ProfileData _buildProfile() {
    return ProfileData(
      fullName: _fullName.text.trim(),
      whatsapp: _whatsapp.text.trim(),
      telegram: _telegram.text.trim(),
      twitter: _twitter.text.trim(),
      youtube: _youtube.text.trim(),
      tiktok: _tiktok.text.trim(),
      jobTitle: _jobTitle.text.trim(),
      email: _email.text.trim(),
      notes: _notes.text.trim(),
      facebook: _facebook.text.trim(),
      linkedin: _linkedin.text.trim(),
      instagram: _instagram.text.trim(),
      phone: _phone.text.trim(),
      phone2: _phone2.text.trim(),
      address: _address.text.trim(),
      mediaType: _mediaType,
      mediaPath: _mediaPath,
      mediaFileName: _mediaFileName,
    );
  }

  Future<String?> _cropImage(String sourcePath) async {
    final colors = colorsOf(context);
    final cropped = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: context.tr('crop_image'),
          toolbarColor: colors.surface,
          toolbarWidgetColor: colors.textPrimary,
          activeControlsWidgetColor: colors.accent,
          backgroundColor: colors.backgroundTop,
          dimmedLayerColor: colors.backgroundTop,
          cropFrameColor: colors.accent,
          cropGridColor: colors.surfaceLight,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: context.tr('crop_image'),
          cancelButtonTitle: context.tr('cancel'),
          doneButtonTitle: context.tr('done'),
          aspectRatioLockEnabled: false,
          resetAspectRatioEnabled: true,
          aspectRatioPickerButtonHidden: false,
        ),
      ],
    );
    return cropped?.path;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final croppedPath = await _cropImage(file.path);
    if (croppedPath == null) return;

    setState(() {
      _mediaType = ProfileMediaType.image;
      _mediaPath = croppedPath;
      _mediaFileName = croppedPath.split('/').last;
    });
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _mediaType = ProfileMediaType.video;
      _mediaPath = file.path;
      _mediaFileName = file.name;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;
    setState(() {
      _mediaType = ProfileMediaType.file;
      _mediaPath = file.path;
      _mediaFileName = file.name;
    });
  }

  void _clearMedia() {
    setState(() {
      _mediaType = ProfileMediaType.none;
      _mediaPath = null;
      _mediaFileName = null;
    });
  }

  Future<void> _createBarcode() async {
    final profile = _buildProfile();
    if (profile.isEmpty) {
      _showMessage(context.tr('enter_data_first'));
      return;
    }

    setState(() => _saving = true);
    try {
      final published = await ProfilePublishService.publish(profile);
      if (!mounted) return;
      await Navigator.push<void>(
        context,
        fadeSlideRoute(
          ProfileViewScreen(profile: published, showBarcode: true),
        ),
      );
    } on CloudMediaException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (_) {
      if (mounted) {
        _showMessage(context.tr('upload_error'));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(context.tr('profile_data_title')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.accent,
          labelColor: colors.accent,
          unselectedLabelColor: colors.textMuted,
          tabs: [
            Tab(
              icon: const Icon(Icons.person_rounded),
              text: context.tr('tab_personal'),
            ),
            Tab(
              icon: const Icon(Icons.share_rounded),
              text: context.tr('tab_social'),
            ),
          ],
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: ResponsiveLayout(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _PersonalTab(
                        fullName: _fullName,
                        jobTitle: _jobTitle,
                        email: _email,
                        notes: _notes,
                        mediaType: _mediaType,
                        mediaPath: _mediaPath,
                        mediaFileName: _mediaFileName,
                        onPickImage: _pickImage,
                        onPickVideo: _pickVideo,
                        onPickFile: _pickFile,
                        onClearMedia: _clearMedia,
                      ),
                      _SocialTab(
                        whatsapp: _whatsapp,
                        telegram: _telegram,
                        twitter: _twitter,
                        youtube: _youtube,
                        tiktok: _tiktok,
                        facebook: _facebook,
                        linkedin: _linkedin,
                        instagram: _instagram,
                        phone: _phone,
                        phone2: _phone2,
                        address: _address,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _createBarcode,
                    icon: _saving
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.qr_code_2_rounded),
                    label: Text(
                      _saving
                          ? context.tr('saving_upload')
                          : context.tr('save_create_qr'),
                    ),
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
  const _PersonalTab({
    required this.fullName,
    required this.jobTitle,
    required this.email,
    required this.notes,
    required this.mediaType,
    required this.mediaPath,
    required this.mediaFileName,
    required this.onPickImage,
    required this.onPickVideo,
    required this.onPickFile,
    required this.onClearMedia,
  });

  final TextEditingController fullName;
  final TextEditingController jobTitle;
  final TextEditingController email;
  final TextEditingController notes;
  final ProfileMediaType mediaType;
  final String? mediaPath;
  final String? mediaFileName;
  final VoidCallback onPickImage;
  final VoidCallback onPickVideo;
  final VoidCallback onPickFile;
  final VoidCallback onClearMedia;

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Field(
                controller: fullName,
                label: context.tr('full_name'),
                icon: Icons.badge_rounded,
              ),
              SizedBox(height: 12.h),
              _Field(
                controller: jobTitle,
                label: context.tr('job_title'),
                icon: Icons.work_rounded,
              ),
              SizedBox(height: 12.h),
              _Field(
                controller: email,
                label: context.tr('email_label'),
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12.h),
              _Field(
                controller: notes,
                label: context.tr('notes_label'),
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('upload_media'),
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                context.tr('upload_media_hint'),
                style: TextStyle(color: colors.textMuted, fontSize: 13.sp),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  _MediaChip(
                    icon: Icons.image_rounded,
                    label: context.tr('photo'),
                    onTap: onPickImage,
                  ),
                  _MediaChip(
                    icon: Icons.videocam_rounded,
                    label: context.tr('video'),
                    onTap: onPickVideo,
                  ),
                  _MediaChip(
                    icon: Icons.attach_file_rounded,
                    label: context.tr('file'),
                    onTap: onPickFile,
                  ),
                ],
              ),
              if (mediaType != ProfileMediaType.none) ...[
                const SizedBox(height: 16),
                _SelectedMediaPreview(
                  mediaType: mediaType,
                  mediaPath: mediaPath,
                  mediaFileName: mediaFileName,
                  onClear: onClearMedia,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialTab extends StatelessWidget {
  const _SocialTab({
    required this.facebook,
    required this.linkedin,
    required this.instagram,
    required this.phone,
    required this.phone2,
    required this.address,
    required this.whatsapp,
    required this.telegram,
    required this.twitter,
    required this.youtube,
    required this.tiktok,
  });

  final TextEditingController facebook;
  final TextEditingController linkedin;
  final TextEditingController instagram;
  final TextEditingController phone;
  final TextEditingController phone2;
  final TextEditingController address;
  final TextEditingController whatsapp;
  final TextEditingController telegram;
  final TextEditingController twitter;
  final TextEditingController youtube;
  final TextEditingController tiktok;

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('social_title'),
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 14.h),
              _Field(
                controller: facebook,
                label: context.tr('facebook'),
                icon: Image.asset(
                  'assets/icons/facebook.png',
                  width: 20.w,
                  height: 20.w,
                ),
              ),

              SizedBox(height: 12.h),
              _Field(
                controller: whatsapp,
                label: context.tr('whatsapp'),
                icon: Image.asset(
                  'assets/icons/whatsapp.png',
                  width: 20.w,
                  height: 20.w,
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12.h),
              _Field(
                controller: tiktok,
                label: context.tr('tiktok'),
                icon: Image.asset(
                  'assets/icons/tiktok.png',
                  width: 20.w,
                  height: 20.w,
                ),
              ),
              SizedBox(height: 12.h),
              _Field(
                controller: telegram,
                label: context.tr('telegram'),
                icon: Image.asset(
                  'assets/icons/telegram.png',
                  width: 20.w,
                  height: 20.w,
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12.h),
              _Field(
                controller: twitter,
                label: context.tr('twitter'),
                icon: Image.asset(
                  'assets/icons/twitter.png',
                  width: 20.w,
                  height: 20.w,
                ),
              ),
              SizedBox(height: 12.h),
              _Field(
                controller: youtube,
                label: context.tr('youtube'),
                icon: Image.asset(
                  'assets/icons/youtube.png',
                  width: 20.w,
                  height: 20.w,
                ),
              ),
              SizedBox(height: 12.h),

              _Field(
                controller: instagram,
                label: context.tr('instagram'),
                icon: Image.asset(
                  'assets/icons/instgram.png',
                  width: 20.w,
                  height: 20.w,
                ),
              ),
              SizedBox(height: 12.h),
              _Field(
                controller: linkedin,
                label: context.tr('linkedin'),
                icon: Image.asset(
                  'assets/icons/linkedin.png',
                  width: 20.w,
                  height: 20.w,
                ),
              ),
              SizedBox(height: 12.h),
              _Field(
                controller: phone,
                label: context.tr('phone_label'),
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12.h),
              _Field(
                controller: phone2,
                label: context.tr('phone2_label'),
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12.h),
              _Field(
                controller: address,
                label: context.tr('address_label'),
                icon: Icons.location_on_rounded,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final Object icon; // ← غيّرناها من IconData إلى Object
  final int maxLines;
  final TextInputType? keyboardType;

  Widget _buildIcon(BuildContext context) {
    final colors = colorsOf(context);
    if (icon is IconData) {
      return Icon(icon as IconData, color: colors.accent);
    }
    return icon as Widget;
  }

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: colors.textPrimary, fontSize: 14.sp),
      cursorColor: colors.accent,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: EdgeInsets.all(12.w),
          child: _buildIcon(context),
        ),
      ),
    );
  }
}

class _MediaChip extends StatelessWidget {
  const _MediaChip({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: colors.surfaceLight.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: colors.accent.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.accent, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(color: colors.textPrimary, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedMediaPreview extends StatelessWidget {
  const _SelectedMediaPreview({
    required this.mediaType,
    required this.mediaPath,
    required this.mediaFileName,
    required this.onClear,
  });

  final ProfileMediaType mediaType;
  final String? mediaPath;
  final String? mediaFileName;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.surfaceLight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mediaType == ProfileMediaType.image && mediaPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(
                File(mediaPath!),
                height: 160.h,
                fit: BoxFit.cover,
              ),
            )
          else
            Row(
              children: [
                Icon(
                  mediaType == ProfileMediaType.video
                      ? Icons.videocam_rounded
                      : Icons.insert_drive_file_rounded,
                  color: colors.accent,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    mediaFileName ?? context.tr('selected_file'),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 10.h),
          OutlinedButton.icon(
            onPressed: onClear,
            icon: Icon(Icons.close_rounded, size: 18.sp),
            label: Text(context.tr('remove_file')),
          ),
        ],
      ),
    );
  }
}
