import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:my_diary_app/db/diary_database.dart';
import 'package:my_diary_app/db/user_database.dart';

class DiaryScreen extends StatefulWidget {
  final DateTime selectedDay;
  final Diary? diary;
  final User user;

  const DiaryScreen({
    Key? key,
    required this.selectedDay,
    this.diary,
    required this.user,
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
      if (widget.diary!.imagePath != null) {
        _image = File(widget.diary!.imagePath!);
      }
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
          userId: widget.user.id!,
          platoon: widget.user.platoon,
          battalion: widget.user.battalion,
          imagePath: _image?.path,
        );
        await DiaryDatabase.instance.insertDiary(diary);
      } else {
        final updatedDiary = widget.diary!.copyWith(
          content: _diaryController.text,
          isPublic: _isPublic,
          userId: widget.user.id!,
          platoon: widget.user.platoon,
          battalion: widget.user.battalion,
          imagePath: _image?.path,
        );
        await DiaryDatabase.instance.updateDiary(updatedDiary);
      }
      if (mounted) {
        Navigator.pop(context, true);
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
        backgroundColor: Color(0xFF8BC34A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : Center(
                        child:
                            Icon(Icons.image, color: Colors.green, size: 100),
                      ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _diaryController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: '일기를 작성하세요.(20자 이내)',
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
                maxLength: 20,
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.photo_camera, color: Colors.green),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: Icon(Icons.image, color: Colors.green),
                    onPressed: _pickImage,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isPublic = !_isPublic;
                      });
                    },
                    child: Text(
                      _isPublic ? '공개' : '비공개',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveDiary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
