import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alfurqan/constant.dart';
import 'package:html/parser.dart' as html;

class AppUtils {
  // Arabic numerals conversion
  static String toArabicNumerals(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) => arabicDigits[int.parse(digit)]).join();
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

  // Get current language code based on locale
  static String getCurrentLanguageCode(BuildContext context) {
    final locale = context.locale;
    switch (locale.languageCode) {
      case 'id':
        return 'id';
      case 'en':
        return 'en';
      case 'tr':
        return 'tr';
      case 'fr':
        return 'fr';
      case 'ar':
        return 'ar';
      default:
        return 'en';
    }
  }

  // Get current translation type based on locale
  static TranslationType getCurrentTranslationType(BuildContext context) {
    final locale = context.locale;
    switch (locale.languageCode) {
      case 'id':
        return TranslationType.idIndonesianIslamicAffairsMinistry;
      case 'en':
        return TranslationType.enMASAbdelHaleem;
      case 'tr':
        return TranslationType.trDarAlSalamCenter;
      case 'fr':
        return TranslationType.frMontadaIslamicFoundation;
      default:
        return TranslationType.enMASAbdelHaleem;
    }
  }

  // Theme color getters
  static Color getAccentColor(BuildContext context, [ThemeMode? themeMode]) {
    final isDark = themeMode == ThemeMode.dark;
    return isDark ? const Color(0xFF4CE619) : const Color(0xFF2C2C2C);
  }

  static Color getBackgroundColor(BuildContext context, [ThemeMode? themeMode]) {
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

  static Color getSecondaryTextColor(BuildContext context, [ThemeMode? themeMode]) {
    final isDark = themeMode == ThemeMode.dark;
    return isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF666666);
  }
}