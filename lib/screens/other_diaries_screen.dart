import 'package:flutter/material.dart';
import 'package:my_diary_app/db/diary_database.dart';

class OtherDiariesScreen extends StatelessWidget {
  final DateTime selectedDay;

  const OtherDiariesScreen({Key? key, required this.selectedDay})
      : super(key: key);

  Future<List<Diary>> _fetchOtherDiaries() async {
    return await DiaryDatabase.instance
        .fetchPublicDiariesByDate(selectedDay.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Other Diaries'),
      ),
      body: FutureBuilder<List<Diary>>(
        future: _fetchOtherDiaries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No public diaries found for this date'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final diary = snapshot.data![index];
                return ListTile(
                  title: Text(diary.content),
                  subtitle: Text(diary.date),
                );
              },
            );
          }
        },
      ),
    );
  }
}
