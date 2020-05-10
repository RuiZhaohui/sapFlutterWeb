import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/components/DividerBetweenIconListItem.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/pages/orderCenter/assisantOrder/AssisantOrderCenterHomePage.dart';
import 'package:gztyre/pages/orderCenter/blockOrder/BlockOrderCenterHomePage.dart';
import 'package:gztyre/pages/orderCenter/noPlanOrder/NoPlanOrderCenterHomePage.dart';
import 'package:gztyre/pages/orderCenter/planOrder/PlanOrderCenterHomePage.dart';

class OrderCategory extends StatefulWidget {
  OrderCategory({Key key,@required this.rootContext}) : super(key: key);

  final BuildContext rootContext;

  @override
  State createState() => _OrderCategoryState();
}

class _OrderCategoryState extends State<OrderCategory> {

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle:
        Text("订单中心", style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                color: Color.fromRGBO(231, 233, 234, 1),
                child: CupertinoScrollbar(
                    child: ListView(
                      children: <Widget>[
                        ListItemWidget(
                          title: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: ImageIcon(AssetImage("assets/images/icon/plan_repair.png"), color: Colors.redAccent,),
                              ),
                              Text(
                                "计划性维修",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.of(widget.rootContext).push(CupertinoPageRoute(
                              builder: (BuildContext context) {
                              return PlanOrderCenterHomePage(rootContext: context,);
                            }, settings: RouteSettings(name: "planOrderHome"),));
                          },
                        ),
                        DividerBetweenIconListItem(),
                        ListItemWidget(
                          title: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: ImageIcon(AssetImage("assets/images/icon/no_plan_repair.png"), color: Colors.deepOrangeAccent,),
                              ),
                              Text(
                                "非计划性维修",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.of(widget.rootContext).push(CupertinoPageRoute(builder: (BuildContext context) {
                              return NoPlanOrderCenterHomePage(rootContext: context,);
                            }, settings: RouteSettings(name: "noPlanOrderHome"),));
                          },
                        ),
                        DividerBetweenIconListItem(),
                        ListItemWidget(
                          title: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: ImageIcon(AssetImage("assets/images/icon/assisant_repair.png"), color: Colors.indigoAccent,),
                              ),
                              Text(
                                "组织维修",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.of(widget.rootContext).push(CupertinoPageRoute(
                              builder: (BuildContext context) {
                                return AssisantOrderCenterHomePage(rootContext: context,);
                              }, settings: RouteSettings(name: "assisantOrderHome"),));
                          },
                        ),
                        DividerBetweenIconListItem(),
                        ListItemWidget(
                          title: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: ImageIcon(AssetImage("assets/images/icon/block_repair.png"), color: Colors.greenAccent,),
                              ),
                              Text(
                                "备件维修",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.of(widget.rootContext).push(CupertinoPageRoute(
                              builder: (BuildContext context) {
                                return BlockOrderCenterHomePage(rootContext: context,);
                              }, settings: RouteSettings(name: "blockOrderHome"),));
                          },
                        ),
                      ],
                    ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}