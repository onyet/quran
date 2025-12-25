import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'quran.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create bookmarks table
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        surah_name TEXT NOT NULL,
        verse_number INTEGER NOT NULL,
        verse_text TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create last_read table
    await db.execute('''
      CREATE TABLE last_read (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        surah_name TEXT NOT NULL,
        verse_number INTEGER NOT NULL,
        verse_text TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Insert default theme setting
    await db.insert('settings', {'key': 'isDarkMode', 'value': 'true'});
  }

  // Bookmark methods
  Future<int> addBookmark(int surahNumber, String surahName, int verseNumber, String verseText) async {
    final db = await database;
    return await db.insert('bookmarks', {
      'surah_number': surahNumber,
      'surah_name': surahName,
      'verse_number': verseNumber,
      'verse_text': verseText,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await database;
    return await db.query('bookmarks', orderBy: 'created_at DESC');
  }

  Future<int> removeBookmark(int id) async {
    final db = await database;
    return await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isBookmarked(int surahNumber, int verseNumber) async {
    final db = await database;
    final result = await db.query(
      'bookmarks',
      where: 'surah_number = ? AND verse_number = ?',
      whereArgs: [surahNumber, verseNumber],
    );
    return result.isNotEmpty;
  }

  // Last read methods
  Future<int> saveLastRead(int surahNumber, String surahName, int verseNumber, String verseText) async {
    final db = await database;

    // Delete existing last read
    await db.delete('last_read');

    // Insert new last read
    return await db.insert('last_read', {
      'surah_number': surahNumber,
      'surah_name': surahName,
      'verse_number': verseNumber,
      'verse_text': verseText,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getLastRead() async {
    final db = await database;
    final result = await db.query('last_read', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> clearLastRead() async {
    final db = await database;
    return await db.delete('last_read');
  }

  // Settings methods
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return result.isNotEmpty ? result.first['value'] as String : null;
  }
}