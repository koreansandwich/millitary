import 'package:flutter/material.dart';
import 'screens/calendar_screen.dart';

void main() {
  runApp(const MyApp()); // const 추가
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // const와 key 추가

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Diary App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalendarScreen(), // const 추가
    );
  }
}
