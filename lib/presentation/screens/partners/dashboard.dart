import 'package:device_info_application/presentation/screens/shared/device_info_service.dart';
import 'package:flutter/material.dart';
import 'package:device_info_application/presentation/screens/device_info.dart';
import 'package:device_info_application/presentation/screens/store_code_input.dart';
import 'package:device_info_application/presentation/screens/display_device.dart';

class DashboardScreen extends StatelessWidget {
  final DeviceInfoService deviceInfoService = DeviceInfoService();

  DashboardScreen({Key? key}) : super(key: key);

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

  void _displayScreen(BuildContext context, int deviceId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DisplayDevice(deviceId: deviceId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: deviceInfoService.getDeviceInfo(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          final deviceId = snapshot.data!['deviceId'] as int;
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
                  SizedBox(height: 20),
                  Text(
                    'Welcome to Your Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  _buildCardButton(
                    icon: Icons.add_circle_outline,
                    title: 'Connect To Store',
                    onPressed: () => _addNewDevice(context),
                  ),
                  SizedBox(height: 16),
                  _buildCardButton(
                    icon: Icons.info_outline,
                    title: 'Device Info',
                    onPressed: () => _deviceInfo(context),
                  ),
                  SizedBox(height: 16),
                  _buildCardButton(
                    icon: Icons.devices,
                    title: 'Display Device',
                    onPressed: () => _displayScreen(context, deviceId),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            body: Center(child: Text('No data available')),
          );
        }
      },
    );
  }

  Widget _buildCardButton({
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.teal,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text(title),
            ),
          ],
        ),
      ),
    );
  }
}
