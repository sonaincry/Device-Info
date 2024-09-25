import 'dart:convert';
import 'package:device_info_application/models/store_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';
import 'dart:ui' as ui;

class StoreCodeInputScreen extends StatefulWidget {
  @override
  _StoreCodeInputScreenState createState() => _StoreCodeInputScreenState();
}

class _StoreCodeInputScreenState extends State<StoreCodeInputScreen> {
  final TextEditingController storeCodeController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<List<StoreDevice>> fetchExistingDevices(int storeId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/StoreDevices?storeId=$storeId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> devicesJson = jsonDecode(response.body);
        return devicesJson.map((json) => StoreDevice.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load devices');
      }
    } catch (e) {
      print("Error fetching devices: $e");
      return [];
    }
  }

  Future<void> fetchStoreIdAndAddDevice() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String storeCode = storeCodeController.text;
      try {
        final response = await http
            .get(
              Uri.parse(
                  'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Stores?searchString=$storeCode&pageNumber=1&pageSize=10'),
            )
            .timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final List<dynamic> responseData = jsonDecode(response.body);
          if (responseData.isNotEmpty) {
            final storeId = responseData[0]['storeId'];
            if (storeId != null) {
              await _storage.write(key: 'storeId', value: storeId.toString());

              final deviceInfo = await getDeviceInfo();

              final existingDevices = await fetchExistingDevices(storeId);

              bool deviceExists = existingDevices.any((device) =>
                  device.storeDeviceName == deviceInfo['deviceName'] &&
                  device.deviceCode == deviceInfo['deviceCode']);

              if (deviceExists) {
                _showSuccessMessage('Device already connect with the store!');
              } else {
                await addNewDevice(storeId, deviceInfo);
              }
            } else {
              _showErrorMessage('Store ID not found in response');
            }
          } else {
            _showErrorMessage('Store not found');
          }
        } else {
          _showErrorMessage('API Error: ${response.statusCode}');
        }
      } catch (e) {
        _showErrorMessage('Network error: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> addNewDevice(
      int storeId, Map<String, dynamic> deviceInfo) async {
    try {
      final storeDeviceData = {
        'storeId': storeId,
        'storeDeviceName': deviceInfo['deviceName'],
        'deviceCode': deviceInfo['deviceCode'],
        'deviceWidth': deviceInfo['screenWidth'],
        'deviceHeight': deviceInfo['screenHeight'],
        'isDeleted': false,
      };

      final response = await http.post(
        Uri.parse(
            'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/StoreDevices'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(storeDeviceData),
      );

      if (response.statusCode == 201) {
        _showSuccessMessage('Device added successfully');
        Navigator.pop(context);
      } else {
        _showErrorMessage('Failed to add device: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorMessage('Error adding device: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidId _androidIdPlugin = AndroidId();
    String deviceName = 'Unknown';
    String deviceCode = 'Unknown';
    double screenWidth = 0;
    double screenHeight = 0;

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

    return {
      'deviceName': deviceName,
      'deviceCode': deviceCode,
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
    };
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF392850),
      appBar: AppBar(
        backgroundColor: Color(0xFF392850),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 71, 40, 119)!, Color(0xFF392850)!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.store,
                            size: 80,
                            color: Color(0xFF392850),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Enter Store Code',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF392850),
                            ),
                          ),
                          SizedBox(height: 24),
                          TextFormField(
                            controller: storeCodeController,
                            decoration: InputDecoration(
                              labelText: 'Store Code',
                              prefixIcon: Icon(Icons.qr_code),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.blue[800]!, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a store code';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed:
                                _isLoading ? null : fetchStoreIdAndAddDevice,
                            child: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white),
                                  )
                                : Text('Connect'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color(0xFF392850),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    storeCodeController.dispose();
    super.dispose();
  }
}
