import 'dart:convert';
import 'package:device_info_application/presentation/screens/partners/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:device_info_application/presentation/widgets/custom_text_field.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    HttpOverrides.global = _DevHttpOverrides();
  }

  void handlerForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        HttpClient client = HttpClient();
        client.badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);

        // Create the request
        HttpClientRequest request = await client.postUrl(
          Uri.parse(
              'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Auth/Login'),
        );

        // Set the headers
        request.headers.set('Content-Type', 'application/json');

        // Add the credentials to the request body
        request.add(utf8.encode(json.encode({
          'userName': emailController.text,
          'password': passwordController.text,
        })));

        // Get the response
        HttpClientResponse response = await request.close();

        if (response.statusCode == 200) {
          String reply = await response.transform(utf8.decoder).join();
          final Map<String, dynamic> responseData = jsonDecode(reply);

          final storeId = responseData['storeId'].toString();

          await _storage.write(key: 'storeId', value: storeId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful!'),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('API Error: ${response.statusCode}')),
          );
        }
      } on HandshakeException catch (e) {
        print('HandshakeException: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Error connecting to server. Please check your network connection.')),
        );
      } catch (e) {
        // Handle other errors
        print('Error during login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during login: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(color: Color.fromARGB(255, 0, 0, 0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(80),
                ),
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    const Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold),
                    ),
                    CustomTextField(
                      controller: emailController,
                      hintText: 'Enter your email',
                      isPassword: false,
                      label: "Email",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: passwordController,
                      hintText: "********",
                      isPassword: true,
                      label: "Password",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      margin: const EdgeInsets.only(top: 50),
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black,
                      ),
                      child: TextButton(
                        onPressed: () {
                          handlerForm();
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 190, 189, 189),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: () {
                        // Navigate to sign-up screen (if implemented)
                      },
                      child: const Text(
                        "Don't have any account? Sign Up",
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
