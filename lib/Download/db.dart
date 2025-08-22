import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._();
  static Database? _database;

  DBHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('downloads.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE downloads(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fileName TEXT,
        fileCat TEXT,
        fileSub TEXT,
        fileDate TEXT,
        filePath TEXT
      )
    ''');
  }

  Future<int> insertDownload(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('downloads', data);
  }

  Future<List<Map<String, dynamic>>> getDownloads() async {
    final db = await instance.database;
    return await db.query('downloads');
  }

  Future<void> deleteDownload(int id) async {
    final db = await database;
    await db.delete('downloads', where: 'id = ?', whereArgs: [id]);
  }
  Future<bool> doesFileExist(String fileName) async {
    final db = await instance.database;
    final result = await db.query(
      'downloads',
      where: 'fileName = ?',
      whereArgs: [fileName],
    );
    return result.isNotEmpty; // Returns true if the file exists
  }

}
