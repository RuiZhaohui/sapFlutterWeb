class ReportOrder {
  /// 报修人员编码
  String PERNR;

  /// 报修人员名称
  String KTEXT;

  /// 维修类型编码
  String ILART;

  /// 计划员组编码
  String INGRP;

  /// 报修分公司代码
  String MATYP;

  /// 维修区域
  String CPLTX;

  /// 报修区域代码
  String CPLGR;

  /// 报修单号
  String QMNUM;

  /// 报修单名称
  String QMTXT;

  /// 故障描述
  String FETXT;

  /// 设备编码
  String EQUNR;

  /// 设备名称
  String EQKTX;

  /// 故障代码大类
  String FEGRP;

  /// 故障代码细类
  String FECOD;

  /// 功能位置编码
  String TPLNR;

  /// 功能位置名称
  String PLTXT;

  /// 维修工单状态
  String ASTXT;

  /// 报修日期
  String ERDAT;

  /// 报修时间
  String ERTIM;

  /// 是否停机
  bool MSAUS;

  ReportOrder();

  ReportOrder.formJson(Map<String, dynamic> json)
      : PERNR = json['PERNR'],
        KTEXT = json['KTEXT'],
        CPLTX = json['CPLTX'],
        QMNUM = json['QMNUM'],
        QMTXT = json['QMTXT'],
        FETXT = json["FETXT"],
        EQUNR = json['EQUNR'],
        EQKTX = json['EQKTX'],
        TPLNR = json['TPLNR'],
        PLTXT = json['PLTXT'],
        ASTXT = json["ASTXT"],
        ERDAT = json["ERDAT"],
        ERTIM = json["ERTIM"],
        MSAUS = json["MSAUS"];

  Map<String, dynamic> toJson() => <String, dynamic>{
        "PERNR": PERNR,
        "KTEXT": KTEXT,
        "CPLTX": CPLTX,
        "QMNUM": QMNUM,
        "QMTXT": QMTXT,
        "FETXT": FETXT,
        "EQUNR": EQUNR,
        "EQKTX": EQKTX,
        "TPLNR": TPLNR,
        "PLTXT": PLTXT,
        "ASTXT": ASTXT,
        "ERDAT": ERDAT,
        "ERTIM": ERTIM,
        "MSAUS": MSAUS
      };
}
