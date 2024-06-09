import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/scheduler.dart';
import 'dart:convert';

class MealScreen extends StatefulWidget {
  final DateTime selectedDay;
  final String platoon;
  final String company;

  const MealScreen({
    Key? key,
    required this.selectedDay,
    required this.platoon,
    required this.company,
  }) : super(key: key);

  @override
  _MealScreenState createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  List<List<dynamic>> _mealData = [];

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  void _showErrorSnackbar(String message) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  String _getCsvFileUrl(String company) {
    switch (company) {
      case '5397':
        return 'https://drive.google.com/uc?export=download&id=1HxjVThZuYKXpCaKd_fNkPgVFyQ6G-Vs6';
      case '2291':
        return 'https://drive.google.com/uc?export=download&id=1QdcKD6pselwEsQe8O6mhiOwjVxqXiPcG';
      case '1575':
        return 'https://drive.google.com/uc?export=download&id=1ZuczR8G9O8Igx_281VNwsNhHv1E_qbag';
      default:
        return ''; // Handle default case or unknown company
    }
  }

  Future<void> _loadCSV() async {
    final url = _getCsvFileUrl(widget.company);
    print('URL: $url');
    print('Selected Date: ${_formatDate(widget.selectedDay)}');
    print('Company: ${widget.company}');
    if (url.isEmpty) {
      _showErrorSnackbar('Unknown company. Cannot load meal data.');
      return;
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Response Bytes: ${response.bodyBytes}');
      try {
        final csvData = utf8.decode(response.bodyBytes);
        final List<List<dynamic>> csvTable =
            const CsvToListConverter().convert(csvData);
        setState(() {
          _mealData = csvTable;
          print('Meal Data Loaded: ${_mealData.length} entries');
        });
      } catch (e) {
        print('Decoding Error: $e');
        _showErrorSnackbar('Failed to decode CSV file');
      }
    } else {
      _showErrorSnackbar('Failed to load CSV file');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(widget.selectedDay);
    final meals = _mealData.where((row) => row[0] == formattedDate).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8BC34A),
        title: Text('식단 정보'),
      ),
      body: Container(
        color: Colors.white,
        child: meals.isEmpty
            ? Center(child: Text('해당 날짜에 식단 정보가 없습니다.'))
            : ListView(
                children: [
                  _buildMealSection('조식', meals, 1, 2),
                  _buildMealSection('중식', meals, 3, 4),
                  _buildMealSection('석식', meals, 5, 6),
                ],
              ),
      ),
    );
  }

  Widget _buildMealSection(String mealType, List<List<dynamic>> meals,
      int startIndex, int endIndex) {
    final mealItems = meals.expand((meal) {
      return [
        for (int i = startIndex; i <= endIndex; i += 2)
          _removeParentheses('${meal[i]}')
      ];
    }).join(', ');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFF8BC34A), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                mealType,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto', // 적절한 세련된 폰트 사용
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                mealItems,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _removeParentheses(String item) {
    return item.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
