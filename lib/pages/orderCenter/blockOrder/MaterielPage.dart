import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/HttpRequestRest.dart';
import 'package:gztyre/api/model/Materiel.dart';
import 'package:gztyre/api/model/SubmitMateriel.dart';
import 'package:gztyre/components/BottomDragWidget.dart';
import 'package:gztyre/components/ListItemShopChartWidget.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/components/TextButtonWidget.dart';
import 'package:gztyre/pages/orderCenter/MaterielDetailPage.dart';
import 'package:gztyre/utils/screen_utils.dart';

class MaterielPage extends StatefulWidget {
  MaterielPage(
      {Key key,
        @required this.AUFNR,
      })
      : super(key: key);
  final String AUFNR;

  @override
  State createState() => _MaterielPageState();
}

class _MaterielPageState extends State<MaterielPage> {
  var _listMaterielFuture;
  bool _loading;
  List<Materiel> _materielList = new List();
  List<SubmitMateriel> _requireMaterielList = new List();
  TextEditingController _editMaterielController = new TextEditingController();
  TextEditingController _editSearchMaterielController =
  new TextEditingController();

  Future<Materiel> _getMateriel(String code) async {
    return await HttpRequestRest.getMateriel(code, (materiel) {
      return materiel;
    }, (err) {
      return null;
    });
  }

  Future<bool> _isMaterielExist(String code) async {
    return await HttpRequestRest.isMaterielExist(code, (success) {
      return success;
    }, (err) {
      return false;
    });
  }

  List<Widget> _buildList(List<Materiel> list) {
    List<Widget> widgetList = new List();
    if (list.length == 0) {
      return widgetList;
    }
    list.forEach((item) {
      Widget listItem = ListItemWidget(
        title: Text(item.MAKTX),
        onTap: () {
          Navigator.of(context)
              .push(CupertinoPageRoute(builder: (BuildContext context) {
            return MaterielDetailPage(
              materiel: item,
              materielList: this._materielList,
            );
          })).then((val) {
            if (val is Materiel) {
              if (!this._requireMaterielList.any((materiel) {
                return materiel.MATNR == val.MATNR;
              })) {
                SubmitMateriel submitMateriel = new SubmitMateriel();
                submitMateriel.AUFNR = widget.AUFNR;
                submitMateriel.MAKTX = val.MAKTX;
                submitMateriel.MATNR = val.MATNR;
                submitMateriel.MENGE = 0;
                this._requireMaterielList.add(submitMateriel);
                setState(() {});
              }
            } else if (val is SubstituteMateriel) {
              if (!this._requireMaterielList.any((materiel) {
                return materiel.MATNR == val.REMATNR;
              })) {
                SubmitMateriel submitMateriel = new SubmitMateriel();
                submitMateriel.AUFNR = widget.AUFNR;
                submitMateriel.MAKTX = val.REMAKTX;
                submitMateriel.MATNR = val.REMATNR;
                submitMateriel.MENGE = 0;
                this._requireMaterielList.add(submitMateriel);
                setState(() {});
              }
            }
          });
        },
      );
      widgetList.add(listItem);
    });
    return widgetList;
  }

  List<Widget> _buildShopChartList(List<SubmitMateriel> list) {
    List<Widget> widgetList = new List();
    if (list.length == 0) {
      return widgetList;
    }
    for (int i = 0; i < list.length; i++) {
      Widget listItem = ListItemShopChartWidget(
        title: ListView(
          children: [
            Text(list[i].MAKTX != "" ? list[i].MAKTX : list[i].MATNR)
          ],
        ),
        number: list[i].MENGE,
        onTap: (val) {
          list[i].MENGE = val;
        },
        onDelete: () {
          setState(() {
            list.removeAt(i);
          });
        },
      );
      widgetList.add(listItem);
    }
    return widgetList;
  }

  _listMateriels() async {
    setState(() {
      this._loading = true;
    });
    print('查询已领取物料');
    await HttpRequest.searchMaterialTemp(widget.AUFNR, (list) {
      _requireMaterielList.addAll(list);
      setState(() {
        this._loading = false;
      });
    },
            (err) => {
          setState(() {
            this._loading = false;
          })
        });
  }

  Future _addMateriel(List<SubmitMateriel> list) {
    return Future.forEach(list, (item) async {
      await HttpRequest.addMateriel(item.AUFNR, item.MATNR, item.MAKTX,
          item.MENGE, null, (res) {}, (err) {
            throw err;
          });
    });
  }

  @override
  void initState() {
    super.initState();
//    if (widget.list != null) {
//      this._requireMaterielList = widget.list;
//    }
    this._loading = false;
    setState(() {});
//    HttpRequest.searchBom(widget.device.deviceCode, (list) {
////      print(list);
//    }, (err) {
////      print(err);
//    });
    this._listMaterielFuture = this._listMateriels();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: _listMaterielFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return ProgressDialog(
            loading: this._loading,
            child: CupertinoPageScaffold(
              navigationBar: new CupertinoNavigationBar(
                leading: CupertinoNavigationBarBackButton(
                  onPressed: () => Navigator.pop(context, false),
                  color: Color.fromRGBO(94, 102, 111, 1),
                ),
                middle: Text(
                  "领取物料",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: TextButtonWidget(
                  onTap: () async {
                    if (this._requireMaterielList.length > 0) {
                      this._addMateriel(this._requireMaterielList).then((val) {
                        showCupertinoDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return CupertinoAlertDialog(
                                content: Text(
                                  "添加成功",
                                  style: TextStyle(fontSize: 18),
                                ),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text("好"),
                                  ),
                                ],
                              );
                            });
                      }).catchError((err) {
                        showCupertinoDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return CupertinoAlertDialog(
                                content: Text(
                                  err.message,
                                  style: TextStyle(fontSize: 18),
                                ),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Text("好"),
                                  ),
                                ],
                              );
                            });
                      });
                    } else {
                      showCupertinoDialog(
                          context: context,
                          builder: (BuildContext ctx) {
                            return CupertinoAlertDialog(
                              content: Text(
                                "未添加物料",
                                style: TextStyle(fontSize: 18),
                              ),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text("好"),
                                ),
                              ],
                            );
                          });
                    }
                  },
                  text: "确定",
                ),
              ),
              child: SafeArea(
                child: BottomDragWidget(
                  body: CupertinoScrollbar(
                      child: ListView(
                        children: <Widget>[
                          ListItemWidget(title: Text('手动添加物料'),
                            onTap: () {

                              showCupertinoDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      content: CupertinoTextField(
                                        controller:
                                        _editSearchMaterielController,
                                        placeholder: "请输入物料编码",
                                      ),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            this
                                                ._editSearchMaterielController
                                                .text = null;
                                            Navigator.of(context)
                                                .pop();
                                          },
                                          child: Text("取消"),
                                        ),
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            SubmitMateriel
                                            submitMateriel =
                                            new SubmitMateriel();
                                            submitMateriel.MAKTX = "";
                                            submitMateriel.MATNR =
                                                _editSearchMaterielController
                                                    .text;
                                            submitMateriel.AUFNR =
                                                widget.AUFNR;
                                            submitMateriel.MENGE = 0;
                                            this
                                                ._getMateriel(
                                                submitMateriel
                                                    .MATNR)
                                                .then((materiel) {
                                              if (materiel != null) {
                                                submitMateriel.MATNR = materiel.MATNR;
                                                submitMateriel.MAKTX = materiel.MAKTX;
                                                this
                                                    ._requireMaterielList
                                                    .add(
                                                    submitMateriel);
                                                this
                                                    ._editSearchMaterielController
                                                    .text = null;
                                                Navigator.of(context)
                                                    .pop();
                                              } else {
                                                Navigator.of(context)
                                                    .pop();
                                                showCupertinoDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext
                                                    ctx) {
                                                      return CupertinoAlertDialog(
                                                        content: Text(
                                                          "未找到物料",
                                                          style: TextStyle(
                                                              fontSize:
                                                              18),
                                                        ),
                                                        actions: <
                                                            Widget>[
                                                          CupertinoDialogAction(
                                                            onPressed:
                                                                () {
                                                              Navigator.of(ctx)
                                                                  .pop();
                                                            },
                                                            child: Text(
                                                                "好"),
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              }
                                            });
                                          },
                                          child: Text("确定"),
                                        ),
                                      ],
                                    );
                                  });
                            },
                          ),
                          ListItemWidget(
                            title: Text('编辑文本物料'),
                            onTap: () {

                              showCupertinoDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      content: CupertinoTextField(
                                        controller:
                                        _editMaterielController,
                                        placeholder: "请输入物料名称",
                                      ),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            this
                                                ._editMaterielController
                                                .text = null;
                                            setState(() {});
                                            Navigator.of(context)
                                                .pop();
                                          },
                                          child: Text("取消"),
                                        ),
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            SubmitMateriel
                                            submitMateriel =
                                            new SubmitMateriel();
                                            submitMateriel.MAKTX = this
                                                ._editMaterielController
                                                .text;
                                            submitMateriel.AUFNR =
                                                widget.AUFNR;
                                            submitMateriel.MENGE = 0;
                                            this
                                                ._requireMaterielList
                                                .add(submitMateriel);
                                            this
                                                ._editMaterielController
                                                .text = null;
                                            setState(() {});
                                            Navigator.of(context)
                                                .pop();
                                          },
                                          child: Text("确定"),
                                        ),
                                      ],
                                    );
                                  });
                            },
                          ),
                          ...this._buildList(this._materielList),
                        ],
                      )),
                  dragContainer: DragContainer(
                    drawer: Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                Text("已选物料"),
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                              Ch: Text("已选物料"),
                            ),
                            height: 40,
                            width: ScreenUtils.screenW(context),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      offset: Offset.zero,
                                      spreadRadius: 0.5,
                                      color: Color.fromRGBO(200, 220, 220, 1)),
                                  BoxShadow(
                                      offset: Offset.zero,
                                      spreadRadius: 0.5,
                                      color: Color.fromRGBO(200, 220, 220, 1)),
                                  BoxShadow(
                                      offset: Offset.zero,
                                      spreadRadius: 0.5,
                                      color: Color.fromRGBO(200, 220, 220, 1)),
                                  BoxShadow(
                                      offset: Offset.zero,
                                      spreadRadius: 0.5,
                                      color: Color.fromRGBO(220, 220, 220, 1))
                                ],
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0)),
                                color: Color.fromRGBO(255, 255, 255, 0.5)),
                          ),
                          Divider(height: 1,),
                          Expanded(
                            child: Container(
                              color: Color.fromRGBO(240, 240, 240, 1),
                              child: OverscrollNotificationWidget(
                                child: ListView(
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    ...this._buildShopChartList(
                                        this._requireMaterielList)
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    defaultShowHeight: 40.0,
                    height: ScreenUtils.screenH(context) / 3,
                  ),
                ),
              ),
            ),
          );
        });
  }
}