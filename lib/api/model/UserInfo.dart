class UserInfo {

  String PERNR;
  String ENAME;
  String SORTB;
  String SORTT;
  String CPLGR;
  String CPLTX;
  String MATYP;
  String MATYT;
  String WERKS;
  String TXTMD;
  String WCTYPE;
  String M_TYPE;
  String phoneNumber;

  UserInfo();

  UserInfo.formJson(Map<String, dynamic> json)
      : PERNR = json['PERNR'],
        ENAME = json['ENAME'],
        SORTB = json['SORTB'],
        SORTT = json['SORTT'],
        CPLGR = json['CPLGR'],
        CPLTX = json["CPLTX"],
        MATYP = json['MATYP'],
        MATYT = json['MATYT'],
        WERKS = json['WERKS'],
        TXTMD = json['TXTMD'],
        WCTYPE = json["WCTYPE"],
        M_TYPE = json["M_TYPE"],
        phoneNumber = json["phoneNumber"];

  Map<String, dynamic> toJson() => <String, dynamic>{
    "PERNR": PERNR,
    "ENAME": ENAME,
    "SORTB": SORTB,
    "SORTT": SORTT,
    "CPLGR": CPLGR,
    "CPLTX": CPLTX,
    "MATYP": MATYP,
    "MATYT": MATYT,
    "WERKS": WERKS,
    "TXTMD": TXTMD,
    "WCTYPE": WCTYPE,
    "M_TYPE": M_TYPE,
    "phoneNumber": phoneNumber
  };
}