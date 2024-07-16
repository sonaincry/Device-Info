import 'package:device_info_plus/device_info_plus.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class DeviceInfoScreen extends StatefulWidget {
  @override
  _DeviceInfoScreenState createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  String deviceName = 'Unknown';
  double screenWidth = 0;
  double screenHeight = 0;
  double devicePixelRatio = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getDeviceInfo());
  }

  Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var deviceData;

    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        setState(() {
          deviceName = androidInfo.model ?? 'Unknown';
        });
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        setState(() {
          deviceName = iosInfo.utsname.machine ?? 'Unknown';
        });
      }
      print("Device name: $deviceName");
    } catch (e) {
      print("Failed to get device info: $e");
    }

    try {
      final window = ui.window;
      setState(() {
        devicePixelRatio = window.devicePixelRatio;
        screenWidth = window.physicalSize.width;
        screenHeight = window.physicalSize.height;
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
            Text('Screen Width: ${screenWidth.toStringAsFixed(2)} px'),
            SizedBox(height: 16),
            Text('Screen Height: ${screenHeight.toStringAsFixed(2)} px'),
          ],
        ),
      ),
    );
  }
}
