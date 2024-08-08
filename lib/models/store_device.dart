class StoreDevice {
  final int storeDeviceId;
  final int storeId;
  final String storeDeviceName;
  final String deviceCode;
  final int deviceWidth;
  final int deviceHeight;
  final dynamic displays;
  final bool isDeleted;

  StoreDevice({
    required this.storeDeviceId,
    required this.storeId,
    required this.storeDeviceName,
    required this.deviceCode,
    required this.deviceWidth,
    required this.deviceHeight,
    this.displays,
    required this.isDeleted,
  });

  factory StoreDevice.fromJson(Map<String, dynamic> json) {
    return StoreDevice(
      storeDeviceId: json['storeDeviceId'],
      storeId: json['storeId'],
      storeDeviceName: json['storeDeviceName'],
      deviceCode: json['deviceCode'],
      deviceWidth: json['deviceWidth'],
      deviceHeight: json['deviceHeight'],
      displays: json['displays'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeDeviceId': storeDeviceId,
      'storeId': storeId,
      'storeDeviceName': storeDeviceName,
      'deviceCode': deviceCode,
      'deviceWidth': deviceWidth,
      'deviceHeight': deviceHeight,
      'displays': displays,
      'isDeleted': isDeleted,
    };
  }
}
