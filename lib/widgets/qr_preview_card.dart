import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:barcode_app/l10n/app_strings.dart';
import 'package:barcode_app/services/qr_action_service.dart';
import 'package:barcode_app/theme/app_theme.dart';
import 'package:barcode_app/utils/app_responsive.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class QrPreviewCard extends StatefulWidget {
  const QrPreviewCard({
    super.key,
    required this.data,
    this.title,
    this.showActions = true,
  });

  final String data;
  final String? title;
  final bool showActions;

  @override
  State<QrPreviewCard> createState() => _QrPreviewCardState();
}

class _QrPreviewCardState extends State<QrPreviewCard> {
  final _key = GlobalKey();

  Future<Uint8List?> _capture() async {
    final boundary = _key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    if (widget.data.trim().isEmpty) {
      return Container(
        height: 260.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          context.tr('qr_preview_empty'),
          style: TextStyle(color: colors.textMuted, fontSize: 14.sp),
        ),
      );
    }

    return Column(
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
        ],
        RepaintBoundary(
          key: _key,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: BarcodeWidget(
              barcode: Barcode.qrCode(
                errorCorrectLevel: BarcodeQRCorrectionLevel.high,
              ),
              data: widget.data,
              width: 220,
              height: 220,
            ),
          ),
        ),
        if (widget.showActions) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final bytes = await _capture();
                    if (bytes == null || !context.mounted) return;
                    await QrActionService.saveBytesToGallery(bytes);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr('saved_to_gallery'))),
                      );
                    }
                  },
                  icon: Icon(Icons.download_rounded, size: 18.sp),
                  label: Text(context.tr('save')),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => QrActionService.share(widget.data, subject: 'QR Code'),
                  icon: Icon(Icons.share_rounded, size: 18.sp),
                  label: Text(context.tr('share')),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
