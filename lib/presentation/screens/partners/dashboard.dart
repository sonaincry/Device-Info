import 'package:flutter/material.dart';
import 'package:device_info_application/presentation/screens/device_info.dart';
import 'package:device_info_application/presentation/screens/store_code_input.dart';
import 'package:device_info_application/presentation/screens/display_device.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({Key? key}) : super(key: key);

  final List<DashboardItem> items = [
    DashboardItem(
      title: 'Connect To Store',
      subtitle: 'Add new device',
      icon: Icons.store,
      color: Colors.blue,
      onTap: (context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StoreCodeInputScreen()),
      ),
    ),
    DashboardItem(
      title: 'Device Info',
      subtitle: 'View device details',
      icon: Icons.info_outline,
      color: Colors.orange,
      onTap: (context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DeviceInfoScreen()),
      ),
    ),
    DashboardItem(
      title: 'Display Device',
      subtitle: 'Show connected device',
      icon: Icons.devices,
      color: Colors.green,
      onTap: (context) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                DisplayDevice(deviceId: 1)), // Assuming a default deviceId of 1
      ),
    ),
    DashboardItem(
      title: 'Settings',
      subtitle: 'App preferences',
      icon: Icons.settings,
      color: Colors.red,
      onTap: (context) {}, // Placeholder for settings navigation
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF392850),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Home",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(16),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: items
                    .map((item) => _buildDashboardItem(context, item))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, DashboardItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => item.onTap(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color.withOpacity(0.8),
                item.color.withOpacity(0.6)
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 50, color: Colors.white),
              SizedBox(height: 12),
              Text(
                item.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                item.subtitle,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
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

class DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Function(BuildContext) onTap;

  DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
