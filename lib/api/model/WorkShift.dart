class WorkShift {
  String TPLNR;
  String PLTXT;
  String M_TYPE;

  WorkShift();

  WorkShift.formJson(Map<String, dynamic> json)
      : TPLNR = json['TPLNR'],
        PLTXT = json['PLTXT'],
        M_TYPE = json['M_TYPE'];

  Map<String, dynamic> toJson() => <String, dynamic>{
    "TPLNR": TPLNR,
    "PLTXT": PLTXT,
    "M_TYPE": M_TYPE
  };
}