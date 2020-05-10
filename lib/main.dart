import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gztyre/api/HttpRequest.dart' as HttpRequestLocal;
import 'package:gztyre/api/HttpRequestRest.dart';
import 'package:gztyre/api/model/UserInfo.dart';
import 'package:gztyre/commen/ChineseCupertinoLocalizations.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/pages/ContainerPage.dart';
import 'package:gztyre/pages/login/LoginPage.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:gztyre/pages/login/MaintenanceGroupSelectionPage.dart';
import 'package:gztyre/pages/login/WorkShiftSelectionPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Global.init().then((val) {
    runApp(MyApp());
//    if (Platform.isAndroid) {
//      //设置Android头部的导航栏透明
//      SystemUiOverlayStyle systemUiOverlayStyle =
//      SystemUiOverlayStyle(statusBarColor: Colors.transparent);
//      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
//    }
  });
}


class MyApp extends StatefulWidget {

  // This widget is the root of your application.
  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: '故障维修',
      theme: CupertinoThemeData(
        primaryColor: Color.fromRGBO(253, 255, 255, 1),
        scaffoldBackgroundColor: Color.fromRGBO(231, 233, 234, 1),
      ),
      home: EntryWidget(),
      supportedLocales: [
        const Locale('en', 'US'), // 美国英语
        const Locale('zh', 'CN'), // 中文简体
        //其它Locales
      ],
      localizationsDelegates: [
        ChineseCupertinoLocalizations.delegate,

      ],
    );
  }
}

class EntryWidget extends StatefulWidget {
  EntryWidget({Key key}) : super(key: key);


  @override
  _EntryWidgetState createState() => _EntryWidgetState();
}

class _EntryWidgetState extends State<EntryWidget> {

  _buildError(String desc) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Text(
              desc,
              style: TextStyle(fontSize: 18),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("好"),
              ),
            ],
          );
        });
  }

  Future getInfo(username, password) async {
    if (username != null) {
      Global.saveUsername(username);
    } else {
      Global.prefs.setString("username", '');
    }
    if (password != null) {
      Global.savePassword(password);
    } else {
      Global.prefs.setString("password", '');
    }
    Global.logout();
      await HttpRequestLocal.HttpRequest.searchUserInfo(username,
              (UserInfo userInfo) async {
            if (userInfo.PERNR == "" || userInfo.PERNR == null) {
              _buildError("未找到账号，请确认账号信息或联系管理员重置密码");
              return null;
            } else {
              return userInfo;
            }
          }, (err) {
            _buildError("未找到用户");
            return null;
          }).then(
              (userInfo) async {
            if (userInfo != null) {
              await Global.saveUserInfo(userInfo);
              return await HttpRequestRest.exist(userInfo.PERNR,
                      (bool isExist) async {
                    if (isExist) {
                      return true;
                    } else {
                      return await HttpRequestRest.registry(
                          userInfo.PERNR, userInfo.ENAME, userInfo.SORTB, userInfo.SORTT,
                          userInfo.CPLGR, userInfo.CPLTX, userInfo.MATYP, userInfo.MATYT,
                          userInfo.WERKS, userInfo.TXTMD, userInfo.WCTYPE, () {
                        return true;
                      }, (err) {
                        _buildError("系统繁忙");
                        return null;
                      });
                    }
                  }, (err) {
                    _buildError("未找到账号，请确认账号信息或联系管理员重置密码");
                    return false;
                  }).then((success) async {
                if (success != null && success) {
                  return await HttpRequestRest.login(username, password,
                          (String token) async {
                        await Global.saveToken(token);
                        return true;
                      }, (err) async {
                        await Global.logout();
                        _buildError("账号或密码错误");
                        return false;
                      });
                } else if (success != null && !success) {
                  await Global.logout();
                  return false;
                } else {
                  return false;
                }
              }).then((isLogin) async {
                if (isLogin) {
                  await HttpRequestRest.searchUser(userInfo.PERNR, (data) {
                    Global.userInfo.phoneNumber = data["phoneNumber"];
                    Global.saveUserInfo(Global.userInfo);
                      if (Global.userInfo.WCTYPE != "是") {
                        Navigator.push(
                            context,
                            new CupertinoPageRoute(
                                builder: (context) => new WorkShiftSelectionPage(
                                    userName: username)));
                      } else {
                        Navigator.push(
                            context,
                            new CupertinoPageRoute(
                                builder: (context) =>
                                new MaintenanceGroupSelectionPage()));
                      }
                  }, (err) {
                  });
                } else {
                }
              });
            }
          }
      );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Global.token == null || Global.token == "" || (Global.maintenanceGroup == null && Global.workShift == null)) {
      print(window.location.href);
      var uri = Uri.dataFromString(window.location.href);
      var qp = uri.queryParameters;
      print(qp);
      var username = qp['appId'].replaceAll('#/', '');
      var password = qp['appSecret'].replaceAll('#/', '');
      getInfo(String.fromCharCodes(Base64Decoder().convert(username)), String.fromCharCodes(Base64Decoder().convert(password))).then((value) => new ContainerPage(rootContext: context,)).catchError((err) => Container());
    } else {
      Global.logout();
      window.open("http://192.168.6.211/#/passport/login", '_self');
    }
  }
}
