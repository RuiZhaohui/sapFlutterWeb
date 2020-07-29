class Materiel {
  /// 物料编码
  String MATNR;
  /// 物料名称
  String MAKTX;
  /// 分公司代码
  String MATYP;
  /// 分公司名称
  String MATYT;
  /// 工厂代码
  String WERKS;
  /// 工厂名称
  String NAME1;
  /// 库位代码
  String LGORT;
  /// 库位名称
  String LGOBE;
  /// 库存数量
  int LABST;
  /// 基本单位
  String MEINS;
  /// 库存总数
  int SUMLABST;
  /// 替代料
  List<SubstituteMateriel> list;

  Materiel();

  Materiel.formJson(Map<String, dynamic> json)
      : MATNR=json['materialsCode'],
        MAKTX=json['materialsName'],
        WERKS=json['factoryCode'],
        NAME1=json['factoryName'],
        MEINS=json['unit'];
}

class SubstituteMateriel {
  /// 替代料物料编码
  String REMATNR;
  /// 替代物料名称
  String REMAKTX;
  /// 分公司代码
  String MATYP;
  /// 分公司名称
  String MATYT;
  /// 工厂代码
  String WERKS;
  /// 工厂名称
  String NAME1;
  /// 库位代码
  String LGORT;
  /// 库位名称
  String LGOBE;
  /// 库存数量
  int LABST;
  /// 基本单位
  String MEINS;
  /// 库存总数
  int SUMLABST;
}