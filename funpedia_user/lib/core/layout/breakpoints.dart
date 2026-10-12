import 'package:flutter/widgets.dart';

const wideScreenMinWidth = 900.0;

extension ScreenLayout on BuildContext {
  bool get isWideScreen => MediaQuery.sizeOf(this).width >= wideScreenMinWidth;
}
