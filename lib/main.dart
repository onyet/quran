import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:google_fonts/google_fonts.dart';
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
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
      ],
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
  final ThemeMode _themeMode = ThemeMode.dark; // Default to dark
  // final DatabaseHelper _dbHelper = DatabaseHelper(); // Temporarily disabled for debugging

  @override
  void initState() {
    super.initState();
    // _loadThemeMode(); // Temporarily disabled for debugging
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
        // Use Amiri for general text in the app
        textTheme: GoogleFonts.amiriTextTheme(),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CE619),
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        // Use Amiri in dark theme as well
        textTheme: GoogleFonts.amiriTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: _themeMode,
      home: const SplashScreen(),
    );
  }
}
