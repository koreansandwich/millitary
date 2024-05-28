import 'package:flutter/material.dart';
import 'package:my_diary_app/screens/other_diaries_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:my_diary_app/db/diary_database.dart';
import 'diary_screen.dart';
import 'login_screen.dart';

class CalendarScreen extends StatefulWidget {
  final int userId;
  const CalendarScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Diary? _diary;

  @override
  void initState() {
    super.initState();
    _fetchDiary();
  }

  Future<void> _fetchDiary() async {
    if (_selectedDay != null) {
      final diary = await DiaryDatabase.instance
          .fetchDiaryByDate(_selectedDay!.toIso8601String(), widget.userId);
      setState(() {
        _diary = diary;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _fetchDiary();
  }

  Future<void> _navigateToDiaryScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryScreen(
          selectedDay: _selectedDay!,
          diary: _diary,
          userId: widget.userId,
        ),
      ),
    );

    if (result == true) {
      _fetchDiary();
    }
  }

  Future<void> _navigateToOtherDiariesScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtherDiariesScreen(
          selectedDay: _selectedDay!,
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // 로그아웃 버튼 클릭 시 호출될 함수
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          if (_selectedDay != null) ...[
            if (_diary == null) ...[
              ElevatedButton(
                onPressed: _navigateToDiaryScreen,
                child: Text('Write Diary'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _navigateToDiaryScreen,
                child: Text('View/Edit Diary'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await DiaryDatabase.instance.deleteDiary(_diary!.id!);
                  setState(() {
                    _diary = null;
                  });
                },
                child: Text('Delete Diary'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
            ElevatedButton(
              onPressed: _navigateToOtherDiariesScreen, // 다른 사람의 일기를 볼 수 있는 버튼
              child: Text('View Other Diaries'),
            ),
          ],
        ],
      ),
    );
  }
}
