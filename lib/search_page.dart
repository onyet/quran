// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alfurqan/alfurqan.dart';
import 'package:alfurqan/constant.dart';
import 'package:alfurqan/data/dart/types.dart';
import 'database_helper.dart';
import 'utils.dart';

class SearchPage extends StatefulWidget {
  final String initialQuery;
  final ThemeMode? themeMode;

  const SearchPage({super.key, this.initialQuery = '', this.themeMode});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _filter = 'Semua'; // Semua, Surah, Ayat
  List<Map<String, dynamic>> _surahResults = [];
  List<Map<String, dynamic>> _verseResults = [];
  bool _isLoading = false;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _query = widget.initialQuery;
    if (_query.isNotEmpty) {
      _performSearch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    if (_query.isEmpty) {
      setState(() {
        _surahResults = [];
        _verseResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final queryLower = _query.toLowerCase();

    // Search Surahs
    final surahResults = <Map<String, dynamic>>[];
    for (int i = 1; i <= AlQuran.totalChapter; i++) {
      final chapter = AlQuran.chapter(i);
      final name = _decodeHtmlEntities(chapter.nameSimple).toLowerCase();
      final translation = _decodeHtmlEntities(
        chapter.translatedName[_getTranslationType().languageCode] ??
            chapter.nameSimple,
      ).toLowerCase();

      if (name.contains(queryLower) || translation.contains(queryLower)) {
        surahResults.add({
          'number': chapter.id,
          'name': _decodeHtmlEntities(chapter.nameSimple),
          'translation': _decodeHtmlEntities(
            chapter.translatedName[_getTranslationType().languageCode] ??
                chapter.nameSimple,
          ),
          'arabic': chapter.nameArabic,
          'verses': chapter.versesCount,
          'type': chapter.revelationPlace == ChapterRevelationPlace.makkah
              ? 'Makkiyah'
              : 'Madaniyah',
        });
      }
    }

    // Search Verses
    final verseResults = <Map<String, dynamic>>[];
    if (_filter != 'Surah') {
      final translationType = _getTranslationType();
      for (
        int surahIndex = 1;
        surahIndex <= AlQuran.totalChapter;
        surahIndex++
      ) {
        final chapter = AlQuran.chapter(surahIndex);
        for (
          int verseIndex = 1;
          verseIndex <= chapter.versesCount;
          verseIndex++
        ) {
          final verse = AlQuran.verse(surahIndex, verseIndex);
          final arabicText = verse.text.toLowerCase();
          final translation = AlQuran.translation(
            translationType,
            verse.verseKey,
          ).text.toLowerCase();

          if (arabicText.contains(queryLower) ||
              translation.contains(queryLower)) {
            verseResults.add({
              'surahNumber': surahIndex,
              'surahName': _decodeHtmlEntities(chapter.nameSimple),
              'surahArabic': chapter.nameArabic,
              'verseNumber': verseIndex,
              'arabicText': verse.text,
              'translation': AlQuran.translation(
                translationType,
                verse.verseKey,
              ).text,
            });
          }
        }
      }
    }

    setState(() {
      _surahResults = surahResults;
      _verseResults = verseResults;
      _isLoading = false;
    });
  }

  TranslationType _getTranslationType() {
    return AppUtils.getCurrentTranslationType(context);
  }

  String _decodeHtmlEntities(String text) {
    return AppUtils.decodeHtmlEntities(text);
  }

  String _formatNumber(int number) {
    final currentLang = AppUtils.getCurrentLanguageCode(context);
    return AppUtils.formatNumber(number, currentLang);
  }

  TextSpan _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return TextSpan(
        text: text,
        style: TextStyle(color: _getSecondaryTextColor(), fontSize: 14),
      );
    }

    final queryLower = query.toLowerCase();
    final regExp = RegExp('($queryLower)', caseSensitive: false);
    final matches = regExp.allMatches(text.toLowerCase());

    if (matches.isEmpty) {
      return TextSpan(
        text: text,
        style: TextStyle(color: _getSecondaryTextColor(), fontSize: 14),
      );
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: TextStyle(color: _getSecondaryTextColor(), fontSize: 14),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: TextStyle(
            color: _getAccentColor(),
            fontWeight: FontWeight.bold,
            backgroundColor: _getAccentColor().withValues(alpha: 0.1),
            fontSize: 14,
          ),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: TextStyle(color: _getSecondaryTextColor(), fontSize: 14),
        ),
      );
    }

    return TextSpan(children: spans);
  }

  Color _getAccentColor() => AppUtils.getAccentColor(context, widget.themeMode);

  Color _getBackgroundColor() =>
      AppUtils.getBackgroundColor(context, widget.themeMode);
  Color _getSurfaceColor() =>
      AppUtils.getSurfaceColor(context, widget.themeMode);
  Color _getBorderColor() => AppUtils.getBorderColor(context, widget.themeMode);
  Color _getTextColor() => AppUtils.getTextColor(context, widget.themeMode);
  Color _getSecondaryTextColor() =>
      AppUtils.getSecondaryTextColor(context, widget.themeMode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: _getTextColor()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getSurfaceColor(),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _getBorderColor()),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(Icons.search, color: _getSecondaryTextColor()),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: _getTextColor()),
                              decoration: InputDecoration(
                                hintText: 'search_surah'.tr(),
                                hintStyle: TextStyle(
                                  color: _getSecondaryTextColor().withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _query = value;
                                });
                              },
                              onSubmitted: (value) {
                                _performSearch();
                              },
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _query = '';
                                  _surahResults = [];
                                  _verseResults = [];
                                });
                              },
                              icon: Icon(
                                Icons.close,
                                color: _getSecondaryTextColor(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  _buildFilterTab('Semua'),
                  _buildFilterTab('Surah'),
                  _buildFilterTab('Ayat'),
                ],
              ),
            ),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_surahResults.isNotEmpty &&
                              (_filter == 'Semua' || _filter == 'Surah')) ...[
                            _buildSurahSection(),
                          ],
                          if (_verseResults.isNotEmpty &&
                              (_filter == 'Semua' || _filter == 'Ayat')) ...[
                            _buildVerseSection(),
                          ],
                          if (_surahResults.isEmpty &&
                              _verseResults.isEmpty &&
                              !_isLoading) ...[
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    color: _getSecondaryTextColor().withValues(
                                      alpha: 0.3,
                                    ),
                                    size: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'no_results'.tr(),
                                    style: TextStyle(
                                      color: _getSecondaryTextColor(),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title) {
    final isSelected = _filter == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filter = title;
          });
          _performSearch();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? _getAccentColor().withValues(alpha: 0.1)
                : _getSurfaceColor(),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? _getAccentColor() : _getBorderColor(),
            ),
          ),
          child: Text(
            title.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? _getAccentColor() : _getSecondaryTextColor(),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'surah_matches'.tr(args: [_surahResults.length.toString()]),
                style: TextStyle(
                  color: _getTextColor(),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'matches'.tr().toUpperCase(),
                style: TextStyle(
                  color: _getSecondaryTextColor(),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        ..._surahResults.map((surah) => _buildSurahItem(surah)),
      ],
    );
  }

  Widget _buildSurahItem(Map<String, dynamic> surah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getSurfaceColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Row(
        children: [
          // Number Badge
          Transform.rotate(
            angle: 45 * 3.14159 / 180,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _getAccentColor().withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -45 * 3.14159 / 180,
                  child: Text(
                    _formatNumber(surah['number']),
                    style: TextStyle(
                      color: _getTextColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah['name'],
                  style: TextStyle(
                    color: _getTextColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${surah['translation']} • ${surah['type']} • ${_formatNumber(surah['verses'])} ${'verses'.tr()}',
                  style: TextStyle(
                    color: _getSecondaryTextColor(),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: _getSecondaryTextColor(), size: 24),
        ],
      ),
    );
  }

  Widget _buildVerseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'verse_matches'.tr(args: [_verseResults.length.toString()]),
                style: TextStyle(
                  color: _getTextColor(),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'matches'.tr().toUpperCase(),
                style: TextStyle(
                  color: _getSecondaryTextColor(),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        ..._verseResults.map((verse) => _buildVerseItem(verse)),
      ],
    );
  }

  Widget _buildVerseItem(Map<String, dynamic> verse) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getSurfaceColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getAccentColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'QS. ${verse['surahNumber']}:${verse['verseNumber']}',
                      style: TextStyle(
                        color: _getAccentColor(),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    verse['surahName'],
                    style: TextStyle(
                      color: _getTextColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                    },
                    icon: Icon(
                      Icons.play_arrow,
                      color: _getSecondaryTextColor(),
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _dbHelper.addBookmark(
                        verse['surahNumber'],
                        verse['surahName'],
                        verse['verseNumber'],
                        verse['arabicText'],
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('bookmarked'.tr())),
                      );
                    },
                    icon: Icon(
                      Icons.bookmark_border,
                      color: _getSecondaryTextColor(),
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                    },
                    icon: Icon(
                      Icons.share,
                      color: _getSecondaryTextColor(),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Arabic Text
          Text(
            verse['arabicText'],
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 20,
              fontFamily: 'Amiri', // Assuming Arabic font
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          // Translation
          RichText(text: _buildHighlightedText(verse['translation'], _query)),
        ],
      ),
    );
  }
}
