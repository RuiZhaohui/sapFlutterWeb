import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/model/Device.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/components/TextButtonWidget.dart';
import 'package:gztyre/pages/orderCenter/planOrder/MaterielPage.dart';

class ChildrenDeviceSelectionPage extends StatefulWidget {
  ChildrenDeviceSelectionPage({Key key, @required this.device, @required this.selectItem,this.isAddMaterial = false,
    this.AUFNR})
      : super(key: key);

  final List<Device> device;
  final Device selectItem;
  final bool isAddMaterial;
  final String AUFNR;

  @override
  State createState() => _ChildrenDeviceSelectionPageState();
}

class _ChildrenDeviceSelectionPageState
    extends State<ChildrenDeviceSelectionPage> {

  Device _selectItem;

  List<Widget> createWidgetList(List<Device> list) {
    List<Widget> itemList = [];
    if (list.length == 0) {
      return itemList;
    }
    for (int i = 0; i < list.length; i++) {
      if (i == 0) {
        itemList.add(
          new ListItemWidget(
            actionArea: list[i].children.length == 0 ? Container() : Icon(CupertinoIcons.right_chevron, color: Color.fromRGBO(94, 102, 111, 1),),
            title: Row(
              children: <Widget>[
                Material(
                  child: Checkbox(
                    value: this._selectItem.deviceCode == list[i].deviceCode,
                    onChanged: (bool val) {
                      if (val) {
                        this._selectItem = list[i];
                        setState(() {});
                      } else {
                        this._selectItem = new Device();
                        setState(() {});
                      }
                    },
                  ),
                ),
                Expanded(
                  child: Text(list[i].deviceName),
                ),
              ],
            ),
            onTap: () {
              if (list[i].children.length > 0) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (BuildContext context) {
                  return ChildrenDeviceSelectionPage(
                    device: list[i].children, selectItem: this._selectItem, isAddMaterial: widget.isAddMaterial, AUFNR: widget.AUFNR,
                  );
                })).then((val) {
                  if (val["isOk"]) {
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
          actionArea: list[i].children.length == 0 ? Container() : Icon(CupertinoIcons.right_chevron, color: Color.fromRGBO(94, 102, 111, 1),),
          title: Row(
            children: <Widget>[
              Material(
                child: Checkbox(
                  value: this._selectItem.deviceCode == list[i].deviceCode,
                  onChanged: (bool val) {
                    if (val) {
                      this._selectItem = list[i];
                      setState(() {});
                    } else {
                      this._selectItem = new Device();
                      setState(() {});
                    }
                  },
                ),
              ),
              Expanded(
                child: Text(list[i].deviceName),
              ),
            ],
          ),
          onTap: () {
            print(list[i].children.length);
            if (list[i].children.length > 0) {
              Navigator.of(context)
                  .push(CupertinoPageRoute(builder: (BuildContext context) {
                return ChildrenDeviceSelectionPage(
                  device: list[i].children, selectItem: this._selectItem, isAddMaterial: widget.isAddMaterial, AUFNR: widget.AUFNR,
                );
              })).then((val) {
                if (val["isOk"]) {
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
          onPressed: () => Navigator.pop(context, {"item": this._selectItem, "isOk": false}),
          color: Color.fromRGBO(94, 102, 111, 1),
        ),
        middle: Text(
          /// todo 改为父位置名称
          "选择设备",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: TextButtonWidget(
          onTap: ()  {
            if (widget.isAddMaterial) {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (BuildContext context) {
                    return MaterielPage(
                      list: null,
                      AUFNR: widget.AUFNR,
                      device: this._selectItem,
                    );
                  })).then((val) {
                    if (val) {
                      Navigator.of(context).pop({"item": this._selectItem, "isOk": true});
                    }
              });
            } else
            Navigator.pop(context, {"item": this._selectItem, "isOk": true});
          },
          text: "确定",
        ),
      ),
      child: SafeArea(
          child: CupertinoScrollbar(
              child: ListView(
        children: <Widget>[
//                  SearchBar(controller: this._shiftController),
          ...createWidgetList(widget.device),
        ],
      ))),
    );
  }
}
