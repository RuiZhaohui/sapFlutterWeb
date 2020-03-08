import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/model/UserInfo.dart';
import 'package:gztyre/utils/screen_utils.dart';

class UserInfoWidget extends StatelessWidget {

  UserInfoWidget({Key key, this.userInfo}) : super(key: key);

  final UserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                image: DecorationImage(image: AssetImage('assets/images/user.jpeg'), fit: BoxFit.cover,)
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(2),
                      child: Text(
                        userInfo.ENAME,
                        style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2, bottom: 2, left: 8),
                      child: Text(
                        (userInfo.SORTT == null || userInfo.SORTT == "") ? "" : "【${userInfo.SORTT}】",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 2, top: 4),
                  child: Text(
                    "职工号：${userInfo.PERNR}",
                    style: TextStyle(fontSize: 14, color: Colors.black45, fontWeight: FontWeight.w400),
                  ),
                ),
//              Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  Padding(
//                    padding: EdgeInsets.all(2),
//                    child: Row(
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      children: <Widget>[
//                        Container(
//                          child: Text("分公司名称", style: TextStyle(color: Colors.white, fontSize: 14),),
//                        ),
//                        Container(
//                          width: ScreenUtils.screenW(context) / 2,
//                          child: Padding(
//                            padding: EdgeInsets.only(left: 5),
////                          child: Container(
////                            width: ScreenUtils.screenW(context) / 4,
//                            child: Text(
//                              userInfo.TXTMD,
//                              style: TextStyle(color: Colors.white, fontSize: 14),
//                              maxLines: 3,
//                            ),
////                          ),
//                          ),
//                        )
//                      ],
//                    ),
//                  ),
//                  Padding(
//                      padding: EdgeInsets.all(2),
//                      child:  Row(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: <Widget>[
//                          Text("区域",style: TextStyle(color: Colors.white, fontSize: 14),),
//                          Container(
//                            width: ScreenUtils.screenW(context) / 2,
//                            child: Padding(
//                              padding: EdgeInsets.only(left: 5),
////                            child: Container(
////                              width: ScreenUtils.screenW(context) / 5,
//                              child: Text(
//                                userInfo.CPLTX,
//                                style: TextStyle(color: Colors.white, fontSize: 14),
//                                maxLines: 3,
//                              ),
////                            ),
//                            ),
//                          )
//                        ],
//                      )
//                  ),
//                ],
//              ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
