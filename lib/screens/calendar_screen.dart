import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:my_diary_app/db/diary_database.dart';
import 'diary_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

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
          .fetchDiaryByDate(_selectedDay!.toIso8601String());
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
        ),
      ),
    );

    if (result == true) {
      _fetchDiary();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
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
          ],
        ],
      ),
    );
  }
}
