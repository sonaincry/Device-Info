import 'package:android_id/android_id.dart';
import 'package:device_info_application/models/store_device.dart';
import 'package:device_info_application/repository/store_device_repository.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:ui' as ui;

class StoreDeviceFormScreen extends StatefulWidget {
  final StoreDevice? storeDevice;
  final int storeId;

  const StoreDeviceFormScreen(
      {Key? key, this.storeDevice, required this.storeId})
      : super(key: key);

  @override
  _StoreDeviceFormScreenState createState() => _StoreDeviceFormScreenState();
}

class _StoreDeviceFormScreenState extends State<StoreDeviceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final StoreDeviceRepository _storeDeviceRepository = StoreDeviceRepository();

  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _deviceCodeController;

  String deviceName = 'Unknown';
  String deviceCode = 'Unknown';
  double screenWidth = 0;
  double screenHeight = 0;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.storeDevice?.storeDeviceName ?? '');
    _deviceCodeController =
        TextEditingController(text: widget.storeDevice?.deviceCode ?? '');
    _widthController = TextEditingController(
        text: widget.storeDevice?.deviceWidth?.toString() ?? '');
    _heightController = TextEditingController(
        text: widget.storeDevice?.deviceHeight?.toString() ?? '');

    if (widget.storeDevice == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => getDeviceInfo());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _deviceCodeController.dispose();
    super.dispose();
  }

  Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidId _androidIdPlugin = AndroidId();

    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        String? id = await _androidIdPlugin.getId();

        setState(() {
          deviceName = androidInfo.model ?? 'Unknown';
          deviceCode = id ?? 'Unknown';
        });

        _deviceCodeController.text = deviceCode;
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        setState(() {
          deviceName = iosInfo.utsname.machine ?? 'Unknown';
        });
      }

      _nameController.text = deviceName;
    } catch (e) {
      print("Failed to get device info: $e");
    }

    try {
      final window = ui.window;
      setState(() {
        screenWidth = window.physicalSize.width;
        screenHeight = window.physicalSize.height;
        _widthController.text = screenWidth.toString();
        _heightController.text = screenHeight.toString();
      });
    } catch (e) {
      print("Failed to get screen size: $e");
    }
  }

  Future<bool> _validateDevice() async {
    String name = _nameController.text;
    bool exists = await _storeDeviceRepository.deviceExists(
      widget.storeId,
      name,
    );

    if (exists) {
      _showSnackBar('Device already exists', Colors.red);
      return false;
    }

    return true;
  }

  void _saveStoreDevice() async {
    if (_formKey.currentState!.validate()) {
      if (widget.storeDevice == null && !(await _validateDevice())) {
        return;
      }
      final existingDevices =
          await _storeDeviceRepository.getAll(widget.storeId);
      final deviceExists = existingDevices.any((device) =>
          device.storeDeviceName == _nameController.text &&
          device.deviceCode == _deviceCodeController.text &&
          device.deviceWidth == double.tryParse(_widthController.text) &&
          device.deviceHeight == double.tryParse(_heightController.text));

      if (deviceExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device already exists')),
        );
        return;
      }

      final storeDeviceData = {
        'storeId': widget.storeDevice?.storeId ?? widget.storeId,
        'storeDeviceName': _nameController.text,
        'deviceCode': _deviceCodeController.text,
        'deviceWidth': double.tryParse(_widthController.text),
        'deviceHeight': double.tryParse(_heightController.text),
        'isDeleted': false,
      };

      bool success;
      if (widget.storeDevice == null) {
        success =
            await _storeDeviceRepository.createStoreDevice(storeDeviceData);
      } else {
        success = await _storeDeviceRepository.updateStoreDevice(
            widget.storeDevice!.storeDeviceId, storeDeviceData);
      }

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save store device')),
        );
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeDevice == null
            ? 'Create Store Device'
            : 'Edit Store Device'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Device Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _deviceCodeController,
                decoration: const InputDecoration(labelText: 'Device Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device code';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _widthController,
                decoration: const InputDecoration(labelText: 'Device Width'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device width';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Device Height'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device height';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveStoreDevice,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
