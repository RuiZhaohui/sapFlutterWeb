import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/HttpRequestRest.dart';
import 'package:gztyre/api/model/Device.dart';
import 'package:gztyre/api/model/Order.dart';
import 'package:gztyre/api/model/ProblemDescription.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ButtonBarWidget.dart';
import 'package:gztyre/components/ButtonWidget.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/components/TextareaWithPicAndVideoWidget.dart';
import 'package:gztyre/pages/problemReport/DeviceSelectionPage.dart';
import 'package:gztyre/pages/problemReport/ProblemDescriptionPage.dart';
import 'package:gztyre/utils/ListController.dart';
import 'package:gztyre/utils/StringUtils.dart';

class OrderRepairDetailPage extends StatefulWidget {
  OrderRepairDetailPage({Key key, this.order}) : super(key: key);
  final Order order;

  @override
  State createState() {
    return new _OrderRepairDetailPageState();
  }
}

class _OrderRepairDetailPageState extends State<OrderRepairDetailPage> {
  TextEditingController _description = new TextEditingController();
  ListController _list = ListController(list: []);
  Map<String, String> _selectProblemDescription;
  ProblemDescription _problemDescription;

  Device _device;

  bool _loading = false;

  _buildTextareaWithPicAndVideoWidget() {
    print({'this.list': this._list.value});
    return TextareaWithPicAndVideoWidget(
      listController: this._list,
      rootContext: context,
      textEditingController: this._description,
      placeholder: "输入维修描述...",
      lines: 5,
    );
  }

  Future<String> _getAPPTRADENO(String QMNUM, String AUFNR) async {
    String sapNo;
    if (StringUtils.isBank(QMNUM)) {
      sapNo = AUFNR;
    } else sapNo = QMNUM;
    return await HttpRequestRest.getMalfunction(sapNo, (Map map) async {
      return map['tradeNo'];
    }, (err) async {
      this._resetAPPTRANENO(widget.order);
      setState(() {
        this._loading = false;
      });
      throw Error();
    });
  }

  _resetAPPTRANENO(Order order) async {
    String tradeNo = (new DateTime.now().millisecondsSinceEpoch.toString() + "000").substring(0, 16);
    if (order.QMNUM != null || order.QMNUM != "") {
      await HttpRequestRest.malfunction(tradeNo, order.QMNUM, 0, [], null, null, null, null, null, false, null, null, null, null, null, null, null, null, (s) {}, (e){});
    }
    if (order.AUFNR != null || order.AUFNR != "") {
      await HttpRequestRest.malfunction(tradeNo, order.AUFNR, 0, [], null, null, null, null, null, false, null, null, null, null, null, null, null, null, (s) {}, (e){});
    }
  }

  Future<bool> _repairComplete(Order order, URGRP, URCOD, EQUNR, KTEXT) async {
    setState(() {
      this._loading = true;
    });
    return await this._getAPPTRADENO(order.QMNUM, order.AUFNR).then((APPTRADENO) async {
      return await HttpRequest.changeOrderStatus(
          Global.userInfo.PERNR,
          order.QMNUM,
          order.AUFNR,
          "完工",
          APPTRADENO,
          URGRP,
          URCOD,
          EQUNR,
          KTEXT,
          null, (res) {
        return true;
      }, (err) {
        setState(() {
          this._loading = false;
        });
        return false;
      });
    }).catchError((err) {
      setState(() {
        this._loading = false;
      });
      return false;
    });
  }

  Future<bool> _complete(
      Order order, String PERNR) async {
    setState(() {
      this._loading = true;
    });
    return await this._getAPPTRADENO(order.QMNUM, order.AUFNR).then((APPTRADENO) async {
      return await HttpRequest.completeOrder(
          PERNR, order.AUFNR, "已确认", APPTRADENO, (res) {
        setState(() {
          this._loading = false;
        });
        return true;
      }, (err) {
        setState(() {
          this._loading = false;
        });
        return false;
      });
    }).catchError((err) {
      setState(() {
        this._loading = false;
      });
      return false;
    });
  }

  Future<List<dynamic>> _uploadFile(ListController list) async {
    return await HttpRequestRest.upload(
        list.value.map((item) {
          return item;
        }).toList(), (res) {
      return res;
    }, (err) {
      return null;
    });
  }

  Future<bool> _createOrder(
      String tradeNo,
      String sapNo,
      int type,
      List<String> pictures,
      String video,
      String audio,
      String desc,
      String addDesc,
      String remark,
      bool isStop,
      String userCode,
      String title,
      String level,
      String status,
      String location,
      String device,
      String reportTime,
      String waitTime) async {
    return await HttpRequestRest.malfunction(
        tradeNo,
        sapNo,
        type,
        pictures,
        video,
        audio,
        desc,
        addDesc,
        remark,
        isStop,
        userCode,
        title,
        level,
        status,
        location,
        device,
        reportTime,
        waitTime, (res) {
      return true;
    }, (err) {
      return false;
    });
  }


  @override
  void dispose() {
    if (this._description != null) {
      this._description.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    this._device = new Device();
    this._device.deviceCode = widget.order.EQUNR;
    this._device.deviceName = widget.order.EQKTX;
    this._device.positionCode = widget.order.TPLNR;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressDialog(
        loading: this._loading,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: CupertinoNavigationBarBackButton(
              onPressed: () => Navigator.pop(context),
              color: Color.fromRGBO(94, 102, 111, 1),
            ),
            middle: Text(
              widget.order.QMTXT,
              style: TextStyle(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      ListItemWidget(
                        title: Row(
                          children: <Widget>[
                            ImageIcon(
                              AssetImage('assets/images/icon/icon_device.png'),
                              color: Color.fromRGBO(250, 175, 30, 1),
                              size: 16,
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: this._device == null
                                    ? Text("报修对象")
                                    : Text(
                                  this._device.deviceName,
                                  style: TextStyle(
                                      color: Color.fromRGBO(
                                        52,
                                        115,
                                        178,
                                        1,
                                      )),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        actionArea: widget.order.ILART == "N01"
                            ? Icon(CupertinoIcons.right_chevron, color: Color.fromRGBO(94, 102, 111, 1),)
                            : Container(),
                        onTap: () {
                          if (widget.order.ILART == "N01") {
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (BuildContext context) {
                                  return DeviceSelectionPage(
                                    selectItem: this._device ?? new Device(),
                                  );
                                })).then((val) {
                              if (val["isOk"]) {
                                this._device = val["item"];
                                setState(() {});
                              }
                            });
                          }
                        },
                      ),
                      Divider(
                        height: 1,
                      ),
                      ListItemWidget(
                        title: Row(
                          children: <Widget>[
                            ImageIcon(
                              AssetImage(
                                  'assets/images/icon/icon_description.png'),
                              color: Color.fromRGBO(150, 225, 190, 1),
                              size: 16,
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: this._problemDescription == null
                                    ? Text("维修动作")
                                    : Text(
                                        this._selectProblemDescription["text"],
                                        style: TextStyle(
                                            color: Color.fromRGBO(
                                                52, 115, 178, 1)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (BuildContext context) {
                            return ProblemDescriptionPage(
                              type: "5",
                            );
                          })).then((value) {
                            this._problemDescription = value["problemDesc"];
                            this._selectProblemDescription =
                                value["selectItem"];
                            setState(() {});
                          });
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: _buildTextareaWithPicAndVideoWidget(),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ButtonBarWidget(
                    button: Container(
                      child: ButtonWidget(
                        child: Text(
                          '维修完成',
                          style:
                              TextStyle(color: Color.fromRGBO(76, 129, 235, 1)),
                        ),
                        color: Color.fromRGBO(76, 129, 235, 1),
                        onPressed: () {
                          if ((this._device == null ||
                              this._problemDescription == null ||
                              this._description.text == "") && widget.order.ILART != "N06") {
                            showCupertinoDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    content: Text(
                                      "请选择设备与维修动作并填写描述",
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
                              this._loading = true;
                            });
                            String video = '';
                            List<String> pictures = new List();
                            String audio = '';
                            this
                                ._getAPPTRADENO(widget.order.QMNUM, widget.order.AUFNR)
                                .catchError((err) {
                              setState(() {
                                this._loading = false;
                              });
                              showCupertinoDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    print("获取流水号失败");
                                    return CupertinoAlertDialog(
                                      content: Text(
                                        "操作失败",
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
                            }).then((res) {
                              if (this._list.value.length > 0) {
                                this._uploadFile(this._list).then((map) {
                                  if (map != null) {
                                    map.forEach((item) {
                                      if (Global.videoType.contains(item["fileDownloadUri"].split(".").last.toLowerCase())) {
                                        video = item["fileDownloadUri"];
                                      } else if (Global.audioType.contains(item["fileDownloadUri"].split(".").last.toLowerCase())) {
                                        audio = item["fileDownloadUri"];
                                      } else {
                                        pictures.add(item["fileDownloadUri"]);
                                      }
                                    });
                                    this
                                        ._createOrder(
                                        res,
                                        widget.order.AUFNR,
                                        2,
                                        pictures,
                                        video,
                                        audio,
                                        this._selectProblemDescription == null ? null : this._selectProblemDescription[
                                        "text"],
                                        this._description.text,
                                        null,
                                        true,
                                        widget.order.PERNR,
                                        widget.order.AUFTEXT,
                                        widget.order.COLORS,
                                        "完成",
                                        widget.order.PLTXT,
                                        this._device.deviceName,
                                        new DateTime.now().toString(),
                                        null)
                                        .then((success) {
                                      this
                                          ._repairComplete(
                                          widget.order,
                                          this._problemDescription == null ? null : this._problemDescription.group,
                                          this._selectProblemDescription == null ? null : this._selectProblemDescription[
                                          "code"],
                                          this._device.deviceCode,
                                          this._description.text)
                                          .then((success) async {
                                        if (success) {
                                          if (["N13", "N14", "N15", "N16", "N17"].contains(widget.order.ILART)) {
                                            await this._complete(widget.order, Global.userInfo.PERNR).then((success) async {
                                              if (success) {
                                                setState(() {
                                                  this._loading = false;
                                                });
                                                await HttpRequestRest.pushAlias(
                                                    [widget.order.PERNR],
                                                    "",
                                                    "",
                                                    "${Global.userInfo.ENAME}维修完成",
                                                    [],
                                                        (success) {},
                                                        (err) {});
                                                showCupertinoDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return CupertinoAlertDialog(
                                                        content: Text(
                                                          "维修完成",
                                                          style:
                                                          TextStyle(fontSize: 18),
                                                        ),
                                                        actions: <Widget>[
                                                          CupertinoDialogAction(
                                                            onPressed: () {
                                                              Navigator.of(context)
                                                                  .popUntil(ModalRoute
                                                                  .withName(
                                                                  "assisantOrder"));
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
                                                          "维修已完成，但未确认，请手动确定",
                                                          style:
                                                          TextStyle(fontSize: 18),
                                                        ),
                                                        actions: <Widget>[
                                                          CupertinoDialogAction(
                                                            onPressed: () {
                                                              Navigator.of(context)
                                                                  .pop();
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
                                            await HttpRequestRest.pushAlias(
                                                [widget.order.PERNR],
                                                "",
                                                "",
                                                "${Global.userInfo.ENAME}维修完成",
                                                [],
                                                    (success) {},
                                                    (err) {});
                                            showCupertinoDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return CupertinoAlertDialog(
                                                    content: Text(
                                                      "维修完成",
                                                      style:
                                                      TextStyle(fontSize: 18),
                                                    ),
                                                    actions: <Widget>[
                                                      CupertinoDialogAction(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .popUntil(ModalRoute
                                                              .withName(
                                                              "assisantOrder"));
                                                        },
                                                        child: Text("好"),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          }
                                        } else {
                                          setState(() {
                                            this._loading = false;
                                          });
                                          showCupertinoDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CupertinoAlertDialog(
                                                  content: Text(
                                                    "操作失败",
                                                    style:
                                                    TextStyle(fontSize: 18),
                                                  ),
                                                  actions: <Widget>[
                                                    CupertinoDialogAction(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text("好"),
                                                    ),
                                                  ],
                                                );
                                              });
                                        }
                                      });
                                    });
                                  }
                                });
                              } else {
                                this
                                    ._createOrder(
                                    res,
                                    widget.order.AUFNR,
                                    2,
                                    pictures,
                                    video,
                                    audio,
                                    this._selectProblemDescription == null ? null : this._selectProblemDescription["text"],
                                    this._description.text,
                                    null,
                                    true,
                                    widget.order.PERNR,
                                    widget.order.AUFTEXT,
                                    "1级",
                                    widget.order.ASTTX,
                                    widget.order.PLTXT,
                                    this._device.deviceName,
                                    new DateTime.now().toString(),
                                    null)
                                    .then((success) {
                                  this
                                      ._repairComplete(
                                      widget.order,
                                      this._problemDescription == null ? null : this._problemDescription.group,
                                      this._selectProblemDescription == null ? null : this._selectProblemDescription[
                                      "code"],
                                      this._device.deviceCode,
                                      this._description.text)
                                      .then((success) async {
                                    if (success) {
                                      if (["N13", "N14", "N15", "N16", "N17"].contains(widget.order.ILART)) {
                                        await this._complete(widget.order, Global.userInfo.PERNR).then((success) async {
                                          if (success) {
                                            await HttpRequestRest.pushAlias(
                                                [widget.order.PERNR],
                                                "",
                                                "",
                                                "${Global.userInfo.ENAME}维修完成",
                                                [],
                                                    (success) {},
                                                    (err) {});
                                            setState(() {
                                              this._loading = false;
                                            });
                                            showCupertinoDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return CupertinoAlertDialog(
                                                    content: Text(
                                                      "维修完成",
                                                      style:
                                                      TextStyle(fontSize: 18),
                                                    ),
                                                    actions: <Widget>[
                                                      CupertinoDialogAction(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .popUntil(ModalRoute
                                                              .withName(
                                                              "assisantOrder"));
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
                                                      "维修已完成，但未确认，请手动确定",
                                                      style:
                                                      TextStyle(fontSize: 18),
                                                    ),
                                                    actions: <Widget>[
                                                      CupertinoDialogAction(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("好"),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          }
                                        });
                                      } else {
                                        await HttpRequestRest.pushAlias(
                                            [widget.order.PERNR],
                                            "",
                                            "",
                                            "${Global.userInfo.ENAME}维修完成",
                                            [],
                                                (success) {},
                                                (err) {});
                                        setState(() {
                                          this._loading = false;
                                        });
                                        showCupertinoDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CupertinoAlertDialog(
                                                content: Text(
                                                  "维修完成",
                                                  style:
                                                  TextStyle(fontSize: 18),
                                                ),
                                                actions: <Widget>[
                                                  CupertinoDialogAction(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .popUntil(ModalRoute
                                                          .withName(
                                                          "assisantOrder"));
                                                    },
                                                    child: Text("好"),
                                                  ),
                                                ],
                                              );
                                            });
                                      }
                                    } else {
                                      setState(() {
                                        this._loading = false;
                                      });
                                      showCupertinoDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CupertinoAlertDialog(
                                              content: Text(
                                                "操作失败",
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
                                });
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
