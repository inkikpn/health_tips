import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SportsFacilityMapPage extends StatefulWidget {
  @override
  _SportsFacilityMapPageState createState() => _SportsFacilityMapPageState();
}

class _SportsFacilityMapPageState extends State<SportsFacilityMapPage> {
  Position? _currentPosition;
  List<Marker> _facilityMarkers = [];
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // 獲取當前位置
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("位置服務未啟用");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("位置權限被拒絕");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("位置權限永久被拒絕");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });

      await _fetchNearbyFacilities();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // 查詢附近的體育設施
  Future<void> _fetchNearbyFacilities() async {
    const double radius = 5000; // 搜索半徑（米）
    final url =
        'https://overpass-api.de/api/interpreter?data=[out:json];node(around:$radius,${_currentPosition!.latitude},${_currentPosition!.longitude})["leisure"~"sports_centre|stadium|pitch"];out;';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List elements = data['elements'];

        // 打印返回的數據，用於調試
        print("API 數據：${data}");

        // 解析數據並生成標記
        final markers = elements.map((element) {
          final lat = element['lat'];
          final lon = element['lon'];
          final tags = element['tags'] ?? {};
          final name = tags['name'] ?? '未知體育設施';
          final website = tags['website'] ?? '無網站';

          return Marker(
            point: LatLng(lat, lon),
            child: Tooltip(
              message: "$name\n$website",
              child: Icon(Icons.sports, color: Colors.red, size: 30),
            ),
          );
        }).toList();

        setState(() {
          _facilityMarkers = markers.cast<Marker>();
          _isLoading = false;
        });
      } else {
        throw Exception("無法加載數據，狀態碼：${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('附近體育設施'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text('錯誤：$_errorMessage'))
          : FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                child: Icon(Icons.my_location, color: Colors.blue, size: 40),
              ),
              ..._facilityMarkers, // 添加體育設施的標記
            ],
          ),
        ],
      ),
    );
  }
}
