import 'dart:developer';
import 'package:device_info_application/config/base_service.dart';
import 'package:device_info_application/models/store_device.dart';

class StoreDeviceRepository {
  static const String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/StoreDevices';

  final BaseService service = BaseService();

  Future<List<StoreDevice>> getAll(int storeId) async {
    try {
      final response = await service.get(url, queryParameters: {
        'pageNumber': 1,
        'pageSize': 10,
        'storeId': storeId,
      });
      log(response.toString());

      if (response.statusCode == 200) {
        final List<dynamic> storeDevices = response.data;

        return storeDevices
            .map((storeDevice) => StoreDevice.fromJson(storeDevice))
            .toList();
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  Future<bool> createStoreDevice(Map<String, dynamic> requestBody) async {
    try {
      final response = await service.post(url, data: requestBody);

      if (response.statusCode == 201) return true;
      return false;
    } catch (e) {
      throw Exception('Error creating store device: $e');
    }
  }

  Future<bool> updateStoreDevice(
      int storeDeviceId, Map<String, dynamic> requestBody) async {
    try {
      final response = await service.put('$url/$storeDeviceId',
          data: requestBody, statusCodes: [200, 204], queryParameters: {});

      if (response.statusCode == 204 || response.statusCode == 200) return true;
      return false;
    } catch (e) {
      throw Exception('Error updating store device: $e');
    }
  }

  Future<bool> deleteStoreDevice(int storeDeviceId) async {
    try {
      final response =
          await service.delete('$url/$storeDeviceId', statusCodes: [200, 204]);

      if (response.statusCode == 204) return true;
      return false;
    } catch (e) {
      throw Exception('Error deleting store device: $e');
    }
  }
}
