import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_diary_app/db/diary_database.dart';
import 'package:my_diary_app/db/user_database.dart';

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
        backgroundColor: Color(0xFF8BC34A),
        title: Text('소대원 일기'),
      ),
      body: FutureBuilder<List<Diary>>(
        future: _fetchOtherDiaries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('해당 날짜에 공개된 일기가 없습니다.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final diary = snapshot.data![index];
                return FutureBuilder<User?>(
                  future: UserDatabase.instance.fetchUserById(diary.userId),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Loading...'),
                      );
                    } else if (userSnapshot.hasError) {
                      return ListTile(
                        title: Text('Error: ${userSnapshot.error}'),
                      );
                    } else if (!userSnapshot.hasData) {
                      return ListTile(
                        title: Text('Unknown User'),
                      );
                    } else {
                      final user = userSnapshot.data!;
                      final formattedDate = DateFormat('HH:mm:ss')
                          .format(DateTime.parse(diary.date));
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.person, color: Colors.grey),
                                      SizedBox(width: 8),
                                      Text(user.username,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Text(formattedDate,
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(diary.content),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
