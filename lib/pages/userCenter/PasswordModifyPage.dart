import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequestRest.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ButtonBarWidget.dart';
import 'package:gztyre/components/ButtonWidget.dart';
import 'package:gztyre/components/InputWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/pages/login/LoginPage.dart';

class PasswordModifyPage extends StatefulWidget {
  PasswordModifyPage({
    Key key,
  }) : super(key: key);

  @override
  State createState() => _PasswordModifyPageState();
}

class _PasswordModifyPageState extends State<PasswordModifyPage> {
  TextEditingController _newPasswordController = new TextEditingController();
  TextEditingController _confirmPasswordController =
      new TextEditingController();

  bool _loading = false;

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
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new ProgressDialog(loading: this._loading, child: CupertinoPageScaffold(
      navigationBar: new CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
          color: Color.fromRGBO(94, 102, 111, 1),
        ),
        middle: Text(
          "修改密码",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      child: SafeArea(
          child: CupertinoScrollbar(
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[Padding(
                    padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: InputWidget(
                      controller: this._newPasswordController,
                      obscureText: true,
                      prifixMode: OverlayVisibilityMode.never,
                      placeholderText: "请输入新密码",
                      keyboardType: TextInputType.visiblePassword,
                    ),
                  ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: InputWidget(
                        controller: this._confirmPasswordController,
                        obscureText: false,
                        prifixMode: OverlayVisibilityMode.never,
                        placeholderText: "请再次输入新密码",
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                ButtonBarWidget(
                  button: Container(
                    child:
                    ButtonWidget(
                      child: Text("确认修改", style: TextStyle(color: Color.fromRGBO(33, 127, 184, 1)),),
                      color: Color.fromRGBO(33, 127, 184, 1),
                      onPressed: () {
                        if (this._newPasswordController.text !=
                            this._confirmPasswordController.text) {
                          _buildError("两次密码请保持相同");
                        } else if (this._newPasswordController.text == null ||
                            this._newPasswordController.text == "") {
                          _buildError("请输入密码");
                        } else if (this._newPasswordController.text.length <
                            5) {
                          _buildError("密码请保持5位以上");
                        } else {
                          this._loading = true;
                          HttpRequestRest.update(
                              Global.userInfo.PERNR, Global.userInfo.ENAME, Global.userInfo.SORTB, Global.userInfo.SORTT,
                              Global.userInfo.CPLGR, Global.userInfo.CPLTX, Global.userInfo.MATYP, Global.userInfo.MATYT,
                              Global.userInfo.WERKS, Global.userInfo.TXTMD, Global.userInfo.WCTYPE,
                              this._newPasswordController.text,
                              Global.userInfo.phoneNumber, () {
                            showCupertinoDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    content: Text(
                                      "修改成功，请重新登录",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        onPressed: () async {
                                          setState(() {
                                            this._loading = false;
                                          });
                                          await Global.logout();
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                              CupertinoPageRoute(builder:
                                                  (BuildContext context) {
                                                return LoginPage();
                                              }), (route) {
                                            return false;
                                          });
                                        },
                                        child: Text("好"),
                                      ),
                                    ],
                                  );
                                });
                          }, (err) {
                            _buildError("系统错误，请稍后再试");
                          });
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          )),
    ));
  }
}




