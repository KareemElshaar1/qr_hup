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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PdfQrScreen extends StatefulWidget {
  const PdfQrScreen({super.key});

  @override
  State<PdfQrScreen> createState() => _PdfQrScreenState();
}

class _PdfQrScreenState extends State<PdfQrScreen> {
  String? _filePath;
  String? _fileName;
  String? _payload;
  bool _uploading = false;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;
    setState(() {
      _filePath = file.path;
      _fileName = file.name;
      _payload = null;
    });
  }

  Future<void> _generate() async {
    if (_filePath == null) return;
    final pdfHeader = context.tr('pdf_header');
    final titlePrefix = context.tr('pdf_qr_title');
    final defaultName = context.tr('default_file');
    final uploadFailed = context.tr('upload_failed');

    setState(() => _uploading = true);
    try {
      final url = await CloudMediaService.upload(_filePath!);
      final payload = buildMediaQrPayload(
        header: pdfHeader,
        fileName: _fileName ?? 'document.pdf',
        url: url,
      );
      await HistoryService.instance.addGenerated(
        title: '$titlePrefix — ${_fileName ?? defaultName}',
        content: payload,
        category: QrRecordCategory.pdf,
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
      appBar: AppBar(title: Text(context.tr('pdf_qr_title'))),
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
                        context.tr('pdf_upload_hint'),
                        style: TextStyle(height: 1.5, fontSize: 14.sp, color: colors.textPrimary),
                      ),
                      SizedBox(height: 16.h),
                      OutlinedButton.icon(
                        onPressed: _pickPdf,
                        icon: Icon(Icons.upload_file_rounded, size: 20.sp),
                        label: Text(_fileName ?? context.tr('pick_pdf')),
                      ),
                      if (_filePath != null) ...[
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
                      title: context.tr('pdf_barcode_title'),
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
