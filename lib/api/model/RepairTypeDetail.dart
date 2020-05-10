class RepairTypeDetail {

  /// 维修类型编码
  String ILART;

  /// 维修类型名称
  String ILATX;

  /// 工单数量
  String QUANTITY;

  RepairTypeDetail();

  RepairTypeDetail.formJson(Map<String, dynamic> json)
      : ILART = json["ILART"],
  ILATX = json["ILATX"],
  QUANTITY = json["QUANTITY"];

  Map<String, dynamic> toJson() => <String, dynamic>{
    "ILART": ILART,
    "ILATX": ILATX,
    "QUANTITY": QUANTITY
  };
}
