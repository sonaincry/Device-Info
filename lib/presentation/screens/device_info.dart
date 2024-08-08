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
      print("Android info retrieved: ${androidInfo.model}");

      String? id = await _androidIdPlugin.getId();
      print("Android ID retrieved: $id");

      setState(() {
        deviceName = androidInfo.model ?? 'Unknown';
        androidId = id ?? 'Unknown';
      });

      print("Final device name: $deviceName");
      print("Final Android ID: $androidId");
    } catch (e, stackTrace) {
      print("Failed to get device info: $e");
      print("Stack trace: $stackTrace");
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
      print("Screen width: $screenWidth");
      print("Screen height: $screenHeight");
      print("Device pixel ratio: $devicePixelRatio");
    } catch (e) {
      print("Failed to get screen size: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Device Name: $deviceName'),
            SizedBox(height: 16),
            Text('AndroidID: $androidId'),
            SizedBox(height: 16),
            Text('Screen Width: ${screenWidth.toStringAsFixed(2)} px'),
            SizedBox(height: 16),
            Text('Screen Height: ${screenHeight.toStringAsFixed(2)} px'),
          ],
        ),
      ),
    );
  }
}
