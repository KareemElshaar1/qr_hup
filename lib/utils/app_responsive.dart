import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Design reference: iPhone 14 width.
const Size kDesignSize = Size(390, 844);

Widget appScreenUtilBuilder(Widget Function(BuildContext, Widget?) builder) {
  return ScreenUtilInit(
    designSize: kDesignSize,
    minTextAdapt: true,
    splitScreenMode: true,
    builder: builder,
  );
}

int responsiveGridCount(BuildContext context, {int mobile = 2, int tablet = 3, int desktop = 4}) {
  final width = 1.sw;
  if (width >= 900) return desktop;
  if (width >= 600) return tablet;
  return mobile;
}

double responsiveTileAspect(BuildContext context) {
  final width = 1.sw;
  if (width >= 900) return 1.15;
  if (width >= 600) return 1.08;
  return 1.02;
}

double responsiveMaxContentWidth(BuildContext context) {
  final width = 1.sw;
  if (width >= 1200) return 960;
  if (width >= 900) return 840;
  return width;
}

extension AppResponsive on num {
  double get w => ScreenUtil().setWidth(this);
  double get h => ScreenUtil().setHeight(this);
  double get sp => ScreenUtil().setSp(this);
  double get r => ScreenUtil().radius(this);
}
