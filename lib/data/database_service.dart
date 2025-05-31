import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../domain/models/cat.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cats_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cats(
        id TEXT PRIMARY KEY,
        url TEXT,
        breedName TEXT,
        breedDescription TEXT,
        dateLiked TEXT
      )
    ''');
  }

  Future<int> insertCat(Cat cat) async {
    final db = await database;
    return await db.insert('cats', {
      'id': cat.id,
      'url': cat.url,
      'breedName': cat.breedName,
      'breedDescription': cat.breedDescription,
      'dateLiked': cat.dateLiked.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Cat>> getLikedCats() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cats');

    return List.generate(maps.length, (i) {
      return Cat(
        id: maps[i]['id'],
        url: maps[i]['url'],
        breedName: maps[i]['breedName'],
        breedDescription: maps[i]['breedDescription'],
        dateLiked: DateTime.parse(maps[i]['dateLiked']),
      );
    });
  }

  Future<void> deleteCat(String id) async {
    final db = await database;
    await db.delete('cats', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isCatLiked(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'cats',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }
}
