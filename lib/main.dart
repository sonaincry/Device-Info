import 'dart:io';

import 'package:device_info_application/presentation/screens/device_info.dart';
import 'package:device_info_application/presentation/screens/partners/dashboard.dart';
import 'package:device_info_application/presentation/screens/partners/home_screen.dart';
import 'package:device_info_application/presentation/screens/shared/login_screen.dart';
import 'package:device_info_application/presentation/screens/store_code_input.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  HttpOverrides.global = _DevHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.phone.request();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: (context, child) => MaterialApp(
        home: DashboardScreen(),
      ),
    );
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
