import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class User {
  final int? id;
  final String username;
  final String password;
  final String name;
  final String birthdate;
  final String phoneNumber;
  final String platoon;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.birthdate,
    required this.phoneNumber,
    required this.platoon,
  });

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? name,
    String? birthdate,
    String? phoneNumber,
    String? platoon,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      birthdate: birthdate ?? this.birthdate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      platoon: platoon ?? this.platoon,
    );
  }

  Map<String, dynamic> toJson() => {
        UserFields.id: id,
        UserFields.username: username,
        UserFields.password: password,
        UserFields.name: name,
        UserFields.birthdate: birthdate,
        UserFields.phoneNumber: phoneNumber,
        UserFields.platoon: platoon,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json[UserFields.id],
        username: json[UserFields.username],
        password: json[UserFields.password],
        name: json[UserFields.name],
        birthdate: json[UserFields.birthdate],
        phoneNumber: json[UserFields.phoneNumber],
        platoon: json[UserFields.platoon],
      );
}

class UserFields {
  static final List<String> values = [
    id,
    username,
    password,
    name,
    birthdate,
    phoneNumber,
    platoon,
  ];

  static const String id = '_id';
  static const String username = 'username';
  static const String password = 'password';
  static const String name = 'name';
  static const String birthdate = 'birthdate';
  static const String phoneNumber = 'phoneNumber';
  static const String platoon = 'platoon';
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
  ${UserFields.password} $textType,
  ${UserFields.name} $textType,
  ${UserFields.birthdate} $textType,
  ${UserFields.phoneNumber} $textType,
  ${UserFields.platoon} $textType
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

  Future<User?> fetchUserById(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      'users',
      columns: UserFields.values,
      where: '${UserFields.id} = ?',
      whereArgs: [id],
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
    final path = join(dbPath, 'users.db');

    await deleteDatabase(path);
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
