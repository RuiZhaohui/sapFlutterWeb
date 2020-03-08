import 'dart:convert';

import 'package:gztyre/api/model/FunctionPosition.dart';
import 'package:gztyre/api/model/UserInfo.dart';
import 'package:gztyre/api/model/WorkShift.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Global {
  static SharedPreferences prefs;
  /// 功能位置
  static FunctionPosition functionPosition = FunctionPosition();
  /// 用户信息
  static UserInfo userInfo = UserInfo();
  /// 工作中心
  static WorkShift workShift = WorkShift();
  static List<String> maintenanceGroup = new List();
  static String token = "";
  static String username = "";
  static String password = "";


  // 支持图片格式
  static List<String> picType = ["png", "jpg", "jpeg", "bmp", "gif"];
  // 支持视频格式
  static List<String> videoType = ["mp4", "avi", "mpeg4"];
  // 支持音频格式
  static List<String> audioType = ["wav", "mp3"];

  // 是否为release版
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

//  static Profile profile = Profile();

  //初始化全局信息，会在APP启动时执行
  static Future init() async {
//    jPush = new JPush();
    prefs = await SharedPreferences.getInstance();
    var _userInfo = prefs.getString("userInfo");
    var _workShift = prefs.getString("workShift");
    maintenanceGroup = prefs.getStringList("maintenanceGroup");
    token = prefs.getString("token");
    username = prefs.getString("username");
    password = prefs.getString("password");
    if (_userInfo != null) {
      try {
        userInfo = UserInfo.formJson(jsonDecode(_userInfo));
      } catch (e) {
        print(e);
      }
    }
    if (_workShift != null) {
      try {
        workShift = WorkShift.formJson(jsonDecode(_workShift));
      } catch (e) {
        print(e);
      }
    }
  }

  // 持久化Profile信息
  static saveUserInfo(UserInfo userInfo) async {
    Global.userInfo = userInfo;
    await prefs.setString("userInfo", jsonEncode(userInfo.toJson()));
  }
  static saveWorkShift(WorkShift workShift) async {
    Global.workShift = workShift;
    await prefs.setString("workShift", jsonEncode(workShift.toJson()));
  }
  static saveMaintenanceGroup(List<String> maintenanceGroup) async {
    Global.maintenanceGroup = maintenanceGroup;
    await prefs.setStringList("maintenanceGroup", maintenanceGroup);
  }

  static saveToken(String token) async {
    Global.token = token;
    await prefs.setString("token", token);
  }

  static saveUsername(String username) async {
    Global.username = username;
    await prefs.setString("username", username);
  }

  static savePassword(String password) async {
    Global.password = password;
    await prefs.setString("password", password);
  }

  static logout() async {
    await prefs.remove("userInfo");
    await prefs.remove("workShift");
    await prefs.remove("maintenanceGroup");
    await prefs.remove("token");
  }

}
