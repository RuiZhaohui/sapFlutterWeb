import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/model/Worker.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ButtonBarWidget.dart';
import 'package:gztyre/components/ButtonWidget.dart';
import 'package:gztyre/components/ListItemSelectWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';

class HelpPage extends StatefulWidget {

  @override
  State createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {

  List<Worker> _selectItemList = new List();


  List<Worker> allList = [];


  var _listWorkerFuture;

  bool _loading = true;

  List<Widget> createWidgetList(List<Worker> list) {
    List<Widget> itemList = [];
    if (list.length == 0) {
      return itemList;
    }
    for (int i = 0; i < list.length; i++) {
      if (i == 0) {
        itemList.add(new GestureDetector(
          child: ListItemSelectWidget(
            title: Text("${list[i].ENAME}（${list[i].SORTT}）"),
            item: list[i],
            selectedItemList: this._selectItemList,),
          onTap: () {
            if (!this._selectItemList.contains(list[i]) && this._selectItemList.length <= 5) {
              this._selectItemList.add(list[i]);
            } else if (this._selectItemList.contains(list[i]))  this._selectItemList.remove(list[i]);
            setState(() {});
          },
        ));
      } else {
        itemList.add(Divider(
          height: 1,
        ));
        itemList.add(new GestureDetector(
          child: ListItemSelectWidget(
            title: Text("${list[i].ENAME}（${list[i].SORTT}）"),
            item: list[i],
            selectedItemList: this._selectItemList,),
          onTap: () {
            if (!this._selectItemList.contains(list[i]) && this._selectItemList.length <= 5) {
              this._selectItemList.add(list[i]);
            } else if (this._selectItemList.contains(list[i])) this._selectItemList.remove(list[i]);
            setState(() {});
          },
        ));
      }
    }
    return itemList;
  }

  _listWorker() async {
    setState(() {
      this._loading = true;
    });
    return await HttpRequest.searchWorker(Global.userInfo.PERNR, (res) {
      this.allList = res.where((item) {
        return item.KTEX1 == "闲置" && item.PERNR != Global.userInfo.PERNR && item.CPLGR == Global.userInfo.CPLGR && item.MATYP == Global.userInfo.MATYP;
      }).toList();
      setState(() {
        this._loading = false;
      });
    }, (err) {
      setState(() {
        this._loading = false;
      });
      this.allList = [];
    });
  }

  @override
  void initState() {
    this._listWorkerFuture = _listWorker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: _listWorkerFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return ProgressDialog(
            loading: this._loading,
            child: CupertinoPageScaffold(
              navigationBar: new CupertinoNavigationBar(
                leading: CupertinoNavigationBarBackButton(
                  onPressed: () => Navigator.pop(context, []),
                  color: Color.fromRGBO(94, 102, 111, 1),
                ),
                middle: Text(
                  "选择人员",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              child: SafeArea(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: CupertinoScrollbar(
                            child: ListView(
                              children: <Widget>[
                                ...createWidgetList(this.allList),
                              ],
                            )),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ButtonBarWidget(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          button: ButtonWidget(
                              color: Color.fromRGBO(76, 129, 235, 1),
                              child: Text("确认", style: TextStyle(color: Color.fromRGBO(76, 129, 235, 1)),),
                              onPressed: () {
                                Navigator.of(context).pop(this._selectItemList);
                              }),
                        ),
                      )
                    ],
                  )),
            ),
          );});
  }
}

