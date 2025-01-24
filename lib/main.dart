import 'package:flutter/material.dart';
import 'package:health_tips1/pages/sports_facility_map_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:health_tips1/pages/run_tracking_page.dart';
import 'pages/bmi_page.dart';
import 'pages/history_page.dart';

void main() {
  runApp(HealthTipsApp());
}

class HealthTipsApp extends StatefulWidget {
  @override
  _HealthTipsAppState createState() => _HealthTipsAppState();
}

class _HealthTipsAppState extends State<HealthTipsApp> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  // 動態請求權限
  Future<void> _requestPermissions() async {
    if (await Permission.activityRecognition.isDenied) {
      await Permission.activityRecognition.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tips',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // 各頁面
  final List<Widget> _pages = [
    BmiPage(), // BMI 計算頁
    HistoryPage(), // 查看記錄頁
    RunTrackingPage(), // 運動追蹤頁
    SportsFacilityMapPage(), // 運動地點頁
  ];

  // 頁面標題
  final List<String> _titles = [
    'BMI 計算器',
    '查看記錄',
    '運動',
    '運動地點',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'BMI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '記錄',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: '運動',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '地點',
          ),
        ],
      ),
    );
  }
}
