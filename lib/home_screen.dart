import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alfurqan/alfurqan.dart';
import 'package:alfurqan/data/dart/types.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0: Surah, 1: Juz, 2: Bookmark

  List<Map<String, dynamic>> surahs = [];
  List<Map<String, dynamic>> juzs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _loadSurahs();
    _loadJuzs();
  }

  void _loadSurahs() {
    final currentLang = _getCurrentLanguageKey();
    final loadedSurahs = <Map<String, dynamic>>[];

    for (int i = 1; i <= AlQuran.totalChapter; i++) {
      final chapter = AlQuran.chapter(i);
      loadedSurahs.add({
        'number': chapter.id,
        'name': chapter.nameSimple,
        'translation': chapter.translatedName[currentLang] ?? chapter.nameSimple,
        'arabic': chapter.nameArabic,
        'verses': chapter.versesCount,
        'type': chapter.revelationPlace == ChapterRevelationPlace.makkah ? 'Makkiyah' : 'Madaniyah',
      });
    }

    setState(() {
      surahs = loadedSurahs;
    });
  }

  void _loadJuzs() {
    final loadedJuzs = <Map<String, dynamic>>[];

    for (int i = 1; i <= AlQuran.totalJuz; i++) {
      final juz = AlQuran.juz(juzNumber: i);
      loadedJuzs.add({
        'number': i,
        'name': 'Juz $i',
        'verses': juz.verse.count,
        'chapters': juz.verse.items.length,
      });
    }

    setState(() {
      juzs = loadedJuzs;
    });
  }

  String _getCurrentLanguageKey() {
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

  void _switchLanguage() {
    // Show language selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('select_language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('id', 'Bahasa Indonesia'),
            _buildLanguageOption('en', 'English'),
            _buildLanguageOption('tr', 'Türkçe'),
            _buildLanguageOption('fr', 'Français'),
            _buildLanguageOption('ar', 'العربية'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name) {
    return ListTile(
      title: Text(name),
      onTap: () {
        context.setLocale(Locale(code));
        // Reload data when language changes
        Future.delayed(const Duration(milliseconds: 100), () {
          _loadSurahs();
        });
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF152111), // background-dark
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CE619).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          color: Color(0xFF4CE619),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Al-Quran Offline',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _switchLanguage,
                    icon: const Icon(
                      Icons.language,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E261C), // surface-dark
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF42533C)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(
                      Icons.search,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'search_surah'.tr(),
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Last Read Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E261C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF42533C)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.bookmark,
                                color: const Color(0xFF4CE619),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'last_read'.tr(),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Al-Kahfi',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'verse_10'.tr(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CE619),
                              foregroundColor: const Color(0xFF152111),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('continue'.tr()),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Icon(
                        Icons.local_library,
                        color: const Color(0xFF4CE619).withValues(alpha: 0.3),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildTab(0, 'surah'.tr()),
                  _buildTab(1, 'juz'.tr()),
                  _buildTab(2, 'bookmark'.tr()),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _selectedTab == 0
                  ? _buildSurahList()
                  : _selectedTab == 1
                      ? _buildJuzList()
                      : _buildPlaceholder('bookmark'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF4CE619) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF4CE619) : Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E261C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF42533C)),
          ),
          child: Row(
            children: [
              // Number Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4CE619).withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${surah['number']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          surah['translation'],
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          '${surah['verses']} ${'verses'.tr()}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    surah['arabic'],
                    style: const TextStyle(
                      color: Color(0xFF4CE619),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    surah['type'] == 'Makkiyah' ? Icons.mosque : Icons.location_city,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: juzs.length,
      itemBuilder: (context, index) {
        final juz = juzs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E261C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF42533C)),
          ),
          child: Row(
            children: [
              // Number Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4CE619).withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${juz['number']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
                      juz['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${juz['chapters']} ${'chapters'.tr()}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          '${juz['verses']} ${'verses'.tr()}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.book,
                color: Color(0xFF4CE619),
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(String type) {
    return Center(
      child: Text(
        '$type ${'coming_soon'.tr()}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}