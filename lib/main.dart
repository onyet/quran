import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('id'), Locale('tr'), Locale('fr'), Locale('ar')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark
  // final DatabaseHelper _dbHelper = DatabaseHelper(); // Temporarily disabled for debugging

  @override
  void initState() {
    super.initState();
    // _loadThemeMode(); // Temporarily disabled for debugging
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    // _saveThemeMode(_themeMode == ThemeMode.dark); // Temporarily disabled for debugging
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran App',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CE619)),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CE619),
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: const SplashScreen(),
    );
  }
}
