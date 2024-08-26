import 'package:device_info_application/presentation/screens/store_code_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_application/presentation/screens/partners/store_device_form.dart';

class HomeScreen extends StatelessWidget {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _addNewDevice(BuildContext context) async {
    final storeId = await _storage.read(key: 'storeId');
    if (storeId == null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StoreCodeInputScreen()),
      );
      if (result == true) {
        _navigateToStoreDeviceForm(context);
      }
    } else {
      _navigateToStoreDeviceForm(context);
    }
  }

  void _navigateToStoreDeviceForm(BuildContext context) async {
    final storeId = await _storage.read(key: 'storeId');
    if (storeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              StoreDeviceFormScreen(storeId: int.parse(storeId)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('abc')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _addNewDevice(context),
          child: Text('Add New Device'),
        ),
      ),
    );
  }
}
