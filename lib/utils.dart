import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quran/quran.dart' as quran;
import 'package:html/parser.dart' as html;
import 'package:google_fonts/google_fonts.dart';

class AppUtils {
  // Arabic numerals conversion
  static String toArabicNumerals(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) => arabicDigits[int.parse(digit)])
        .join();
  }

  // Format number based on current language
  static String formatNumber(int number, String languageCode) {
    return languageCode == 'ar' ? toArabicNumerals(number) : number.toString();
  }

  // HTML entity decoding
  static String decodeHtmlEntities(String text) {
    final document = html.parse('<div>$text</div>');
    return document.body?.text ?? text;
  }

  // Get current language code based on locale (limit to 'id' and 'en')
  static String getCurrentLanguageCode(BuildContext context) {
    final locale = context.locale;
    switch (locale.languageCode) {
      case 'id':
        return 'id';
      case 'en':
        return 'en';
      default:
        return 'en';
    }
  }

  // Get current translation object for the quran package
  static quran.Translation getCurrentTranslation(BuildContext context) {
    final locale = context.locale;
    switch (locale.languageCode) {
      case 'id':
        return quran.Translation.indonesian;
      case 'en':
        return quran.Translation.enSaheeh;
      default:
        return quran.Translation.enSaheeh;
    }
  }

  // Theme color getters
  static Color getAccentColor(BuildContext context, [ThemeMode? themeMode]) {
    final isDark = themeMode == ThemeMode.dark;
    return isDark ? const Color(0xFF4CE619) : const Color(0xFF2C2C2C);
  }

  static Color getBackgroundColor(
    BuildContext context, [
    ThemeMode? themeMode,
  ]) {
    final isDark = themeMode == ThemeMode.dark;
    return isDark ? const Color(0xFF152111) : Colors.white;
  }

  static Color getSurfaceColor(BuildContext context, [ThemeMode? themeMode]) {
    final isDark = themeMode == ThemeMode.dark;
    return isDark ? const Color(0xFF1E261C) : const Color(0xFFF5F5F5);
  }

  static Color getBorderColor(BuildContext context, [ThemeMode? themeMode]) {
    final isDark = themeMode == ThemeMode.dark;
    return isDark ? const Color(0xFF42533C) : const Color(0xFFE0E0E0);
  }

  static Color getTextColor(BuildContext context, [ThemeMode? themeMode]) {
    final isDark = themeMode == ThemeMode.dark;
    return isDark ? Colors.white : const Color(0xFF2C2C2C);
  }

  static Color getSecondaryTextColor(
    BuildContext context, [
    ThemeMode? themeMode,
  ]) {
    final isDark = themeMode == ThemeMode.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF666666);
  }

  // Quran Arabic text style helper using Amiri Quran font
  static TextStyle quranArabicStyle({Color? color, double fontSize = 20.0, FontWeight? fontWeight}) {
    // Fallback to Amiri if Amiri Quran is not available in the google_fonts package
    return GoogleFonts.amiri(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}
