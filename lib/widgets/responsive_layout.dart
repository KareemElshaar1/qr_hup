import 'package:barcode_app/utils/app_responsive.dart';
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: responsiveMaxContentWidth(context)),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: 20.w),
          child: child,
        ),
      ),
    );
  }
}
