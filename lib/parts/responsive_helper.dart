import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double getResponsiveWidth(BuildContext context, double value) {
    double width = MediaQuery.of(context).size.width;
    // 375 referans alınarak ölçekleme (iPhone 11 Pro)
    return value * (width / 375);
  }

  static double getResponsiveHeight(BuildContext context, double value) {
    double height = MediaQuery.of(context).size.height;
    // 812 referans alınarak ölçekleme (iPhone 11 Pro)
    return value * (height / 812);
  }

  static double getResponsiveFontSize(BuildContext context, double value) {
    double width = MediaQuery.of(context).size.width;
    return value * (width / 375);
  }
} 