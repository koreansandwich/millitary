import 'package:flutter/material.dart';
import 'package:my_diary_app/screens/login_screen.dart';
import 'package:my_diary_app/db/user_database.dart';
import 'package:my_diary_app/db/diary_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 앱 초기화 시점에서 데이터베이스 파일 삭제
  await UserDatabase.instance.deleteDatabaseFile();
  await DiaryDatabase.instance.deleteDatabaseFile();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Diary App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
