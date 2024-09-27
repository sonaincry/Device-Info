import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class DeviceInfoScreen extends StatefulWidget {
  @override
  _DeviceInfoScreenState createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  String deviceName = 'Unknown';
  String androidId = 'Unknown';
  double screenWidth = 0;
  double screenHeight = 0;
  double devicePixelRatio = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDeviceInfo();
    });
  }

  Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidId _androidIdPlugin = AndroidId();

    try {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String? id = await _androidIdPlugin.getId();

      setState(() {
        deviceName = androidInfo.model ?? 'Unknown';
        androidId = id ?? 'Unknown';
      });
    } catch (e) {
      setState(() {
        deviceName = 'Error: ${e.toString()}';
        androidId = 'Error: ${e.toString()}';
      });
    }

    try {
      final window = ui.window;
      final pixelRatio = window.devicePixelRatio;
      final physicalSize = window.physicalSize;
      setState(() {
        devicePixelRatio = pixelRatio;
        screenWidth = physicalSize.width;
        screenHeight = physicalSize.height;
      });
    } catch (e) {
      print("Failed to get screen size: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF392850),
      appBar: AppBar(
        backgroundColor: Color(0xFF392850),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 80),
              Text(
                'Device Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoCard(
                        icon: Icons.phone_android,
                        label: 'Device Name',
                        value: deviceName,
                      ),
                      _buildInfoCard(
                        icon: Icons.fingerprint,
                        label: 'Android ID',
                        value: androidId,
                      ),
                      _buildInfoCard(
                        icon: Icons.width_normal,
                        label: 'Screen Width',
                        value: '${screenWidth.toStringAsFixed(2)} px',
                      ),
                      _buildInfoCard(
                        icon: Icons.height,
                        label: 'Screen Height',
                        value: '${screenHeight.toStringAsFixed(2)} px',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF453658),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
