import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/HttpRequestRest.dart';
import 'package:gztyre/api/model/Order.dart';
import 'package:gztyre/api/model/RepairOrder.dart';
import 'package:gztyre/api/model/ReportOrder.dart';
import 'package:gztyre/api/model/UserInfo.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ButtonBarWidget.dart';
import 'package:gztyre/components/ButtonWidget.dart';
import 'package:gztyre/components/DividerBetweenIconListItem.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/components/OrderInfoWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/pages/ContainerPage.dart';
import 'package:gztyre/pages/orderCenter/planOrder/WorkerPage.dart';
import 'package:gztyre/pages/repairOrder/RepairDetailPage.dart';
import 'package:gztyre/pages/repairOrder/RepairHistoryPage.dart';
import 'package:gztyre/pages/repairOrder/RepairOrderDetailPage.dart';
import 'package:gztyre/utils/StringUtils.dart';
import 'package:gztyre/utils/screen_utils.dart';

class RepairOrderPage extends StatefulWidget {
  RepairOrderPage({Key key, @required this.order}) : super(key: key);

  final Order order;

  @override
  State createState() {
    return _RepairOrderPageState();
  }
}

class _RepairOrderPageState extends State<RepairOrderPage> {
  bool _loading = false;
  UserInfo _userInfo;
  var _reportOrderDetailFuture;
  ReportOrder _reportOrder = new ReportOrder();
  RepairOrder _repairOrder;
  TextEditingController _controller = TextEditingController();

  List<String> _maintenanceWorker = ["A01", "A02", "A03"];
  List<String> _monitorOrForeman = ["A04", "A05"];
  List<String> _equipmentSupervisor = ["A06"];
  List<String> _engineer = ["A07"];
  List<String> _maintenanceManagementPersonnel = ["A08"];

  Future<String> _getAPPTRADENO(String QMNUM, String AUFNR) async {
    String sapNo;
    if (StringUtils.isBank(QMNUM)) {
      sapNo = AUFNR;
    } else sapNo = QMNUM;
    return await HttpRequestRest.getMalfunction(sapNo, (Map map) async {
      return map['tradeNo'];
    }, (err) async {
      this._resetAPPTRANENO(widget.order);
//      this._loading = false;
      throw Error();
    });
  }

  _resetAPPTRANENO(Order order) async {
    String tradeNo =
    (new DateTime.now().millisecondsSinceEpoch.toString() + "000")
        .substring(0, 16);
    if (order.QMNUM != null || order.QMNUM != "") {
      await HttpRequestRest.malfunction(
          tradeNo,
          order.QMNUM,
          0,
          [],
          null,
          null,
          null,
          null,
          null,
          false,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
              (s) {},
              (e) {});
    }
    if (order.AUFNR != null || order.AUFNR != "") {
      await HttpRequestRest.malfunction(
          tradeNo,
          order.AUFNR,
          0,
          [],
          null,
          null,
          null,
          null,
          null,
          false,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
              (s) {},
              (e) {});
    }
  }

  _orderDetail() async {
    this._loading = true;
    await HttpRequest.reportOrderDetail(widget.order.QMNUM,
            (ReportOrder order) async {
          this._reportOrder = order;
          if (widget.order.AUFNR != null && widget.order.AUFNR != "") {
            await HttpRequest.repairOrderDetail(widget.order.AUFNR,
                    (RepairOrder rOrder) {
                  this._repairOrder = rOrder;
                  widget.order.isStop = rOrder.MSAUS;
                  setState(() {
                    this._loading = false;
                  });
                }, (err) {
                  print(err);
                  setState(() {
                    this._loading = false;
                  });
                });
          } else {
            setState(() {
              this._loading = false;
            });
          }
        }, (err) {
          print(err);
          setState(() {
            this._loading = false;
          });
        });
  }

  Future<bool> _complete(
      Order order, ReportOrder reportOrder, String PERNR) async {
//    setState(() {
//      this._loading = true;
//    });
    return await this._getAPPTRADENO(order.QMNUM, order.AUFNR).then((APPTRADENO) async {
      return await HttpRequest.completeOrder(
          PERNR, order.AUFNR, "已确认", APPTRADENO, (res) {
//        setState(() {
//          this._loading = false;
//        });
        return true;
      }, (err) {
//        setState(() {
//          this._loading = false;
//        });
        return false;
      });
    }).catchError((err) {
//      setState(() {
//        this._loading = false;
//      });
      return false;
    });
  }

  Future<bool> _repairAgain() async {
//    setState(() {
//      this._loading = true;
//    });
    return await this
        ._getAPPTRADENO(widget.order.QMNUM, widget.order.AUFNR)
        .then((APPTRADENO) async {
      return await HttpRequest.changeOrderStatus(null, null, widget.order.AUFNR,
          "再维修", APPTRADENO, '', '', widget.order.EQUNR, null, null, (res) {
//        setState(() {
//          this._loading = false;
//        });
            return true;
          }, (err) {
//        setState(() {
//          this._loading = false;
//        });
            return false;
          });
    }).catchError((err) {
//      setState(() {
//        this._loading = false;
//      });
      return false;
    });
  }

  Future<bool> _transToNextWorkShift(
      ReportOrder reportOrder, String PERNR) async {
//    setState(() {
//      this._loading = true;
//    });
    if (reportOrder == null) {
//      setState(() {
//        this._loading = false;
//      });
      return false;
    } else {
      return await this
          ._getAPPTRADENO(reportOrder.QMNUM, null)
          .then((APPTRADENO) async {
        return await HttpRequest.changeOrderStatus(
            PERNR,
            reportOrder.QMNUM,
            null,
            "转单",
            APPTRADENO,
            '',
            '',
            reportOrder.EQUNR,
            null,
            null, (res) {
//          setState(() {
//            this._loading = false;
//          });
          return true;
        }, (err) {
//          setState(() {
//            this._loading = false;
//          });
          return false;
        });
      }).catchError((err) {
//        setState(() {
//          this._loading = false;
//        });
        return false;
      });
    }
  }

  Future<String> _isExist(username) async {
//    setState(() {
//      this._loading = true;
//    });
    return await HttpRequestRest.exist(username, (isExist) async {
//      setState(() {
//        this._loading = false;
//      });
      if (isExist) {
        return await HttpRequestRest.searchUser(username, (data) {
          return data["werks"];
        }, (err) => null);
      } else {
        return null;
      }
    }, (err) {
//      setState(() {
//        this._loading = false;
//      });
      return null;
    });
  }

  Widget _completeButton() {
    return ButtonWidget(
      padding: EdgeInsets.only(left: 0, right: 0),
      child: Text(
        '确认完工',
        style: TextStyle(color: Colors.deepOrange),
      ),
      color: Colors.deepOrange,
      onPressed: () {
        setState(() {
          this._loading = true;
        });
        if (widget.order.ASTTX == "新建" || widget.order.ASTTX == "新工单") {
          setState(() {
            this._loading = false;
          });
          showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  content: Text(
                    "通知单不可完工",
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
        } else if (widget.order.ASTTX == "维修中") {
          setState(() {
            this._loading = false;
          });
          showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  content: Text(
                    "工单未完工",
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
        } else {
          showCupertinoDialog(
              context: context,
              builder: (BuildContext contextTemp) {
                return CupertinoAlertDialog(
                  content: Text(
                    "是否确认完工",
                    style: TextStyle(fontSize: 18),
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      onPressed: () {
                        setState(() {
                          this._loading = false;
                        });
                        Navigator.of(contextTemp).pop();
                      },
                      child: Text("否"),
                    ),
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(contextTemp).pop();
                        this
                            ._complete(widget.order, this._reportOrder,
                            Global.userInfo.PERNR)
                            .then((success) async {
                          if (success) {
                            setState(() {
                              widget.order.ASTTX = "已确认";
                              this._loading = false;
                            });
                            await HttpRequestRest.pushAlias(
                                [Global.userInfo.CPLGR + Global.userInfo.MATYP + widget.order.PERNR1],
                                "",
                                "",
                                "${Global.userInfo.ENAME}已确认维修单${widget.order.AUFNR}完工",
                                [],
                                    (success) {},
                                    (err) {});
                            Navigator.of(context).pushAndRemoveUntil(
                                CupertinoPageRoute(
                                    builder: (BuildContext context) {
                                      return ContainerPage(
                                        rootContext: context,
                                      );
                                    }), (route) {
                              return true;
                            });
                          } else {
                            setState(() {
                              this._loading = false;
                            });
                            showCupertinoDialog(
                                context: context,
                                builder: (BuildContext contextTempB) {
                                  return CupertinoAlertDialog(
                                    content: Text(
                                      "操作失败",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        onPressed: () {
                                          Navigator.of(contextTempB).pop();
                                        },
                                        child: Text("好"),
                                      ),
                                    ],
                                  );
                                });
                          }
                        });
                      },
                      child: Text("是"),
                    )
                  ],
                );
              });
        }
      },
    );
  }

  Widget _reRepairButton() {
    return ButtonWidget(
      padding: EdgeInsets.only(left: 0, right: 0),
      child: Text('再维修', style: TextStyle(color: Colors.green)),
      color: Colors.green,
      onPressed: () {
        setState(() {
          this._loading = true;
        });
        this._repairAgain().then((success) async {
          if (success) {
            setState(() {
              widget.order.ASTTX = "维修中";
              this._loading = false;
            });
            await HttpRequestRest.pushAlias(
                [Global.userInfo.CPLGR + Global.userInfo.MATYP + widget.order.PERNR1],
                "",
                "",
                "${Global.userInfo.ENAME}请求再维修维修单${widget.order.AUFNR}",
                [],
                    (success) {},
                    (err) {});
            showCupertinoDialog(
                context: context,
                builder: (BuildContext contextTemp) {
                  return CupertinoAlertDialog(
                    content: Text(
                      "操作成功",
                      style: TextStyle(fontSize: 18),
                    ),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.of(contextTemp).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text("好"),
                      ),
                    ],
                  );
                });
          } else {
            setState(() {
              this._loading = false;
            });
            showCupertinoDialog(
                context: context,
                builder: (BuildContext contextTemp) {
                  return CupertinoAlertDialog(
                    content: Text(
                      "操作失败",
                      style: TextStyle(fontSize: 18),
                    ),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.of(contextTemp).pop();
                        },
                        child: Text("好"),
                      ),
                    ],
                  );
                });
          }
        });
      },
    );
  }

  Widget _transferToNextWorkShiftButton() {
    return ButtonWidget(
      padding: EdgeInsets.only(left: 0, right: 0),
      child: Text('转接班人',
          style: TextStyle(color: Color.fromRGBO(76, 129, 235, 1))),
      color: Color.fromRGBO(76, 129, 235, 1),
      onPressed: () {
        setState(() {
          this._loading = true;
        });
        showCupertinoDialog(
            context: context,
            builder: (BuildContext contextA) {
              return CupertinoAlertDialog(
                content: CupertinoTextField(
                  placeholder: "输入接班人工号",
                  controller: this._controller,
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(contextA).pop();

                      setState(() {
                        this._loading = false;
                      });
                    },
                    child: Text("否"),
                  ),
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(contextA).pop();
                      setState(() {
                        this._loading = true;
                      });
                      this._isExist(this._controller.text).then((value) {
                        if (value != null && value == Global.userInfo.WERKS) {
                          this
                              ._transToNextWorkShift(
                              this._reportOrder, this._controller.text)
                              .then((success) async {
                            if (success) {
                              setState(() {
                                this._loading = false;
                              });
                              await HttpRequestRest.pushAlias(
                                  [Global.userInfo.CPLGR + Global.userInfo.MATYP + _controller.text],
                                  "",
                                  "",
                                  "${Global.userInfo.ENAME}转单",
                                  [],
                                      (success) {},
                                      (err) {});
                              showCupertinoDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      content: Text(
                                        "转单成功",
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
                            } else {
                              setState(() {
                                this._loading = false;
                              });
                              showCupertinoDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      content: Text(
                                        "转单失败",
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
                          });
                        } else {
                          setState(() {
                            this._loading = false;
                          });
                          showCupertinoDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                  content: Text(
                                    "未找到用户",
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
                      });
                    },
                    child: Text("是"),
                  )
                ],
              );
            });
      },
    );
  }

  List<Widget> productionFaultRepairOrder() {
    if (widget.order.ILART == "N01") {
      return [
        (widget.order.ASTTX == "新建" ||
            widget.order.ASTTX == "新工单" ||
            widget.order.ASTTX == "维修中" ||
            widget.order.ASTTX == "等待中") && (Global.userInfo.WCTYPE != "是")
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: _transferToNextWorkShiftButton(),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") && (Global.userInfo.WCTYPE != "是")
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _transferToNextWorkShiftButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _reRepairButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") &&
            (_maintenanceWorker.contains(Global.userInfo.SORTB) ||
                _monitorOrForeman.contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
      ];
    } else
      return [];
  }

  List<Widget> unplannedToolingRepairOrder() {
    if (widget.order.ILART == "N02") {
      return [];
    } else
      return [];
  }

  List<Widget> nonPlannedSpecialEquipmentOrder() {
    if (widget.order.ILART == "N03") {
      return [
        (widget.order.ASTTX == "新建" ||
            widget.order.ASTTX == "新工单" ||
            widget.order.ASTTX == "维修中" ||
            widget.order.ASTTX == "等待中")
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: _transferToNextWorkShiftButton(),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工")
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _transferToNextWorkShiftButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _reRepairButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
      ];
    } else
      return [];
  }

  List<Widget> unplannedInfrastructureRepairOrder() {
    if (widget.order.ILART == "N04") {
      return [
        (widget.order.ASTTX == "新建" ||
            widget.order.ASTTX == "新工单" ||
            widget.order.ASTTX == "维修中" ||
            widget.order.ASTTX == "等待中") &&
            (_monitorOrForeman.contains(Global.userInfo.SORTB) ||
                _equipmentSupervisor.contains(Global.userInfo.SORTB) ||
                _engineer.contains(Global.userInfo.SORTB) ||
                _maintenanceManagementPersonnel
                    .contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: _transferToNextWorkShiftButton(),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") &&
            (_monitorOrForeman.contains(Global.userInfo.SORTB) ||
                _equipmentSupervisor.contains(Global.userInfo.SORTB) ||
                _engineer.contains(Global.userInfo.SORTB) ||
                _maintenanceManagementPersonnel
                    .contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _transferToNextWorkShiftButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _reRepairButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") &&
            (_maintenanceWorker.contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
      ];
    } else
      return [];
  }

  List<Widget> machiningRepairOrder() {
    if (widget.order.ILART == "N18") {
      return [];
    } else
      return [];
  }

  List<Widget> nonPlanedInspectionOrder() {
    if (widget.order.ILART == "N21") {
      return [];
    } else
      return [];
  }

  List<Widget> preventiveMaintenanceOrder() {
    if (widget.order.ILART == "N05") {
      return [
        (widget.order.ASTTX == "新建" ||
            widget.order.ASTTX == "新工单" ||
            widget.order.ASTTX == "维修中" ||
            widget.order.ASTTX == "等待中") &&
            (_engineer.contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: _transferToNextWorkShiftButton(),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") &&
            (_engineer.contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _transferToNextWorkShiftButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _reRepairButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
      ];
    } else
      return [];
  }

  List<Widget> inspectionOrder() {
    if (widget.order.ILART == "N06") {
      return [
        (widget.order.ASTTX == "新建" ||
            widget.order.ASTTX == "新工单" ||
            widget.order.ASTTX == "维修中" ||
            widget.order.ASTTX == "等待中") &&
            (_maintenanceWorker.contains(Global.userInfo.SORTB) ||
                _engineer.contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: _transferToNextWorkShiftButton(),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") &&
            (_maintenanceWorker.contains(Global.userInfo.SORTB) ||
                _engineer.contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _transferToNextWorkShiftButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
      ];
    } else
      return [];
  }

  List<Widget> forecastMaintenanceOrder() {
    if (widget.order.ILART == "N07") {
      return [
        (widget.order.ASTTX == "新建" ||
            widget.order.ASTTX == "新工单" ||
            widget.order.ASTTX == "维修中" ||
            widget.order.ASTTX == "等待中") &&
            (Global.userInfo.WCTYPE != "是" ||
                _maintenanceWorker.contains(Global.userInfo.SORTB) ||
                _engineer.contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: _transferToNextWorkShiftButton(),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") && (Global.userInfo.WCTYPE != "是")
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _transferToNextWorkShiftButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _reRepairButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") &&
            (_engineer.contains(Global.userInfo.SORTB) || _maintenanceWorker.contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _transferToNextWorkShiftButton(),
                        ),
                      ),
                      (_engineer.contains(Global.userInfo.SORTB)) ? Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _reRepairButton(),
                        ),
                      ) : Container(),
                      !widget.order.isStop ? Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ) : Container(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") &&
            widget.order.isStop
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _transferToNextWorkShiftButton(),
                        ),
                      ),
                      (_engineer.contains(Global.userInfo.SORTB)) ? Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _reRepairButton(),
                        ),
                      ) : Container(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
      ];
    } else
      return [];
  }

  List<Widget> improveMaintenanceOrder() {
    if (widget.order.ILART == "N09") {
      return [
        (widget.order.ASTTX == "新建" ||
            widget.order.ASTTX == "新工单" ||
            widget.order.ASTTX == "维修中" ||
            widget.order.ASTTX == "等待中") &&
            (_engineer.contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: _transferToNextWorkShiftButton(),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") &&
            (_engineer.contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _transferToNextWorkShiftButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _reRepairButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
      ];
    } else
      return [];
  }

  List<Widget> plannedToolingRepairOrder() {
    if (widget.order.ILART == "N10") {
      return [];
    } else
      return [];
  }

  List<Widget> plannedSpecialEquipmentOrder() {
    if (widget.order.ILART == "N11") {
      return [
        (widget.order.ASTTX == "新建" ||
            widget.order.ASTTX == "新工单" ||
            widget.order.ASTTX == "维修中" ||
            widget.order.ASTTX == "等待中")
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: _transferToNextWorkShiftButton(),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工")
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _transferToNextWorkShiftButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _reRepairButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
      ];
    } else
      return [];
  }

  List<Widget> plannedInfrastructureRepairOrder() {
    if (widget.order.ILART == "N12") {
      return [
        (widget.order.ASTTX == "新建" ||
            widget.order.ASTTX == "新工单" ||
            widget.order.ASTTX == "维修中" ||
            widget.order.ASTTX == "等待中") &&
            (_monitorOrForeman.contains(Global.userInfo.SORTB) ||
                _equipmentSupervisor.contains(Global.userInfo.SORTB) ||
                _engineer.contains(Global.userInfo.SORTB) ||
                _maintenanceManagementPersonnel
                    .contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: _transferToNextWorkShiftButton(),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") &&
            (_monitorOrForeman.contains(Global.userInfo.SORTB) ||
                _equipmentSupervisor.contains(Global.userInfo.SORTB) ||
                _engineer.contains(Global.userInfo.SORTB) ||
                _maintenanceManagementPersonnel
                    .contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _transferToNextWorkShiftButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _reRepairButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") &&
            (_maintenanceWorker.contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
      ];
    } else
      return [];
  }

  List<Widget> plannedInspectionRepairOrder() {
    if (widget.order.ILART == "N19") {
      return [
        (widget.order.ASTTX == "新建" ||
            widget.order.ASTTX == "新工单" ||
            widget.order.ASTTX == "维修中" ||
            widget.order.ASTTX == "等待中") &&
            (Global.userInfo.WCTYPE != "是" ||
                _maintenanceWorker.contains(Global.userInfo.SORTB) ||
                _engineer.contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: _transferToNextWorkShiftButton(),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") && (Global.userInfo.WCTYPE != "是")
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _transferToNextWorkShiftButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _reRepairButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") &&
            (_engineer.contains(Global.userInfo.SORTB) || _maintenanceWorker.contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _transferToNextWorkShiftButton(),
                        ),
                      ),
                      _engineer.contains(Global.userInfo.SORTB) ? Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _reRepairButton(),
                        ),
                      ) : Container(),
                      !widget.order.isStop ? Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ) : Container()
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
      ];
    } else
      return [];
  }

  List<Widget> plannedAddingRepairOrder() {
    if (widget.order.ILART == "N20") {
      return [
        (widget.order.ASTTX == "新建" ||
            widget.order.ASTTX == "新工单" ||
            widget.order.ASTTX == "维修中" ||
            widget.order.ASTTX == "等待中") && (Global.userInfo.WCTYPE != "是")
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: _transferToNextWorkShiftButton(),
          ),
        )
            : Container(),
        (widget.order.ASTTX == "已完工") && (Global.userInfo.WCTYPE != "是")
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _transferToNextWorkShiftButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _reRepairButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
      ];
    } else
      return [];
  }

  List<Widget> organizationOrder() {
    if (["N13", "N14", "N15", "N16", "N17"].contains(widget.order.ILART)) {
      return [];
    } else
      return [];
  }

  List<Widget> blockRepairOrder() {
    if (widget.order.ILART == "N08") {
      return [
        (widget.order.ASTTX == "已完工") &&
            (_maintenanceWorker.contains(Global.userInfo.SORTB) ||
                _monitorOrForeman.contains(Global.userInfo.SORTB) ||
                _engineer.contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: ButtonBarWidget(
              button: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _reRepairButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _completeButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(),
      ];
    } else
      return [];
  }

  @override
  void initState() {
    widget.order.isStop = widget.order.isStop ?? false;
    this._userInfo = Global.userInfo;
    this._reportOrderDetailFuture = this._orderDetail();
    super.initState();
  }

  @override
  void dispose() {
    if (this._controller != null) {
      this._controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: this._reportOrderDetailFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return ProgressDialog(
              loading: this._loading,
              child: CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  leading: CupertinoNavigationBarBackButton(
                    onPressed: () => Navigator.pop(context),
                    color: Color.fromRGBO(94, 102, 111, 1),
                  ),
                  middle: Text(
                    this._reportOrder.QMTXT ?? '',
                    style: TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          OrderInfoWidget(
                            reportOrder: this._reportOrder,
                            repairOrder: this._repairOrder,
                            order: widget.order,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Column(
                              children: <Widget>[
                                ListItemWidget(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      ImageIcon(
                                        AssetImage(
                                            "assets/images/icon/icon_detail.png"),
                                        size: 16,
                                        color: Color.fromRGBO(60, 115, 240, 1),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          "工单详情",
                                          style: TextStyle(fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        CupertinoPageRoute(
                                            builder: (BuildContext context) {
                                              return RepairOrderDetailPage(
                                                reportOrder: this._reportOrder,
                                              );
                                            }));
                                  },
                                ),
                                DividerBetweenIconListItem(),
                                ListItemWidget(
                                  title: Row(
                                    children: <Widget>[
                                      ImageIcon(
                                        AssetImage(
                                            'assets/images/icon/icon_repair.png'),
                                        color: Color.fromRGBO(10, 65, 150, 1),
                                        size: 16,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          "维修详情",
                                          style: TextStyle(fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    if (widget.order.ASTTX == "新建" ||
                                        widget.order.ASTTX == "新工单") {
                                      showCupertinoDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CupertinoAlertDialog(
                                              content: Text(
                                                "无维修详情",
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
                                    } else {
                                      Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (BuildContext context) {
                                                return RepairDetailPage(
                                                  order: widget.order,
                                                );
                                              }));
                                    }
                                  },
                                ),
                                DividerBetweenIconListItem(),
                                ListItemWidget(
                                  title: Row(
                                    children: <Widget>[
                                      ImageIcon(
                                        AssetImage(
                                            'assets/images/icon/icon_time.png'),
                                        color: Color.fromRGBO(250, 90, 50, 1),
                                        size: 16,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          "维修记录",
                                          style: TextStyle(fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    if (widget.order.ASTTX == "新建" ||
                                        widget.order.ASTTX == "新工单") {
                                      showCupertinoDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CupertinoAlertDialog(
                                              content: Text(
                                                "无维修记录",
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
                                    } else {
                                      Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (BuildContext context) {
                                                return RepairHistoryPage(
                                                  order: widget.order,
                                                );
                                              }));
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      ...productionFaultRepairOrder(),
                      ...unplannedToolingRepairOrder(),
                      ...nonPlannedSpecialEquipmentOrder(),
                      ...unplannedInfrastructureRepairOrder(),
                      ...machiningRepairOrder(),
                      ...nonPlanedInspectionOrder(),
                      ...preventiveMaintenanceOrder(),
                      ...inspectionOrder(),
                      ...forecastMaintenanceOrder(),
                      ...improveMaintenanceOrder(),
                      ...plannedToolingRepairOrder(),
                      ...plannedSpecialEquipmentOrder(),
                      ...plannedInfrastructureRepairOrder(),
                      ...plannedInspectionRepairOrder(),
                      ...plannedAddingRepairOrder(),
                      ...organizationOrder(),
                      ...blockRepairOrder()
                    ],
                  ),
                ),
              ));
        });
  }
}
