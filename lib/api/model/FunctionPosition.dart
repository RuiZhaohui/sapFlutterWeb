import 'dart:convert';

import 'package:gztyre/api/model/Device.dart';

class FunctionPosition {

  int id;
  String parentId;
  String positionCode;
  String positionName;
  String branchCompanyCode;
  String branchCompanyName;
  List<FunctionPosition> children;
  List<Device> deviceChildren;

  FunctionPosition();

  FunctionPosition.formJson(Map<String, dynamic> json)
      : id = json['id'],
        parentId = json['parentId'],
        positionCode = json['positionCode'],
        positionName = json['positionName'],
        branchCompanyCode = json['branchCompanyCode'],
        branchCompanyName = json["branchCompanyName"],
        children = json['children'].length == 0 ? [] : List<FunctionPosition>.from(json['children'].map((item) {
          return FunctionPosition.formJson(item);
        }).toList()),
        deviceChildren = json['deviceChildren'].length == 0 ? [] : List<Device>.from(json['deviceChildren'].map((item) {
          return Device.formJson(item);
        }).toList());
}