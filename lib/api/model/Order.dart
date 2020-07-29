class Order {
  /// 报修人员编码
  String PERNR;

  /// 报修人员名称
  String KTEXT;

  /// 维修区域
  String CPLTX;

  /// 报修单号
  String QMNUM;

  /// 报修单名称
  String QMTXT;

  /// 负责人员编码
  String PERNR1;

  /// 负责人员名称
  String KTEXT1;

  /// 维修工单号
  String AUFNR;

  /// 维修工单名称
  String AUFTEXT;

  /// 设备编码
  String EQUNR;

  /// 设备名称
  String EQKTX;

  /// 功能位置编码
  String TPLNR;

  /// 功能位置名称
  String PLTXT;

  /// 修复备件编码
  String BAUTL;

  /// 修复备件名称
  String MAKTX;

  /// 维修工单状态
  String ASTTX;

  /// 接单时间
  String acceptTime;

  /// 完成时间
  String completeTime;

  /// 创建时间
  String createTime;

  /// 是否停机
  bool isStop;

  /// 区域编码
  String CPLGR;

  /// 颜色代码
  String COLORS;

  /// 维修区域编码
  String WCPLGR;

  /// 维修区域名称
  String WCPLTX;

  /// 维修分组描述
  String WXFZ;

  String APPSTATUS;

  /// 维修类型
  String ILART;

  String ILATX;

  /// 报修日期
  String ERDAT;

  /// 报修时间
  String ERTIM;

  /// 接单日期
  String ERDAT2;

  /// 接单时间
  String ERTIM2;

  /// 完成日期
  String ERDAT3;

  /// 完成时间
  String ERTIM3;

  /// 计划日期
  String NPLDA;

  Order();

  Order.formJson(Map<String, dynamic> json)
      : PERNR = json['PERNR'],
        KTEXT = json['KTEXT'],
        CPLTX = json['CPLTX'],
        QMNUM = json['QMNUM'],
        QMTXT = json['QMTXT'],
        PERNR1 = json['PERNR1'],
        KTEXT1 = json['KTEXT1'],
        AUFNR = json['AUFNR'],
        AUFTEXT = json["AUFTEXT"],
        EQUNR = json['EQUNR'],
        EQKTX = json['EQKTX'],
        TPLNR = json['TPLNR'],
        PLTXT = json['PLTXT'],
        BAUTL = json["BAUTL"],
        MAKTX = json["MAKTX"],
        ASTTX = json["ASTTX"],
        acceptTime = json["acceptTime"],
        completeTime = json["completeTime"],
        createTime = json["createTime"],
        isStop = json["isStop"],
        CPLGR = json["CPLGR"],
        COLORS = json["COLORS"],
        WCPLGR = json["WCPLGR"],
        WCPLTX = json["WCPLTX"],
        WXFZ = json["WXFZ"],
        APPSTATUS = json["APPSTATUS"],
        ERDAT = json["ERDAT"],
        ERTIM = json["ERTIM"],
        ERDAT2 = json["ERDAT2"],
        ERTIM2 = json["ERTIM2"],
        ERDAT3 = json["ERDAT3"],
        ERTIM3 = json["ERTIM3"];

  Map<String, dynamic> toJson() => <String, dynamic>{
    "PERNR": PERNR,
    "KTEXT": KTEXT,
    "CPLTX": CPLTX,
    "QMNUM": QMNUM,
    "QMTXT": QMTXT,
    "PERNR1": PERNR1,
    "KTEXT1": KTEXT1,
    "AUFNR": AUFNR,
    "AUFTEXT": AUFTEXT,
    "EQUNR": EQUNR,
    "EQKTX": EQKTX,
    "TPLNR": TPLNR,
    "PLTXT": PLTXT,
    "BAUTL": BAUTL,
    "MAKTX": MAKTX,
    "ASTTX": ASTTX,
    "acceptTime": acceptTime,
    "completeTime": completeTime,
    "createTime": createTime,
    "isStop": isStop,
    "CPLGR": CPLGR,
    "COLORS": COLORS,
    "WCPLGR": WCPLGR,
    "WCPLTX": WCPLTX,
    "WXFZ": WXFZ,
    "APPSTATUS": APPSTATUS,
    "ERDAT": ERDAT,
    "ERTIM": ERTIM,
    "ERDAT2": ERDAT2,
    "ERTIM2": ERTIM2,
    "ERDAT3": ERDAT3,
    "ERTIM3": ERTIM3
  };
}
