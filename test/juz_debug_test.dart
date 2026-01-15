import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart' as quran;

int _parseToInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim()) ?? 0;
  return 0;
}

int computeVersesFromJuz(int i) {
  final data = quran.getSurahAndVersesFromJuz(i);
  int versesCount = 0;

  for (final entry in data.entries) {
    final keySurah = _parseToInt(entry.key);
    final val = entry.value;

    if (val is List && val.length >= 2) {
      final sVerse = _parseToInt(val[0]);
      final eVerse = _parseToInt(val[1]);
      final surah = keySurah > 0 ? keySurah : 0;
      if (surah >= 1 && sVerse > 0 && eVerse >= sVerse) {
        versesCount += (eVerse - sVerse + 1);
        continue;
      }
    }

    final valStr = '${entry.key}:${entry.value}';
    final nums = RegExp(r'\d+').allMatches(valStr).map((m) => int.parse(m.group(0)!)).toList();
    if (nums.isEmpty) continue;

    int idx = 0;
    if (keySurah > 0 && nums.isNotEmpty && nums[0] == keySurah) idx = 1;

    final remaining = nums.length - idx;
    if (valStr.contains(':') && remaining >= 4) {
      final sSurah = nums[idx + 0];
      final sVerse = nums[idx + 1];
      final eSurah = nums[idx + 2];
      final eVerse = nums[idx + 3];

      if (sSurah == eSurah) {
        if (eVerse >= sVerse) versesCount += (eVerse - sVerse + 1);
      } else if (sSurah < eSurah) {
        versesCount += (quran.getVerseCount(sSurah) - sVerse + 1);
        for (int s = sSurah + 1; s < eSurah; s++) {
          versesCount += quran.getVerseCount(s);
        }
        versesCount += eVerse;
      }
    } else if (remaining >= 2) {
      final sVerse = nums[idx + 0];
      final eVerse = nums[idx + 1];
      final surah = keySurah > 0 ? keySurah : (remaining >= 3 ? nums[idx + 2] : 1);
      final max = (surah >= 1 && surah <= quran.totalSurahCount) ? quran.getVerseCount(surah) : 0;
      final clampedStart = sVerse <= 0 ? 1 : (sVerse > max ? max : sVerse);
      final clampedEnd = eVerse <= 0 ? max : (eVerse > max ? max : eVerse);
      if (clampedEnd >= clampedStart) versesCount += (clampedEnd - clampedStart + 1);
    } else if (remaining == 1) {
      versesCount += 1;
    }
  }

  return versesCount;
}

void main() {
  test('Debug: find juz with zero verses and print raw data', () {
    final zeroJuz = <int>[];
    for (int i = 1; i <= quran.totalJuzCount; i++) {
      final v = computeVersesFromJuz(i);
      if (v == 0) {
        zeroJuz.add(i);
        print('Juz $i has 0 verses computed');
        final data = quran.getSurahAndVersesFromJuz(i);
        for (final entry in data.entries) {
          print('  key=${entry.key} value=${entry.value} (${entry.value.runtimeType})');
        }
      }
    }

    expect(zeroJuz.isEmpty, isTrue, reason: 'Some juz computed to 0 verses: $zeroJuz');
  });
}
