import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart' as quran;


void main() {
  test('Each juz should have at least one chapter and verse count > 0', () {
    for (int i = 1; i <= quran.totalJuzCount; i++) {
      final data = quran.getSurahAndVersesFromJuz(i);
      expect(data.isNotEmpty, isTrue, reason: 'Juz $i returned empty mapping');

      int chaptersCount = data.length;
      int versesCount = 0;

      for (final entry in data.entries) {
        // Normalize any kind of value into numbers using regex to avoid type issues
        final valStr = entry.value.toString();
        final matches = RegExp(r'\d+').allMatches(valStr).map((m) => int.parse(m.group(0)!)).toList();
        if (matches.isEmpty) continue;
        final start = matches.first;
        final end = matches.length >= 2 ? matches.last : start;
        if (start > 0 && end >= start) {
          versesCount += (end - start + 1);
        }
      }

      expect(chaptersCount, greaterThan(0), reason: 'Juz $i has zero chapters');
      expect(versesCount, greaterThan(0), reason: 'Juz $i has zero verses');
    }
  });
}
