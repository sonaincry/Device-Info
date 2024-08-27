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
      appBar: AppBar(
        title: Text('Device Info'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Card for device name
              _buildInfoCard(
                icon: Icons.phone_android,
                label: 'Device Name',
                value: deviceName,
              ),
              SizedBox(height: 16),
              // Card for Android ID
              _buildInfoCard(
                icon: Icons.fingerprint,
                label: 'Android ID',
                value: androidId,
              ),
              SizedBox(height: 16),
              // Card for Screen Width
              _buildInfoCard(
                icon: Icons.straighten,
                label: 'Screen Width',
                value: '${screenWidth.toStringAsFixed(2)} px',
              ),
              SizedBox(height: 16),
              // Card for Screen Height
              _buildInfoCard(
                icon: Icons.straighten,
                label: 'Screen Height',
                value: '${screenHeight.toStringAsFixed(2)} px',
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.teal),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
