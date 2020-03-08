class Device {
  int id;
  String parentCode;
  String positionCode;
  String deviceCode;
  String deviceName;
  List<Device> children;

  Device();

  Device.formJson(Map<String, dynamic> json)
      : id = json['id'],
        parentCode = json['parentCode'],
        positionCode = json['positionCode'],
        deviceCode = json['deviceCode'],
        deviceName = json['deviceName'],
        children = json['children'].length == 0 ? [] : List<Device>.from(json['children'].map((item) {
          return Device.formJson(item);
        }).toList());

  Map<String, dynamic> toJson() => <String, dynamic>{
    "id": id,
    "parentCode": parentCode,
    "positionCode": positionCode,
    "deviceCode": deviceCode,
    "deviceName": deviceName,
    "children": []
  };
}