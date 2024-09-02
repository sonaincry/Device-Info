import 'dart:convert';
import 'dart:ui';
import 'package:device_info_application/models/display.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DisplayRepository {
  Future<List<Image>> getDeviceImage(int deviceId) async {
    final url =
        'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Displays/V1/$deviceId/image';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return [Image.memory(response.bodyBytes)];
    } else {
      throw Exception('Failed to load images');
    }
  }

  Future<Template> fetchTemplate(int deviceId) async {
    final url =
        'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Displays/$deviceId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final display = Display.fromJson(jsonResponse);

      return display.template;
    } else {
      throw Exception('Failed to load template');
    }
  }
}
