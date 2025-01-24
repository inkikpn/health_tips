import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class RunTrackingPage extends StatefulWidget {
  @override
  _RunTrackingPageState createState() => _RunTrackingPageState();
}

class _RunTrackingPageState extends State<RunTrackingPage> {
  double _speed = 0.0; // 當前速度 (公里/小時)
  double _acceleration = 0.0; // 當前加速度
  double _previousAcceleration = 0.0; // 上一次加速度
  int _steps = 0; // 步數
  bool _isTracking = false; // 是否正在計步
  DateTime _lastStepTime = DateTime.now(); // 最後一步的時間

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  // 開始加速度計監聽
  void _startListening() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        // 計算加速度模長
        _acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

        // 計算步伐
        _detectStep();
      });
    });
  }

  // 步伐檢測
  void _detectStep() {
    const double stepThreshold = 12.0; // 當加速度大於此閾值時，判定為一步
    const int stepCooldownTime = 1000; // 每步之間的最短間隔時間，防止重複檢測同一步

    // 檢測到步伐
    if (_acceleration > stepThreshold && DateTime.now().difference(_lastStepTime).inMilliseconds > stepCooldownTime) {
      // 檢測到一步，增加步數
      _steps++;
      _lastStepTime = DateTime.now(); // 更新最後一步的時間

      // 計算速度，防止負數
      _speed = max(0.0, (_acceleration - _previousAcceleration) * 3.6); // 轉換為公里/小時，並保證不為負數
      _previousAcceleration = _acceleration; // 更新上一加速度
    }
  }

  // 開始計步
  void _startTracking() {
    setState(() {
      _isTracking = true;
    });
  }

  // 停止計步
  void _stopTracking() {
    setState(() {
      _isTracking = false;
    });

    // 顯示最終步數與速度
    print('運動結束：步數：$_steps');
    print('當前速度：$_speed 公里/小時');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('運動計步器'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '步數：$_steps 步',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '當前速度：${_speed.toStringAsFixed(2)} 公里/小時',
              style: TextStyle(fontSize: 20, color: Colors.blue),
            ),
            SizedBox(height: 20),
            _isTracking
                ? ElevatedButton(
              onPressed: _stopTracking,
              child: Text('結束'),
            )
                : ElevatedButton(
              onPressed: _startTracking,
              child: Text('開始'),
            ),
          ],
        ),
      ),
    );
  }
}
