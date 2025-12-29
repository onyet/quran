import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alfurqan/alfurqan.dart';
import 'package:alfurqan/constant.dart';
import 'package:alfurqan/data/dart/types.dart';
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

  String _formatNumber(int number) {
    final currentLang = AppUtils.getCurrentLanguageCode(context);
    return AppUtils.formatNumber(number, currentLang);
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
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: _getSurfaceColor(),
        elevation: 0,
        title: Text(
          widget.surahName,
          style: TextStyle(
            color: _getTextColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
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
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_getAccentColor()),
              ),
            )
          : ListView.builder(
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
                      // Verse number
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getAccentColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatNumber(index + 1),
                          style: TextStyle(
                            color: _getAccentColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Arabic text
                      Text(
                        verse.text,
                        style: TextStyle(
                          color: _getTextColor(),
                          fontSize: 20,
                          fontFamily: 'Amiri',
                          height: 2.0,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 8),
                      // Translation
                      Builder(
                        builder: (context) {
                          try {
                            final translation = AlQuran.translation(_getTranslationType(), verse.verseKey).text;
                            if (translation.isNotEmpty) {
                              return Text(
                                translation,
                                style: TextStyle(
                                  color: _getSecondaryTextColor(),
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.justify,
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
    );
  }
}