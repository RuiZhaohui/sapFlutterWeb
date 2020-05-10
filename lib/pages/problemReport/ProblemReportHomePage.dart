import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/HttpRequestRest.dart';
import 'package:gztyre/api/model/Device.dart';
import 'package:gztyre/api/model/FunctionPosition.dart';
import 'package:gztyre/api/model/ProblemDescription.dart';
import 'package:gztyre/api/model/RepairType.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ButtonBarWidget.dart';
import 'package:gztyre/components/ButtonWidget.dart';
import 'package:gztyre/components/DividerBetweenIconListItem.dart';
import 'package:gztyre/components/ListItemSwitchWidget.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/components/TextareaWidget.dart';
import 'package:gztyre/components/TextareaWithPicAndVideoForWebWidget.dart';
import 'package:gztyre/components/TextareaWithPicAndVideoWidget.dart';
import 'package:gztyre/pages/problemReport/DeviceSelectionPage.dart';
import 'package:gztyre/pages/problemReport/ProblemDescriptionPage.dart';
import 'package:gztyre/pages/problemReport/RepairTypePage.dart';
import 'package:gztyre/utils/ListController.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;

class ProblemReportHomePage extends StatefulWidget {
  ProblemReportHomePage({Key key, @required this.rootContext})
      : assert(rootContext != null),
        super(key: key);

  final BuildContext rootContext;

  @override
  State createState() {
    return new _ProblemReportHomePageState();
  }
}

class _ProblemReportHomePageState extends State<ProblemReportHomePage> {
  bool _isStop = false;
  TextEditingController _description = new TextEditingController();
  TextEditingController _remark = new TextEditingController();
  TextEditingController _bautl = new TextEditingController();
  TextEditingController _bautlNum = new TextEditingController();
  ListController _list = ListController(list: []);

  Device _device;

//  FunctionPosition _position;
  RepairType _repairType;
  Map<String, String> _selectProblemDescription;
  ProblemDescription _problemDescription;

  bool _loading = false;
  Map<String, String> result;

//  List<String> _list = [];

  _notification(String QMNUM, String WCPLGR) async {
    await HttpRequest.searchWorkerByWCPLGR(QMNUM, WCPLGR, (res) async {
      List workerList = res.where((item) {
        return item.PERNR != Global.userInfo.PERNR &&
            ["A01", "A02", "A03"].contains(item.SORTB) &&
            item.KTEX1 == "闲置";
      }).map((item) {
        return item.PERNR;
      }).toList();
      await HttpRequestRest.pushAlias(workerList, "", "",
          "${Global.userInfo.ENAME}上报维修", [], (success) {}, (err) {});
    }, (err) {});
  }

  _buildTextareaWithPicAndVideoWidget() {
    print({'this.list': this._list.value});
    return TextareaWithPicAndVideoForWebWidget(
      listController: this._list,
      rootContext: widget.rootContext,
      textEditingController: this._description,
      placeholder: "补充故障描述...",
      lines: 3,
    );
  }

  _commitReport() {

    if (this._device == null ||
        this._repairType == null ||
        this._problemDescription == null ||
        (this._repairType.ILART == "N08" && (_bautl.text == null || _bautlNum.text == null))) {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              content: Text(
                "请填写完整",
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
    } else if (this._repairType.ILART == "N08" && !_bautl.text.startsWith("WX")) {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              content: Text(
                "备件编号请以 WX 开头",
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
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              content: Text(
                "是否上报故障",
                style: TextStyle(fontSize: 18),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("否"),
                ),
                CupertinoDialogAction(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    setState(() {
                      this._loading = true;
                    });
                    Uuid uuid = Uuid();
                    String left = (new DateTime
                        .now()
                        .millisecondsSinceEpoch
                        .toString() +
                        uuid
                            .v4()
                            .substring(0, 3))
                        .substring(0, 16);
                    List<String> pictures = List();
                    String video = '';
                    String audio = '';
                    if (this._list.value.length >
                        0) {
                      await HttpRequestRest.upload(
                          this
                              ._list
                              .value
                              .map((item) {
                            return item;
                          }).toList(), (res) {
                        res.forEach((item) {
                          if (Global.videoType
                              .contains(item[
                          "fileDownloadUri"]
                              .split(".")
                              .last
                              .toLowerCase())) {
                            video = item[
                            "fileDownloadUri"];
                          } else if (Global
                              .audioType
                              .contains(item[
                          "fileDownloadUri"]
                              .split(".")
                              .last
                              .toLowerCase())) {
                            audio = item[
                            "fileDownloadUri"];
                          } else {
                            pictures.add(item[
                            "fileDownloadUri"]);
                          }
                        });

                        String sapNo = "";
                        HttpRequest.createReportOrder(
                            Global.userInfo == null
                                ? ''
                                : Global
                                .userInfo.PERNR,
                            Global.workShift == null
                                ? ''
                                : Global.workShift
                                .TPLNR,
                            this._repairType == null
                                ? ''
                                : this
                                ._repairType
                                .ILART,
                            this._device == null
                                ? ''
                                : this
                                ._device
                                .deviceCode,
                            this._device == null
                                ? ''
                                : this
                                ._device
                                .positionCode,
                            this._problemDescription ==
                                null
                                ? ''
                                : this
                                ._problemDescription
                                .group,
                            this._selectProblemDescription ==
                                null
                                ? ''
                                : this._selectProblemDescription[
                            "code"],
                            this._description ==
                                null
                                ? ''
                                : this
                                ._description
                                .text,
                            Global.userInfo == null
                                ? ''
                                : Global
                                .userInfo.CPLGR,
                            Global.userInfo == null
                                ? ''
                                : Global
                                .userInfo.MATYP,
                            this._isStop ? "X" : '',
                            left, (res) {
                          sapNo = res['QMNUM'];
                          result = res;
                          HttpRequestRest.malfunction(
                              left,
                              sapNo,
                              1,
                              pictures,
                              video,
                              audio,
                              this._problemDescription ==
                                  null
                                  ? ''
                                  : this._selectProblemDescription[
                              "text"],
                              this._description == null
                                  ? ''
                                  : this
                                  ._description
                                  .text,
                              this._remark == null
                                  ? ''
                                  : this
                                  ._remark
                                  .text,
                              this._isStop,
                              Global.userInfo == null
                                  ? ''
                                  : Global.userInfo
                                  .PERNR,
                              '',
                              '',
                              '新工单',
                              "",
                              this._device == null
                                  ? ''
                                  : this
                                  ._device
                                  .deviceName,
                              new DateTime.now()
                                  .toString(),
                              '', (res) {
                            setState(() {
                              this._loading = false;
                            });
                            _notification(
                                res["QMNUM"],
                                res["WCPLGR"]);
                            showCupertinoDialog(
                                context: widget
                                    .rootContext,
                                builder:
                                    (BuildContext
                                context) {
                                  return CupertinoAlertDialog(
                                    content: Text(
                                      "上报成功",
                                      style: TextStyle(
                                          fontSize:
                                          18),
                                    ),
                                    actions: <
                                        Widget>[
                                      CupertinoDialogAction(
                                        onPressed:
                                            () {
                                          Navigator.of(
                                              context)
                                              .pop();
                                        },
                                        child: Text(
                                            "好"),
                                      ),
                                    ],
                                  );
                                });
                            setState(() {
                              this._device = null;
                              this._repairType =
                              null;
                              this._problemDescription =
                              null;
                              this._description =
                              new TextEditingController();
                              this._remark =
                              new TextEditingController();
                              this._list.value =
                              new List();
                            });
                          }, (err) {
                            setState(() {
                              this._loading = false;
                            });
                            showCupertinoDialog(
                                context: widget
                                    .rootContext,
                                builder:
                                    (BuildContext
                                context) {
                                  return CupertinoAlertDialog(
                                    content: Text(
                                      err.error ?? "上报失败",
                                      style: TextStyle(
                                          fontSize:
                                          18),
                                    ),
                                    actions: <
                                        Widget>[
                                      CupertinoDialogAction(
                                        onPressed:
                                            () {
                                          Navigator.of(
                                              context)
                                              .pop();
                                        },
                                        child: Text(
                                            "好"),
                                      ),
                                    ],
                                  );
                                });
                          });
                        }, (err) {
                          print(err);
                          setState(() {
                            this._loading = false;
                          });
                          showCupertinoDialog(
                              context: widget
                                  .rootContext,
                              builder: (BuildContext
                              context) {
                                return CupertinoAlertDialog(
                                  content: Text(
                                    err.error ?? "上报失败",
                                    style: TextStyle(
                                        fontSize:
                                        18),
                                  ),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      onPressed:
                                          () {
                                        Navigator.of(
                                            context)
                                            .pop();
                                      },
                                      child:
                                      Text("好"),
                                    ),
                                  ],
                                );
                              });
                        });
                      }, (err) {
                        print(err);
                        setState(() {
                          this._loading = false;
                        });
                        showCupertinoDialog(
                            context:
                            widget.rootContext,
                            builder: (BuildContext
                            context) {
                              return CupertinoAlertDialog(
                                content: Text(
                                  err.error ?? '上报失败',
                                  style: TextStyle(
                                      fontSize: 18),
                                ),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    onPressed: () {
                                      Navigator.of(
                                          context)
                                          .pop();
                                    },
                                    child:
                                    Text("好"),
                                  ),
                                ],
                              );
                            });
                      });
                    } else {
                      String sapNo = "";
                      await HttpRequest.createReportOrder(
                          Global.userInfo == null
                              ? ''
                              : Global
                              .userInfo.PERNR,
                          Global.workShift == null
                              ? ''
                              : Global
                              .workShift.TPLNR,
                          this._repairType == null
                              ? ''
                              : this
                              ._repairType
                              .ILART,
                          this._device == null
                              ? ''
                              : this
                              ._device
                              .deviceCode,
                          this._device == null
                              ? ''
                              : this
                              ._device
                              .positionCode,
                          this._problemDescription ==
                              null
                              ? ''
                              : this
                              ._problemDescription
                              .group,
                          this._problemDescription ==
                              null
                              ? ''
                              : this._selectProblemDescription[
                          "code"],
                          this._description == null
                              ? ''
                              : this
                              ._description
                              .text,
                          Global.userInfo == null
                              ? ''
                              : Global
                              .userInfo.CPLGR,
                          Global.userInfo == null
                              ? ''
                              : Global
                              .userInfo.MATYP,
                          this._isStop ? "X" : '',
                          left, (res) {
                        sapNo = res['QMNUM'];
                        result = res;
                        HttpRequestRest.malfunction(
                            left,
                            sapNo,
                            1,
                            pictures,
                            video,
                            null,
                            this._problemDescription ==
                                null
                                ? ''
                                : this._selectProblemDescription[
                            "text"],
                            this._description ==
                                null
                                ? ''
                                : this
                                ._description
                                .text,
                            this
                                ._remark ==
                                null
                                ? ''
                                : this._remark.text,
                            this._isStop,
                            Global
                                .userInfo ==
                                null
                                ? ''
                                : Global
                                .userInfo.PERNR,
                            '',
                            '',
                            '新工单',
                            "",
                            this
                                ._device ==
                                null
                                ? ''
                                : this
                                ._device
                                .deviceName,
                            new DateTime.now()
                                .toString(),
                            '', (res) {
                          setState(() {
                            this._loading = false;
                          });
                          _notification(
                              result["QMNUM"],
                              result["WCPLGR"]);
                          showCupertinoDialog(
                              context: widget
                                  .rootContext,
                              builder: (BuildContext
                              context) {
                                return CupertinoAlertDialog(
                                  content: Text(
                                    "上报成功",
                                    style: TextStyle(
                                        fontSize:
                                        18),
                                  ),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      onPressed:
                                          () {
                                        Navigator.of(
                                            context)
                                            .pop();
                                      },
                                      child:
                                      Text("好"),
                                    ),
                                  ],
                                );
                              });
                          setState(() {
                            this._device = null;
                            this._repairType = null;
                            this._problemDescription =
                            null;
                            this._description.text =
                            "";
                            this._remark.text = "";
                            this._list.value =
                            new List();
                          });
                          this.initState();
                        }, (err) {
                          setState(() {
                            this._loading = false;
                          });
                          showCupertinoDialog(
                              context: widget
                                  .rootContext,
                              builder: (BuildContext
                              context) {
                                return CupertinoAlertDialog(
                                  content: Text(
                                    err.error ?? "上报失败",
                                    style: TextStyle(
                                        fontSize:
                                        18),
                                  ),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      onPressed:
                                          () {
                                        Navigator.of(
                                            context)
                                            .pop();
                                      },
                                      child:
                                      Text("好"),
                                    ),
                                  ],
                                );
                              });
                        });
                      }, (err) {
                        print(err);
                        setState(() {
                          this._loading = false;
                        });
                        showCupertinoDialog(
                            context:
                            widget.rootContext,
                            builder: (BuildContext
                            context) {
                              return CupertinoAlertDialog(
                                content: Text(
                                  err.error ?? "上报失败",
                                  style: TextStyle(
                                      fontSize: 18),
                                ),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    onPressed: () {
                                      Navigator.of(
                                          context)
                                          .pop();
                                    },
                                    child:
                                    Text("好"),
                                  ),
                                ],
                              );
                            });
                      });
                    }
                  },
                  child: Text("是"),
                )
              ],
            );
          });
    }
  }

  _commitRepair() {
    if (this._repairType == null ||
        (this._repairType.ILART == "N08" && (_bautl.text == null || _bautlNum.text == null))) {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              content: Text(
                "请填写完整",
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
    } else if (this._repairType.ILART == "N08" && !_bautl.text.startsWith("WX")) {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              content: Text(
                "备件编号请以 WX 开头",
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
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              content: Text(
                "是否上报故障",
                style: TextStyle(fontSize: 18),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("否"),
                ),
                CupertinoDialogAction(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    setState(() {
                      this._loading = true;
                    });
                    Uuid uuid = Uuid();
                    String left = (new DateTime
                        .now()
                        .millisecondsSinceEpoch
                        .toString() +
                        uuid
                            .v4()
                            .substring(0, 3))
                        .substring(0, 16);
                    List<String> pictures = List();
                    String video = '';
                    String audio = '';
                    if (this._list.value.length >
                        0) {
                      await HttpRequestRest.upload(
                          this
                              ._list
                              .value
                              .map((item) {
                            return item;
                          }).toList(), (res) {
                        res.forEach((item) {
                          if (Global.videoType
                              .contains(item[
                          "fileDownloadUri"]
                              .split(".")
                              .last
                              .toLowerCase())) {
                            video = item[
                            "fileDownloadUri"];
                          } else if (Global
                              .audioType
                              .contains(item[
                          "fileDownloadUri"]
                              .split(".")
                              .last
                              .toLowerCase())) {
                            audio = item[
                            "fileDownloadUri"];
                          } else {
                            pictures.add(item[
                            "fileDownloadUri"]);
                          }
                        });

                        String sapNo = "";
                        HttpRequest.createRepairOrder(
                            Global.userInfo == null
                                ? ''
                                : Global
                                .userInfo.PERNR,
                            "011",
                            this._repairType == null
                                ? ''
                                : this
                                ._repairType
                                .ILART,
                            null,
                            null,
                            null,
                            null,
                            null,
                            this._description ==
                                null
                                ? ''
                                : this
                                ._description
                                .text,
                            Global.userInfo == null
                                ? ''
                                : Global
                                .userInfo.CPLGR,
                            Global.userInfo == null
                                ? ''
                                : Global
                                .userInfo.MATYP,
                            this._isStop ? "X" : '',
                            left,
                            this._bautl == null
                                ? ''
                                : this._bautl.text,
                            this._bautlNum == null
                                ? 0
                                : int.parse(this._bautlNum.text),
                                (res) {
                              sapNo = left;
//                          result = res;
                              HttpRequestRest.malfunction(
                                  left,
                                  sapNo,
                                  1,
                                  pictures,
                                  video,
                                  audio,
                                  this._problemDescription ==
                                      null
                                      ? ''
                                      : this._selectProblemDescription[
                                  "text"],
                                  this._description == null
                                      ? ''
                                      : this
                                      ._description
                                      .text,
                                  this._remark == null
                                      ? ''
                                      : this
                                      ._remark
                                      .text,
                                  this._isStop,
                                  Global.userInfo == null
                                      ? ''
                                      : Global.userInfo
                                      .PERNR,
                                  '',
                                  '',
                                  '新工单',
                                  "",
                                  this._device == null
                                      ? ''
                                      : this
                                      ._device
                                      .deviceName,
                                  new DateTime.now()
                                      .toString(),
                                  '', (res) {
                                setState(() {
                                  this._loading = false;
                                });
                                _notification(
                                    left,
                                    res["WCPLGR"]);
                                showCupertinoDialog(
                                    context: widget
                                        .rootContext,
                                    builder:
                                        (BuildContext
                                    context) {
                                      return CupertinoAlertDialog(
                                        content: Text(
                                          "上报成功",
                                          style: TextStyle(
                                              fontSize:
                                              18),
                                        ),
                                        actions: <
                                            Widget>[
                                          CupertinoDialogAction(
                                            onPressed:
                                                () {
                                              Navigator.of(
                                                  context)
                                                  .pop();
                                            },
                                            child: Text(
                                                "好"),
                                          ),
                                        ],
                                      );
                                    });
                                setState(() {
                                  this._device = null;
                                  this._repairType =
                                  null;
                                  this._problemDescription =
                                  null;
                                  this._bautlNum = new TextEditingController();
                                  this._bautl = new TextEditingController();
                                  this._description =
                                  new TextEditingController();
                                  this._remark =
                                  new TextEditingController();
                                  this._list.value =
                                  new List();
                                });
                              }, (err) {
                                setState(() {
                                  this._loading = false;
                                });
                                showCupertinoDialog(
                                    context: widget
                                        .rootContext,
                                    builder:
                                        (BuildContext
                                    context) {
                                      return CupertinoAlertDialog(
                                        content: Text(
                                          err.error ?? "上报失败",
                                          style: TextStyle(
                                              fontSize:
                                              18),
                                        ),
                                        actions: <
                                            Widget>[
                                          CupertinoDialogAction(
                                            onPressed:
                                                () {
                                              Navigator.of(
                                                  context)
                                                  .pop();
                                            },
                                            child: Text(
                                                "好"),
                                          ),
                                        ],
                                      );
                                    });
                              });
                            }, (err) {
                          print(err);
                          setState(() {
                            this._loading = false;
                          });
                          showCupertinoDialog(
                              context: widget
                                  .rootContext,
                              builder: (BuildContext
                              context) {
                                return CupertinoAlertDialog(
                                  content: Text(
                                    err.error ?? "上报失败",
                                    style: TextStyle(
                                        fontSize:
                                        18),
                                  ),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      onPressed:
                                          () {
                                        Navigator.of(
                                            context)
                                            .pop();
                                      },
                                      child:
                                      Text("好"),
                                    ),
                                  ],
                                );
                              });
                        });
                      }, (err) {
                        print(err);
                        setState(() {
                          this._loading = false;
                        });
                        showCupertinoDialog(
                            context:
                            widget.rootContext,
                            builder: (BuildContext
                            context) {
                              return CupertinoAlertDialog(
                                content: Text(
                                  err.error ?? "上报失败",
                                  style: TextStyle(
                                      fontSize: 18),
                                ),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    onPressed: () {
                                      Navigator.of(
                                          context)
                                          .pop();
                                    },
                                    child:
                                    Text("好"),
                                  ),
                                ],
                              );
                            });
                      });
                    } else {
                      String sapNo = "";
                      await HttpRequest.createRepairOrder(
                          Global.userInfo == null
                              ? ''
                              : Global
                              .userInfo.PERNR,
                          "011",
                          this._repairType == null
                              ? ''
                              : this
                              ._repairType
                              .ILART,
                          null,
                          null,
                          null,
                          null,
                          null,
                          this._description ==
                              null
                              ? ''
                              : this
                              ._description
                              .text,
                          Global.userInfo == null
                              ? ''
                              : Global
                              .userInfo.CPLGR,
                          Global.userInfo == null
                              ? ''
                              : Global
                              .userInfo.MATYP,
                          this._isStop ? "X" : '',
                          left,
                          this._bautl == null
                              ? ''
                              : this._bautl.text,
                          this._bautlNum == null
                              ? 0
                              : int.parse(this._bautlNum.text),
                              (res) {
                            sapNo = left;
//                        result = res;
                            HttpRequestRest.malfunction(
                                left,
                                sapNo,
                                1,
                                pictures,
                                video,
                                null,
                                this._problemDescription ==
                                    null
                                    ? ''
                                    : this._selectProblemDescription[
                                "text"],
                                this._description ==
                                    null
                                    ? ''
                                    : this
                                    ._description
                                    .text,
                                this
                                    ._remark ==
                                    null
                                    ? ''
                                    : this._remark.text,
                                this._isStop,
                                Global
                                    .userInfo ==
                                    null
                                    ? ''
                                    : Global
                                    .userInfo.PERNR,
                                '',
                                '',
                                '新工单',
                                "",
                                this
                                    ._device ==
                                    null
                                    ? ''
                                    : this
                                    ._device
                                    .deviceName,
                                new DateTime.now()
                                    .toString(),
                                '', (res) {
                              setState(() {
                                this._loading = false;
                              });
                              _notification(
                                  left,
                                  result["WCPLGR"]);
                              showCupertinoDialog(
                                  context: widget
                                      .rootContext,
                                  builder: (BuildContext
                                  context) {
                                    return CupertinoAlertDialog(
                                      content: Text(
                                        "上报成功",
                                        style: TextStyle(
                                            fontSize:
                                            18),
                                      ),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          onPressed:
                                              () {
                                            Navigator.of(
                                                context)
                                                .pop();
                                          },
                                          child:
                                          Text("好"),
                                        ),
                                      ],
                                    );
                                  });
                              setState(() {
                                this._device = null;
                                this._repairType = null;
                                this._problemDescription =
                                null;
                                this._description.text =
                                "";
                                this._remark.text = "";
                                this._bautl.text = null;
                                this._bautlNum.text = null;
                                this._list.value =
                                new List();
                              });
                              this.initState();
                            }, (err) {
                              setState(() {
                                this._loading = false;
                              });
                              showCupertinoDialog(
                                  context: widget
                                      .rootContext,
                                  builder: (BuildContext
                                  context) {
                                    return CupertinoAlertDialog(
                                      content: Text(
                                        err.error ?? "上报失败",
                                        style: TextStyle(
                                            fontSize:
                                            18),
                                      ),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          onPressed:
                                              () {
                                            Navigator.of(
                                                context)
                                                .pop();
                                          },
                                          child:
                                          Text("好"),
                                        ),
                                      ],
                                    );
                                  });
                            });
                          }, (err) {
                        print(err);
                        setState(() {
                          this._loading = false;
                        });
                        showCupertinoDialog(
                            context:
                            widget.rootContext,
                            builder: (BuildContext
                            context) {
                              return CupertinoAlertDialog(
                                content: Text(
                                  err.error ?? "上报失败",
                                  style: TextStyle(
                                      fontSize: 18),
                                ),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    onPressed: () {
                                      Navigator.of(
                                          context)
                                          .pop();
                                    },
                                    child:
                                    Text("好"),
                                  ),
                                ],
                              );
                            });
                      });
                    }
                  },
                  child: Text("是"),
                )
              ],
            );
          });
    }
  }


  @override
  void initState() {
super.initState();
  }


  @override
  void dispose() {
    print('销毁');
    if (this._description != null) {
      _description.dispose();
    }
    if (this._remark != null) {
      _remark.dispose();
    }
    super.dispose();
  }


  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressDialog(
        loading: this._loading,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text("故障上报", style: TextStyle(fontWeight: FontWeight.w500)),
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
                            )
                          ],
                        ),
                        onTap: () {
                          Navigator.of(widget.rootContext).push(
                              CupertinoPageRoute(
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
                        },
                      ),
                      DividerBetweenIconListItem(),
                      ListItemSwitchWidget(
                        title: Row(
                          children: <Widget>[
                            ImageIcon(
                              AssetImage('assets/images/icon/icon_stop.png'),
                              color: Color.fromRGBO(250, 70, 70, 1),
                              size: 16,
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text("是否停机"),
                              ),
                            )
                          ],
                        ),
                        isStop: this._isStop,
                        onChanged: (bool isStop) {
                          this._isStop = isStop;
                          setState(() {});
                        },
                      ),
                      DividerBetweenIconListItem(),
                      ListItemWidget(
                        title: Row(
                          children: <Widget>[
                            ImageIcon(
                              AssetImage('assets/images/icon/icon_repair.png'),
                              color: Color.fromRGBO(10, 65, 150, 1),
                              size: 16,
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: this._repairType == null
                                    ? Text("维修类型")
                                    : Text(
                                  this._repairType.ILATX,
                                  style: TextStyle(
                                      color:
                                      Color.fromRGBO(52, 115, 178, 1)),
                                ),
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          Navigator.of(widget.rootContext).push(
                              CupertinoPageRoute(
                                  builder: (BuildContext context) {
                            return RepairTypePage(
                              selectItem: this._repairType,
                            );
                          })).then((value) {
                            this._repairType = value;
                            setState(() {});
                          });
                        },
                      ),
                      DividerBetweenIconListItem(),
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
                                child: this._selectProblemDescription == null || this._problemDescription == null
                                    ? Text("故障描述")
                                    : Text(
                                  '${this._problemDescription.title}-${this._selectProblemDescription["text"]}',
                                  style: TextStyle(
                                      color:
                                      Color.fromRGBO(52, 115, 178, 1)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          Navigator.of(widget.rootContext).push(
                              CupertinoPageRoute(
                                  builder: (BuildContext context) {
                            return ProblemDescriptionPage(
                              type: "C",
                            );
                          })).then((value) {
                            this._problemDescription = value["problemDesc"];
                            this._selectProblemDescription = value["selectItem"];
                            setState(() {});
                          });
                        },
                      ),
                      this._repairType != null && this._repairType.ILART == "N08" ? Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            TextareaWidget(
                              textEditingController: this._bautl,
                              placeholder: "物料编号",
                              lines: 1,
                            ),
                            Divider(height: 1,),
                            TextareaWidget(
                              textEditingController: this._bautlNum,
                              placeholder: "物料数量",
                              type: TextInputType.number,
                              lines: 1,
                            )
                          ],
                        ),
                      ) : Container(),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: _buildTextareaWithPicAndVideoWidget(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: TextareaWidget(
                          textEditingController: this._remark,
                          placeholder: "备注...",
                          lines: 2,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: ButtonBarWidget(
                          button: Container(
                            height: 22,
                            color: Colors.transparent,
                            child: ButtonWidget(
                              padding: EdgeInsets.all(0),
                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                              child: Text('上报故障', style: TextStyle(color: Colors.redAccent),),
                              color: Colors.transparent,
                              onPressed: () {
                                if (_repairType != null) {
                                  if (_repairType.ILART == "N08") {
                                    _commitRepair();
                                  } else {
                                    _commitReport();
                                  }
                                } else {
                                  showCupertinoDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CupertinoAlertDialog(
                                          content: Text(
                                            "请填写完整",
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
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
