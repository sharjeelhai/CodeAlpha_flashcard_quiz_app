import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/flashcard.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flashcards.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE flashcards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Insert some sample flashcards
    await db.insert('flashcards', {
      'question': 'What is Flutter?',
      'answer': 'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });

    await db.insert('flashcards', {
      'question': 'What is Dart?',
      'answer': 'Dart is a programming language developed by Google that is used to build Flutter applications.',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Flashcard>> getFlashcards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'flashcards',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) => Flashcard.fromMap(maps[i]));
  }

  Future<int> insertFlashcard(Flashcard flashcard) async {
    final db = await database;
    return await db.insert('flashcards', flashcard.toMap());
  }

  Future<int> updateFlashcard(Flashcard flashcard) async {
    final db = await database;
    return await db.update(
      'flashcards',
      flashcard.toMap(),
      where: 'id = ?',
      whereArgs: [flashcard.id],
    );
  }

  Future<int> deleteFlashcard(int id) async {
    final db = await database;
    return await db.delete(
      'flashcards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}