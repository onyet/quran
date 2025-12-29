import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alfurqan/alfurqan.dart';
import 'package:alfurqan/data/dart/types.dart';
import 'database_helper.dart';
import 'search_page.dart';
import 'reading_screen.dart';
import 'utils.dart';

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabHeaderDelegate({required this.child});

  @override
  double get minExtent => 48; // Approximate height of tabs

  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_TabHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0: Surah, 1: Juz, 2: Bookmark
  bool _isDarkMode = true; // Default to dark mode

  List<Map<String, dynamic>> surahs = [];
  List<Map<String, dynamic>> juzs = [];
  List<Map<String, dynamic>> bookmarks = [];
  Map<String, dynamic>? lastRead;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    // _loadJuzs(); // Moved to didChangeDependencies
    _loadBookmarks();
    _loadLastRead();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load surahs here because it depends on locale from context
    if (surahs.isEmpty) {
      _loadSurahs();
    }
    // Load juzs here as well since it now depends on locale for translation
    if (juzs.isEmpty) {
      _loadJuzs();
    }
  }

  void _loadSurahs() {
    final currentLang = _getCurrentLanguageKey();
    final loadedSurahs = <Map<String, dynamic>>[];

    for (int i = 1; i <= AlQuran.totalChapter; i++) {
      final chapter = AlQuran.chapter(i);
      loadedSurahs.add({
        'number': chapter.id,
        'name': _decodeHtmlEntities(chapter.nameSimple),
        'translation': _decodeHtmlEntities(chapter.translatedName[currentLang] ?? chapter.nameSimple),
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
        'name': '${'juz'.tr()} ${_formatNumber(i)}',
        'verses': juz.verse.count,
        'chapters': juz.verse.items.length,
      });
    }

    setState(() {
      juzs = loadedJuzs;
    });
  }

  void _loadBookmarks() async {
    final loadedBookmarks = await _dbHelper.getBookmarks();
    setState(() {
      bookmarks = loadedBookmarks;
    });
  }

  void _loadLastRead() async {
    final loadedLastRead = await _dbHelper.getLastRead();
    setState(() {
      lastRead = loadedLastRead;
    });
  }

  String _getCurrentLanguageKey() {
    return AppUtils.getCurrentLanguageCode(context);
  }

  String _decodeHtmlEntities(String text) {
    return AppUtils.decodeHtmlEntities(text);
  }

  String _formatNumber(int number) {
    final currentLang = _getCurrentLanguageKey();
    return AppUtils.formatNumber(number, currentLang);
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
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
        setState(() {}); // Force rebuild to update translations
        // Reload data when language changes
        Future.delayed(const Duration(milliseconds: 100), () {
          _loadSurahs();
          _loadJuzs();
          _loadBookmarks();
          _loadLastRead();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildLastReadCard() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bookmark,
                    color: _getAccentColor(),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'last_read'.tr(),
                    style: TextStyle(
                      color: _getSecondaryTextColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                lastRead!['surah_name'],
                style: TextStyle(
                  color: _getTextColor(),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'verse'.tr(namedArgs: {'number': _formatNumber(lastRead!['verse_number'])}),
                style: TextStyle(
                  color: _getSecondaryTextColor(),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReadingScreen(
                        surahNumber: lastRead!['surah_number'],
                        surahName: lastRead!['surah_name'],
                        initialVerse: lastRead!['verse_number'],
                        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getAccentColor(),
                  foregroundColor: _isDarkMode ? const Color(0xFF152111) : Colors.white,
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
            color: _isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _isDarkMode ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1)),
          ),
          child: Icon(
            Icons.local_library,
            color: _getAccentColor().withValues(alpha: 0.3),
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildStartReadingCard() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.play_circle,
                    color: _getAccentColor(),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'start_reading'.tr(),
                    style: TextStyle(
                      color: _getSecondaryTextColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Al-Fatihah',
                style: TextStyle(
                  color: _getTextColor(),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'verse'.tr(namedArgs: {'number': _formatNumber(1)}),
                style: TextStyle(
                  color: _getSecondaryTextColor(),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  // Save first verse as last read and navigate
                  final verse = AlQuran.verse(1, 1);
                  await _dbHelper.saveLastRead(1, 'Al-Fatihah', 1, verse.text);
                  _loadLastRead();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReadingScreen(
                        surahNumber: 1,
                        surahName: 'Al-Fatihah',
                        initialVerse: 1,
                        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getAccentColor(),
                  foregroundColor: _isDarkMode ? const Color(0xFF152111) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('start'.tr()),
                    const SizedBox(width: 8),
                    const Icon(Icons.play_arrow, size: 16),
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
            color: _isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _isDarkMode ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1)),
          ),
          child: Icon(
            Icons.menu_book,
            color: _getAccentColor().withValues(alpha: 0.3),
            size: 40,
          ),
        ),
      ],
    );
  }

  Color _getAccentColor() => AppUtils.getAccentColor(context, _isDarkMode ? ThemeMode.dark : ThemeMode.light);

  Color _getBackgroundColor() => AppUtils.getBackgroundColor(context, _isDarkMode ? ThemeMode.dark : ThemeMode.light);
  Color _getSurfaceColor() => AppUtils.getSurfaceColor(context, _isDarkMode ? ThemeMode.dark : ThemeMode.light);
  Color _getBorderColor() => AppUtils.getBorderColor(context, _isDarkMode ? ThemeMode.dark : ThemeMode.light);
  Color _getTextColor() => AppUtils.getTextColor(context, _isDarkMode ? ThemeMode.dark : ThemeMode.light);
  Color _getSecondaryTextColor() => AppUtils.getSecondaryTextColor(context, _isDarkMode ? ThemeMode.dark : ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey('home_scaffold_$_isDarkMode'),
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverList(
              delegate: SliverChildListDelegate([
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
                              color: _getAccentColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.menu_book,
                              color: _getAccentColor(),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Al-Quran',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _toggleTheme,
                            icon: Icon(
                              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              color: _getTextColor(),
                            ),
                          ),
                          IconButton(
                            onPressed: _switchLanguage,
                            icon: Icon(
                              Icons.language,
                              color: _getTextColor(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SearchPage(themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light),
                        ),
                      );
                    },
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
                          Icon(
                            Icons.search,
                            color: _getSecondaryTextColor(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'search_surah'.tr(),
                              style: TextStyle(
                                color: _getSecondaryTextColor().withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Last Read Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getSurfaceColor(),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _getBorderColor()),
                    ),
                    child: lastRead != null ? _buildLastReadCard() : _buildStartReadingCard(),
                  ),
                ),
              ]),
            ),

            // Sticky Tabs
            SliverPersistentHeader(
              pinned: true,
              floating: true,
              delegate: _TabHeaderDelegate(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  color: _getBackgroundColor(),
                  child: Row(
                    children: [
                      _buildTab(0, 'surah'.tr()),
                      _buildTab(1, 'juz'.tr()),
                      _buildTab(2, 'bookmark'.tr()),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            if (_selectedTab == 0)
              SliverPadding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSurahItem(index),
                    childCount: surahs.length,
                  ),
                ),
              )
            else if (_selectedTab == 1)
              SliverPadding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildJuzItem(index),
                    childCount: juzs.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildBookmarkItem(index),
                    childCount: bookmarks.isEmpty ? 1 : bookmarks.length,
                  ),
                ),
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
          decoration: BoxDecoration(
            color: isSelected ? _getAccentColor().withValues(alpha: 0.1) : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? _getAccentColor() : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? _getAccentColor() : _getTextColor(),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahItem(int index) {
    final surah = surahs[index];
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
            angle: 45 * 3.14159 / 180, // 45 degrees in radians
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: _getAccentColor().withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -45 * 3.14159 / 180, // Rotate text back to readable position
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
                Row(
                  children: _getCurrentLanguageKey() == 'ar'
                      ? [
                          Text(
                            '${_formatNumber(surah['verses'])} ${'verses'.tr()}',
                            style: TextStyle(
                              color: _getSecondaryTextColor(),
                              fontSize: 12,
                            ),
                          ),
                        ]
                      : [
                          Text(
                            surah['translation'],
                            style: TextStyle(
                              color: _getSecondaryTextColor(),
                              fontSize: 12,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _getSecondaryTextColor().withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            '${_formatNumber(surah['verses'])} ${'verses'.tr()}',
                            style: TextStyle(
                              color: _getSecondaryTextColor(),
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
                style: TextStyle(
                  color: _getAccentColor(),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                surah['type'] == 'Makkiyah' ? Icons.mosque : Icons.location_city,
                color: _getSecondaryTextColor(),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJuzItem(int index) {
    final juz = juzs[index];
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
            angle: 45 * 3.14159 / 180, // 45 degrees in radians
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: _getAccentColor().withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -45 * 3.14159 / 180, // Rotate text back to readable position
                  child: Text(
                    _formatNumber(juz['number']),
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
                  juz['name'],
                  style: TextStyle(
                    color: _getTextColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${_formatNumber(juz['chapters'])} ${'chapters'.tr()}',
                      style: TextStyle(
                        color: _getSecondaryTextColor(),
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _getSecondaryTextColor().withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      '${_formatNumber(juz['verses'])} ${'verses'.tr()}',
                      style: TextStyle(
                        color: _getSecondaryTextColor(),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.book,
            color: _getAccentColor(),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkItem(int index) {
    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              color: _getSecondaryTextColor().withValues(alpha: 0.3),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'no_bookmarks'.tr(),
              style: TextStyle(
                color: _getSecondaryTextColor(),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final bookmark = bookmarks[index];
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getAccentColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.bookmark,
              color: _getAccentColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${bookmark['surah_name']} - ${'verse'.tr(namedArgs: {'number': _formatNumber(bookmark['verse_number'])})}',
                  style: TextStyle(
                    color: _getTextColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bookmark['verse_text'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _getSecondaryTextColor(),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await _dbHelper.removeBookmark(bookmark['id']);
              _loadBookmarks();
            },
            icon: Icon(
              Icons.delete,
              color: Colors.red.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }


}