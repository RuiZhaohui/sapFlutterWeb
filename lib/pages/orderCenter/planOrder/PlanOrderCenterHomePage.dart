import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/model/Order.dart';
import 'package:gztyre/api/model/UserInfo.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/Badge.dart';
import 'package:gztyre/components/DividerBetweenIconListItem.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/pages/orderCenter/planOrder/OrderListPage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PlanOrderCenterHomePage extends StatefulWidget {
  PlanOrderCenterHomePage({Key key, @required this.rootContext})
      : assert(rootContext != null),
        super(key: key);

  final BuildContext rootContext;

  @override
  State createState() => _PlanOrderCenterHomePageState();
}

class _PlanOrderCenterHomePageState extends State<PlanOrderCenterHomePage> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  var _listOrderFuture;

  bool _loading = false;
  UserInfo _userInfo;
  List<Order> _list;

  List<String> _managerList = ["A04", "A05", "A06", "A07", "A08"];
  bool _isManager = false;
  Map<String, int> _countMap ;

  Future<Map<String, int>> _getCountMap(List<Order> list, bool isManager) async {
    Map<String, int> map = new Map();
    map.putIfAbsent("新工单", () {
      List<Order> resList = new List();
      list.forEach((item) {
        if (item.QMNUM != null &&
            item.QMNUM != '' &&
            (item.APPSTATUS == "" ||
                item.ASTTX == "新建" ||
                item.ASTTX == "新工单")) {
          resList.add(item);
        }
      });
      return resList.length;
    });
    map.putIfAbsent("转卡单", () {
      List<Order> resList = new List();
      list.forEach((item) {
        if (item.QMNUM != null && item.QMNUM != '' && item.APPSTATUS == "转卡") {
          resList.add(item);
        }
      });
      return resList.length;
    });
    map.putIfAbsent("维修中", () {
      List<Order> resList = new List();
      list.forEach((item) {
        if (item.QMNUM != null &&
            item.QMNUM != '' &&
            (isManager ? true : item.PERNR1 == _userInfo.PERNR) && item.ASTTX == "维修中" &&
            (item.APPSTATUS == "接单" ||
                item.APPSTATUS == "转单" ||
                (item.APPSTATUS == "呼叫协助") ||
                (item.APPSTATUS == "加入"))) {
          resList.add(item);
        }
      });
      return resList.length;
    });
    map.putIfAbsent("等待中", () {
      List<Order> resList = new List();
      list.forEach((item) {
        if (item.QMNUM != null &&
            item.QMNUM != '' &&
            (item.APPSTATUS == "等待" &&
                    (isManager ? true : item.PERNR1 == _userInfo.PERNR) ||
                item.APPSTATUS == "再维修" ||
                item.APPSTATUS == "派单")) {
          resList.add(item);
        }
      });
      return resList.length;
    });
    map.putIfAbsent("协助单", () {
      List<Order> resList = new List();
      list.forEach((item) {
        if (item.QMNUM != null &&
            item.QMNUM != '' &&
            (item.APPSTATUS == "呼叫协助" || item.APPSTATUS == "加入") &&
            item.PERNR1 != _userInfo.PERNR) {
          resList.add(item);
        }
      });
      return resList.length;
    });
    await _countHistoryOrder().then((val) {
      map.putIfAbsent("历史单", () {
        return val;
      });
    });
    return map;
  }

  Future<int> _countHistoryOrder() async {
    this._loading = true;
    return await HttpRequest.historyOrder(this._userInfo.PERNR, this._userInfo.WCTYPE == "是" ? "X" : "", (List<Order> list) {
      print(list);
      return list.length;
    }, (err) {
      print(err);
      return 0;
    });
  }

  _listOrder() async {
    this._loading = true;
    this._list = [];
    if (this._userInfo.WCTYPE == "是") {
      return await HttpRequest.listPlanOrder(this._userInfo.PERNR, null, null, null,
          "X", null, "ZPM2", Global.maintenanceGroup, (List<Order> list) async {
            list.forEach((item) {
              if (item.QMNUM != null &&
                  item.QMNUM != '') {
                this._list.add(item);
              }
            });
            this._countMap = await this._getCountMap(this._list, this._isManager);
            this._refreshController.refreshCompleted();
            setState(() {
              this._loading = false;
            });
          }, (err) {
            print(err);
            this._refreshController.refreshFailed();
            setState(() {
              this._loading = false;
            });
          });
    } else {
      return await this._countHistoryOrder().then((val) {
        this._countMap.putIfAbsent("历史单", () {
          return val;
        });
        print(this._countMap);
        this._refreshController.refreshCompleted();
        setState(() {
          this._loading = false;
        });
      }).catchError((err) {
        this._refreshController.refreshFailed();
        setState(() {
          this._loading = false;
        });
      });
    }
  }

  Future<Null> onHeaderRefresh() async {
    this._list = [];
    return await _listOrder();
  }

  @override
  void initState() {
    this._userInfo = Global.userInfo;
    this._isManager =
        this._managerList.any((item) => item == this._userInfo.SORTB);
    this._listOrderFuture = this._listOrder();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this._listOrderFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return ProgressDialog(
          loading: this._loading,
          child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              leading: CupertinoNavigationBarBackButton(
                onPressed: () => Navigator.pop(context),
                color: Color.fromRGBO(94, 102, 111, 1),
              ),
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
                        child: SmartRefresher(
                          controller: _refreshController,
                          header:  WaterDropHeader(complete: Text("刷新成功"), failed: Text("刷新失败"),),
                          enablePullDown: true,
                          onRefresh: onHeaderRefresh,
                          child: ListView(
                            children: <Widget>[
                              this._userInfo.WCTYPE == "是" ? ListItemWidget(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    ImageIcon(
                                      AssetImage(
                                          "assets/images/icon/icon_new_item.png"),
                                      size: 16,
                                      color: Color.fromRGBO(43, 118, 255, 1),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        "新工单",
                                        style: TextStyle(fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(widget.rootContext).push(
                                      new CupertinoPageRoute(
                                          settings:
                                              RouteSettings(name: "repairList"),
                                          builder: (BuildContext context) {
                                            return OrderListPage(
                                              title: "新工单",
                                            );
                                          })).then((val) {
                                    this._listOrder();
                                  });
                                },
                                actionArea: Row(
                                  children: <Widget>[
                                    this._countMap != null && this._countMap["新工单"] != 0
                                        ? Badge(
                                            child: Text(
                                              this
                                                  ._countMap["新工单"]
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            ),
                                            color: Colors.red)
                                        : Container(),
                                    Icon(
                                      CupertinoIcons.right_chevron,
                                      color: Color.fromRGBO(94, 102, 111, 1),
                                    )
                                  ],
                                ),
                              ) : Container(),
                              this._userInfo.WCTYPE == "是" ? DividerBetweenIconListItem() : Container(),
                              this._userInfo.WCTYPE == "是" ? ListItemWidget(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    ImageIcon(
                                      AssetImage(
                                          "assets/images/icon/icon_transfer_card.png"),
                                      size: 16,
                                      color: Color.fromRGBO(250, 74, 38, 1),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        "转卡单",
                                        style: TextStyle(fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(widget.rootContext).push(
                                      new CupertinoPageRoute(
                                          settings:
                                              RouteSettings(name: "repairList"),
                                          builder: (BuildContext context) {
                                            return OrderListPage(
                                              title: "转卡单",
                                            );
                                          })).then((val) {
                                    this._listOrder();
                                  });
                                },
                                actionArea: Row(
                                  children: <Widget>[
                                    this._countMap != null && this._countMap["转卡单"] != 0
                                        ? Badge(
                                            child: Text(
                                              this
                                                  ._countMap["转卡单"]
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            ),
                                            color: Colors.red,
                                          )
                                        : Container(),
                                    Icon(
                                      CupertinoIcons.right_chevron,
                                      color: Color.fromRGBO(94, 102, 111, 1),
                                    )
                                  ],
                                ),
                              ) : Container(),
                              this._userInfo.WCTYPE == "是" ? DividerBetweenIconListItem() : Container(),
                              this._userInfo.WCTYPE == "是" ? ListItemWidget(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    ImageIcon(
                                      AssetImage(
                                          "assets/images/icon/icon_repairing.png"),
                                      size: 16,
                                      color: Colors.blueAccent,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        "维修中",
                                        style: TextStyle(fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(widget.rootContext).push(
                                      new CupertinoPageRoute(
                                          settings:
                                              RouteSettings(name: "repairList"),
                                          builder: (BuildContext context) {
                                            return OrderListPage(
                                              title: "维修中",
                                            );
                                          })).then((val) {
                                            this._listOrder();
                                  });
                                },
                                actionArea: Row(
                                  children: <Widget>[
                                    this._countMap != null && this._countMap["维修中"] != 0
                                        ? Badge(
                                            child: Text(
                                              this
                                                  ._countMap["维修中"]
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            ),
                                            color: Colors.red,
                                          )
                                        : Container(),
                                    Icon(
                                      CupertinoIcons.right_chevron,
                                      color: Color.fromRGBO(94, 102, 111, 1),
                                    )
                                  ],
                                ),
                              ) : Container(),
                              this._userInfo.WCTYPE == "是" ? DividerBetweenIconListItem() : Container(),
                              this._userInfo.WCTYPE == "是" ? ListItemWidget(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    ImageIcon(
                                      AssetImage(
                                          "assets/images/icon/icon_waiting.png"),
                                      size: 16,
                                      color: Colors.greenAccent,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        "等待中",
                                        style: TextStyle(fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(widget.rootContext).push(
                                      new CupertinoPageRoute(
                                          settings:
                                              RouteSettings(name: "repairList"),
                                          builder: (BuildContext context) {
                                            return OrderListPage(
                                              title: "等待中",
                                            );
                                          })).then((val) {
                                    this._listOrder();
                                  });
                                },
                                actionArea: Row(
                                  children: <Widget>[
                                    this._countMap != null && this._countMap["等待中"] != 0
                                        ? Badge(
                                            child: Text(
                                              this
                                                  ._countMap["等待中"]
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            ),
                                            color: Colors.red,
                                          )
                                        : Container(),
                                    Icon(
                                      CupertinoIcons.right_chevron,
                                      color: Color.fromRGBO(94, 102, 111, 1),
                                    )
                                  ],
                                ),
                              ) : Container(),
                              this._userInfo.WCTYPE == "是" ? DividerBetweenIconListItem() : Container(),
                              this._userInfo.WCTYPE == "是" ? ListItemWidget(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    ImageIcon(
                                      AssetImage(
                                          "assets/images/icon/icon_assiant.png"),
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        "协助单",
                                        style: TextStyle(fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(widget.rootContext).push(
                                      new CupertinoPageRoute(
                                          settings:
                                              RouteSettings(name: "repairList"),
                                          builder: (BuildContext context) {
                                            return OrderListPage(
                                              title: "协助单",
                                            );
                                          })).then((val) {
                                    this._listOrder();
                                  });
                                },
                                actionArea: Row(
                                  children: <Widget>[
                                    this._countMap != null && this._countMap["协助单"] != 0
                                        ? Badge(
                                      child: Text(
                                        this
                                            ._countMap["协助单"]
                                            .toString(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14),
                                      ),
                                      color: Colors.red,
                                    )
                                        : Container(),
                                    Icon(
                                      CupertinoIcons.right_chevron,
                                      color: Color.fromRGBO(94, 102, 111, 1),
                                    )
                                  ],
                                ),
                              ) : Container(),
                              this._userInfo.WCTYPE == "是" ? DividerBetweenIconListItem() : Container(),
                              ListItemWidget(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    ImageIcon(
                                      AssetImage(
                                          "assets/images/icon/icon_history.png"),
                                      size: 16,
                                      color: Colors.deepOrangeAccent,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        "历史单",
                                        style: TextStyle(fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(widget.rootContext).push(
                                      new CupertinoPageRoute(
                                          settings:
                                              RouteSettings(name: "repairList"),
                                          builder: (BuildContext context) {
                                            return OrderListPage(
                                              title: "历史单",
                                            );
                                          })).then((val) {
                                    this._listOrder();
                                  });
                                },
                                actionArea: Row(
                                  children: <Widget>[
                                    this._countMap != null && this._countMap["历史单"] != 0
                                        ? Badge(
                                      child: Text(
                                        this
                                            ._countMap["历史单"]
                                            .toString(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14),
                                      ),
                                      color: Colors.red,
                                    )
                                        : Container(),
                                    Icon(
                                      CupertinoIcons.right_chevron,
                                      color: Color.fromRGBO(94, 102, 111, 1),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
