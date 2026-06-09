import 'package:flutter/material.dart';

class ResponsiveSize {
  static late double screenWidth;
  static late double screenHeight;
  static late double shortestSide;
  static late double textScale;

  static const double designWidth = 375.0;
  static const double designHeight = 812.0;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    shortestSide = mediaQuery.size.shortestSide;
    
    try {
      textScale = mediaQuery.textScaler.scale(1.0);
    } catch (_) {
      // Fallback for older Flutter version compatibility
      textScale = mediaQuery.textScaleFactor;
    }
  }

  // Linear scaling factors
  static double get scaleX => screenWidth / designWidth;
  static double get scaleY => screenHeight / designHeight;
  
  // Dampened scaling factor to prevent massive sizes on tablets (iPad)
  static double get scale => screenWidth < 600 ? scaleX : (1.0 + (scaleX - 1.0) * 0.45);

  // Responsive width
  static double w(double width) => width * scale;

  // Responsive height
  static double h(double height) => height * (screenHeight < 600 ? scaleY : (1.0 + (scaleY - 1.0) * 0.45));

  // Responsive radius / border / spacing
  static double r(double radius) => radius * scale;

  // Responsive font size
  static double sp(double fontSize) => fontSize * scale;
  
  // Device helpers
  static bool get isTablet => shortestSide >= 600;
  static bool get isSmallPhone => screenWidth < 360;
}

extension ResponsiveSizeExtension on num {
  double get w => ResponsiveSize.w(toDouble());
  double get h => ResponsiveSize.h(toDouble());
  double get r => ResponsiveSize.r(toDouble());
  double get sp => ResponsiveSize.sp(toDouble());
}
