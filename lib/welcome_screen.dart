import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class PatternPainter extends CustomPainter {
  final double animationValue;

  PatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CE619).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    const double radius = 1.0;
    const double spacing = 32.0;

    // Calculate offset based on animation
    final double offset = animationValue * spacing;

    for (double x = -offset; x < size.width + spacing; x += spacing) {
      for (double y = -offset; y < size.height + spacing; y += spacing) {
        // Add diagonal movement
        final double adjustedX = x + (animationValue * spacing * 0.5);
        final double adjustedY = y + (animationValue * spacing * 0.5);
        canvas.drawCircle(Offset(adjustedX, adjustedY), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(PatternPainter oldDelegate) => oldDelegate.animationValue != animationValue;
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  String selectedLanguage = 'en'; // Default to English

  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Map<String, String>> languages = [
    {'code': 'id', 'name': 'Bahasa Indonesia'},
    {'code': 'en', 'name': 'English'},
    {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'ar', 'name': 'العربية'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load selected language from current locale
    selectedLanguage = context.locale.languageCode;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    if (mounted) {
      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF152111), // background-dark
        ),
        child: Stack(
          children: [
            // Background Pattern
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned.fill(
                  child: CustomPaint(
                    painter: PatternPainter(_animation.value),
                  ),
                );
              },
            ),
            // Decorative Glow
            Positioned(
              top: -MediaQuery.of(context).size.height * 0.1,
              left: MediaQuery.of(context).size.width / 2 - 150,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CE619).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            // Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Section
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E261C), // surface-dark
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF42533C)), // border-dark
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CE619).withValues(alpha: 0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.menu_book,
                            size: 64,
                            color: Color(0xFF4CE619), // primary
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Text
                        Text(
                          'welcome_title',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).tr(),
                        const SizedBox(height: 16),
                        Text(
                          'welcome_description',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ).tr(),
                      ],
                    ),
                  ),
                  // Bottom Section
                  Column(
                    children: [
                      // Language Selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'select_language',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ).tr(),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E261C), // surface-dark
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF42533C)), // border-dark
                            ),
                            child: DropdownButton<String>(
                              value: selectedLanguage,
                              isExpanded: true,
                              underline: const SizedBox(),
                              dropdownColor: const Color(0xFF1E261C), // surface-dark
                              style: const TextStyle(
                                color: Colors.white, // text color for selected item
                                fontSize: 16,
                              ),
                              items: languages.map((lang) {
                                return DropdownMenuItem(
                                  value: lang['code'],
                                  child: Text(
                                    lang['name']!,
                                    style: const TextStyle(color: Colors.white), // text color for items
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedLanguage = value!;
                                });
                                context.setLocale(Locale(value!));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Action Button
                      ElevatedButton(
                        onPressed: _startApp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CE619), // primary
                          foregroundColor: const Color(0xFF152111), // background-dark
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: const Color(0xFF4CE619).withValues(alpha: 0.3),
                          elevation: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'start_now',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ).tr(),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'version',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ).tr(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}