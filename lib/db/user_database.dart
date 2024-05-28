import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class User {
  final int? id;
  final String username;
  final String password;

  User({
    this.id,
    required this.username,
    required this.password,
  });

  User copyWith({
    int? id,
    String? username,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toJson() => {
        UserFields.id: id,
        UserFields.username: username,
        UserFields.password: password,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json[UserFields.id],
        username: json[UserFields.username],
        password: json[UserFields.password],
      );
}

class UserFields {
  static final List<String> values = [id, username, password];

  static const String id = '_id';
  static const String username = 'username';
  static const String password = 'password';
}

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();

  static Database? _database;

  UserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('users.db');
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
CREATE TABLE users ( 
  ${UserFields.id} $idType, 
  ${UserFields.username} $textType,
  ${UserFields.password} $textType
  )
''');
  }

  Future<User?> getUser(String username, String password) async {
    final db = await instance.database;

    final maps = await db.query(
      'users',
      columns: UserFields.values,
      where: '${UserFields.username} = ? AND ${UserFields.password} = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<User?> fetchUserByUsername(String username) async {
    // 새로운 메소드 추가
    final db = await instance.database;

    final maps = await db.query(
      'users',
      columns: UserFields.values,
      where: '${UserFields.username} = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<void> insertUser(User user) async {
    final db = await instance.database;

    await db.insert('users', user.toJson());
  }

  Future<void> updateUser(User user) async {
    final db = await instance.database;

    await db.update(
      'users',
      user.toJson(),
      where: '${UserFields.id} = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await instance.database;

    await db.delete(
      'users',
      where: '${UserFields.id} = ?',
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
