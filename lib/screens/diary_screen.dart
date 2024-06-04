import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:my_diary_app/db/diary_database.dart';

class DiaryScreen extends StatefulWidget {
  final DateTime selectedDay;
  final Diary? diary;
  final int userId;

  const DiaryScreen({
    Key? key,
    required this.selectedDay,
    this.diary,
    required this.userId,
  }) : super(key: key);

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController _diaryController = TextEditingController();
  File? _image;
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    if (widget.diary != null) {
      _diaryController.text = widget.diary!.content;
      _isPublic = widget.diary!.isPublic;
      // 이미지 불러오는 코드 추가 필요
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveDiary() async {
    if (_diaryController.text.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내용은 20자 이내로 작성해주세요.')),
      );
      return;
    }

    try {
      if (widget.diary == null) {
        final diary = Diary(
          date: widget.selectedDay.toIso8601String(),
          content: _diaryController.text,
          isPublic: _isPublic,
          userId: widget.userId, // 사용자 식별자 추가
        );
        await DiaryDatabase.instance.insertDiary(diary);
      } else {
        final updatedDiary = widget.diary!.copyWith(
          content: _diaryController.text,
          isPublic: _isPublic,
          userId: widget.userId, // 사용자 식별자 업데이트
        );
        await DiaryDatabase.instance.updateDiary(updatedDiary);
      }
      if (mounted) {
        Navigator.pop(context, true); // 캘린더 화면으로 돌아가기
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8BC34A), // 배경 색상 변경
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Color(0xFF8BC34A), // 배경 색상 변경
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Diary for ${widget.selectedDay.toLocal()}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _diaryController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Write your diary here (20자 이내)',
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
              maxLength: 20, // 글자수 제한
            ),
            SizedBox(height: 20),
            _image != null
                ? Image.file(_image!)
                : Text(
                    'No image selected.',
                    style: TextStyle(color: Colors.white),
                  ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Pick Image'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Public',
                  style: TextStyle(color: Colors.white),
                ),
                Switch(
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveDiary,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Save Diary'),
            ),
          ],
        ),
      ),
    );
  }
}
