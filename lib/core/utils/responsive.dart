import 'dart:math' as math;
import 'package:flutter/material.dart';

class R {
  R._();

  // غيّر هذا الرقم فقط لتصغير أو تكبير كل التصميم
  static const double uiScale = 0.70;

  static double width(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static double height(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  static double scale(BuildContext context) {
    final w = width(context);

    final value = w / 393;

    return value.clamp(0.88, 1.12) * uiScale;
  }

  static double sp(BuildContext context, double size) {
    return size * scale(context);
  }

  static double size(BuildContext context, double value) {
    return value * scale(context);
  }

  static double clamp(
    BuildContext context,
    double value, {
    double min = 0,
    double max = double.infinity,
  }) {
    return math.min(math.max(size(context, value), min), max);
  }
}
