import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/model/WorkShift.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ListItemSelectWidget.dart';
import 'package:gztyre/components/ListTitleWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/components/SearchBar.dart';
import 'package:gztyre/components/TextButtonWidget.dart';
import 'package:gztyre/pages/ContainerPage.dart';

class UserWorkShiftSelectionPage extends StatefulWidget {
  UserWorkShiftSelectionPage({Key key, @required this.userName, @required this.selectItem}) : super(key: key);

  final String userName;
  final WorkShift selectItem;

  @override
  State createState() => _UserWorkShiftSelectionPageState();
}

class _UserWorkShiftSelectionPageState extends State<UserWorkShiftSelectionPage> {

  WorkShift _selectItem;

  List<WorkShift> _historyList = List();
  List _historyStringList = List();

  List<WorkShift> allList = [];
  List<WorkShift> _tempList = [];

  TextEditingController _shiftController = new TextEditingController();

  var _listWorkShiftFuture;

  bool _loading = true;

  List<Widget> createWidgetList(List<WorkShift> list, String position) {
    List<Widget> itemList = [];
    if (list.length == 0) {
      return itemList;
    }
    itemList.add(ListTitleWidget(
      title: position,
    ));
    for (int i = 0; i < list.length; i++) {
      if (i == 0) {
        itemList.add(new GestureDetector(
          child: ListItemSelectWidget(
              title: Text(list[i].PLTXT),
              item: list[i],
              selectedItem: this._selectItem),
          onTap: () {
            this._selectItem = list[i];
            setState(() {});
          },
        ));
      } else {
        itemList.add(Divider(
          height: 1,
        ));
        itemList.add(new GestureDetector(
          child: ListItemSelectWidget(
              title: Text(list[i].PLTXT),
              item: list[i],
              selectedItem: this._selectItem),
          onTap: () {
            this._selectItem = list[i];
            setState(() {});
          },
        ));
      }
    }
    return itemList;
  }

  Future<bool> _listWorkShift() async {
    var listString = await Global.prefs.get("historyWorkShift");
    List historyList = jsonDecode(listString ?? '[]');
    this._historyStringList = historyList;
    return await HttpRequest.listWorkShift(widget.userName, (list) {
      this.allList = list;
      this._tempList.addAll(list);
      historyList.forEach((item2) {
        list.forEach((item) {
          if (item.TPLNR == item2) {
            this._historyList.add(item);
            this._tempList.remove(item);
          }
        });
      });
      this.allList.clear();
      this.allList.addAll(this._tempList);
      print(this._historyList.length);
      if (this._historyList.length > 0) {
        this._selectItem = this._historyList.first;
      }
      setState(() {
        this._loading = false;
      });
      return true;
    }, (err) {
      print(err);
      setState(() {
        this._loading = false;
      });
      return false;
    });
  }

  @override
  void initState() {
    this._shiftController.addListener(() {
      this.allList = this._tempList.where((item) {
        return item.PLTXT.contains(this._shiftController.text);
      }).toList();
      setState(() {
      });
    });
    this._listWorkShiftFuture = this._listWorkShift();
    this._selectItem = widget.selectItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: _listWorkShiftFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return ProgressDialog(
            loading: this._loading,
            child: CupertinoPageScaffold(
              navigationBar: new CupertinoNavigationBar(
                leading: CupertinoNavigationBarBackButton(
                  onPressed: () => Navigator.pop(context),
                  color: Color.fromRGBO(94, 102, 111, 1),
                ),
                middle: Text(
                  "选择班次",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: TextButtonWidget(
                  onTap: () async {
                    await Global.saveWorkShift(this._selectItem);
                    if (this._selectItem == null) {
                      showCupertinoDialog(
                          context: context,
                          builder: (
                              BuildContext context) {
                            return CupertinoAlertDialog(
                              content: Text(
                                "请选择工作班次",
                                style:
                                TextStyle(fontSize: 18),
                              ),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  onPressed: () {
                                    Navigator.of(
                                        context)
                                        .pop();
                                  },
                                  child: Text("好"),
                                ),
                              ],
                            );
                          });
                    } else {
                      if (!this._historyStringList.contains(this._selectItem.TPLNR)) {
                        this._historyStringList.insert(0,this._selectItem.TPLNR);
                      }
                      if (this._historyStringList.length > 5) {
                        this._historyStringList.removeLast();
                      }
                      var string = jsonEncode(this._historyStringList.toList());
                      print(string);
                      await Global.prefs.setString("historyWorkShift", jsonEncode(this._historyStringList.toList()));
                      await Navigator.of(context).pop();
                    }
                  },
                  text: "确定",
                ),
              ),
              child: SafeArea(
                  child: CupertinoScrollbar(
                      child: ListView(
                        children: <Widget>[
                          SearchBar(controller: this._shiftController),
                          ...createWidgetList(this._historyList.toList(), "历史选择"),
                          ...createWidgetList(this.allList, "所有班次"),
                        ],
                      ))),
            ),
          );});
  }
}
