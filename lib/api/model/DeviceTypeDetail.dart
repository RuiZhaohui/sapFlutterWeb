class DeviceTypeDetail {

  /// 设备编码
  String EQUNR;

  /// 设备名称
  String EQKTX;

  /// 订单类型数量
  String QUANTITY;

  DeviceTypeDetail();

  DeviceTypeDetail.formJson(Map<String, dynamic> json)
      : EQUNR = json["ILART"],
        EQKTX = json["ILATX"],
        QUANTITY = json["QUANTITY"];

  Map<String, dynamic> toJson() => <String, dynamic>{
    "EQUNR": EQUNR,
    "EQKTX": EQKTX,
    "QUANTITY": QUANTITY
  };
}
