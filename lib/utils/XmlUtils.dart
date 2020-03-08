import 'dart:math';

import 'package:dio/dio.dart';
import 'package:gztyre/api/model/Device.dart';
import 'package:gztyre/api/model/FunctionPositionWithDevice.dart';
import 'package:gztyre/api/model/Materiel.dart';
import 'package:gztyre/api/model/Order.dart';
import 'package:gztyre/api/model/ProblemDescription.dart';
import 'package:gztyre/api/model/RepairHistory.dart';
import 'package:gztyre/api/model/RepairOrder.dart' as repair;
import 'package:gztyre/api/model/RepairType.dart';
import 'package:gztyre/api/model/ReportOrder.dart';
import 'package:gztyre/api/model/UserInfo.dart';
import 'package:gztyre/api/model/WorkShift.dart';
import 'package:gztyre/api/model/Worker.dart';
import 'package:xml/xml.dart' as xml;

class XmlUtils {
  static final XmlUtils _singleton = XmlUtils();

  static XmlUtils getInstance() {
    return _singleton;
  }

//  static Xml2Json myTransformer = Xml2Json();

  static xml.XmlNode buildUserInfoXml(String userId) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmSearchPernr", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("EtCplgr", attributes: {"xmlns": ""});
          builder.element("EtMatyp", attributes: {"xmlns": ""});
          builder.element("Pernr", attributes: {"xmlns": ""}, nest: userId);
        });
      });
    });
    return builder.build();
  }

  static UserInfo readUserInfoXml(String stringXml) {
    var document = xml.parse(stringXml);
    UserInfo userInfo = new UserInfo();
    userInfo.PERNR = document.findAllElements("Pernr").first.text;
    userInfo.ENAME = document.findAllElements("Ename").first.text;
    userInfo.SORTB = document.findAllElements("Sortb").first.text;
    userInfo.SORTT = document.findAllElements("Sortt").first.text;
    userInfo.CPLGR = document.findAllElements("Cplgr").first.text;
    userInfo.CPLTX = document.findAllElements("Cpltx").first.text;
    userInfo.MATYP = document.findAllElements("Matyp").first.text;
    userInfo.MATYT = document.findAllElements("Matyt").first.text;
    userInfo.WERKS = document.findAllElements("Werks").first.text;
    userInfo.TXTMD = document.findAllElements("Txtmd").first.text;
    userInfo.WCTYPE = document.findAllElements("Wctype").first.text;
    userInfo.M_TYPE = document.findAllElements("MType").first.text;
    return userInfo;
  }

  static xml.XmlNode buildFunctionPositionXml(String PERNR) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmSearchTplnr", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("EtData", attributes: {"xmlns": ""});
          builder.element("Pernr", attributes: {"xmlns": ""}, nest: PERNR);
        });
      });
    });
    return builder.build();
  }

  static List<FunctionPositionWithDevice> readFunctionPositionXml(
      String stringXml) {
    var document = xml.parse(stringXml);
    List<FunctionPositionWithDevice> list =
        document.findAllElements("item").map((e) {
      FunctionPositionWithDevice functionPositionWithDevice =
          new FunctionPositionWithDevice();
      functionPositionWithDevice.TPLNR = e.findAllElements("Tplnr").first.text;
      functionPositionWithDevice.PLTXT = e.findAllElements("Pltxt").first.text;
      functionPositionWithDevice.TPLNR2 =
          e.findAllElements("Tplnr2").first.text;
      functionPositionWithDevice.PLTXT2 =
          e.findAllElements("Pltxt2").first.text;
      functionPositionWithDevice.EQUNR3 =
          e.findAllElements("Equnr3").first.text;
      functionPositionWithDevice.EQKTX3 =
          e.findAllElements("Eqktx3").first.text;
      functionPositionWithDevice.EQUNR4 =
          e.findAllElements("Equnr4").first.text;
      functionPositionWithDevice.EQKTX4 =
          e.findAllElements("Eqktx4").first.text;
      functionPositionWithDevice.EQUNR5 =
          e.findAllElements("Equnr5").first.text;
      functionPositionWithDevice.EQKTX5 =
          e.findAllElements("Eqktx5").first.text;
      return functionPositionWithDevice;
    }).toList();
    return list;
  }

  static xml.XmlNode buildWorkShiftXml(String PERNR) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmSearchIngrp", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("EtData", attributes: {"xmlns": ""});
          builder.element("Pernr", attributes: {"xmlns": ""}, nest: PERNR);
        });
      });
    });
    return builder.build();
  }

  static List<WorkShift> readWorkShiftXml(String stringXml) {
    var document = xml.parse(stringXml);
    if (document.findAllElements("MType").first.text == "E") {
      return new List();
    }
    List<WorkShift> list = document.findAllElements("item").map((e) {
      WorkShift workShift = new WorkShift();
      workShift.TPLNR = e.findElements("Ingrp").first.text;
      workShift.PLTXT = e.findElements("Innam").first.text;
      return workShift;
    }).toList();
    return list;
  }

  static xml.XmlNode buildOrderXml(String PERNR, String CPLGR, String MATYP,
      String SORTB, String WCTYPE, String ASTTX, List<String> ItWxfz) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmSearchOrder", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("IAppData", attributes: {"xmlns": ""}, nest: () {
            builder.element("Pernr", nest: PERNR);
            builder.element("Cplgr", nest: CPLGR);
            builder.element("Matyp", nest: MATYP);
            builder.element("Sortb", nest: SORTB);
            builder.element("Wctype", nest: WCTYPE);
            builder.element("Asttx", nest: ASTTX);
          });
          builder.element("ItOrder", attributes: {"xmlns": ""});
          builder.element("ItWxfz", attributes: {"xmlns": ""}, nest: () {
            ItWxfz.map((item) {
              return builder.element("item", nest: () {
                builder.element("Wxfz", nest: item);
              });
            }).toList();
          });
        });
      });
    });
    return builder.build();
  }

  static List<Order> readOrderXml(String stringXml) {
    var document = xml.parse(stringXml);
   try {
     List<Order> list = document.findAllElements("item").map((e) {
       Order order = new Order();
       order.PERNR = e.findElements("Pernr").first.text;
       order.KTEXT = e.findElements("Ktext").first.text;
       order.CPLTX = e.findElements("Cpltx").first.text;
       order.QMNUM = e.findElements("Qmnum").first.text;
       order.QMTXT = e.findElements("Qmtxt").first.text;
       order.PERNR1 = e.findElements("Pernr1").first.text;
       order.AUFNR = e.findElements("Aufnr").first.text;
       order.AUFTEXT = e.findElements("Auftext").first.text;
       order.EQUNR = e.findElements("Equnr").first.text;
       order.EQKTX = e.findElements("Eqktx").first.text;
       order.TPLNR = e.findElements("Tplnr").first.text;
       order.PLTXT = e.findElements("Pltxt").first.text;
       order.BAUTL = e.findElements("Bautl").first.text;
       order.MAKTX = e.findElements("Maktx").first.text;
       order.ASTTX = e.findElements("Asttx").first.text;
       order.CPLGR = e.findElements("Cplgr").first.text;
       order.COLORS = e.findElements("Colors").first.text;
       order.WCPLGR = e.findElements("Wcplgr").first.text;
       order.WCPLTX = e.findElements("Wcpltx").first.text;
       order.WXFZ = e.findElements("Wxfz").first.text;
       order.APPSTATUS = e.findElements("Appstatus").first.text;
       order.ILART = e.findAllElements("Ilart").first.text;
       order.ILATX = e.findAllElements("Ilatx").first.text;
       order.ERDAT = e.findElements("Erdat").first.text;
       order.ERTIM = e.findElements("Ertim").first.text;
       order.ERDAT2 = e.findElements("Erdat2").first.text;
       order.ERTIM2 = e.findElements("Ertim2").first.text;
       order.ERDAT3 = e.findElements("Erdat3").first.text;
       order.ERTIM3 = e.findElements("Ertim3").first.text;
       return order;
     }).toList();
     return list;
   } catch (e) {
     throw DioError();
   }
  }

  static xml.XmlNode buildNoPlanOrderXml(String PERNR, String CPLGR, String MATYP,
      String SORTB, String WCTYPE, String ASTTX, String AUART, List<String> ItWxfz) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
          builder.element("Body", nest: () {
            builder.element("ZpmSearchOrderZpm1", attributes: {
              "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
            }, nest: () {
              builder.element("IAppData", attributes: {"xmlns": ""}, nest: () {
                builder.element("Pernr", nest: PERNR);
                builder.element("Cplgr", nest: CPLGR);
                builder.element("Matyp", nest: MATYP);
                builder.element("Sortb", nest: SORTB);
                builder.element("Wctype", nest: WCTYPE);
                builder.element("Asttx", nest: ASTTX);
                builder.element("Auart", nest: AUART);
              });
              builder.element("ItOrder", attributes: {"xmlns": ""});
              builder.element("ItWxfz", attributes: {"xmlns": ""}, nest: () {
                ItWxfz.map((item) {
                  return builder.element("item", nest: () {
                    builder.element("Wxfz", nest: item);
                  });
                }).toList();
              });
            });
          });
        });
    return builder.build();
  }

  static List<Order> readNoPlanOrderXml(String stringXml) {
    var document = xml.parse(stringXml);
    try {
      List<Order> list = document.findAllElements("item").map((e) {
        Order order = new Order();
        order.PERNR = e.findElements("Pernr").first.text;
        order.KTEXT = e.findElements("Ktext").first.text;
        order.CPLTX = e.findElements("Cpltx").first.text;
        order.QMNUM = e.findElements("Qmnum").first.text;
        order.QMTXT = e.findElements("Qmtxt").first.text;
        order.PERNR1 = e.findElements("Pernr1").first.text;
        order.AUFNR = e.findElements("Aufnr").first.text;
        order.AUFTEXT = e.findElements("Auftext").first.text;
        order.EQUNR = e.findElements("Equnr").first.text;
        order.EQKTX = e.findElements("Eqktx").first.text;
        order.TPLNR = e.findElements("Tplnr").first.text;
        order.PLTXT = e.findElements("Pltxt").first.text;
        order.BAUTL = e.findElements("Bautl").first.text;
        order.MAKTX = e.findElements("Maktx").first.text;
        order.ASTTX = e.findElements("Asttx").first.text;
        order.CPLGR = e.findElements("Cplgr").first.text;
        order.COLORS = e.findElements("Colors").first.text;
        order.WCPLGR = e.findElements("Wcplgr").first.text;
        order.WCPLTX = e.findElements("Wcpltx").first.text;
        order.WXFZ = e.findElements("Wxfz").first.text;
        order.APPSTATUS = e.findElements("Appstatus").first.text;
        order.ILART = e.findAllElements("Ilart").first.text;
        order.ILATX = e.findAllElements("Ilatx").first.text;
        order.ERDAT = e.findElements("Erdat").first.text;
        order.ERTIM = e.findElements("Ertim").first.text;
        order.ERDAT2 = e.findElements("Erdat2").first.text;
        order.ERTIM2 = e.findElements("Ertim2").first.text;
        order.ERDAT3 = e.findElements("Erdat3").first.text;
        order.ERTIM3 = e.findElements("Ertim3").first.text;
        order.NPLDA = e.findAllElements("Nplda").first.text;
        return order;
      }).toList();
      return list;
    } catch (e) {
      throw DioError();
    }
  }

  static xml.XmlNode buildPlanOrderXml(String PERNR, String CPLGR, String MATYP,
      String SORTB, String WCTYPE, String ASTTX, String AUART, List<String> ItWxfz) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
          builder.element("Body", nest: () {
            builder.element("ZpmSearchOrderZpm2", attributes: {
              "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
            }, nest: () {
              builder.element("IAppData", attributes: {"xmlns": ""}, nest: () {
                builder.element("Pernr", nest: PERNR);
                builder.element("Cplgr", nest: CPLGR);
                builder.element("Matyp", nest: MATYP);
                builder.element("Sortb", nest: SORTB);
                builder.element("Wctype", nest: WCTYPE);
                builder.element("Asttx", nest: ASTTX);
                builder.element("Auart", nest: AUART);
              });
              builder.element("ItOrder", attributes: {"xmlns": ""});
              builder.element("ItWxfz", attributes: {"xmlns": ""}, nest: () {
                ItWxfz.map((item) {
                  return builder.element("item", nest: () {
                    builder.element("Wxfz", nest: item);
                  });
                }).toList();
              });
            });
          });
        });
    return builder.build();
  }

  static List<Order> readPlanOrderXml(String stringXml) {
    var document = xml.parse(stringXml);
    try {
      List<Order> list = document.findAllElements("item").map((e) {
        Order order = new Order();
        order.PERNR = e.findElements("Pernr").first.text;
        order.KTEXT = e.findElements("Ktext").first.text;
        order.CPLTX = e.findElements("Cpltx").first.text;
        order.QMNUM = e.findElements("Qmnum").first.text;
        order.QMTXT = e.findElements("Qmtxt").first.text;
        order.PERNR1 = e.findElements("Pernr1").first.text;
        order.AUFNR = e.findElements("Aufnr").first.text;
        order.AUFTEXT = e.findElements("Auftext").first.text;
        order.EQUNR = e.findElements("Equnr").first.text;
        order.EQKTX = e.findElements("Eqktx").first.text;
        order.TPLNR = e.findElements("Tplnr").first.text;
        order.PLTXT = e.findElements("Pltxt").first.text;
        order.BAUTL = e.findElements("Bautl").first.text;
        order.MAKTX = e.findElements("Maktx").first.text;
        order.ASTTX = e.findElements("Asttx").first.text;
        order.CPLGR = e.findElements("Cplgr").first.text;
        order.COLORS = e.findElements("Colors").first.text;
        order.WCPLGR = e.findElements("Wcplgr").first.text;
        order.WCPLTX = e.findElements("Wcpltx").first.text;
        order.WXFZ = e.findElements("Wxfz").first.text;
        order.APPSTATUS = e.findElements("Appstatus").first.text;
        order.ILART = e.findAllElements("Ilart").first.text;
        order.ILATX = e.findAllElements("Ilatx").first.text;
        order.ERDAT = e.findElements("Erdat").first.text;
        order.ERTIM = e.findElements("Ertim").first.text;
        order.ERDAT2 = e.findElements("Erdat2").first.text;
        order.ERTIM2 = e.findElements("Ertim2").first.text;
        order.ERDAT3 = e.findElements("Erdat3").first.text;
        order.ERTIM3 = e.findElements("Ertim3").first.text;
        order.NPLDA = e.findAllElements("Nplda").first.text;
        return order;
      }).toList();
      return list;
    } catch (e) {
      throw DioError();
    }
  }

  static xml.XmlNode buildAssisantOrderXml(String PERNR, String CPLGR, String MATYP,
      String SORTB, String WCTYPE, String ASTTX, String AUART, List<String> ItWxfz) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
          builder.element("Body", nest: () {
            builder.element("ZpmSearchOrderZpm3", attributes: {
              "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
            }, nest: () {
              builder.element("IAppData", attributes: {"xmlns": ""}, nest: () {
                builder.element("Pernr", nest: PERNR);
                builder.element("Cplgr", nest: CPLGR);
                builder.element("Matyp", nest: MATYP);
                builder.element("Sortb", nest: SORTB);
                builder.element("Wctype", nest: WCTYPE);
                builder.element("Asttx", nest: ASTTX);
                builder.element("Auart", nest: AUART);
              });
              builder.element("ItOrder", attributes: {"xmlns": ""});
              builder.element("ItWxfz", attributes: {"xmlns": ""}, nest: () {
                ItWxfz.map((item) {
                  return builder.element("item", nest: () {
                    builder.element("Wxfz", nest: item);
                  });
                }).toList();
              });
            });
          });
        });
    return builder.build();
  }

  static List<Order> readAssisantOrderXml(String stringXml) {
    var document = xml.parse(stringXml);
    try {
      List<Order> list = document.findAllElements("item").map((e) {
        Order order = new Order();
        order.PERNR = e.findElements("Pernr").first.text;
        order.KTEXT = e.findElements("Ktext").first.text;
        order.CPLTX = e.findElements("Cpltx").first.text;
        order.QMNUM = e.findElements("Qmnum").first.text;
        order.QMTXT = e.findElements("Qmtxt").first.text;
        order.PERNR1 = e.findElements("Pernr1").first.text;
        order.AUFNR = e.findElements("Aufnr").first.text;
        order.AUFTEXT = e.findElements("Auftext").first.text;
        order.EQUNR = e.findElements("Equnr").first.text;
        order.EQKTX = e.findElements("Eqktx").first.text;
        order.TPLNR = e.findElements("Tplnr").first.text;
        order.PLTXT = e.findElements("Pltxt").first.text;
        order.BAUTL = e.findElements("Bautl").first.text;
        order.MAKTX = e.findElements("Maktx").first.text;
        order.ASTTX = e.findElements("Asttx").first.text;
        order.CPLGR = e.findElements("Cplgr").first.text;
        order.COLORS = e.findElements("Colors").first.text;
        order.WCPLGR = e.findElements("Wcplgr").first.text;
        order.WCPLTX = e.findElements("Wcpltx").first.text;
        order.WXFZ = e.findElements("Wxfz").first.text;
        order.APPSTATUS = e.findElements("Appstatus").first.text;
        order.ILART = e.findAllElements("Ilart").first.text;
        order.ILATX = e.findAllElements("Ilatx").first.text;
        order.ERDAT = e.findElements("Erdat").first.text;
        order.ERTIM = e.findElements("Ertim").first.text;
        order.ERDAT2 = e.findElements("Erdat2").first.text;
        order.ERTIM2 = e.findElements("Ertim2").first.text;
        order.ERDAT3 = e.findElements("Erdat3").first.text;
        order.ERTIM3 = e.findElements("Ertim3").first.text;
        order.NPLDA = e.findAllElements("Nplda").first.text;
        return order;
      }).toList();
      return list;
    } catch (e) {
      throw DioError();
    }
  }

  static xml.XmlNode buildBlockOrderXml(String PERNR, String CPLGR, String MATYP,
      String SORTB, String WCTYPE, String ASTTX, String AUART, List<String> ItWxfz) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
          builder.element("Body", nest: () {
            builder.element("ZpmSearchOrderZpm4", attributes: {
              "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
            }, nest: () {
              builder.element("IAppData", attributes: {"xmlns": ""}, nest: () {
                builder.element("Pernr", nest: PERNR);
                builder.element("Cplgr", nest: CPLGR);
                builder.element("Matyp", nest: MATYP);
                builder.element("Sortb", nest: SORTB);
                builder.element("Wctype", nest: WCTYPE);
                builder.element("Asttx", nest: ASTTX);
                builder.element("Auart", nest: AUART);
              });
              builder.element("ItOrder", attributes: {"xmlns": ""});
              builder.element("ItWxfz", attributes: {"xmlns": ""}, nest: () {
                ItWxfz.map((item) {
                  return builder.element("item", nest: () {
                    builder.element("Wxfz", nest: item);
                  });
                }).toList();
              });
            });
          });
        });
    return builder.build();
  }

  static List<Order> readBlockOrderXml(String stringXml) {
    var document = xml.parse(stringXml);
    try {
      List<Order> list = document.findAllElements("item").map((e) {
        Order order = new Order();
        order.PERNR = e.findElements("Pernr").first.text;
        order.KTEXT = e.findElements("Ktext").first.text;
        order.CPLTX = e.findElements("Cpltx").first.text;
        order.QMNUM = e.findElements("Qmnum").first.text;
        order.QMTXT = e.findElements("Qmtxt").first.text;
        order.PERNR1 = e.findElements("Pernr1").first.text;
        order.AUFNR = e.findElements("Aufnr").first.text;
        order.AUFTEXT = e.findElements("Auftext").first.text;
        order.EQUNR = e.findElements("Equnr").first.text;
        order.EQKTX = e.findElements("Eqktx").first.text;
        order.TPLNR = e.findElements("Tplnr").first.text;
        order.PLTXT = e.findElements("Pltxt").first.text;
        order.BAUTL = e.findElements("Bautl").first.text;
        order.MAKTX = e.findElements("Maktx").first.text;
        order.ASTTX = e.findElements("Asttx").first.text;
        order.CPLGR = e.findElements("Cplgr").first.text;
        order.COLORS = e.findElements("Colors").first.text;
        order.WCPLGR = e.findElements("Wcplgr").first.text;
        order.WCPLTX = e.findElements("Wcpltx").first.text;
        order.WXFZ = e.findElements("Wxfz").first.text;
        order.APPSTATUS = e.findElements("Appstatus").first.text;
        order.ILART = e.findAllElements("Ilart").first.text;
        order.ILATX = e.findAllElements("Ilatx").first.text;
        order.ERDAT = e.findElements("Erdat").first.text;
        order.ERTIM = e.findElements("Ertim").first.text;
        order.ERDAT2 = e.findElements("Erdat2").first.text;
        order.ERTIM2 = e.findElements("Ertim2").first.text;
        order.ERDAT3 = e.findElements("Erdat3").first.text;
        order.ERTIM3 = e.findElements("Ertim3").first.text;
        order.NPLDA = e.findAllElements("Nplda").first.text;
        return order;
      }).toList();
      return list;
    } catch (e) {
      throw DioError();
    }
  }

  static xml.XmlNode buildRepairTypeXml() {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmSearchIlart", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("EtData", attributes: {"xmlns": ""});
        });
      });
    });
    return builder.build();
  }

  static xml.XmlNode buildReportOrderDetailXml(String QMNUM) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmSearchOrdermess", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("Qmnum", attributes: {"xmlns": ""}, nest: QMNUM);
        });
      });
    });
    return builder.build();
  }

  static ReportOrder readReportOrderDetailXml(String stringXml) {
    var document = xml.parse(stringXml);
    ReportOrder order = new ReportOrder();
    order.PERNR = document.findAllElements("Pernr").first.text;
    order.KTEXT = document.findAllElements("Ktext").first.text;
    order.ILART = document.findAllElements("Ilart").first.text;
    order.INGRP = document.findAllElements("Ingrp").first.text;
    order.MATYP = document.findAllElements("Matyp").first.text;
    order.CPLTX = document.findAllElements("Cpltx").first.text;
    order.CPLGR = document.findAllElements("Cplgr").first.text;
    order.QMNUM = document.findAllElements("Qmnum").first.text;
    order.QMTXT = document.findAllElements("Qmtxt").first.text;
    order.FETXT = document.findAllElements("Fetxt").first.text;
    order.EQUNR = document.findAllElements("Equnr").first.text;
    order.EQKTX = document.findAllElements("Eqktx").first.text;
    order.FEGRP = document.findAllElements("Fegrp").first.text;
    order.FECOD = document.findAllElements("Fecod").first.text;
    order.TPLNR = document.findAllElements("Tplnr").first.text;
    order.PLTXT = document.findAllElements("Pltxt").first.text;
    order.ASTXT = document.findAllElements("Astxt").first.text;
    order.MSAUS =
        document.findAllElements("Msaus").first.text == "X" ? true : false;
    order.ERDAT = document.findAllElements("Erdat").first.text;
    order.ERTIM = document.findAllElements("Ertim").first.text;
    return order;
  }

  static xml.XmlNode buildRepairOrderHistoryXml(String AUFNR) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmSearchWxrec", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("Aufnr", attributes: {"xmlns": ""}, nest: AUFNR);
          builder.element("EtData", attributes: {"xmlns": ""});
          builder.element("EtResb", attributes: {"xmlns": ""});
        });
      });
    });
    return builder.build();
  }

  static List<RepairHistory> readRepairOrderHistoryXml(String stringXml) {
    var document = xml.parse(stringXml);
    List<RepairHistory> list = new List();
    try {
      document
          .findAllElements("EtData")
          .first
          .findAllElements("item")
          .forEach((item) {
        RepairHistory order = new RepairHistory();
        order.PERNR = item.findAllElements("Pernr").first.text;
        order.KTEXT = item.findAllElements("Ktext").first.text;
        order.MAKTX = '';
        order.ENMG = '';
        order.ERDAT = item.findAllElements("Erdat").first.text;
        order.ERTIM = item.findAllElements("Ertim").first.text;
        order.KTEXT2 = item.findAllElements("Ktext2").first.text;
        order.PERNR1 = item.findAllElements("Pernr1").first.text;
        order.APPSTATUS = item.findAllElements("Appstatus").first.text;
        list.add(order);
      });
      if (document.findAllElements("EtResb").first.text == "") {
        list.sort((a, b) {
          return DateTime.parse('${a.ERDAT} ${a.ERTIM}').compareTo(DateTime.parse('${b.ERDAT} ${b.ERTIM}'));
        });
        return list;
      }
      document
          .findAllElements("EtResb")
          .first
          .findAllElements("item")
          .forEach((item) {
        RepairHistory order = new RepairHistory();
        order.PERNR =  '';
        order.KTEXT = "";
        order.KTEXT2 = "";
        order.PERNR1 = "";
        order.MAKTX = item.findAllElements("Maktx").first.text;
        order.ENMG = item.findAllElements("Enmg").first.text;
        order.ERDAT = item.findAllElements("Erdat").first.text;
        order.ERTIM = item.findAllElements("Ertim").first.text;
        order.APPSTATUS = item.findAllElements("Appstatus").first.text;
        if (order.ERDAT != "00-00-00") {
          list.add(order);
        }
      });
      list.sort((a, b) {
        return DateTime.parse('${a.ERDAT} ${a.ERTIM}').compareTo(DateTime.parse('${b.ERDAT} ${b.ERTIM}'));
      });
      return list;
    } catch (e) {
      throw DioError();
    }
  }

  static xml.XmlNode buildRepairOrderDetailXml(String AUFNR) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmSearchInfo", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("IvAufnr", attributes: {"xmlns": ""}, nest: AUFNR);
          builder.element("ItInfo", attributes: {"xmlns": ""});
        });
      });
    });
    return builder.build();
  }

  static repair.RepairOrder readRepairOrderDetailXml(String stringXml) {
    var document = xml.parse(stringXml);
    repair.RepairOrder order = new repair.RepairOrder();
    try {
      var infoDom = document.findAllElements("ItInfo").first;
      order.PERNR = infoDom.findAllElements("Pernr").first.text;
      order.KTEXT = infoDom.findAllElements("Ktext").first.text;
      order.CPLTX = infoDom.findAllElements("Cpltx").first.text;
      order.AUFNR = infoDom.findAllElements("Aufnr").first.text;
      order.KTEXT_AUFNR = infoDom.findAllElements("KtextAufnr").first.text;
      order.EQUNR = infoDom.findAllElements("Equnr").first.text;
      order.EQKTX = infoDom.findAllElements("Eqktx").first.text;
      order.TPLNR = infoDom.findAllElements("Tplnr").first.text;
      order.PLTXT = infoDom.findAllElements("Pltxt").first.text;
      order.FETXT = infoDom.findAllElements("Fetxt").first.text;
      order.ASTTX = infoDom.findAllElements("Asttx").first.text;
      order.MSAUS =
      infoDom.findAllElements("Msaus").first.text == "X" ? true : false;
      order.FEGRP = infoDom.findAllElements("Fegrp").first.text;
      order.KURZTEXT3 = infoDom.findAllElements("Kurztext3").first.text;
      order.FECOD = infoDom.findAllElements("Fecod").first.text;
      order.KURZTEXT4 = infoDom.findAllElements("Kurztext4").first.text;
      order.URGRP = infoDom.findAllElements("Urgrp").first.text;
      order.KURZTEXT = infoDom.findAllElements("Kurztext").first.text;
      order.URCOD = infoDom.findAllElements("Urcod").first.text;
      order.KURZTEXT1 = infoDom.findAllElements("Kurztext1").first.text;
      order.ERDAT = infoDom.findAllElements("Erdat").first.text.substring(2, 8);
      order.ERTIM = infoDom.findAllElements("Ertim").first.text.substring(0, 5);
      order.AEDAT = infoDom.findAllElements("Aedat").first.text.substring(2, 8);
      order.AETIM = infoDom.findAllElements("Aetim").first.text.substring(0, 5);
      order.materielList = new List();
      infoDom.findAllElements("item").forEach((item) {
        if (item.findAllElements("Maktx").first.text != "" &&
            item.findAllElements("Maktx").first.text != null) {
          repair.Materiel materiel = new repair.Materiel();
          materiel.MATNR = item.findAllElements("Matnr").first.text;
          materiel.MAKTX = item.findAllElements("Maktx").first.text;
          materiel.ENMNG =
              double.parse(item.findAllElements("Enmng").first.text).toInt();
          order.materielList.add(materiel);
        }
      });
      return order;
    } catch (e) {
      throw DioError();
    }
  }

  static xml.XmlNode buildOtherDeviceXml(String AUFNR) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
          builder.element("Body", nest: () {
            builder.element("ZpmSearchInfo", attributes: {
              "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
            }, nest: () {
              builder.element("IvAufnr", attributes: {"xmlns": ""}, nest: AUFNR);
              builder.element("ItInfo", attributes: {"xmlns": ""});
              builder.element("ItEqunr", attributes: {"xmlns": ""});
            });
          });
        });
    return builder.build();
  }

  static List<Device> readOtherDeviceXml(String stringXml) {
    var document = xml.parse(stringXml);
    List<Device> list = new List();
    var deviceDom = document.findAllElements("ItEqunr").first;
    try {
      list = deviceDom.findAllElements("item").map((e) {
        Device device = new Device();
        device.deviceName = e.findAllElements("Eqktx").first.text;
        device.deviceCode = e.findAllElements("Equnr").first.text;
        return device;
      }).toList();
      return list;
    } catch (e) {
      return new List();
    }
  }

  static List<RepairType> readRepairTypeXml(String stringXml) {
    var document = xml.parse(stringXml);
    try {
      if (document.findAllElements("MType").first.text == "E") {
        return new List();
      }
    } catch (e) {
      print(e);
    }
    List<RepairType> list = document.findAllElements("item").map((e) {
      RepairType repairType = new RepairType();
      repairType.ILART = e.findAllElements("Ilart").first.text;
      repairType.ILATX = e.findAllElements("Ilatx").first.text;
      return repairType;
    }).toList();
    return list;
  }

  static xml.XmlNode buildProblemDescriptionXml(String Katalogart) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmSearchKatalogart", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("EtData", attributes: {"xmlns": ""});
          builder.element("Katalogart",
              attributes: {"xmlns": ""}, nest: Katalogart);
        });
      });
    });
    return builder.build();
  }

  static List<ProblemDescription> readProblemDescriptionXml(String stringXml) {
    var document = xml.parse(stringXml);
    if (document.findAllElements("MType").first.text == "E") {
      return new List();
    }
    List<ProblemDescription> list = new List();
    document.findAllElements("item").map((e) {
      if (list.any((item) {
        return item.title == e.findAllElements("Kurztext").first.text;
      })) {
        list.firstWhere((item) {
          return item.title == e.findAllElements("Kurztext").first.text;
        }).content.add({
          "code": e.findAllElements("Code").first.text,
          "text": e.findAllElements("KurztextCode").first.text
        });
      } else {
        ProblemDescription problemDescription = new ProblemDescription();
        problemDescription.title = e.findAllElements("Kurztext").first.text;
        problemDescription.group = e.findAllElements("Codegruppe").first.text;
        problemDescription.content = new List();
        problemDescription.content.add({
          "code": e.findAllElements("Code").first.text,
          "text": e.findAllElements("KurztextCode").first.text
        });
        list.add(problemDescription);
      }
    }).toList();
    return list;
  }

  static xml.XmlNode buildReportOrderXml(
      String PERNR,
      String INGRP,
      String ILART,
      String EQUNR,
      String TPLNR,
      String FEGRP,
      String FECOD,
      String FETXT,
      String CPLGR,
      String MATYP,
      String MSAUS,
      String APPTRADENO) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmCreateIw21", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("EtMessage", attributes: {"xmlns": ""});
          builder.element("IData", attributes: {"xmlns": ""}, nest: () {
            builder.element("Pernr", nest: PERNR);
            builder.element("Ingrp", nest: INGRP);
            builder.element("Ilart", nest: ILART);
            builder.element("Equnr", nest: EQUNR);
            builder.element("Tplnr", nest: TPLNR);
            builder.element("Fegrp", nest: FEGRP);
            builder.element("Fecod", nest: FECOD);
            builder.element("Fetxt", nest: FETXT);
            builder.element("Cplgr", nest: CPLGR);
            builder.element("Matyp", nest: MATYP);
            builder.element("Msaus", nest: MSAUS);
            builder.element("Apptradeno", nest: APPTRADENO);
          });
        });
      });
    });
    return builder.build();
  }

  static Map<String, String> readReportOrderXml(String stringXml) {
    var document = xml.parse(stringXml);
    try {
      if (document.findAllElements("Type").first.text == "E") {
        throw DioError();
      }
    } catch (e) {
      throw DioError();
    }
    Map<String, String> map = new Map();
    map.putIfAbsent("QMNUM", () {
      return document.findAllElements("Qmnum").first.text;
    });
    map.putIfAbsent("WCPLGR", () {
      return document.findAllElements("Wcplgr").first.text;
    });
    map.putIfAbsent("COLORS", () {
      return document.findAllElements("Colors").first.text;
    });
    map.putIfAbsent("WCPLTX", () {
      return document.findAllElements("Wcpltx").first.text;
    });
    map.putIfAbsent("WXFZ", () {
      return document.findAllElements("Wxfz").first.text;
    });
    map.putIfAbsent("TYPE", () {
      return document.findAllElements("Type").first.text;
    });
    return map;
  }

  static xml.XmlNode buildRepairOrderXml(
      String PERNR,
      String INGRP,
      String ILART,
      String QMNUM,
      String EQUNR,
      String TPLNR,
      String FEGRP,
      String FECOD,
      String FETXT,
      String CPLGR,
      String MATYP,
      String MSAUS,
      String APPTRADENO,
      String BAUTL) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmCreateOrder", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("ItReturn", attributes: {"xmlns": ""});
          builder.element("IAppData", attributes: {"xmlns": ""}, nest: () {
            builder.element("Pernr", nest: PERNR);
            builder.element("Ingrp", nest: INGRP);
            builder.element("Ilart", nest: ILART);
            builder.element("Qmnum", nest: QMNUM);
            builder.element("Equnr", nest: EQUNR);
            builder.element("Tplnr", nest: TPLNR);
            builder.element("Fegrp", nest: FEGRP);
            builder.element("Fecod", nest: FECOD);
            builder.element("Fetxt", nest: FETXT);
            builder.element("Cplgr", nest: CPLGR);
            builder.element("Matyp", nest: MATYP);
            builder.element("Msaus", nest: MSAUS);
            builder.element("Apptradeno", nest: APPTRADENO);
            builder.element("Bault", nest: BAUTL ?? "");
          });
        });
      });
    });
    return builder.build();
  }

  static String readRepairOrderXml(String stringXml) {
    var document = xml.parse(stringXml);
    try {
      if (document.findAllElements("Type").first.text == "E") {
        throw DioError();
      } else {
        return document.findAllElements("Aufnr").first.text;
      }
    } catch (e) {
      throw DioError();
    }
  }

  static xml.XmlNode buildChangeOrderXml(
      String PERNR,
      String QMNUM,
      String AUFNR,
      String APPSTATUS,
      String APPTRADENO,
      String URGRP,
      String URCOD,
      String EQUNR,
      String KTEXT,
      List<Worker> list) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmChangeOrderStatus", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("IData", attributes: {"xmlns": ""}, nest: () {
            builder.element("Pernr", nest: PERNR);
            builder.element("Qmnum", nest: QMNUM);
            builder.element("Aufnr", nest: AUFNR);
            builder.element("Appstatus", nest: APPSTATUS);
            builder.element("Apptradeno", nest: APPTRADENO);
            builder.element("Urgrp", nest: URGRP);
            builder.element("Urcod", nest: URCOD);
            builder.element("Equnr", nest: EQUNR);
            builder.element("Ktext", nest: KTEXT);
          });
          builder.element("ItData", attributes: {"xmlns": ""}, nest: () {
            if (list != null) {
              list.map((item) {
                return builder.element("item", nest: () {
                  builder.element("Aufnr", nest: AUFNR);
                  builder.element("Pernr1", nest: item.PERNR);
                });
              }).toList();
            }
          });
        });
      });
    });
    return builder.build();
  }

  static bool readChangeOrderXml(String stringXml) {
    var document = xml.parse(stringXml);
    try {
      bool flag = false;
      document.findAllElements("MType").forEach((item) {
        if (item.text == "S") flag = true;
      });
      if (flag) {
        return true;
      } else
        throw DioError();
    } catch (e) {
      throw DioError();
    }
  }

  static xml.XmlNode buildOuterRepairXml(
      String AUFNR,
      String PERNR) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
          builder.element("Body", nest: () {
            builder.element("ZpmChangeWw", attributes: {
              "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
            }, nest: () {
              builder.element("Aufnr", attributes: {"xmlns": ""}, nest: AUFNR);
              builder.element("Pernr", attributes: {"xmlns": ""}, nest: PERNR);
            });
          });
        });
    return builder.build();
  }

  static bool readOuterRepairXml(String stringXml) {
    var document = xml.parse(stringXml);
    try {
      bool flag = false;
      document.findAllElements("MType").forEach((item) {
        if (item.text == "S") flag = true;
      });
      if (flag) {
        return true;
      } else
        throw DioError();
    } catch (e) {
      throw DioError();
    }
  }

  static xml.XmlNode buildCompleteOrderXml(
      String PERNR, String AUFNR, String APPSTATUS, String APPTRADENO) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmOrderConfirm", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("IData", attributes: {"xmlns": ""}, nest: () {
            builder.element("Pernr", nest: PERNR);
            builder.element("Aufnr", nest: AUFNR);
            builder.element("Appstatus", nest: APPSTATUS);
            builder.element("Apptradeno", nest: APPTRADENO);
          });
          builder.element("ItData", attributes: {"xmlns": ""});
        });
      });
    });
    return builder.build();
  }

  static bool readCompleteOrderXml(String stringXml) {
    var document = xml.parse(stringXml);
    try {
      if (document.findAllElements("MType").first.text == "E") throw DioError();
//      forEach((item) {
//        if (item.text == "E") throw DioError();
//      });
      return true;
    } catch (e) {
      throw DioError();
    }
  }

  static xml.XmlNode buildSearchBomXml(String EQUNR) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmSearchBom", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("IvEqunr", attributes: {"xmlns": ""}, nest: EQUNR);
          builder.element("EtMatnr", attributes: {"xmlns": ""});
          builder.element("EtMatnr2", attributes: {"xmlns": ""});
          builder.element("EtMatnrRep", attributes: {"xmlns": ""});
        });
      });
    });
    return builder.build();
  }

  static List<Materiel> readSearchBomXml(String stringXml) {
    var document = xml.parse(stringXml);
//    if (document.findAllElements("EtMatnr").first.document == null) {
//      return new List();
//    }
    var materielDom = document.findAllElements("EtMatnr").first;
    var substituteMaterielDom = document.findAllElements("EtMatnr2").first;
    var relateDom = document.findAllElements("EtMatnrRep").first;
    List<Materiel> materielList = new List();
    List<SubstituteMateriel> substituteMaterielList = new List();
    List<Map> relateList = new List();
    try {
      materielList = materielDom.findAllElements("item").map((e) {
        Materiel materiel = new Materiel();
        materiel.list = new List();
        materiel.MATNR = e.findAllElements("Matnr").first.text;
        materiel.MAKTX = e.findAllElements("Maktx").first.text;
        materiel.MATYP = e.findAllElements("Matyp").first.text;
        materiel.MATYT = e.findAllElements("Matyt").first.text;
        materiel.WERKS = e.findAllElements("Werks").first.text;
        materiel.NAME1 = e.findAllElements("Name1").first.text;
        materiel.LGORT = e.findAllElements("Lgort").first.text;
        materiel.LGOBE = e.findAllElements("Lgobe").first.text;
        materiel.LABST =
            double.parse(e.findAllElements("Labst").first.text).toInt();
        materiel.MEINS = e.findAllElements("Meins").first.text;
        materiel.SUMLABST =
            double.parse(e.findAllElements("Sumlabst").first.text).toInt();
        return materiel;
      }).toList();
    } catch (e) {
      materielList = [];
    }
    try {
      substituteMaterielList = substituteMaterielDom.findAllElements("item").map((e) {
        SubstituteMateriel materiel = new SubstituteMateriel();
        materiel.REMATNR = e.findAllElements("Rematnr").first.text;
        materiel.REMAKTX = e.findAllElements("Remaktx").first.text;
        materiel.MATYP = e.findAllElements("Matyp").first.text;
        materiel.MATYT = e.findAllElements("Matyt").first.text;
        materiel.WERKS = e.findAllElements("Werks").first.text;
        materiel.NAME1 = e.findAllElements("Name1").first.text;
        materiel.LGORT = e.findAllElements("Lgort").first.text;
        materiel.LGOBE = e.findAllElements("Lgobe").first.text;
        materiel.LABST =
            double.parse(e.findAllElements("Labst").first.text).toInt();
        materiel.MEINS = e.findAllElements("Meins").first.text;
        materiel.SUMLABST =
            double.parse(e.findAllElements("Sumlabst").first.text).toInt();
        return materiel;
      }).toList();
    } catch (e) {
      return materielList;
    }
    try {
      relateList = relateDom.findAllElements("item").map((e) {
        Map relate = new Map();
        relate["MATNR"] = e.findAllElements("Matnr").first.text;
        relate["MAKTX"] = e.findAllElements("Maktx").first.text;
        relate["REMATNR"] = e.findAllElements("Rematnr").first.text;
        relate["REMAKTX"] = e.findAllElements("Remaktx").first.text;
        return relate;
      }).toList();
    } catch (e) {
      return materielList;
    }
    materielList.forEach((materiel) {
      materiel.list = substituteMaterielList.where((substituteMateriel) {
        return relateList.any((relate) {
          return relate["MATNR"] == materiel.MATNR &&
              relate["REMATNR"] == substituteMateriel.REMATNR;
        });
      }).toList();
    });
    return materielList;
  }

  static xml.XmlNode buildWorkerXml(String PERNR) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmSearchWcg", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("EtData", attributes: {"xmlns": ""});
          builder.element("Pernr", attributes: {"xmlns": ""}, nest: PERNR);
        });
      });
    });
    return builder.build();
  }

  static xml.XmlNode buildWorkerByWCPLGRXml(String QMNUM, String WCPLGR) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
          builder.element("Body", nest: () {
            builder.element("ZpmSearchWcgqy", attributes: {
              "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
            }, nest: () {
              builder.element("EtData", attributes: {"xmlns": ""});
              builder.element("Qmnum", attributes: {"xmlns": ""}, nest: QMNUM);
              builder.element("Wcplgr", attributes: {"xmlns": ""}, nest: WCPLGR);
            });
          });
        });
    return builder.build();
  }

  static List<Worker> readWorkerXml(String stringXml) {
    var document = xml.parse(stringXml);
    if (document.findAllElements("MType").first.text == "E") {
      return new List();
    }
    List<Worker> list = document.findAllElements("item").map((e) {
      Worker worker = new Worker();
      worker.PERNR = e.findAllElements("Pernr").first.text;
      worker.ENAME = e.findAllElements("Ename").first.text;
      worker.SORTB = e.findAllElements("Sortb").first.text;
      worker.SORTT = e.findAllElements("Sortt").first.text;
      worker.CPLGR = e.findAllElements("Cplgr").first.text;
      worker.CPLTX = e.findAllElements("Cpltx").first.text;
      worker.MATYP = e.findAllElements("Matyp").first.text;
      worker.MATYT = e.findAllElements("Matyt").first.text;
      worker.WERKS = e.findAllElements("Werks").first.text;
      worker.TXTMD = e.findAllElements("Txtmd").first.text;
      worker.RUZUS = e.findAllElements("Ruzus").first.text;
      worker.KTEX1 = e.findAllElements("Ktex1").first.text;
      return worker;
    }).toList();
    return list;
  }

  static xml.XmlNode buildAddMaterielXml(
      String AUFNR, String MATNR, String MAKTX, int MENGE, String EQUNR) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
      builder.element("Body", nest: () {
        builder.element("ZpmChangeComponents", attributes: {
          "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
        }, nest: () {
          builder.element("IvAufnr", attributes: {"xmlns": ""}, nest: AUFNR);
          builder.element("IvMaktx", attributes: {"xmlns": ""}, nest: MAKTX);
          builder.element("IvMatnr", attributes: {"xmlns": ""}, nest: MATNR);
          builder.element("IvEqunr", attributes: {"xmlns": ""}, nest: EQUNR);
          builder.element("IvMenge",
              attributes: {"xmlns": ""}, nest: MENGE.toString());
        });
      });
    });
    return builder.build();
  }

  static bool readAddMaterielXml(String stringXml) {
    var document = xml.parse(stringXml);
    bool flag = false;
    try {
      document.findAllElements("MType").forEach((item) {
        if (item.text == "E")
          throw DioError();
        else
          flag = true;
      });
      return flag;
    } catch (e) {
      throw DioError();
    }
  }

  static xml.XmlNode buildHistoryOrder(
      String PERNR, String WCTYPE) {
    var builder = new xml.XmlBuilder();
    builder.element("Envelope",
        attributes: {"xmlns": "http://schemas.xmlsoap.org/soap/envelope/"},
        nest: () {
          builder.element("Body", nest: () {
            builder.element("ZpmSearchOrderHistory", attributes: {
              "xmlns": "urn:sap-com:document:sap:soap:functions:mc-style"
            }, nest: () {
              builder.element("EtData", attributes: {"xmlns": ""});
              builder.element("Pernr", attributes: {"xmlns": ""}, nest: PERNR);
              builder.element("Wctype", attributes: {"xmlns": ""}, nest: WCTYPE);
            });
          });
        });
    return builder.build();
  }

  static List<Order> readHistoryOrder(String stringXml) {
    var document = xml.parse(stringXml);
    List<Order> list = document.findAllElements("item").map((e) {
      Order order = new Order();
      order.PERNR = e.findElements("Pernr").first.text;
      order.KTEXT = e.findElements("Ktext").first.text;
      order.CPLTX = e.findElements("Cpltx").first.text;
      order.QMNUM = e.findElements("Qmnum").first.text;
      order.QMTXT = e.findElements("Qmtxt").first.text;
      order.PERNR1 = e.findElements("Pernr1").first.text;
      order.AUFNR = e.findElements("Aufnr").first.text;
      order.AUFTEXT = e.findElements("KtextAufnr").first.text;
      order.ILATX = e.findAllElements("Ilatx").first.text;
      order.ILART = e.findAllElements("Ilart").first.text;
      order.EQUNR = e.findElements("Equnr").first.text;
      order.EQKTX = e.findElements("Eqktx").first.text;
      order.TPLNR = e.findElements("Tplnr").first.text;
      order.PLTXT = e.findElements("Pltxt").first.text;
      order.BAUTL = e.findElements("Bautl").first.text;
      order.MAKTX = e.findElements("Maktx").first.text;
      order.ASTTX = e.findElements("Asttx").first.text;
      order.CPLGR = e.findElements("Cplgr").first.text;
      order.APPSTATUS = e.findElements("Appstatus").first.text;
      order.ERDAT = e.findElements("Erdat").first.text;
      order.ERTIM = e.findElements("Ertim").first.text;
      order.ERDAT2 = e.findElements("Erdat2").first.text;
      order.ERTIM2 = e.findElements("Ertim2").first.text;
      order.ERDAT3 = e.findElements("Erdat3").first.text;
      order.ERTIM3 = e.findElements("Ertim3").first.text;
      return order;
    }).toList();
    return list;
  }
}
