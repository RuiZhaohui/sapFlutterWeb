import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/model/Device.dart';
import 'package:gztyre/api/model/FunctionPosition.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/pages/problemReport/ChildrenDeviceSelectionPage.dart';

class ChildrenPositionSelectionPage extends StatefulWidget {
  ChildrenPositionSelectionPage({Key key,@required this.position, @required this.selectItem,this.isAddMaterial = false,
    this.AUFNR}) : super(key: key);

  final List<FunctionPosition> position;
  final Device selectItem;

  final bool isAddMaterial;
  final String AUFNR;

  @override
  State createState() => _ChildrenPositionSelectionPageState();
}

class _ChildrenPositionSelectionPageState extends State<ChildrenPositionSelectionPage> {

  Device _selectItem;

  List<Widget> createWidgetList(List<FunctionPosition> list) {
    List<Widget> itemList = [];
    if (list.length == 0) {
      return itemList;
    }
    for (int i = 0; i < list.length; i++) {
      if (i == 0) {
        itemList.add(new ListItemWidget(
              title: Text(list[i].positionName),
          onTap: () {
            if (list[i].children.length > 0) {
              Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) {
                return ChildrenPositionSelectionPage(position: list[i].children, selectItem: widget.selectItem, isAddMaterial: widget.isAddMaterial, AUFNR: widget.AUFNR,);
              })).then((val) {
                if (val["isOk"]) {
                  this._selectItem = val["item"];
                  Navigator.of(context).pop(val);
                }
              });
            } else if (list[i].deviceChildren.length > 0) {
              Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) {
                return ChildrenDeviceSelectionPage(device: list[i].deviceChildren, selectItem: widget.selectItem, isAddMaterial: widget.isAddMaterial, AUFNR: widget.AUFNR,);
              })).then((val) {
                if (val["isOk"]) {
                  this._selectItem = val["item"];
                  Navigator.of(context).pop(val);
                }
              });
            }
          },
        ),
        );
      } else {
        itemList.add(Divider(
          height: 1,
        ));
        itemList.add(new ListItemWidget(
              title: Text(list[i].positionName),
          onTap: () {
            if (list[i].children.length > 0) {
              Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) {
                return ChildrenPositionSelectionPage(position: list[i].children, selectItem: widget.selectItem, isAddMaterial: widget.isAddMaterial, AUFNR: widget.AUFNR,);
              })).then((val) {
                if (val["isOk"]) {
                  this._selectItem = val["item"];
                  Navigator.of(context).pop(val);
                }
              });
            } else if (list[i].deviceChildren.length > 0) {
              Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) {
                return ChildrenDeviceSelectionPage(device: list[i].deviceChildren, selectItem: widget.selectItem, isAddMaterial: widget.isAddMaterial, AUFNR: widget.AUFNR,);
              })).then((val) {
                if (val["isOk"]) {
                  this._selectItem = val["item"];
                  Navigator.of(context).pop(val);
                }
              });
            }
          },
        ));
      }
    }
    return itemList;
  }


  @override
  void initState() {
    this._selectItem = widget.selectItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new CupertinoPageScaffold(
        navigationBar: new CupertinoNavigationBar(
          leading: CupertinoNavigationBarBackButton(
            onPressed: () => Navigator.pop(context, {"item": widget.selectItem, "isOk": false}),
            color: Color.fromRGBO(94, 102, 111, 1),
          ),
          middle: Text(
            /// todo 改为父位置名称
            "选择设备",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      child: SafeArea(
          child: CupertinoScrollbar(
              child: ListView(
                children: <Widget>[
//                  SearchBar(controller: this._shiftController),
                  ...createWidgetList(widget.position),
                ],
              ))),
    );
  }
}
