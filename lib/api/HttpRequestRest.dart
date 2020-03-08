import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gztyre/api/model/FunctionPosition.dart';
import 'package:gztyre/commen/Global.dart';
import 'dart:html' as html;

class HttpRequestRest {

//  static String _baseUrl = "http://pmapp.gztyre.com:8080"; // 生产
  static String _baseUrl = "http://192.168.6.211:8070"; // 开发

  static Dio getHttp() {
    Dio http = new Dio(BaseOptions(
      baseUrl: _baseUrl, // 开发
        connectTimeout: 300000));
    http.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      if (Global.token != null) {
        options.headers.addEntries([
          MapEntry("Authorization", "Bearer ${Global.token}")
        ]);
      }
      // Do something before request is sent
      return options; //continue
    }, onResponse: (Response response) {
      // Do something with response data
      return response; // continue
    }, onError: (DioError e) {
      // Do something with response error
      return e; //continue
    }));
    return http;
  }

//  static Dio getFileHttp() {
//    Dio http = new Dio(BaseOptions(
////        baseUrl: "http://pmapp.gztyre.com:8080", // 生产
//      baseUrl: "http://192.168.6.211:8070", // 开发
//        connectTimeout: 30000));
//    http.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options) {
//      if (Global.token != null) {
//        options.headers.addEntries([
//          MapEntry("Authorization", "Bearer ${Global.token}")
//        ]);
//      }
//      // Do something before request is sent
//      return options; //continue
//    }, onResponse: (Response response) {
//      // Do something with response data
//      return response; // continue
//    }, onError: (DioError e) {
//      // Do something with response error
//      return e; //continue
//    }));
//    return http;
//  }

  static upload(List<dynamic> fileList, Function(List list) onSuccess,
      Function(DioError err) onError) async {
    var formData = new FormData();
    for (int i = 0; i < fileList.length; i++) {
      formData.files
          .add(MapEntry("files", MultipartFile.fromFileSync(fileList[i],
          filename: Global.userInfo.PERNR + "-" + DateTime.now().toString() + "." + fileList[i].split('.').last
      )));
    }
    try {
      Response response = await getHttp().post(
        "/api/uploadMultipleFiles",
        data: formData,
      );
      return await onSuccess(response.data);
    } on DioError catch (e) {
      return await onError(e);
    }
  }

  static uploadForWeb(List fileList, Function(List list) onSuccess,
      Function(DioError err) onError) async {
    var formData = html.FormData() ;
    Map<String, String> header = new Map();
    header.putIfAbsent("Authorization", () => "Bearer ${Global.token}");
    for (int i = 0; i < fileList.length; i++) {
      formData.appendBlob("files", fileList[i].file, Global.userInfo.PERNR + "-" + DateTime.now().toString() + "." + fileList[i].file.name.split('.').last);
//      formData.files
//          .add(MapEntry("files", MultipartFile.fromFileSync(fileList[i],
//          filename: Global.userInfo.PERNR + "-" + DateTime.now().toString() + "." + fileList[i].split('.').last
//      )));
    }
      return await html.HttpRequest.request(
          "${_baseUrl}/api/uploadMultipleFiles",
        method: "post",
        sendData: formData,
        requestHeaders: header
      ).then((httpRequest) => onSuccess(JsonDecoder().convert(httpRequest.response))).catchError(onError(new DioError()));
  }

 /// 下载文件
  static download(String fileName, Function(File file) onSuccess,
      Function(DioError err) onError) async {
    try {
      Response response = await getHttp().get("/downloadFile/{fileName:$fileName}");
      return await onSuccess(response.data);
    } on DioError catch (e) {
      return await onError(e);
    }
  }

  /// 创建工单
  static malfunction(
      String tradeNo,
      String sapNo,
      int type,
      List<String> pictures,
      String video,
      String audio,
      String desc,
      String addDesc,
      String remark,
      bool isStop,
      String userCode,
      String title,
      String level,
      String status,
      String location,
      String device,
      String reportTime,
      String waitTime,
      Function(Map map) onSuccess,
      Function(DioError err) onError) async {
    try {
      Response response = await getHttp().post("/api/malfunction", data: {
        "userCode": userCode,
        "tradeNo": tradeNo,
        "sapNo": sapNo,
        "type": type,
        "pictures": pictures,
        "video": video,
        "audio": audio,
        "desc": desc,
        "addDesc": addDesc,
        "remark": remark,
        "isStop": isStop,
        "title": title,
        "level": level,
        "status": status,
        "location": location,
        "device": device,
        "reportTime": reportTime,
        "waitTime": waitTime
      });
      return await onSuccess(response.data);
    } on DioError catch (e) {
      return await onError(e);
    }
  }

  /// 查询工单
  static getMalfunction(String sapNo, Function(Map map) onSuccess,
      Function(DioError err) onError) async {
    try {
      Response response = await getHttp().get("/api/malfunction", queryParameters: {
        "sapNo": sapNo
      });
      if (response.data["data"] == null) {
        return await onError(new DioError());
      } else {
        return await onSuccess(response.data["data"]);
      }
    } on DioError catch (e) {
      return await onError(e);
    }
  }

  static getOrders(String userCode, Function(List list) onSuccess,
      Function(DioError err) onError) async {
    try {
      Response response = await getHttp().get("/api/malfunction/user/$userCode");
      print(response.data['data']);
      return await onSuccess(response.data['data']);
    } on DioError catch (e) {
      return await onError(e);
    }
  }

  static login(String username, String password, Function(String token) onSuccess,
      Function(DioError err) onError) async {
    try {
      Response response = await getHttp().post("/api/authenticate", data: {
        "username": username,
        "password": password
      });
      print(response.data['id_token']);
      return await onSuccess(response.data['id_token']);
    } on DioError catch (e) {
      return await onError(e);
    }
  }

  static registry(String PERNR, String ENAME, String SORTB, String SORTT, String CPLGR, String CPLTX,
      String MATYP, String MATYT, String WERKS, String TXTMD, String WCTYPE, Function() onSuccess,
      Function(DioError err) onError) async {
    try {
      Response response = await getHttp().post("/api/sap/users", data: {
        "txtmd": TXTMD,
        "matyp": MATYP,
        "ename": ENAME,
        "cpltx": CPLTX,
        "matyt": MATYT,
        "pernr": PERNR,
        "werks": WERKS,
        "cplgr": CPLGR,
        "sortb": SORTB,
        "sortt": SORTT,
        "wctype": WCTYPE
      });
      print(response.data);
      return await onSuccess();
    } on DioError catch (e) {
      return await onError(e);
    }
  }

  static update(String PERNR, String ENAME, String SORTB, String SORTT, String CPLGR, String CPLTX,
  String MATYP, String MATYT, String WERKS, String TXTMD, String WCTYPE, String password, String phoneNumber, Function() onSuccess,
      Function(DioError err) onError) async {
    try {
      Response response = await getHttp().post("/api/sap/updateUser", data: {
        "txtmd": TXTMD,
        "matyp": MATYP,
        "ename": ENAME,
        "cpltx": CPLTX,
        "matyt": MATYT,
        "pernr": PERNR,
        "werks": WERKS,
        "cplgr": CPLGR,
        "sortb": SORTB,
        "sortt": SORTT,
        "wctype": WCTYPE,
        "password": password,
        "phoneNumber": phoneNumber
      });
      print(response.data);
      return await onSuccess();
    } on DioError catch (e) {
      return await onError(e);
    }
  }

  static searchUser(String username, Function(Map data) onSuccess,
      Function(DioError err) onError) async {
    try {
      Response response = await getHttp().get("/api/sap/user/$username");
      print(response.data);
      return await onSuccess(response.data["data"]);
    } on DioError catch (e) {
      return await onError(e);
    }
  }

  static exist(String username, Function(bool isExist) onSuccess,
      Function(DioError err) onError) async {
    try {
      Response response = await getHttp().get("/api/sap/exist/$username");
      print(response.data['isExist']);
      return await onSuccess(response.data['isExist']);
    } on DioError catch (e) {
      return await onError(e);
    }
  }

  static pushAlias(List<String> alias, String msgContent, String msgTitle,
        String notificationTitle, List<String> tags, Function(bool isSuccess) onSuccess,
        Function(DioError err) onError) async {
      try {
        Response response = await getHttp().post("/api/sap/push/alias", data: {
          "alias": alias,
          "msgTitle": msgTitle,
          "msgContent": msgContent,
          "notificationTitle": notificationTitle,
          "tagsList": tags
        });
        print(response.data);
        return await onSuccess(response.data['code'] == 0);
      } on DioError catch (e) {
        return await onError(e);
      }
  }

  static pushTags(List<String> alias, String msgContent, String msgTitle,
      String notificationTitle, List<String> tags, Function(bool isSuccess) onSuccess,
      Function(DioError err) onError) async {
    try {
      Response response = await getHttp().post("/api/sap/push/tags", data: {
        "alias": alias,
        "msgTitle": msgTitle,
        "msgContent": msgContent,
        "notificationTitle": notificationTitle,
        "tagsList": tags
      });
      print(response.data);
      return await onSuccess(response.data['code'] == 0);
    } on DioError catch (e) {
      return await onError(e);
    }
  }

  static listPosition(String userCode, Function(List<FunctionPosition> functionPositionList) onSuccess,
      Function(DioError err) onError) async {
    try {
      Response response = await getHttp().get("/api/sap/positions/$userCode");
      print(response.data);
      List list = response.data['data'];
      List<FunctionPosition> functionPositionList = list.map((item) {
        return FunctionPosition.formJson(item);
      }).toList();
      return await onSuccess(functionPositionList);
    } on DioError catch (e) {
      return await onError(e);
    }
  }

  static isMaterielExist(String code, Function(bool success) onSuccess,
      Function(DioError err) onError) async {
    try {
      Response response = await getHttp().get("/api/sap/materials/${code}");
      print(response.data);
      return await onSuccess(response.data['data']);
    } on DioError catch (e) {
      return await onError(e);
    }
  }
}
