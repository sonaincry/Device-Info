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

  String deviceName = 'Unknown';
  double screenWidth = 0;
  double screenHeight = 0;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.storeDevice?.storeDeviceName ?? '');
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
    super.dispose();
  }

  Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

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
      _nameController.text = deviceName; // Set device name to controller
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

  void _saveStoreDevice() async {
    if (_formKey.currentState!.validate()) {
      // Check for duplicate device
      final existingDevices =
          await _storeDeviceRepository.getAll(widget.storeId);
      final deviceExists = existingDevices.any((device) =>
          device.storeDeviceName == _nameController.text &&
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
