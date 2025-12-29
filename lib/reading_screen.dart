import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alfurqan/alfurqan.dart';
import 'package:alfurqan/constant.dart';
import 'package:alfurqan/data/dart/types.dart';
import 'package:flutter_html/flutter_html.dart';
import 'utils.dart';

class ReadingScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int? initialVerse;
  final ThemeMode? themeMode;

  const ReadingScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    this.initialVerse,
    this.themeMode,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Verse> _verses = [];
  bool _isLoading = true;
  bool _isDarkMode = true;

  TranslationType _getTranslationType() {
    return AppUtils.getCurrentTranslationType(context);
  }

  String _formatArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) => arabicDigits[int.parse(digit)]).join();
  }

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.themeMode == ThemeMode.dark;
    _loadVerses();
    if (widget.initialVerse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToVerse(widget.initialVerse!);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadVerses() async {
    try {
      final chapter = AlQuran.chapter(widget.surahNumber);
      final verses = <Verse>[];
      for (int i = 1; i <= chapter.versesCount; i++) {
        final verse = AlQuran.verse(widget.surahNumber, i);
        verses.add(verse);
      }
      setState(() {
        _verses = verses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_loading_surah'.tr())),
        );
      }
    }
  }

  void _scrollToVerse(int verseNumber) {
    // Simple scroll to verse - could be improved with better positioning
    final index = verseNumber - 1;
    if (index >= 0 && index < _verses.length) {
      _scrollController.animateTo(
        index * 120.0, // Approximate height per verse
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Color _getBackgroundColor() => _isDarkMode ? const Color(0xFF152111) : Colors.white;
  Color _getSurfaceColor() => _isDarkMode ? const Color(0xFF1E261C) : Colors.grey.shade50;
  Color _getTextColor() => _isDarkMode ? Colors.white : Colors.black87;
  Color _getSecondaryTextColor() => _isDarkMode ? Colors.white70 : Colors.black54;
  Color _getAccentColor() => const Color(0xFF4CE619);

  @override
  Widget build(BuildContext context) {
    final chapter = AlQuran.chapter(widget.surahNumber);
    final surahType = chapter.revelationPlace == ChapterRevelationPlace.makkah ? 'makkiyah'.tr() : 'madaniyah'.tr();
    final translatedName = AppUtils.decodeHtmlEntities(chapter.translatedName[_getTranslationType().languageCode] ?? chapter.nameSimple);

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: _getSurfaceColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: _getTextColor(),
            ),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Surah name and translation
                Text(
                  widget.surahName,
                  style: TextStyle(
                    color: _getTextColor(),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (translatedName != widget.surahName)
                  Text(
                    translatedName,
                    style: TextStyle(
                      color: _getSecondaryTextColor(),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 8),
                // Meta info: verses count and type
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getAccentColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getAccentColor().withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${chapter.versesCount} ${'verses'.tr()}',
                        style: TextStyle(
                          color: _getAccentColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _getAccentColor().withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        surahType,
                        style: TextStyle(
                          color: _getAccentColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_getAccentColor()),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _verses.length,
                    itemBuilder: (context, index) {
                      final verse = _verses[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getSurfaceColor(),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getAccentColor().withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Verse number in Arabic numerals, positioned at top right
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getAccentColor().withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatArabicNumber(index + 1),
                                  style: TextStyle(
                                    color: _getAccentColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Arabic text - right aligned
                            Html(
                              data: '<div style="text-align: right; font-family: \'Noto Naskh Arabic\', serif; font-size: 20px; line-height: 2.0; color: #${_getTextColor().toARGB32().toRadixString(16).substring(2)};">${AppUtils.decodeHtmlEntities(verse.text)}</div>',
                              style: {
                                "div": Style(
                                  textAlign: TextAlign.right,
                                  fontFamily: 'Noto Naskh Arabic',
                                  fontSize: FontSize(20),
                                  lineHeight: LineHeight.number(2.0),
                                  color: _getTextColor(),
                                ),
                              },
                            ),
                            const SizedBox(height: 12),
                            // Translation - left aligned
                            Builder(
                              builder: (context) {
                                try {
                                  final translation = AlQuran.translation(_getTranslationType(), verse.verseKey).text;
                                  if (translation.isNotEmpty) {
                                    return Html(
                                      data: '<div style="text-align: left; font-size: 16px; line-height: 1.5; color: #${_getSecondaryTextColor().toARGB32().toRadixString(16).substring(2)};">${AppUtils.decodeHtmlEntities(translation)}</div>',
                                      style: {
                                        "div": Style(
                                          textAlign: TextAlign.left,
                                          fontSize: FontSize(16),
                                          lineHeight: LineHeight.number(1.5),
                                          color: _getSecondaryTextColor(),
                                        ),
                                      },
                                    );
                                  }
                                  return const SizedBox.shrink();
                                } catch (e) {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.bookmark_border,
                                    color: _getSecondaryTextColor(),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    // TODO: Add bookmark functionality
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.share,
                                    color: _getSecondaryTextColor(),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    // TODO: Add share functionality
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.play_arrow,
                                    color: _getSecondaryTextColor(),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    // TODO: Add audio play functionality
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Navigation buttons for previous/next surah
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getSurfaceColor(),
                    border: Border(
                      top: BorderSide(
                        color: _getAccentColor().withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.surahNumber > 1)
                        ElevatedButton.icon(
                          onPressed: () {
                            final prevChapter = AlQuran.chapter(widget.surahNumber - 1);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => ReadingScreen(
                                  surahNumber: widget.surahNumber - 1,
                                  surahName: AppUtils.decodeHtmlEntities(prevChapter.translatedName[_getTranslationType().languageCode] ?? prevChapter.nameSimple),
                                  themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: Text('previous_surah'.tr()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getAccentColor(),
                            foregroundColor: _isDarkMode ? const Color(0xFF152111) : Colors.white,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      if (widget.surahNumber < 114)
                        ElevatedButton.icon(
                          onPressed: () {
                            final nextChapter = AlQuran.chapter(widget.surahNumber + 1);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => ReadingScreen(
                                  surahNumber: widget.surahNumber + 1,
                                  surahName: AppUtils.decodeHtmlEntities(nextChapter.translatedName[_getTranslationType().languageCode] ?? nextChapter.nameSimple),
                                  themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: Text('next_surah'.tr()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getAccentColor(),
                            foregroundColor: _isDarkMode ? const Color(0xFF152111) : Colors.white,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}