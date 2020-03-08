import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/HttpRequestRest.dart';
import 'package:gztyre/api/model/UserInfo.dart';
import 'package:gztyre/components/DividerBetweenIconListItem.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/components/UserInfoWidget.dart';
import 'package:gztyre/pages/userCenter/UserInfoModifyPage.dart';
import 'package:url_launcher/url_launcher.dart';

class UserInfoPage extends StatefulWidget {
  UserInfoPage({Key key, @required this.PERNR}) : assert(PERNR != null) , super(key: key);

  final String PERNR;

  @override
  State createState() {
    return _UserInfoPageState();
  }
}

class _UserInfoPageState extends State<UserInfoPage> {
  UserInfo _userInfo = new UserInfo();
  bool _loading = false;
  var _getUserInfoFuture;

  _getUserInfo() async {
    setState(() {
      this._loading = true;
    });
    await HttpRequest.searchUserInfo(widget.PERNR, (UserInfo userInfo) async {
      _userInfo = userInfo;
      await HttpRequestRest.searchUser(widget.PERNR, (Map map) {
        this._userInfo.phoneNumber = map["phoneNumber"];
        setState(() {
          this._loading = false;
        });
      }, (err) {
        setState(() {
          this._loading = false;
        });
      });
    }, (err) {
      setState(() {
        this._loading = false;
      });
    });
  }

  _launchPhone(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  @override
  void initState() {
    this._getUserInfoFuture = this._getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this._getUserInfoFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        return ProgressDialog(
            loading: this._loading,
            child: CupertinoPageScaffold(
              backgroundColor: Colors.white,
//              navigationBar: CupertinoNavigationBar(
//                leading: CupertinoNavigationBarBackButton(
//                  onPressed: () => Navigator.pop(context),
//                  color: Color.fromRGBO(94, 102, 111, 1),
//                ),
//              ),
              child: SafeArea(
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.chevron_left, color: Color.fromRGBO(76, 83, 92, 1), size: 40,),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 25),
                            child: UserInfoWidget(
                              userInfo: this._userInfo,
                            ),
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
                                          "分公司    ${this._userInfo.MATYT}",
                                          style: TextStyle(fontSize: 16),
                                        )
                                      ],
                                    ),
                                    actionArea: Container(),
                                  ),
                                  DividerBetweenIconListItem(),
                                  ListItemWidget(
                                    title: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(right: 5),
                                          child: Icon(Icons.map, color: Colors.blueGrey,),
                                        ),
                                        Text(
                                          "所在区域    ${this._userInfo.CPLTX}",
                                          style: TextStyle(fontSize: 16),
                                        )
                                      ],
                                    ),
                                    actionArea: Container(),
                                  ),
                                  DividerBetweenIconListItem(),
                                  ListItemWidget(
                                    onTap: () {
                                      if (this._userInfo.phoneNumber == null) {
                                        showCupertinoDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CupertinoAlertDialog(
                                                content: Text(
                                                  "无号码信息",
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
                                      } else {
//                                        this._launchPhone(this._userInfo.phoneNumber);
                                      }
                                    },
                                    title: Row(
                                      children: <Widget>[
                                        Padding(
                                          child: Icon(Icons.phone_iphone, color: Colors.blueAccent,),
                                          padding: EdgeInsets.only(right: 5),
                                        ),
                                        Text(
                                          "呼叫用户    ${this._userInfo.phoneNumber ?? "无"}",
                                          style: TextStyle(fontSize: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
              ),
            ));
      } else return ProgressDialog(
          loading: this._loading, child: Container(),);
    });
  }
}
