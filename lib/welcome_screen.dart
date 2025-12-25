import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String selectedLanguage = 'en'; // Default to English

  final List<Map<String, String>> languages = [
    {'code': 'id', 'name': 'Bahasa Indonesia'},
    {'code': 'en', 'name': 'English'},
    {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'fr', 'name': 'Français'},
  ];

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
          color: const Color(0xFFF6F8F6), // background-light
        ),
        child: Stack(
          children: [
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
                        const Text(
                          'welcome_title',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ).tr(),
                        const SizedBox(height: 16),
                        const Text(
                          'welcome_description',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
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
                          const Text(
                            'select_language',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ).tr(),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButton<String>(
                              value: selectedLanguage,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: languages.map((lang) {
                                return DropdownMenuItem(
                                  value: lang['code'],
                                  child: Text(lang['name']!),
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
                            const Text(
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
                      const Text(
                        'version',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
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

// Placeholder for HomeScreen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran App'),
      ),
      body: const Center(
        child: Text('Home Screen'),
      ),
    );
  }
}