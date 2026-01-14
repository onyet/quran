import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 20.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // Total duration
    if (!mounted) return;

    final navigator = Navigator.of(context);

    if (kDebugMode) {
      // In debug mode, always show welcome screen
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } else {
      // In production, check if first time
      final isFirstTime = await _isFirstTime();
      if (isFirstTime) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      } else {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  Future<bool> _isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first_time') ?? true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF152111), // background-dark
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF152111)),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E261C), // surface-dark
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF42533C),
                      ), // border-dark
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CE619).withValues(alpha: 0.3),
                          blurRadius: _glowAnimation.value,
                          spreadRadius: _glowAnimation.value * 0.5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      size: 64,
                      color: Color(0xFF4CE619), // primary
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
