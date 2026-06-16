import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  // Reference: iPhone 11 Pro Max (414 × 896)
  static const double _refWidth = 414;
  static const double _refHeight = 896;

  static double scaleWidth(BuildContext context) =>
      MediaQuery.of(context).size.width / _refWidth;

  static double scaleHeight(BuildContext context) =>
      MediaQuery.of(context).size.height / _refHeight;

  static double scaleMin(BuildContext context) =>
      scaleWidth(context) < scaleHeight(context)
          ? scaleWidth(context)
          : scaleHeight(context);

  static double sp(BuildContext context, double size) =>
      size * scaleMin(context);

  static double w(BuildContext context, double size) =>
      size * scaleWidth(context);

  static double h(BuildContext context, double size) =>
      size * scaleHeight(context);
}
