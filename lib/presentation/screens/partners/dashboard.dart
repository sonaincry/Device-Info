import 'package:flutter/material.dart';
import 'package:device_info_application/presentation/screens/shared/device_info_service.dart';
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
          return _buildLoadingScreen();
        } else if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error.toString());
        } else if (snapshot.hasData) {
          final deviceId = snapshot.data!['deviceId'] as int;
          return _buildDashboard(context, deviceId);
        } else {
          return _buildNoDataScreen();
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataScreen() {
    return Scaffold(
      body: Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, int deviceId) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(''),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.teal, Colors.teal.shade200],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.dashboard,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              delegate: SliverChildListDelegate(
                [
                  _buildDashboardCard(
                    icon: Icons.add_circle_outline,
                    title: 'Connect To Store',
                    onTap: () => _addNewDevice(context),
                    color: Colors.blue,
                  ),
                  _buildDashboardCard(
                    icon: Icons.info_outline,
                    title: 'Device Info',
                    onTap: () => _deviceInfo(context),
                    color: Colors.orange,
                  ),
                  _buildDashboardCard(
                    icon: Icons.devices,
                    title: 'Display Device',
                    onTap: () => _displayScreen(context, deviceId),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
