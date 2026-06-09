import 'package:flutter/material.dart';
import 'responsive_size.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
  });

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide < 600;
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive sizes for scaling
    ResponsiveSize.init(context);

    if (isTablet(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}
