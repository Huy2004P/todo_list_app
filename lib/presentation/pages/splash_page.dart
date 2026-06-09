import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/presentation/pages/main_navigation_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Điều hướng sang MainNavigationPage sau 2.5 giây
    Timer(const Duration(milliseconds: 2500), _navigateToHome);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Premium Apple-style Transition: Fade & Scale
          var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.easeInOutCubic),
          );
          var scaleTween = Tween<double>(begin: 0.96, end: 1.0).chain(
            CurveTween(curve: Curves.easeInOutCubic),
          );

          return FadeTransition(
            opacity: animation.drive(fadeTween),
            child: ScaleTransition(
              scale: animation.drive(scaleTween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 850),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Màu sắc theo Apple Design Guidelines
    final backgroundColor = isDark ? const Color(0xFF1D1D1F) : const Color(0xFFFFFFFF);
    final primaryTextColor = isDark ? const Color(0xFFF5F5F7) : const Color(0xFF1D1D1F);
    final secondaryTextColor = isDark ? const Color(0xFF86868B) : const Color(0xFF86868B);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Animation
                FadeTransition(
                  opacity: _logoOpacity,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0066CC), // Action Blue
                            Color(0xFF5E5CE6), // Action Purple
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.checkmark_alt,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Text & Tagline Animation
                FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        Text(
                          'TaskFlow',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đơn giản. Hiệu quả. Tập trung.',
                          style: TextStyle(
                            fontFamily: 'SF Pro Text',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Loading Indicator ở cạnh dưới
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _textOpacity,
                child: CupertinoActivityIndicator(
                  color: secondaryTextColor,
                  radius: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
