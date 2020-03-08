class RepairOrder {
  /// 报修人员编码
  String PERNR;

  /// 接单人员名称
  String KTEXT;

  /// 维修区域
  String CPLTX;

  /// 维修工单号
  String AUFNR;

  /// 维修工单名称
  String KTEXT_AUFNR;

  /// 故障描述
  String FETXT;

  /// 设备编码
  String EQUNR;

  /// 设备名称
  String EQKTX;

  /// 功能位置编码
  String TPLNR;

  /// 功能位置名称
  String PLTXT;

  /// 维修工单状态
  String ASTTX;

  /// 接单日期
  String ERDAT;

  /// 接单时间
  String ERTIM;

  ///完工日期
  String AEDAT;

  ///完工时间
  String AETIM;

  /// 是否停机
  bool MSAUS;

  /// 故障代码大类
  String FEGRP;
  String KURZTEXT3;

  /// 故障代码细类
  String FECOD;
  String KURZTEXT4;

  /// 原因代码大类
  String URGRP;
  String KURZTEXT;

  /// 原因代码细类
  String URCOD;
  String KURZTEXT1;

  /// 物料列表
  List<Materiel> materielList;

  String APPSTATUS;

  RepairOrder();

  RepairOrder.formJson(Map<String, dynamic> json)
      : PERNR = json['PERNR'],
        KTEXT = json['KTEXT'],
        CPLTX = json['CPLTX'],
        AUFNR = json['AUFNR'],
        KTEXT_AUFNR = json['KTEXT_AUFNR'],
        FETXT = json["FETXT"],
        EQUNR = json['EQUNR'],
        EQKTX = json['EQKTX'],
        TPLNR = json['TPLNR'],
        PLTXT = json['PLTXT'],
        ASTTX = json["ASTTX"],
        ERDAT = json["ERDAT"],
        ERTIM = json["ERTIM"],
        MSAUS = json["MSAUS"],
        AEDAT = json["AEDAT"],
        AETIM = json["AETIM"],
        KURZTEXT3 = json["KURZTEXT3"],
        KURZTEXT4 = json["KURZTEXT4"],
        URGRP = json["URGRP"],
        KURZTEXT = json["KURZTEXT"],
        URCOD = json["URCOD"],
        KURZTEXT1 = json["KURZTEXT1"], APPSTATUS = json["APPSTATUS"];

  Map<String, dynamic> toJson() => <String, dynamic>{
        "PERNR": PERNR,
        "KTEXT": KTEXT,
        "CPLTX": CPLTX,
        "AUFNR": AUFNR,
        "KTEXT_AUFNR": KTEXT_AUFNR,
        "FETXT": FETXT,
        "EQUNR": EQUNR,
        "EQKTX": EQKTX,
        "TPLNR": TPLNR,
        "PLTXT": PLTXT,
        "ASTTX": ASTTX,
        "ERDAT": ERDAT,
        "ERTIM": ERTIM,
        "AEDAT": AEDAT,
        "AETIM": AETIM,
        "MSAUS": MSAUS,
        "KURZTEXT3": KURZTEXT3,
        "KURZTEXT4": KURZTEXT4,
        "URGRP": URGRP,
        "KURZTEXT": KURZTEXT,
        "URCOD": URCOD,
        "KURZTEXT1": KURZTEXT1,
    "APPSTATUS": APPSTATUS
      };
}

class Materiel {
  /// 物料编码
  String MATNR;

  /// 物料描述
  String MAKTX;

  /// 领料数量
  int ENMNG;

  Materiel();

  Materiel.formJson(Map<String, dynamic> json)
      : MATNR = json['MATNR'],
        MAKTX = json['MAKTX'],
        ENMNG = json['ENMNG'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        "MATNR": MATNR,
        "MAKTX": MAKTX,
        "ENMNG": ENMNG,
      };
}
