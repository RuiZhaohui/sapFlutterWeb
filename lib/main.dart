import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gztyre/commen/ChineseCupertinoLocalizations.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/pages/ContainerPage.dart';
import 'package:gztyre/pages/login/LoginPage.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

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


//  Future<void> initPlatformState() async {
//
//    Global.jPush.getRegistrationID().then((rid) {
//      print('---->rid:${rid}');
//    });
//
//    if (Platform.isIOS) {
//      Global.jPush.setup(
//        appKey: Global.JPUSH_APP_KEY,
//        channel: "developer-default",
//        production: false,
//        debug: true,
//      );
//      Global.jPush.applyPushAuthority(
//          NotificationSettingsIOS(sound: true, alert: true, badge: true)
//      );
//    }
//    String platformVersion;
//
//    try {
//      /*监听响应方法的编写*/
//      Global.jPush.addEventHandler(
//          onReceiveNotification: (Map<String, dynamic> message) async {
//            print(">>>>>>>>>>>>>>>>>flutter 接收到推送: $message");
//            FlutterRingtonePlayer.playNotification(looping: false);
//          },
//          onOpenNotification: (Map<String, dynamic> message) async {
//            FlutterRingtonePlayer.stop();
//      }
//      );
//    } on PlatformException {
//      platformVersion = '平台版本获取失败，请检查！';
//    }
//
//    if (!mounted){
//      return;
//    }
//  }


  @override
  void initState() {
//    this.initPlatformState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Flutter Demo',
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

  @override
  void initState() {
//    hasToken().then((val) {
//      _hasToken = val;
//      print(val);
//    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Global.token == null || Global.token == "" || (Global.maintenanceGroup == null && Global.workShift == null)) {
      return new LoginPage();
    } else {
//      Global.jPush.setAlias(Global.userInfo.PERNR);
//      if ([
//        "A01", "A02", "A3"
//      ].contains(Global.userInfo.SORTB)) {
//        Global.jPush.setTags(["维修工"]);
//      }
//      if ([
//        "A04", "A05"
//      ].contains(Global.userInfo.SORTB)) {
//        Global.jPush.setTags(["领班"]);
//      }
//      if ([
//        "A06", "A08"
//      ].contains(Global.userInfo.SORTB)) {
//        Global.jPush.setTags(["主管"]);
//      }
//      if ([
//        "A07"
//      ].contains(Global.userInfo.SORTB)) {
//        Global.jPush.setTags(["工程师"]);
//      }
      return new ContainerPage(rootContext: context,);
    }
  }
}
