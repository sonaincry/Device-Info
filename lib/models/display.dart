class Display {
  final int displayId;
  final int storeDeviceId;
  final int? menuId;
  final int collectionId;
  final int templateId;
  final int activeHour;
  final bool isChanged;
  final String displayImgPath;
  final Template template;
  final bool isDeleted;

  Display({
    required this.displayId,
    required this.storeDeviceId,
    this.menuId,
    required this.collectionId,
    required this.templateId,
    required this.activeHour,
    required this.isChanged,
    required this.displayImgPath,
    required this.template,
    required this.isDeleted,
  });

  factory Display.fromJson(Map<String, dynamic> json) {
    return Display(
      displayId: json['displayId'],
      storeDeviceId: json['storeDeviceId'],
      menuId: json['menuId'],
      collectionId: json['collectionId'],
      templateId: json['templateId'],
      activeHour: json['activeHour'],
      isChanged: json['isChanged'],
      displayImgPath: json['displayImgPath'],
      template: Template.fromJson(json['template']),
      isDeleted: json['isDeleted'],
    );
  }
}

class Template {
  final int templateId;
  final int brandId;
  final String templateName;
  final String templateDescription;
  final int templateWidth;
  final int templateHeight;
  final int? templateType;
  final String templateImgPath;

  Template({
    required this.templateId,
    required this.brandId,
    required this.templateName,
    required this.templateDescription,
    required this.templateWidth,
    required this.templateHeight,
    required this.templateType,
    required this.templateImgPath,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      templateId: json['templateId'],
      brandId: json['brandId'],
      templateName: json['templateName'],
      templateDescription: json['templateDescription'],
      templateWidth: json['templateWidth'],
      templateHeight: json['templateHeight'],
      templateType: json['templateType'],
      templateImgPath: json['templateImgPath'],
    );
  }
}
