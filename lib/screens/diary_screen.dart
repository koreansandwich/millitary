import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:my_diary_app/db/diary_database.dart';

class DiaryScreen extends StatefulWidget {
  final DateTime selectedDay;
  final Diary? diary;

  const DiaryScreen({Key? key, required this.selectedDay, this.diary})
      : super(key: key);

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController _diaryController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    if (widget.diary != null) {
      _diaryController.text = widget.diary!.content;
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

    if (widget.diary == null) {
      final diary = Diary(
        date: widget.selectedDay.toIso8601String(),
        content: _diaryController.text,
      );
      await DiaryDatabase.instance.insertDiary(diary);
    } else {
      final updatedDiary = widget.diary!.copyWith(
        content: _diaryController.text,
      );
      await DiaryDatabase.instance.updateDiary(updatedDiary);
    }
    Navigator.pop(context, true); // 캘린더 화면으로 돌아가기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write Diary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Diary for ${widget.selectedDay.toLocal()}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _diaryController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Write your diary here (20자 이내)',
              ),
              maxLines: 3,
              maxLength: 20, // 글자수 제한
            ),
            SizedBox(height: 20),
            _image != null ? Image.file(_image!) : Text('No image selected.'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveDiary,
              child: Text('Save Diary'),
            ),
          ],
        ),
      ),
    );
  }
}
