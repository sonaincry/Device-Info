import 'package:device_info_application/presentation/screens/device_info.dart';
import 'package:device_info_application/presentation/screens/store_code_input.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _addNewDevice(context),
              child: Text('Add New Device'),
            ),
            SizedBox(height: 16), // Add some space between buttons
            ElevatedButton(
              onPressed: () => _deviceInfo(context),
              child: Text('Device Info'),
            ),
          ],
        ),
      ),
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
}
