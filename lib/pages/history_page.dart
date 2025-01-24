import 'package:flutter/material.dart';
import 'package:health_tips1/db/database_helper.dart';
import 'health_detail_record_page.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await DatabaseHelper().getAllRecords();
    setState(() {
      _records = records;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('身高體重記錄'),
      ),
      body: _records.isEmpty
          ? Center(child: Text('目前沒有記錄'))
          : ListView.builder(
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];
          return ListTile(
            title: Text('身高: ${record['height']} cm, 體重: ${record['weight']} kg'),
            subtitle: Text('日期: ${record['date']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HealthDetailRecordPage(record: record),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
