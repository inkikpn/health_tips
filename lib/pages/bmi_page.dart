import 'package:flutter/material.dart';
import 'package:health_tips1/db/database_helper.dart';

class BmiPage extends StatefulWidget {
  @override
  _BmiPageState createState() => _BmiPageState();
}

class _BmiPageState extends State<BmiPage> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  String result = '';
  String evaluation = '';

  void calculateBmi() {
    final double height = double.tryParse(heightController.text) ?? 0;
    final double weight = double.tryParse(weightController.text) ?? 0;

    if (height > 0 && weight > 0) {
      final bmi = weight / ((height / 100) * (height / 100));
      setState(() {
        result = bmi.toStringAsFixed(2);
        if (bmi < 18.5) {
          evaluation = '過輕';
        } else if (bmi >= 18.5 && bmi < 24.9) {
          evaluation = '正常';
        } else if (bmi >= 25 && bmi < 29.9) {
          evaluation = '過重';
        } else {
          evaluation = '肥胖';
        }
      });
    } else {
      setState(() {
        result = '請輸入有效的數值';
        evaluation = '';
      });
    }
  }

  void saveRecord() async {
    final double height = double.tryParse(heightController.text) ?? 0;
    final double weight = double.tryParse(weightController.text) ?? 0;

    if (height > 0 && weight > 0) {
      final date = DateTime.now().toIso8601String();
      await DatabaseHelper().insertRecord(height, weight, date);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('記錄已保存')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('請輸入有效的數據')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI 計算器'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: heightController,
              decoration: InputDecoration(labelText: '身高 (cm)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: '體重 (kg)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateBmi,
              child: Text('計算 BMI'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: saveRecord,
              child: Text('保存記錄'),
            ),
            SizedBox(height: 20),
            if (result.isNotEmpty) ...[
              Text('BMI: $result'),
              Text('健康評價: $evaluation'),
            ]
          ],
        ),
      ),
    );
  }
}
