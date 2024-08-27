import 'dart:convert';

import 'package:android_id/android_id.dart';
import 'package:device_info_application/presentation/screens/device_info.dart';
import 'package:device_info_application/presentation/screens/display_device.dart';
import 'package:device_info_application/presentation/screens/store_code_input.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class DashboardScreen extends StatelessWidget {
  int deviceId;

  DashboardScreen({super.key, required this.deviceId});

  Future<Map<String, dynamic>> getDeviceInfo(BuildContext context) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidId _androidIdPlugin = AndroidId();
    String deviceName = 'Unknown';
    String deviceCode = 'Unknown';
    double screenWidth = 0;
    double screenHeight = 0;

    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        String? id = await _androidIdPlugin.getId();
        deviceName = androidInfo.model ?? 'Unknown';
        deviceCode = id ?? 'Unknown';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.utsname.machine ?? 'Unknown';
        deviceCode = iosInfo.identifierForVendor ?? 'Unknown';
      }

      final window = ui.window;
      screenWidth = window.physicalSize.width;
      screenHeight = window.physicalSize.height;
    } catch (e) {
      print("Failed to get device info: $e");
    }

    try {
      final response = await http
          .get(
            Uri.parse(
                'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/StoreDevices?searchString=$deviceName&pageNumber=1&pageSize=10'),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        if (responseData.isNotEmpty) {
          deviceId = responseData[0]['storeDeviceId'];
        }
      }
    } catch (e) {
      _showErrorMessage('Network error: ${e.toString()}', context);
    }
    return {
      'deviceName': deviceName,
      'deviceCode': deviceCode,
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
    };
  }

  void _showErrorMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _deviceInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeviceInfoScreen()),
    );
  }

  void _addNewDevice(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoreCodeInputScreen()),
    );
  }

  void _displayScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DisplayDevice(deviceId: deviceId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Add some padding or margin at the top
            SizedBox(height: 20),

            // Dashboard header
            Text(
              'Welcome to Your Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Create a card for each button to make the UI more structured
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 48,
                      color: Colors.teal,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _addNewDevice(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text('Add New Device'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Colors.teal,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _deviceInfo(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text('Device Info'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 48,
                      color: Colors.teal,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _displayScreen(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text('Add New Device'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
