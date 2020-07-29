import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/model/RepairType.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ListItemSelectWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/components/TextButtonWidget.dart';

class RepairTypePage extends StatefulWidget {
  RepairTypePage({Key key, @required this.selectItem}) : super(key: key);

  final RepairType selectItem;

  @override
  State createState() => _RepairTypePageState();
}

class _RepairTypePageState extends State<RepairTypePage> {
  RepairType _selectItem = RepairType();

  bool _loading = false;

  List<RepairType> _repairType = [];

  TextEditingController _shiftController = new TextEditingController();

  var _listRepairTypeFuture;

//  List<String> repairPosition = [
//    "N01","N02","N03","N13","N14","N15","N16","N17"
//  ];
//  List<String> producePosition = [
//    "N01","N02","N03","N04","N07","N09","N10","N11","N12","N13","N14","N15","N16","N17","N18"
//  ];

  List<String> repairPosition = [
    "N01","N02","N03","N04","N07","N08","N09","N10","N11","N12","N13","N14","N15","N16","N17","N18","N19","N20","N21"
  ];
  List<String> producePosition = [
    "N01","N02","N03","N04"
  ];

  List<String> _maintenanceWorker = ["A01", "A02", "A03"];
  List<String> _monitorOrForeman = ["A04", "A05"];
  List<String> _equipmentSupervisor = ["A06"];
  List<String> _engineer = ["A07"];
  List<String> _maintenanceManagementPersonnel = ["A08"];

  _listRepairType() async {
    setState(() {
      this._loading = true;
    });
    HttpRequest.listRepairType((List<RepairType> list) {
      if (Global.userInfo.WCTYPE == "是") {
        if (_maintenanceWorker.contains(Global.userInfo.SORTB)) {
          this._repairType = list.where((item) {
            return ["N01", "N07", "N08", "N19"].contains(item.ILART);
          }).toList();
        } else if (_monitorOrForeman.contains(Global.userInfo.SORTB)) {
          this._repairType = list.where((item) {
            return ["N01", "N08", "N13"].contains(item.ILART);
          }).toList();
        } else if (_equipmentSupervisor.contains(Global.userInfo.SORTB)) {
          this._repairType = list.where((item) {
            return ["N01", "N13"].contains(item.ILART);
          }).toList();
        } else if (_engineer.contains(Global.userInfo.SORTB)) {
          this._repairType = list.where((item) {
            return ["N01", "N07", "N08", "N09", "N13", "N19"].contains(item.ILART);
          }).toList();
        } else if (_maintenanceManagementPersonnel.contains(Global.userInfo.SORTB)) {
          this._repairType = list.where((item) {
            return ["N01", "N13"].contains(item.ILART);
          }).toList();
        } else {
          this._repairType = [];
        }
      } else {
        this._repairType = list.where((item) {
          return ["N01", "N20"].contains(item.ILART);
        }).toList();
      }
      setState(() {
        this._loading = false;
      });
    }, (err) {
      print(err);
      setState(() {
        this._loading = false;
      });
    });
  }

  List<Widget> createWidgetList(List<RepairType> list) {
    List<Widget> itemList = [];
//    itemList.add(ListTitleWidget(
//      title: position,
//    ));
    for (int i = 0; i < list.length; i++) {
      if (i == 0) {
        itemList.add(new GestureDetector(
          child: ListItemSelectWidget(
              title: Text(list[i].ILATX),
              item: list[i],
              selectedItem: this._selectItem),
          onTap: () {
            if (this._selectItem == list[i]) {
              this._selectItem = null;
            } else
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
              title: Text(list[i].ILATX),
              item: list[i],
              selectedItem: this._selectItem),
          onTap: () {
            if (this._selectItem == list[i]) {
              this._selectItem = null;
            } else
              this._selectItem = list[i];
            setState(() {});
          },
        ));
      }
    }
    return itemList;
  }

  @override
  void initState() {
    this._listRepairTypeFuture = _listRepairType();
    this._selectItem = widget.selectItem;
    this._shiftController.addListener(() {
      if (this._shiftController.text == 'a') {
        print(this._selectItem);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: FutureBuilder(
            future: _listRepairTypeFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return ProgressDialog(
                loading: this._loading,
                child: CupertinoPageScaffold(
                  navigationBar: new CupertinoNavigationBar(
                    leading: CupertinoNavigationBarBackButton(
                      onPressed: () =>
                          Navigator.of(context).pop(widget.selectItem),
                      color: Color.fromRGBO(94, 102, 111, 1),
                    ),
                    middle: Text(
                      "维修类型",
                      style: TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: TextButtonWidget(
                      onTap: () {
                        Navigator.of(context).pop(this._selectItem);
                      },
                      text: "确定",
                    ),
                  ),
                  child: SafeArea(
                      child: CupertinoScrollbar(
                          child: ListView(
                            children: <Widget>[
//                  SearchBar(controller: this._shiftController),
                              ...createWidgetList(_repairType),
                            ],
                          ))),
                ),
              );
            }),
        onWillPop: () async {
          Navigator.of(context).pop(this._selectItem);
          return false;
        });
  }
}
