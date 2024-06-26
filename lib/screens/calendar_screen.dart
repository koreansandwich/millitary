import 'package:flutter/material.dart';
import 'package:my_diary_app/screens/other_diaries_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:my_diary_app/db/diary_database.dart';
import 'package:my_diary_app/screens/diary_screen.dart';
import 'package:my_diary_app/db/user_database.dart';
import 'package:my_diary_app/screens/login_screen.dart';
import 'package:my_diary_app/screens/meal_screen.dart'; // 추가된 임포트

class CalendarScreen extends StatefulWidget {
  final User user; // User 객체를 사용
  const CalendarScreen({Key? key, required this.user}) : super(key: key);

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
          .fetchDiaryByDate(_selectedDay!.toIso8601String(), widget.user.id!);
      setState(() {
        _diary = diary;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (selectedDay.isAfter(DateTime.now())) {
      return; // 미래 날짜는 선택하지 않도록 함
    }
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
          user: widget.user,
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
          user: widget.user, // User 객체 전달
        ),
      ),
    );
  }

  Future<void> _navigateToMealScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealScreen(
          selectedDay: _selectedDay!,
          platoon: widget.user.platoon,
          company: widget.user.company, // 'battalion'을 'company'로 수정
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // 전체 배경 색상 변경
      appBar: AppBar(
        backgroundColor: Color(0xFF8BC34A),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(color: Colors.green),
                    holidayTextStyle: TextStyle(color: Colors.red),
                    disabledTextStyle:
                        TextStyle(color: Colors.grey), // 선택 불가능한 날짜 스타일
                  ),
                  enabledDayPredicate: (day) {
                    return !day.isAfter(DateTime.now()); // 미래 날짜는 비활성화
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Colors.black,
                    ),
                    titleTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.red),
                    weekdayStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
          if (_selectedDay != null) ...[
            SizedBox(height: 10), // 버튼 간격 추가
            if (_diary == null) ...[
              ElevatedButton(
                onPressed: _navigateToDiaryScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('일기 쓰기'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _navigateToDiaryScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('일기 보기/수정하기'),
              ),
              SizedBox(height: 10), // 버튼 간격 추가
              ElevatedButton(
                onPressed: () async {
                  await DiaryDatabase.instance.deleteDiary(_diary!.id!);
                  setState(() {
                    _diary = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('일기 지우기'),
              ),
            ],
            SizedBox(height: 10), // 버튼 간격 추가
            ElevatedButton(
              onPressed: _navigateToOtherDiariesScreen, // 다른 사람의 일기를 볼 수 있는 버튼
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('소대원 일기 보기'),
            ),
            SizedBox(height: 10), // 버튼 간격 추가
            ElevatedButton(
              onPressed: _navigateToMealScreen, // 식단 보기 버튼
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('식단 보기'),
            ),
          ],
        ],
      ),
    );
  }
}
