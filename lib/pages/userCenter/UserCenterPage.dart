import 'dart:convert';
import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ButtonBarWidget.dart';
import 'package:gztyre/components/ButtonWidget.dart';
import 'package:gztyre/components/DividerBetweenIconListItem.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/components/UserInfoWidget.dart';
import 'package:gztyre/pages/login/LoginPage.dart';
import 'package:gztyre/pages/userCenter/PasswordModifyPage.dart';
import 'package:gztyre/pages/userCenter/UserInfoModifyPage.dart';
import 'package:gztyre/pages/userCenter/UserMaintenanceGroupSelectionPage.dart';
import 'package:gztyre/pages/userCenter/UserWorkShiftSelectionPage.dart';


class UserCenterPage extends StatefulWidget {
  UserCenterPage({Key key, @required this.rootContext})
      : assert(rootContext != null),
        super(key: key);

  final BuildContext rootContext;

  @override
  State createState() => _UserCenterPageState();


}

class _UserCenterPageState extends State<UserCenterPage> {
  String _password = "";


  Widget _showPasswordWidget() {
    return GestureDetector(
      child: Container(
        height: 50,
        width: 50,
        child: Icon(Icons.remove_red_eye, color: Colors.black45,),
      ),
      onTap: () {
        if (this._password == "********") {
          this._password = Global.password;
        } else {
          this._password = "********";
        }
        setState(() {

        });
      },
    );
  }


  @override
  void initState() {
    Global.password == null ? this._password = null : this._password = "********";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: UserInfoWidget(userInfo: Global.userInfo,),
            ),
            Expanded(
                child: Container(
                  color: Color.fromRGBO(231, 233, 234, 1),
                  child: ListView(
                    children: <Widget>[
                      Container(
                        height: 10,
                      ),
                      ListItemWidget(
                        title: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(Icons.edit_location, color: Colors.green,),
                            ),
                            Text(
                              "分公司    ${Global.userInfo.MATYT}",
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                        actionArea: Container(),
                      ),
                      Container(
                        height: 10,
                      ),
                      ListItemWidget(
                        title: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(Icons.map, color: Colors.blueGrey,),
                            ),
                            Text(
                              "所在区域：${Global.userInfo.CPLTX}",
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                        actionArea: Container(),
                      ),
                      DividerBetweenIconListItem(),
                      ListItemWidget(
                        onTap: () {
                          Navigator.of(widget.rootContext).push(CupertinoPageRoute(builder: (BuildContext context) {
                            return UserInfoModifyPage();
                          }));
                        },
                        title: Row(
                          children: <Widget>[
                            Padding(
                              child: Icon(Icons.phone_iphone, color: Colors.blueAccent,),
                              padding: EdgeInsets.only(right: 5),
                            ),
                            Text(
                              "联系电话：${Global.userInfo.phoneNumber ?? "无"}",
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                      ),
                      DividerBetweenIconListItem(),
                      ListItemWidget(
                        onTap: () {
                          Navigator.of(widget.rootContext).push(CupertinoPageRoute(builder: (BuildContext context) {
                            return PasswordModifyPage();
                          })).then((val) {
                            setState(() {

                            });
                          });
                        },
                        title: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(Icons.lock_outline, color: Colors.indigoAccent,),
                            ),
                            Text(
                              "密码设置：${this._password}",
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                        actionArea: Row(
                          children: <Widget>[
                            _showPasswordWidget(),
                            Icon(CupertinoIcons.right_chevron, color: Color.fromRGBO(94, 102, 111, 1),)
                          ],
                        ),
                      ),
                      DividerBetweenIconListItem(),
                      ListItemWidget(
                        onTap: () {
                          if (Global.maintenanceGroup == null) {
                            Navigator.of(widget.rootContext).push(CupertinoPageRoute(builder: (BuildContext context) {
                              return UserWorkShiftSelectionPage(userName: Global.userInfo.PERNR, selectItem: Global.workShift,);
                            }));
                          } else {
                            Navigator.of(widget.rootContext).push(CupertinoPageRoute(builder: (BuildContext context) {
                              return UserMaintenanceGroupSelectionPage(selectItemList: Global.maintenanceGroup,);
                            }));
                          }
                        },
                        title: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(Icons.build, color: Colors.indigo,),
                            ),
                            Expanded(
                              child: Global.userInfo.WCTYPE != "是" ? Text(
                                "工作班次：${Global.workShift.PLTXT}",
                                style: TextStyle(fontSize: 16),
                              ) : Text(
                                "维修分组：${Global.maintenanceGroup.toString().substring(1, Global.maintenanceGroup.toString().length - 1)}",
                                style: TextStyle(fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 10,
                      ),
                      Container(
                        color: Color.fromRGBO(231, 233, 234, 1),
                        child: ButtonBarWidget(
                          button: Container(
                            height: 26,
                            child:
                            ButtonWidget(
                              padding: EdgeInsets.all(0),
                              child: Text('退出登录', style: TextStyle(color: Colors.redAccent),),
                              color: Colors.transparent,
                              onPressed: () async {
                                await Global.logout();
                                Navigator.of(widget.rootContext).pushAndRemoveUntil(
                                    CupertinoPageRoute(builder: (BuildContext context) {
                                      return LoginPage();
                                    }), (route) {
                                  return true;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ),
          ],
        ),

      ),
    );
  }
}