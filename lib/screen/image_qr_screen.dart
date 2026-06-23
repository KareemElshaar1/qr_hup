import 'dart:io';

import 'package:barcode_app/l10n/app_strings.dart';
import 'package:barcode_app/models/qr_record.dart';
import 'package:barcode_app/services/cloud_media_service.dart';
import 'package:barcode_app/services/history_service.dart';
import 'package:barcode_app/theme/app_theme.dart';
import 'package:barcode_app/utils/app_responsive.dart';
import 'package:barcode_app/utils/media_qr_payload.dart';
import 'package:barcode_app/widgets/qr_preview_card.dart';
import 'package:barcode_app/widgets/responsive_layout.dart';
import 'package:barcode_app/widgets/ui_components.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageQrScreen extends StatefulWidget {
  const ImageQrScreen({super.key});

  @override
  State<ImageQrScreen> createState() => _ImageQrScreenState();
}

class _ImageQrScreenState extends State<ImageQrScreen> {
  String? _filePath;
  String? _fileName;
  String? _payload;
  bool _uploading = false;

  Future<void> _pickImage() async {
    final cropTitle = context.tr('crop_image');
    final colors = colorsOf(context);

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: cropTitle,
          toolbarColor: colors.surface,
          toolbarWidgetColor: colors.textPrimary,
          activeControlsWidgetColor: colors.accent,
        ),
        IOSUiSettings(title: cropTitle),
      ],
    );
    if (cropped == null || !mounted) return;

    setState(() {
      _filePath = cropped.path;
      _fileName = cropped.path.split(Platform.pathSeparator).last;
      _payload = null;
    });
  }

  Future<void> _generate() async {
    if (_filePath == null) return;
    final imageHeader = context.tr('image_header');
    final titlePrefix = context.tr('image_qr_title');
    final defaultName = context.tr('default_image');
    final uploadFailed = context.tr('image_upload_failed');

    setState(() => _uploading = true);
    try {
      final url = await CloudMediaService.upload(_filePath!);
      final payload = buildMediaQrPayload(
        header: imageHeader,
        fileName: _fileName ?? 'image.jpg',
        url: url,
      );
      await HistoryService.instance.addGenerated(
        title: '$titlePrefix — ${_fileName ?? defaultName}',
        content: payload,
        category: QrRecordCategory.image,
        previewUrl: url,
      );
      if (mounted) setState(() => _payload = payload);
    } on CloudMediaException catch (e) {
      if (mounted) _show(e.message);
    } catch (_) {
      if (mounted) _show(uploadFailed);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(context.tr('image_qr_title'))),
      body: GradientBackground(
        child: SafeArea(
          child: ResponsiveLayout(
            child: ListView(
              padding: EdgeInsets.all(20.w),
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.tr('image_upload_hint'),
                        style: TextStyle(height: 1.5, fontSize: 14.sp, color: colors.textPrimary),
                      ),
                      SizedBox(height: 16.h),
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.add_photo_alternate_rounded, size: 20.sp),
                        label: Text(context.tr('pick_image')),
                      ),
                      if (_filePath != null) ...[
                        SizedBox(height: 14.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.file(
                            File(_filePath!),
                            height: 200.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ElevatedButton.icon(
                          onPressed: _uploading ? null : _generate,
                          icon: _uploading
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(Icons.qr_code_2_rounded, size: 20.sp),
                          label: Text(
                            _uploading ? context.tr('uploading') : context.tr('create_qr'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_payload != null) ...[
                  SizedBox(height: 20.h),
                  GlassCard(
                    child: QrPreviewCard(
                      data: _payload!,
                      title: context.tr('image_barcode_title'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
