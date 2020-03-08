import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/HttpRequestRest.dart';
import 'package:gztyre/api/model/UserInfo.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ButtonWidget.dart';
import 'package:gztyre/components/InputWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/pages/login/DefaultPasswordAndPhoneNumberChangePage.dart';
import 'package:gztyre/pages/login/MaintenanceGroupSelectionPage.dart';
import 'package:gztyre/pages/login/WorkShiftSelectionPage.dart';
import 'package:gztyre/utils/screen_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  State createState() {
    return new _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  bool _rememberUsername = true;
  bool _rememberPassword = true;
  GlobalKey _formKey = new GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Global.logout();
    _get("isRememberUsername").then((String val) {
      if ('0' == val) {
        _rememberUsername = false;
      } else {
        _rememberUsername = true;
      }
    });
    _get("isRememberPassword").then((String val) {
      if ('0' == val) {
        _rememberPassword = false;
      } else {
        _rememberPassword = true;
      }
    });
    _get("username").then((String username) {
      _usernameController.text = username;
    });
    _get("password").then((String password) {
      _passwordController.text = password;
    });
  }

  Future<String> _get(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.get(key);
  }

  _set(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

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
                  setState(() {
                    this._loading = false;
                  });
                  Navigator.of(context).pop();
                },
                child: Text("好"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget logo = Image.asset(
      'assets/images/logo.png',
      fit: BoxFit.fitWidth,
    );

    Widget inputArea = Form(
      autovalidate: true,
      child: Column(
        children: <Widget>[
          InputWidget(
            controller: _usernameController,
            prefixText: "工号",
            placeholderText: "请输入工号",
            keyboardType: TextInputType.number,
          ),
          InputWidget(
            controller: _passwordController,
            prefixText: "密码",
            placeholderText: "请输入密码",
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
          ),
        ],
      ),
    );

    Widget operationArea = Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            child: Text(
              '忘记密码？',
              style: TextStyle(
                  color: Color.fromRGBO(44, 93, 187, 1), fontSize: 14),
              overflow: TextOverflow.fade,
            ),
            onTap: () {
              showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      content: Text(
                        "请联系主管重置密码",
                        style: TextStyle(fontSize: 18),
                      ),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          onPressed: () {
                            setState(() {
                              this._loading = false;
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text("好"),
                        ),
                      ],
                    );
                  });
            },
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                CupertinoSwitch(
                    value: _rememberUsername,
                    onChanged: (val) {
                      setState(() {
                        _rememberUsername = val;
                      });
                    }),
                Expanded(
                  child: Text(
                    "记住账号",
                    style: TextStyle(fontSize: 14),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                CupertinoSwitch(
                    value: _rememberPassword,
                    onChanged: (val) {
                      setState(() {
                        _rememberPassword = val;
                      });
                    }),
                Expanded(
                  child: Text(
                    "记住密码",
                    style: TextStyle(fontSize: 14),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );

    return new CupertinoPageScaffold(
        child: ProgressDialog(
      loading: this._loading,
      child: ListView(
        children: <Widget>[
          new SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: ScreenUtils.screenW(context) * 0.15,bottom: ScreenUtils.screenW(context) * 0.15,
              left: ScreenUtils.screenW(context) * 0.22, right: ScreenUtils.screenW(context) * 0.22),
              child: logo,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: ScreenUtils.screenH(context) / 10),
            child: inputArea,
          ),
          Padding(
            padding: EdgeInsets.only(top: 25.0, left: 10.0, right: 10.0),
            child: ButtonWidget(
              child: Text(
                "登录",
                style: TextStyle(fontSize: 20, color: Color.fromRGBO(51, 115, 178, 1)),
              ),
              color: Color.fromRGBO(51, 115, 178, 1),
              onPressed: () async {
                if (_rememberUsername) {
                  Global.saveUsername(_usernameController.text);
                } else {
                  Global.prefs.setString("username", null);
                }
                if (_rememberPassword) {
                  Global.savePassword(_passwordController.text);
                } else {
                  Global.prefs.setString("password", null);
                }
                Global.logout();
                setState(() {
                  this._loading = true;
                });
                if (this._usernameController.text == null ||
                    this._passwordController.text == null ||
                    this._usernameController.text == "" ||
                    this._passwordController.text == "") {
                  _buildError("请完成账号和密码");
                } else {
                  await HttpRequest.searchUserInfo(_usernameController.text,
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
//                                  if (this._passwordController.text == "123456") {
                                    return await HttpRequestRest.registry(
                                        userInfo.PERNR, userInfo.ENAME, userInfo.SORTB, userInfo.SORTT,
                                        userInfo.CPLGR, userInfo.CPLTX, userInfo.MATYP, userInfo.MATYT,
                                        userInfo.WERKS, userInfo.TXTMD, userInfo.WCTYPE, () {
                                      return true;
                                    }, (err) {
                                      _buildError("系统繁忙");
                                      return null;
                                    });
//                                  }
//                                  else {
//                                    _buildError("密码错误");
//                                    return null;
//                                  }
                                }
                              }, (err) {
                                _buildError("未找到账号，请确认账号信息或联系管理员重置密码");
                                return false;
                              }).then((success) async {
                                if (success != null && success) {
                                  return await HttpRequestRest.login(this._usernameController.text, this._passwordController.text,
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
                              setState(() {
                                this._loading = false;
                              });
                              await HttpRequestRest.searchUser(userInfo.PERNR, (data) {
                                Global.userInfo.phoneNumber = data["phoneNumber"];
                                Global.saveUserInfo(Global.userInfo);
                                if (this._passwordController.text == "123456") {
                                  Navigator.of(context).push(new CupertinoPageRoute(
                                      builder: (context) =>
                                      new DefaultPasswordAndPhoneNumberChangePage()));
                                } else {
                                  if (Global.userInfo.WCTYPE != "是") {
//                                    Global.jPush.setAlias(Global.userInfo.PERNR);
//                                    if ([
//                                      "A01", "A02", "A3"
//                                    ].contains(Global.userInfo.SORTB)) {
//                                      Global.jPush.setTags(["维修工"]);
//                                    }
//                                    if ([
//                                      "A04", "A05"
//                                    ].contains(Global.userInfo.SORTB)) {
//                                      Global.jPush.setTags(["领班"]);
//                                    }
//                                    if ([
//                                      "A06", "A08"
//                                    ].contains(Global.userInfo.SORTB)) {
//                                      Global.jPush.setTags(["主管"]);
//                                    }
//                                    if ([
//                                      "A07"
//                                    ].contains(Global.userInfo.SORTB)) {
//                                      Global.jPush.setTags(["工程师"]);
//                                    }
                                    Navigator.push(
                                        context,
                                        new CupertinoPageRoute(
                                            builder: (context) => new WorkShiftSelectionPage(
                                                userName: this._usernameController.text)));
                                  } else {
//                                    Global.jPush.setAlias(Global.userInfo.PERNR);
//                                    if ([
//                                      "A01", "A02", "A3"
//                                    ].contains(Global.userInfo.SORTB)) {
//                                      Global.jPush.setTags(["维修工"]);
//                                    }
//                                    if ([
//                                      "A04", "A05"
//                                    ].contains(Global.userInfo.SORTB)) {
//                                      Global.jPush.setTags(["领班"]);
//                                    }
//                                    if ([
//                                      "A06", "A08"
//                                    ].contains(Global.userInfo.SORTB)) {
//                                      Global.jPush.setTags(["主管"]);
//                                    }
//                                    if ([
//                                      "A07"
//                                    ].contains(Global.userInfo.SORTB)) {
//                                      Global.jPush.setTags(["工程师"]);
//                                    }
                                    Navigator.push(
                                        context,
                                        new CupertinoPageRoute(
                                            builder: (context) =>
                                            new MaintenanceGroupSelectionPage()));
                                  }
                                }
                              }, (err) {
                                setState(() {
                                  this._loading = false;
                                });
                              });
                            } else {
                              setState(() {
                                this._loading = false;
                              });
                            }
                          });
                        }
                      }
                  );
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: operationArea,
          )
        ],
      ),
    ));
  }
}
