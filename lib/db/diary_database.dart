import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Diary {
  final int? id;
  final String date;
  final String content;

  Diary({
    this.id,
    required this.date,
    required this.content,
  });

  Diary copyWith({
    int? id,
    String? date,
    String? content,
  }) {
    return Diary(
      id: id ?? this.id,
      date: date ?? this.date,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'content': content,
      };

  factory Diary.fromJson(Map<String, dynamic> json) => Diary(
        id: json['id'],
        date: json['date'],
        content: json['content'],
      );
}

class DiaryDatabase {
  static final DiaryDatabase instance = DiaryDatabase._init();

  static Database? _database;

  DiaryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('diaries.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE diaries ( 
  ${DiaryFields.id} $idType, 
  ${DiaryFields.date} $textType,
  ${DiaryFields.content} $textType
  )
''');
  }

  Future<Diary?> fetchDiaryByDate(String date) async {
    final db = await instance.database;

    final maps = await db.query(
      'diaries',
      columns: DiaryFields.values,
      where: '${DiaryFields.date} = ?',
      whereArgs: [date],
    );

    if (maps.isNotEmpty) {
      return Diary.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<void> insertDiary(Diary diary) async {
    final db = await instance.database;

    final id = await db.insert('diaries', diary.toJson());
    print('Diary inserted with id: $id');
  }

  Future<void> updateDiary(Diary diary) async {
    final db = await instance.database;

    await db.update(
      'diaries',
      diary.toJson(),
      where: '${DiaryFields.id} = ?',
      whereArgs: [diary.id],
    );
  }

  Future<void> deleteDiary(int id) async {
    final db = await instance.database;

    await db.delete(
      'diaries',
      where: '${DiaryFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}

class DiaryFields {
  static final List<String> values = [id, date, content];

  static const String id = '_id';
  static const String date = 'date';
  static const String content = 'content';
}
