import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Diary {
  final int? id;
  final String date;
  final String content;
  final bool isPublic;
  final int userId;
  final String platoon;
  final String battalion;
  final String? imagePath; // 이미지 경로 추가

  Diary({
    this.id,
    required this.date,
    required this.content,
    required this.isPublic,
    required this.userId,
    required this.platoon,
    required this.battalion,
    this.imagePath, // 이미지 경로 추가
  });

  Diary copyWith({
    int? id,
    String? date,
    String? content,
    bool? isPublic,
    int? userId,
    String? platoon,
    String? battalion,
    String? imagePath, // 이미지 경로 추가
  }) {
    return Diary(
      id: id ?? this.id,
      date: date ?? this.date,
      content: content ?? this.content,
      isPublic: isPublic ?? this.isPublic,
      userId: userId ?? this.userId,
      platoon: platoon ?? this.platoon,
      battalion: battalion ?? this.battalion,
      imagePath: imagePath ?? this.imagePath, // 이미지 경로 추가
    );
  }

  Map<String, dynamic> toJson() => {
        DiaryFields.id: id,
        DiaryFields.date: date,
        DiaryFields.content: content,
        DiaryFields.isPublic: isPublic ? 1 : 0,
        DiaryFields.userId: userId,
        DiaryFields.platoon: platoon,
        DiaryFields.battalion: battalion,
        DiaryFields.imagePath: imagePath, // 이미지 경로 추가
      };

  factory Diary.fromJson(Map<String, dynamic> json) => Diary(
        id: json[DiaryFields.id],
        date: json[DiaryFields.date],
        content: json[DiaryFields.content],
        isPublic: json[DiaryFields.isPublic] == 1,
        userId: json[DiaryFields.userId],
        platoon: json[DiaryFields.platoon],
        battalion: json[DiaryFields.battalion],
        imagePath: json[DiaryFields.imagePath], // 이미지 경로 추가
      );
}

class DiaryFields {
  static final List<String> values = [
    id,
    date,
    content,
    isPublic,
    userId,
    platoon,
    battalion,
    imagePath, // 이미지 경로 추가
  ];

  static const String id = '_id';
  static const String date = 'date';
  static const String content = 'content';
  static const String isPublic = 'isPublic';
  static const String userId = 'userId';
  static const String platoon = 'platoon';
  static const String battalion = 'battalion';
  static const String imagePath = 'imagePath'; // 이미지 경로 추가
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

    return await openDatabase(path,
        version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE diaries ( 
  ${DiaryFields.id} $idType, 
  ${DiaryFields.date} $textType,
  ${DiaryFields.content} $textType,
  ${DiaryFields.isPublic} $boolType,
  ${DiaryFields.userId} $intType,
  ${DiaryFields.platoon} $textType,
  ${DiaryFields.battalion} $textType,
  ${DiaryFields.imagePath} $textType
  )
''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE diaries ADD COLUMN ${DiaryFields.imagePath} TEXT');
    }
  }

  Future<Diary?> fetchDiaryByDate(String date, int userId) async {
    final db = await instance.database;

    final maps = await db.query(
      'diaries',
      columns: DiaryFields.values,
      where: '${DiaryFields.date} = ? AND ${DiaryFields.userId} = ?',
      whereArgs: [date, userId],
    );

    if (maps.isNotEmpty) {
      return Diary.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Diary>> fetchPublicDiariesByDate(
      String date, String platoon, String battalion) async {
    final db = await instance.database;

    final maps = await db.query(
      'diaries',
      columns: DiaryFields.values,
      where:
          '${DiaryFields.date} = ? AND ${DiaryFields.isPublic} = 1 AND ${DiaryFields.platoon} = ? AND ${DiaryFields.battalion} = ?',
      whereArgs: [date, platoon, battalion],
    );

    return maps.map((json) => Diary.fromJson(json)).toList();
  }

  Future<void> insertDiary(Diary diary) async {
    final db = await instance.database;

    await db.insert('diaries', diary.toJson());
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

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'diaries.db');

    await deleteDatabase(path);
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
