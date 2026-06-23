import 'package:barcode_app/l10n/app_strings.dart';
import 'package:barcode_app/models/qr_content.dart';
import 'package:barcode_app/screen/scan_result_screen.dart';
import 'package:barcode_app/services/history_service.dart';
import 'package:barcode_app/services/qr_content_detector.dart';
import 'package:barcode_app/theme/app_theme.dart';
import 'package:barcode_app/utils/app_responsive.dart';
import 'package:barcode_app/widgets/ui_components.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;
  bool _analyzingGallery = false;
  bool _torchOn = false;

  Future<void> _processScan(String value) async {
    if (_handled || !mounted) return;
    _handled = true;

    final content = QrContentDetector.analyze(value);
    final record = await HistoryService.instance.addScanned(content);

    if (!mounted) return;

    if (content.imageUrl != null || content.type == QrContentType.profile) {
      await Navigator.pushReplacement(
        context,
        fadeSlideRoute(
          ScanResultScreen(
            content: content,
            recordId: record.id,
            autoOpenLink: content.imageUrl == null,
          ),
        ),
      );
      return;
    }

    await Navigator.pushReplacement(
      context,
      fadeSlideRoute(
        ScanResultScreen(content: content, recordId: record.id),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;
    _processScan(value);
  }

  Future<void> _pickFromGallery() async {
    if (_analyzingGallery || _handled) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;

    setState(() => _analyzingGallery = true);
    try {
      final capture = await _controller.analyzeImage(image.path);
      if (!mounted) return;
      if (capture == null || capture.barcodes.isEmpty) {
        _showMessage(context.tr('no_qr_in_image'));
        return;
      }
      final value = capture.barcodes.first.rawValue;
      if (value == null || value.isEmpty) {
        _showMessage(context.tr('read_failed'));
        return;
      }
      await _processScan(value);
    } catch (_) {
      if (mounted) _showMessage(context.tr('read_error'));
    } finally {
      if (mounted) setState(() => _analyzingGallery = false);
    }
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    if (mounted) setState(() => _torchOn = !_torchOn);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(context.tr('scan_qr')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _toggleTorch,
            icon: Icon(_torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
          ),
          IconButton(
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch_rounded),
          ),
          IconButton(
            onPressed: _analyzingGallery ? null : _pickFromGallery,
            icon: _analyzingGallery
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.photo_library_rounded),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.65),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
          Center(
            child: AnimatedScanFrame(width: 280.w, height: 280.w, detected: false),
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 28.h,
            child: Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Text(
                context.tr('scan_hint'),
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
