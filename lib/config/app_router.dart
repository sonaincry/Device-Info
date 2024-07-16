import 'package:flutter/material.dart';
import 'package:device_info_application/presentation/screens/shared/login_screen.dart';
import 'package:device_info_application/presentation/screens/splash.dart';
import 'package:device_info_application/presentation/widgets/custom_navigation.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => LoginScreen(),
      splash: (context) => SplashScreen(),
      home: (context) => NavigatorProvider(),
    };
  }
}
