import 'package:flutter/material.dart';

class HealthDetailRecordPage extends StatefulWidget {
  final Map<String, dynamic> record;

  const HealthDetailRecordPage({Key? key, required this.record}) : super(key: key);

  @override
  _HealthDetailRecordPageState createState() => _HealthDetailRecordPageState();
}

class _HealthDetailRecordPageState extends State<HealthDetailRecordPage> {
  double age = 25;
  double goalWeight = 70;
  double goalDays = 60;
  String selectedGender = 'male';
  String selectedActivityLevel = '1.55'; // 默認中度活動
  double? tdee;
  double? goalCalories;

  final Map<String, String> activityDescriptions = {
    '1.2': '輕度活動：辦公室工作，缺乏運動',
    '1.375': '輕量活動：偶爾運動或輕體力工作',
    '1.55': '中度活動：每週運動 3-5 次',
    '1.725': '高強度活動：每週運動 6-7 次或重體力工作',
    '1.9': '極高強度活動：每天劇烈運動或重體力勞動',
  };

  // 計算 TDEE
  double calculateTDEE(double weight, double height, double age, String gender, double activityLevel) {
    double bmr;
    if (gender == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }
    return bmr * activityLevel;
  }

  // 計算目標熱量
  void calculateGoalCalories() {
    final double weight = widget.record['weight'];
    final double height = widget.record['height'];
    final double activityLevel = double.parse(selectedActivityLevel);

    // 計算 TDEE
    tdee = calculateTDEE(weight, height, age, selectedGender, activityLevel);

    // 計算每日熱量調整
    final double weightChange = goalWeight - weight;
    const double metabolicAdaptationFactor = 0.9;
    final double dailyAdjustment = (weightChange * 7700 * metabolicAdaptationFactor) / goalDays;

    // 計算目標熱量
    setState(() {
      goalCalories = tdee! + dailyAdjustment;
    });
  }

  @override
  void initState() {
    super.initState();
    calculateGoalCalories(); // 初始化計算
  }

  @override
  Widget build(BuildContext context) {
    final double height = widget.record['height'];
    final double weight = widget.record['weight'];
    final String date = widget.record['date'];
    final double bmi = weight / ((height / 100) * (height / 100));

    // BMI 評估
    String evaluation;
    if (bmi < 18.5) {
      evaluation = '過輕';
    } else if (bmi >= 18.5 && bmi < 24.9) {
      evaluation = '正常';
    } else if (bmi >= 25 && bmi < 29.9) {
      evaluation = '過重';
    } else {
      evaluation = '肥胖';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('詳細記錄'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 基本數據
              Text('身高: $height cm', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('體重: $weight kg', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('日期: $date', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              Text('BMI: ${bmi.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('健康評價: $evaluation', style: TextStyle(fontSize: 18, color: Colors.blueAccent)),
              SizedBox(height: 20),

              // 性別選擇
              Text('性別:', style: TextStyle(fontSize: 18)),
              DropdownButton<String>(
                value: selectedGender,
                items: [
                  DropdownMenuItem(value: 'male', child: Text('男性')),
                  DropdownMenuItem(value: 'female', child: Text('女性')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                    calculateGoalCalories(); // 即時計算
                  });
                },
              ),
              SizedBox(height: 10),

              // 活動水平選擇
              Text('活動水平:', style: TextStyle(fontSize: 18)),
              DropdownButton<String>(
                value: selectedActivityLevel,
                items: activityDescriptions.keys.map((key) {
                  return DropdownMenuItem(
                    value: key,
                    child: Text(activityDescriptions[key]!.split('：')[0]), // 顯示活動名稱
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedActivityLevel = value!;
                    calculateGoalCalories(); // 即時計算
                  });
                },
              ),
              SizedBox(height: 10),

              // 動態顯示活動説明
              Text(
                activityDescriptions[selectedActivityLevel]!,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),

              // 年齡滑塊
              Text('年齡: ${age.toInt()} 歲', style: TextStyle(fontSize: 18)),
              Slider(
                value: age,
                min: 10,
                max: 100,
                divisions: 90,
                label: age.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    age = value;
                    calculateGoalCalories(); // 即時計算
                  });
                },
              ),
              SizedBox(height: 10),

              // 目標體重滑塊
              Text('目標體重: ${goalWeight.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 18)),
              Slider(
                value: goalWeight,
                min: 30,
                max: 200,
                divisions: 170,
                label: goalWeight.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    goalWeight = value;
                    calculateGoalCalories(); // 即時計算
                  });
                },
              ),
              SizedBox(height: 10),

              // 目標時間滑塊
              Text('目標時間: ${goalDays.toInt()} 天', style: TextStyle(fontSize: 18)),
              Slider(
                value: goalDays,
                min: 7,
                max: 365,
                divisions: 358,
                label: goalDays.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    goalDays = value;
                    calculateGoalCalories(); // 即時計算
                  });
                },
              ),
              SizedBox(height: 20),

              // 結果顯示
              if (goalCalories != null) ...[
                Text('TDEE: ${tdee!.toStringAsFixed(2)} 千卡', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('目標熱量: ${goalCalories!.toStringAsFixed(2)} 千卡', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
