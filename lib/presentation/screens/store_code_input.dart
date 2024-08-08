import 'dart:convert';
import 'package:device_info_application/presentation/screens/partners/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class StoreCodeInputScreen extends StatefulWidget {
  @override
  _StoreCodeInputScreenState createState() => _StoreCodeInputScreenState();
}

class _StoreCodeInputScreenState extends State<StoreCodeInputScreen> {
  final TextEditingController storeCodeController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> fetchStoreId() async {
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

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          final List<dynamic> responseData = jsonDecode(response.body);
          if (responseData.isNotEmpty) {
            final storeId = responseData[0]['storeId'];
            if (storeId != null) {
              await _storage.write(key: 'storeId', value: storeId.toString());

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(storeId: storeId),
                ),
              );
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
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Network error: ${e.toString()}');
      }
    }
  }

  void _showErrorMessage(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Store Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: storeCodeController,
                decoration: InputDecoration(labelText: 'Store Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a store code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : fetchStoreId,
                child:
                    _isLoading ? CircularProgressIndicator() : Text('Submit'),
              ),
            ],
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
