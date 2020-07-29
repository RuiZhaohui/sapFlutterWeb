import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/HttpRequestRest.dart';
import 'package:gztyre/api/model/Device.dart';
import 'package:gztyre/api/model/Order.dart';
import 'package:gztyre/api/model/ReportOrder.dart';
import 'package:gztyre/api/model/Worker.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ButtonBarWidget.dart';
import 'package:gztyre/components/ButtonWidget.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/components/TextButtonWidget.dart';
import 'package:gztyre/components/ViewDialog.dart';
import 'package:gztyre/pages/orderCenter/assisantOrder//HelpPage.dart';
import 'package:gztyre/pages/orderCenter/assisantOrder/OrderRepairDetailPage.dart';
import 'package:gztyre/pages/orderCenter/assisantOrder/WorkerPage.dart';
import 'package:gztyre/pages/problemReport/DeviceSelectionPage.dart';
import 'package:gztyre/pages/repairOrder/RepairDetailPage.dart';
import 'package:gztyre/pages/repairOrder/RepairHistoryPage.dart';
import 'package:gztyre/pages/userCenter/UserInfoPage.dart';
import 'package:gztyre/utils/StringUtils.dart';
import 'package:gztyre/utils/screen_utils.dart';
import 'package:video_player/video_player.dart';

class OrderDetailPage extends StatefulWidget {
  OrderDetailPage(
      {Key key,
        @required this.order,
        @required this.itemStatus,
        this.isRepairing = false})
      : super(key: key);

  final Order order;
  final String itemStatus;
  final bool isRepairing;

  @override
  State createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
//  bool _isRepairing;
  bool _loading = false;
  ReportOrder _reportOrder = new ReportOrder();
  List _imgList;
  String _video = '';
  String _audio = '';
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  var _reportOrderDetailFuture;
  List<String> _helpWorker = new List();

  AudioPlayer audioPlayer = new AudioPlayer();
  var icon = Icon(Icons.play_arrow);

  var _audioPlayerStateSubscription;

  List<String> _maintenanceWorker = ["A01", "A02", "A03"];
  List<String> _monitorOrForeman = ["A04", "A05"];
  List<String> _equipmentSupervisor = ["A06"];
  List<String> _engineer = ["A07"];
  List<String> _maintenanceManagementPersonnel = ["A08"];

//  List<String> _distributeList = ["A04", "A05"];
//  List<String> _outerRepairList = ["A06"];
//  List<String> _normalList = ["A01", "A02", "A03", "A07", "A08"];

  playNet(path) async {
    await audioPlayer.play(path);
  }

  pauseNet(path) async {
    await audioPlayer.pause();
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
      this._loading = false;
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

  Future<bool> _transferCard(
      Order order, ReportOrder reportOrder, String PERNR) async {
    setState(() {
      this._loading = true;
    });
    return await this._getAPPTRADENO(order.QMNUM, order.AUFNR).then((APPTRADENO) async {
      return await HttpRequest.changeOrderStatus(
          PERNR,
          order.QMNUM,
          order.AUFNR,
          "转卡",
          APPTRADENO,
          reportOrder.FEGRP,
          reportOrder.FECOD,
          order.EQUNR,
          null,
          null, (res) async {
        await HttpRequestRest.pushAlias([Global.userInfo.CPLGR + Global.userInfo.MATYP + PERNR], "", "",
            "收到${Global.userInfo.ENAME}转卡单", [], (success) {}, (err) {});
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

  Future<bool> _distributeOrder(
      Order order, ReportOrder reportOrder, String PERNR) async {
    setState(() {
      this._loading = true;
    });
    return await this._getAPPTRADENO(order.QMNUM, order.AUFNR).then((APPTRADENO) async {
      return await HttpRequest.changeOrderStatus(
          PERNR,
          order.QMNUM,
          order.AUFNR,
          "派单",
          APPTRADENO,
          reportOrder.FEGRP,
          reportOrder.FECOD,
          order.EQUNR,
          null,
          null, (res) async {
        await HttpRequestRest.pushAlias([Global.userInfo.CPLGR + Global.userInfo.MATYP + PERNR], "", "",
            "收到${Global.userInfo.ENAME}派单", [], (success) {}, (err) {});
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

  Future<bool> _outerRepair(Order order) async {
    setState(() {
      this._loading = true;
    });
    return await HttpRequest.outerRepair(order.AUFNR, Global.userInfo.PERNR,
            (res) {
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
  }

  Future<bool> _callHelp(
      Order order, ReportOrder reportOrder, List<Worker> list) async {
    setState(() {
      this._loading = true;
    });
    return await this._getAPPTRADENO(order.QMNUM, order.AUFNR).then((APPTRADENO) async {
      return await HttpRequest.changeOrderStatus(
          Global.userInfo.PERNR,
          order.QMNUM,
          order.AUFNR,
          "呼叫协助",
          APPTRADENO,
          reportOrder.FEGRP,
          reportOrder.FECOD,
          order.EQUNR,
          null,
          list, (res) async {
        List<String> workList = list.map((item) {
          return Global.userInfo.CPLGR + Global.userInfo.MATYP + item.PERNR;
        }).toList();
        await HttpRequestRest.pushAlias(workList, "", "",
            "${Global.userInfo.ENAME}请求协助", [], (success) {}, (err) {});
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

  Future<bool> _wait(Order order, ReportOrder reportOrder) async {
    setState(() {
      this._loading = true;
    });
    return await this._getAPPTRADENO(order.QMNUM, order.AUFNR).then((APPTRADENO) async {
      return await HttpRequest.changeOrderStatus(
          Global.userInfo.PERNR,
          order.QMNUM,
          order.AUFNR,
          "等待",
          APPTRADENO,
          reportOrder.FEGRP,
          reportOrder.FECOD,
          order.EQUNR,
          null,
          null, (res) async {
        await HttpRequestRest.pushAlias(
            [Global.userInfo.CPLGR + Global.userInfo.MATYP + order.PERNR],
            "",
            "",
            "${Global.userInfo.ENAME}将工单${order.QMNUM}置为等待",
            [],
                (success) {},
                (err) {});
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

  Future<bool> _answerHelp(Order order, ReportOrder reportOrder) async {
    setState(() {
      this._loading = true;
    });
    return await this._getAPPTRADENO(order.QMNUM, order.AUFNR).then((APPTRADENO) async {
      return await HttpRequest.changeOrderStatus(
          Global.userInfo.PERNR,
          order.QMNUM,
          order.AUFNR,
          "加入",
          APPTRADENO,
          reportOrder.FEGRP,
          reportOrder.FECOD,
          order.EQUNR,
          null,
          null, (res) async {
        await HttpRequestRest.pushAlias([Global.userInfo.CPLGR + Global.userInfo.MATYP + order.PERNR1], "", "",
            "${Global.userInfo.ENAME}接受协助请求", [], (success) {}, (err) {});
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

  Future<bool> _takeItem(Order order, ReportOrder reportOrder) async {
//    this._loading = true;
    if (widget.order.ASTTX == "新建") {
      return await this
          ._getAPPTRADENO(order.QMNUM, order.AUFNR)
          .then((APPTRADENO) async {
        return await HttpRequest.createRepairOrder(
            Global.userInfo.PERNR,
            reportOrder.INGRP,
            reportOrder.ILART,
            reportOrder.QMNUM,
            reportOrder.EQUNR,
            reportOrder.TPLNR,
            reportOrder.FEGRP,
            reportOrder.FECOD,
            reportOrder.FETXT,
            reportOrder.CPLGR,
            reportOrder.MATYP,
            reportOrder.MSAUS ? "X" : '',
            APPTRADENO,
            null,
            null, (res) async {
          await HttpRequestRest.pushAlias(
              [Global.userInfo.CPLGR + Global.userInfo.MATYP + reportOrder.PERNR],
              "",
              "",
              "${Global.userInfo.ENAME}开始处理${reportOrder.QMNUM}",
              [],
                  (success) {},
                  (err) {});
          return true;
        }, (err) {
          return false;
        });
      }).catchError((err) {
        setState(() {
          this._loading = false;
        });
        return false;
      });
    } else {
      return await this
          ._getAPPTRADENO(order.QMNUM, order.AUFNR)
          .then((APPTRADENO) async {
        return await HttpRequest.changeOrderStatus(
            Global.userInfo.PERNR,
            reportOrder.QMNUM,
            widget.order.AUFNR,
            "接单",
            APPTRADENO,
            '',
            '',
            reportOrder.EQUNR,
            null,
            null, (res) async {
          await HttpRequestRest.pushAlias(
              [Global.userInfo.CPLGR + Global.userInfo.MATYP + reportOrder.PERNR],
              "",
              "",
              "${Global.userInfo.ENAME}开始处理工单${reportOrder.QMNUM}",
              [],
                  (success) {},
                  (err) {});
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
  }

  _reportOrderDetail() async {
    setState(() {
      this._loading = true;
    });
    if (widget.itemStatus == "协助单") {
      await HttpRequest.listHelpWorker(widget.order.AUFNR, (List<String> list) {
        _helpWorker = list;
      }, (err) => {});
    }
    return await HttpRequest.reportOrderDetail(widget.order.QMNUM,
            (ReportOrder order) async {
          this._reportOrder = order;
          this._getPic(order);
        }, (err) {
          print(err);
          setState(() {
            this._loading = false;
          });
        });
  }

  Future _getPic(ReportOrder reportOrder) async {
    setState(() {
      this._loading = true;
    });
    return await HttpRequestRest.getMalfunction(reportOrder.QMNUM, (res) {
      if (res != null &&
          res["pictures"] != null &&
          res["pictures"].length > 0) {
        this._imgList = res["pictures"].where((item) {
          return item != '' && item != null;
        }).toList();
      }
      if (res != null && res["video"] != null && res["video"].length > 0) {
        this._video = res["video"];
        this._imgList.add(this._video);
        this._controller = VideoPlayerController.network(this._video);
        this._initializeVideoPlayerFuture = this._controller.initialize();
      }
      if (res != null && res["audio"] != null && res["audio"].length > 0) {
        this._audio = res["audio"];
        this._imgList.add(this._audio);
      }
      setState(() {
        this._loading = false;
      });
    }, (err) {
      setState(() {
        this._loading = false;
      });
    });
  }

  List<Widget> _buildPic(List list) {
    List<Widget> imgList = [];
    print(list);
    int count = 0;
    for (int i = 0; i < list.length; i++) {
      if (Global.videoType.contains(list[i].split(".").last.toLowerCase())) {
        imgList.add(Padding(
          padding: EdgeInsets.all(2),
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the VideoPlayerController has finished initialization, use
                // the data it provides to limit the aspect ratio of the video.
                return Stack(
                  children: <Widget>[
                    FittedBox(
                      fit: BoxFit.cover,
                      child: Container(
                        height: ScreenUtils.screenW(context) - 20 - 4,
                        width: ScreenUtils.screenW(context) - 20 - 4,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: FloatingActionButton(
                        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                        onPressed: () {
                          var imgs = new List();
                          int position = 0;
                          list.asMap().keys.toList().forEach((index) {
                            if (Global.videoType.contains(
                                list[index].split(".").last.toLowerCase())) {
                              imgs.add(
                                  {'key': count, 'videoFile': list[index]});
                              count++;
                            } else if (Global.audioType.contains(
                                list[index].split(".").last.toLowerCase())) {
                              position = index;
                            } else if (Global.picType.contains(
                                list[index].split(".").last.toLowerCase())) {
                              imgs.add({'key': count, 'url': list[index]});
                              count++;
                            }
                          });
                          Navigator.of(context)
                              .push(new CupertinoPageRoute(
                              builder: (context) => new ViewDialog(
                                img: {
                                  'key': i > position && position != 0
                                      ? i - 1
                                      : i,
                                  'videoFile': list[i]
                                },
                                imgs: imgs,
                                width:
                                MediaQuery.of(context).size.width,
                                controller: this._controller,
                                initializeVideoPlayerFuture:
                                this._initializeVideoPlayerFuture,
                                onlyView: true,
                              )))
                              .then((index) {
                            if (this._controller != null) {
                              this._controller.pause();
                            }
                            if (index != null) {
                              if (Global.videoType.contains(list[index - 1]
                                  .split(".")
                                  .last
                                  .toLowerCase())) {
                                this._controller.initialize();
                              }
//                              widget.callback(this.list);
                            }
                            setState(() {});
                          });
                        },
                        // Display the correct icon depending on the state of the player.
                        child: Icon(
                          Icons.play_arrow,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // If the VideoPlayerController is still initializing, show a
                // loading spinner.
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ));
      } else if (Global.audioType
          .contains(list[i].split(".").last.toLowerCase())) {
        imgList.add(GestureDetector(
          child: Padding(
            padding: EdgeInsets.all(2),
            child: Container(
              color: Colors.grey,
              child: icon,
            ),
          ),
          onTap: () {
            if (audioPlayer.state != AudioPlayerState.PLAYING) {
              this.playNet(list[i]);
              setState(() {});
            } else {
              this.pauseNet(list[i]);
            }
            setState(() {});
          },
        ));
      } else if (Global.picType
          .contains(list[i].split(".").last.toLowerCase())) {
        imgList.add(GestureDetector(
          child: Padding(
            padding: EdgeInsets.all(2),
            child: Image.network(
              list[i],
              fit: BoxFit.cover,
            ),
          ),
          onTap: () {
            var imgs = new List();
            int position = 0;
            list.asMap().keys.toList().forEach((index) {
              if (Global.videoType
                  .contains(list[index].split(".").last.toLowerCase())) {
                imgs.add({'key': count, 'videoFile': list[index]});
                count++;
              } else if (Global.audioType
                  .contains(list[index].split(".").last.toLowerCase())) {
                position = index;
              } else if (Global.picType
                  .contains(list[index].split(".").last.toLowerCase())) {
                imgs.add({'key': count, 'url': list[index]});
                count++;
              }
            });
            Navigator.of(context)
                .push(new CupertinoPageRoute(
                builder: (context) => new ViewDialog(
                  img: {
                    'key': i > position && position != 0 ? i - 1 : i,
                    'url': list[i]
                  },
                  imgs: imgs,
                  width: MediaQuery.of(context).size.width,
                  controller: this._controller,
                  initializeVideoPlayerFuture:
                  this._initializeVideoPlayerFuture,
                  onlyView: true,
                )))
                .then((index) {
              if (this._controller != null) {
                this._controller.pause();
              }
              if (index != null) {
                if (Global.videoType
                    .contains(list[index - 1].split(".").last.toLowerCase())) {
                  this._controller = null;
                }
              }
              setState(() {});
            });
          },
        ));
      }
    }
    return imgList;
  }

  Widget _callHelpButton() {
    return ButtonWidget(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: Text(
          '邀请',
          style: TextStyle(color: Color.fromRGBO(76, 129, 235, 1)),
        ),
        color: Color.fromRGBO(76, 129, 235, 1),
        onPressed: () {
          Navigator.of(context)
              .push(CupertinoPageRoute(builder: (BuildContext context) {
            return HelpPage();
          })).then((list) {
            if (list.length > 0) {
              this
                  ._callHelp(widget.order, this._reportOrder, list)
                  .then((success) {
                if (success) {
                  showCupertinoDialog(
                      context: context,
                      builder: (BuildContext contextTemp) {
                        return CupertinoAlertDialog(
                          content: Text(
                            "呼叫成功",
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
            }
          });
        });
  }

  Widget _waitButton() {
    return ButtonWidget(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: Text('等待',
            style: TextStyle(color: Color.fromRGBO(40, 180, 110, 1))),
        color: Color.fromRGBO(40, 180, 110, 1),
        onPressed: () async {
          setState(() {
            this._loading = true;
          });
          await this._wait(widget.order, this._reportOrder).then((success) {
            if (success) {
              setState(() {
                this._loading = false;
              });
              showCupertinoDialog(
                  context: context,
                  builder: (BuildContext contextTemp) {
                    return CupertinoAlertDialog(
                      content: Text(
                        "等待成功",
                        style: TextStyle(fontSize: 18),
                      ),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          onPressed: () {
                            Navigator.of(contextTemp).pop();
                            Navigator.of(context).popUntil(
                                ModalRoute.withName("assisantOrderHome"));
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

  Widget _repairButton() {
    return ButtonWidget(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: Text('活动完成',
            style: TextStyle(color: Color.fromRGBO(12, 160, 170, 1))),
        color: Color.fromRGBO(12, 160, 170, 1),
        onPressed: () {
          Navigator.of(context)
              .push(CupertinoPageRoute(builder: (BuildContext context) {
            return OrderRepairDetailPage(
              order: widget.order,
            );
          }));
        });
  }

  Widget _addMaterielButton() {
    Device device = new Device();
    device.deviceName = this.widget.order.EQKTX;
    device.deviceCode = this.widget.order.EQUNR;
    device.positionCode = this.widget.order.TPLNR;
    return ButtonWidget(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: Text('领取物料',
            style: TextStyle(color: Color.fromRGBO(10, 65, 150, 1))),
        color: Color.fromRGBO(10, 65, 150, 1),
        onPressed: () {
          Navigator.of(context)
              .push(CupertinoPageRoute(builder: (BuildContext context) {
            return DeviceSelectionPage(
              selectItem: device,
              isAddMaterial: true,
              AUFNR: widget.order.AUFNR,
            );
          }));
        });
  }

  Widget _takeItemButton() {
    return ButtonWidget(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: Text('接单',
            style: TextStyle(color: Color.fromRGBO(76, 129, 235, 1))),
        color: Color.fromRGBO(76, 129, 235, 1),
        onPressed: () async {
          if (widget.isRepairing) {
            showCupertinoDialog(
                context: context,
                builder: (BuildContext contextTemp) {
                  return CupertinoAlertDialog(
                    content: Text(
                      "请完成维修中工单",
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
              this._loading = true;
            });
            await this._takeItem(widget.order, this._reportOrder).then((success) {
              if (success) {
                setState(() {
                  this._loading = false;
                });
                showCupertinoDialog(
                    context: context,
                    builder: (BuildContext contextTemp) {
                      return CupertinoAlertDialog(
                        content: Text(
                          "接单成功",
                          style: TextStyle(fontSize: 18),
                        ),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            onPressed: () {
                              Navigator.of(contextTemp).pop();
                              Navigator.of(context).popUntil(
                                  ModalRoute.withName("assisantOrderHome"));
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
                          "接单失败",
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
          }
        });
  }

  Widget _handleWaitItemButton() {
    return ButtonWidget(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: Text('开始处理',
            style: TextStyle(color: Color.fromRGBO(76, 129, 235, 1))),
        color: Color.fromRGBO(76, 129, 235, 1),
        onPressed: () async {
          if (widget.isRepairing) {
            showCupertinoDialog(
                context: context,
                builder: (BuildContext contextTemp) {
                  return CupertinoAlertDialog(
                    content: Text(
                      "请完成维修中工单",
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
              this._loading = true;
            });
            await this._takeItem(widget.order, this._reportOrder).then((success) {
              if (success) {
                setState(() {
                  this._loading = false;
                });
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
                              Navigator.of(context).popUntil(
                                  ModalRoute.withName("assisantOrderHome"));
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
                          "接单失败",
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
          }
        });
  }

  Widget _outerRepairButton() {
    return ButtonWidget(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: Text('委外维修',
            style: TextStyle(color: Color.fromRGBO(40, 180, 110, 1))),
        color: Color.fromRGBO(40, 180, 110, 1),
        onPressed: () async {
          setState(() {
            this._loading = true;
          });
          await this._outerRepair(widget.order).then((success) {
            if (success) {
              setState(() {
                this._loading = false;
              });
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
                            Navigator.of(context).popUntil(
                                ModalRoute.withName("assisantOrderHome"));
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

  Widget _distributeButton() {
    return ButtonWidget(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: Text(
          '派单',
          style: TextStyle(color: Color.fromRGBO(76, 129, 235, 1)),
        ),
        color: Color.fromRGBO(76, 129, 235, 1),
        onPressed: () {
          Navigator.of(context)
              .push(CupertinoPageRoute(builder: (BuildContext context) {
            return WorkerPage();
          })).then((worker) {
            if (worker != null) {
              this
                  ._distributeOrder(
                  widget.order, this._reportOrder, worker.PERNR)
                  .then((success) {
                if (success) {
                  showCupertinoDialog(
                      context: context,
                      builder: (BuildContext contextTemp) {
                        return CupertinoAlertDialog(
                          content: Text(
                            "派单成功",
                            style: TextStyle(fontSize: 18),
                          ),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              onPressed: () {
                                Navigator.of(contextTemp).pop();
                                Navigator.of(context).popUntil(
                                    ModalRoute.withName("assisantOrderHome"));
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
            }
          });
        });
  }

  Widget _alreadyAcceptButton() {
    return ButtonWidget(
      padding: EdgeInsets.only(left: 0, right: 0),
      child: Text(
        '已接受',
        style: TextStyle(color: Colors.grey),
      ),
      color: Colors.black,
    );
  }

  Widget _acceptButton() {
    return ButtonWidget(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: Text(
          '接受',
          style: TextStyle(color: Color.fromRGBO(76, 129, 235, 1)),
        ),
        color: Color.fromRGBO(76, 129, 235, 1),
        onPressed: () async {
          setState(() {
            this._loading = true;
          });
          await this
              ._answerHelp(widget.order, this._reportOrder)
              .then((success) {
            if (success) {
              setState(() {
                this._loading = false;
              });
              showCupertinoDialog(
                  context: context,
                  builder: (BuildContext contextTemp) {
                    return CupertinoAlertDialog(
                      content: Text(
                        "加入成功",
                        style: TextStyle(fontSize: 18),
                      ),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          onPressed: () {
                            Navigator.of(contextTemp).pop();
                            Navigator.of(context).popUntil(
                                ModalRoute.withName("assisantOrderHome"));
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
                        "加入失败",
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

  Widget _transferCardButton() {
    return TextButtonWidget(
      text: "转卡",
      onTap: () {
        Navigator.of(context)
            .push(CupertinoPageRoute(builder: (BuildContext context) {
          return WorkerPage();
        })).then((worker) {
          if (worker != null) {
            this
                ._transferCard(widget.order, this._reportOrder, worker.PERNR)
                .then((success) {
              if (success) {
                showCupertinoDialog(
                    context: context,
                    builder: (BuildContext contextTemp) {
                      return CupertinoAlertDialog(
                        content: Text(
                          "转卡成功",
                          style: TextStyle(fontSize: 18),
                        ),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            onPressed: () {
                              Navigator.of(contextTemp).pop();
                              Navigator.of(context).popUntil(
                                  ModalRoute.withName("assisantOrderHome"));
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
          }
        });
      },
    );
  }

  List<Widget> organizationOrder() {
    if (["N13", "N14", "N15", "N16", "N17"].contains(widget.order.ILART)) {
      return [
        widget.itemStatus == "新工单" &&
            (_monitorOrForeman.contains(Global.userInfo.SORTB) ||
                _equipmentSupervisor.contains(Global.userInfo.SORTB) ||
                _engineer.contains(Global.userInfo.SORTB) ||
                _maintenanceManagementPersonnel
                    .contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: _takeItemButton(),
          ),
        )
            : Container(),
        widget.itemStatus == "转卡单" &&
            ((_monitorOrForeman.contains(Global.userInfo.SORTB) ||
                _equipmentSupervisor.contains(Global.userInfo.SORTB) ||
                _engineer.contains(Global.userInfo.SORTB) ||
                _maintenanceManagementPersonnel
                    .contains(Global.userInfo.SORTB)) &&
                widget.order.PERNR1 == Global.userInfo.PERNR)
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: _handleWaitItemButton(),
                  ),
                ),
              ],
            ),
          ),
        )
            : Container(),
        widget.itemStatus == "维修中" &&
            (Global.userInfo.PERNR == widget.order.PERNR1 &&
                (_monitorOrForeman.contains(Global.userInfo.SORTB) ||
                    _equipmentSupervisor.contains(Global.userInfo.SORTB) ||
                    _engineer.contains(Global.userInfo.SORTB) ||
                    _maintenanceManagementPersonnel
                        .contains(Global.userInfo.SORTB)))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
              button: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _callHelpButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: _repairButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        )
            : Container(),
        widget.itemStatus == "等待中" &&
            ((_monitorOrForeman.contains(Global.userInfo.SORTB) ||
                _equipmentSupervisor.contains(Global.userInfo.SORTB) ||
                _engineer.contains(Global.userInfo.SORTB) ||
                _maintenanceManagementPersonnel
                    .contains(Global.userInfo.SORTB)) &&
                widget.order.PERNR1 == Global.userInfo.PERNR)
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: _handleWaitItemButton(),
          ),
        )
            : Container(),
        widget.itemStatus == "协助单"
            && (widget.order.APPSTATUS == "呼叫协助" ||
            widget.order.APPSTATUS == "加入") &&
            (_maintenanceWorker.contains(Global.userInfo.SORTB) ||
                _monitorOrForeman.contains(Global.userInfo.SORTB) ||
                _equipmentSupervisor.contains(Global.userInfo.SORTB) ||
                _engineer.contains(Global.userInfo.SORTB) ||
                _maintenanceManagementPersonnel
                    .contains(Global.userInfo.SORTB))
            ? Align(
          alignment: Alignment.bottomCenter,
          child: ButtonBarWidget(
            button: this._helpWorker.contains(Global.userInfo.PERNR)
                ? _alreadyAcceptButton()
                : _acceptButton(),
          ),
        )
            : Container(),
        widget.itemStatus == "历史单" ? Container() : Container()
      ];
    } else
      return [];
  }

  @override
  void dispose() {
    if (this._controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    this._reportOrderDetailFuture = this._reportOrderDetail();
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
          if (s == AudioPlayerState.PLAYING) {
            setState(() => icon = Icon(Icons.pause));
          } else {
            setState(() {
              icon = Icon(Icons.play_arrow);
            });
          }
        }, onError: (msg) {
          setState(() {
            icon = Icon(Icons.play_arrow);
          });
        });
    super.initState();
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
                    widget.order.QMTXT,
                    style: TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: !(widget.order.ASTTX == "已完成" ||
                      widget.order.ASTTX == "新工单" ||
                      widget.order.ASTTX == "新建" ||
                      (widget.order.APPSTATUS == "呼叫协助" &&
                          widget.order.PERNR1 !=
                              Global.userInfo.PERNR) ||
                      (widget.order.APPSTATUS == "加入" &&
                          widget.order.PERNR1 !=
                              Global.userInfo.PERNR)) &&
                      widget.itemStatus != "历史单" &&
                      widget.order.PERNR1 == Global.userInfo.PERNR &&
                      false
                      ? _transferCardButton()
                      : null,
                ),
                backgroundColor: Colors.white,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: 10, top: 6, bottom: 6, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: widget.order.QMNUM != "" &&
                                  widget.order.QMNUM != null
                                  ? Text(
                                "报修单号：${widget.order.QMNUM}",
                                style: TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 0.45),
                                  fontSize: 12,
                                ),
                              )
                                  : Container(),
                            ),
                            Expanded(
                              child: widget.order.AUFNR != "" &&
                                  widget.order.AUFNR != null
                                  ? Text(
                                "维修单号：${widget.order.AUFNR}",
                                style: TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 0.45),
                                  fontSize: 12,
                                ),
                              )
                                  : Container(),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                      ListItemWidget(
                        title: Text("报修人"),
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (BuildContext context) {
                                return UserInfoPage(
                                  PERNR: widget.order.PERNR,
                                );
                              }));
                        },
                      ),
                      Divider(
                        height: 1,
                      ),
                      ListItemWidget(
                        title: Text("维修记录"),
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
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (BuildContext context) {
                                  return RepairHistoryPage(
                                    order: widget.order,
                                  );
                                }));
                          }
                        },
                      ),
                      Divider(
                        height: 1,
                      ),
                      ListItemWidget(
                        title: Text("活动详情"),
                        onTap: () {
                          if (widget.order.ASTTX == "新建" ||
                              widget.order.ASTTX == "新工单") {
                            showCupertinoDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    content: Text(
                                      "无活动详情",
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
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (BuildContext context) {
                                  return RepairDetailPage(
                                    order: widget.order,
                                  );
                                }));
                          }
                        },
                      ),
                      Divider(
                        height: 1,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20, left: 10, top: 20),
                        child: Text(
                          _reportOrder.FETXT ?? '',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                          EdgeInsets.only(left: 10, right: 10, top: 10),
                          child: GridView.count(
                            crossAxisCount: 2,
                            children: <Widget>[
                              ..._buildPic(this._imgList ?? new List())
                            ],
                          ),
                        ),
                      ),
                      ...organizationOrder()
                    ],
                  ),
                ),
              ));
        });
  }
}
