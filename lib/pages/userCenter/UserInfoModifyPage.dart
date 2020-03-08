import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequestRest.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ButtonBarWidget.dart';
import 'package:gztyre/components/ButtonWidget.dart';
import 'package:gztyre/components/InputWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';

class UserInfoModifyPage extends StatefulWidget {
  UserInfoModifyPage({
    Key key,
  }) : super(key: key);

  @override
  State createState() => _UserInfoModifyPageState();
}

class _UserInfoModifyPageState extends State<UserInfoModifyPage> {
  TextEditingController _phoneNumberController = new TextEditingController();

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
    this._phoneNumberController.text = Global.userInfo.phoneNumber ?? "";
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
          "修改号码",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      child: SafeArea(
          child: CupertinoScrollbar(
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: InputWidget(
                        controller: this._phoneNumberController,
                        obscureText: false,
                        prifixMode: OverlayVisibilityMode.never,
                        placeholderText: "请输入手机号",
                        keyboardType: TextInputType.visiblePassword,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ButtonBarWidget(
                    button: Container(
                      child:
                      ButtonWidget(
                        child: Text("确认修改", style: TextStyle(color: Color.fromRGBO(33, 127, 184, 1)),),
                        color: Color.fromRGBO(33, 127, 184, 1),
                        onPressed: () {
                          if (this._phoneNumberController.text == null ||
                              this._phoneNumberController.text == "") {
                            _buildError("请输入手机号");
                          } else {
                            this._loading = true;
                            HttpRequestRest.update(
                                Global.userInfo.PERNR, Global.userInfo.ENAME, Global.userInfo.SORTB, Global.userInfo.SORTT,
                                Global.userInfo.CPLGR, Global.userInfo.CPLTX, Global.userInfo.MATYP, Global.userInfo.MATYT,
                                Global.userInfo.WERKS, Global.userInfo.TXTMD, Global.userInfo.WCTYPE,
                                null,
                                this._phoneNumberController.text, () {
                                  Global.userInfo.phoneNumber = this._phoneNumberController.text;
                              showCupertinoDialog(
                                  context: context,
                                  builder: (BuildContext contextTemp) {
                                    return CupertinoAlertDialog(
                                      content: Text(
                                        "修改成功",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          onPressed: () async {
                                            Navigator.of(contextTemp).pop();
                                            setState(() {
                                              this._loading = false;
                                            });
                                            await Global.logout();
                                            Navigator.of(context)
                                                .pop();
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
                  ),
                )
              ],
            ),
          )),
    ));
  }
}


