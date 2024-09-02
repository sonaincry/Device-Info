import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class DeviceInfoService {
  Future<Map<String, dynamic>> getDeviceInfo(BuildContext context) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidId _androidIdPlugin = AndroidId();
    String deviceName = 'Unknown';
    String deviceCode = 'Unknown';
    double screenWidth = 0;
    double screenHeight = 0;
    int deviceId = 0;

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
      print('Network error: ${e.toString()}');
    }

    return {
      'deviceName': deviceName,
      'deviceCode': deviceCode,
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'deviceId': deviceId,
    };
  }
}
