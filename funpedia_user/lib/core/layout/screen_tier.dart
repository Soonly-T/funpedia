import 'package:flutter/widgets.dart';

const screenBreakpoints = [600.0, 900.0, 1200.0, 1600.0];

int tierForWidth(double width) {
  for (var i = 0; i < screenBreakpoints.length; i++) {
    if (width < screenBreakpoints[i]) return i;
  }
  return screenBreakpoints.length;
}

extension ScreenLayout on BuildContext {
  int get screenTier => tierForWidth(MediaQuery.sizeOf(this).width);
  bool get isWideScreen => screenTier >= 2;
}
