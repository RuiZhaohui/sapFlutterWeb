import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/HttpRequestRest.dart';
import 'package:gztyre/api/model/Device.dart';
import 'package:gztyre/api/model/FunctionPosition.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ListItemSelectWidget.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/components/ListTitleWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/components/SearchBar.dart';
import 'package:gztyre/components/TextButtonWidget.dart';
import 'package:gztyre/pages/orderCenter/planOrder/MaterielPage.dart';
import 'package:gztyre/pages/problemReport/ChildrenDeviceSelectionPage.dart';
import 'package:gztyre/pages/problemReport/ChildrenPositonSelectionPage.dart';

class DeviceSelectionPage extends StatefulWidget {
  DeviceSelectionPage(
      {Key key,
      @required this.selectItem,
      this.isAddMaterial = false,
      this.AUFNR})
      : super(key: key);

  final Device selectItem;
  final bool isAddMaterial;
  final String AUFNR;

  @override
  State createState() => _DeviceSelectionPageState();
}

class _DeviceSelectionPageState extends State<DeviceSelectionPage> {
  Device _selectItem;

//  FunctionPosition _selectPosition;

  bool _loading = false;

  List<FunctionPosition> _position = [];
  List<FunctionPosition> _tempPosition = [];
  List<Device> _allList = [];

  var _listPositionAndDeviceFuture;

  TextEditingController _shiftController = new TextEditingController();

  _listPositionAndDevice() async {
    this._loading = true;
    HttpRequestRest.listPosition(Global.userInfo.PERNR,
        (List<FunctionPosition> list) {
      this._position = list;
      this._tempPosition.addAll(list);
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

  List<Widget> createWidgetList(List<FunctionPosition> list) {
    List<Widget> deviceList = [];
    list.forEach((item) {
        deviceList.add(ListItemWidget(
            title: Text(item.positionName),
          onTap: () {
              if (item.children.length > 0) {
                Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) {
                  return ChildrenPositionSelectionPage(position: item.children, selectItem: widget.selectItem, isAddMaterial: widget.isAddMaterial, AUFNR: widget.AUFNR,);
                })).then((val) {
                  if (val["isOk"]) {
                    this._selectItem = val["item"];
                    Navigator.of(context).pop(val);
                  }
                });
              } else if (item.deviceChildren.length > 0) {

                Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) {
                  return ChildrenDeviceSelectionPage(device: item.deviceChildren, selectItem: widget.selectItem, isAddMaterial: widget.isAddMaterial, AUFNR: widget.AUFNR,);
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
    });
    return deviceList;
  }

  List<Widget> createSearchWidgetList(List<Device> list) {
    List<Widget> itemList = [];
    if (list.length == 0) {
      return itemList;
    }
    for (int i = 0; i < list.length; i++) {
      if (i == 0) {
        itemList.add(
          new ListItemWidget(
            actionArea: Container(),
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
          ),
        );
      } else {
        itemList.add(Divider(
          height: 1,
        ));
        itemList.add(new ListItemWidget(
          actionArea: Container(),
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
        ));
      }
    }
    return itemList;
  }

  List<Widget> _createWidgetList(List<Device> searchResult, List<FunctionPosition> positionList) {
    if (searchResult.length == 0 && this._shiftController.value.text == null || this._shiftController.value.text.trim().length == 0) {
      return createWidgetList(positionList);
    } else return createSearchWidgetList(searchResult);
  }

  findDeviceByKeywordInDeviceList(List<Device> list, String keyword, List<Device> deviceList) {
    deviceList.forEach((item) {
      if (item.deviceName.indexOf(keyword) > -1) {
        list.add(item);
      }
      if (item.children.length > 0) {
        findDeviceByKeywordInDeviceList(list, keyword, item.children);
      }
    });
  }

  findDeviceByKeyword(List<Device> list, String keyword, List<FunctionPosition> positionList) {
    if (keyword == null || keyword.trim() == "") return;
    print(keyword);
    positionList.forEach((item) {
      if (item.children.length > 0) {
        findDeviceByKeyword(list, keyword, item.children);
      }
      if (item.deviceChildren.length > 0) {
        findDeviceByKeywordInDeviceList(list, keyword, item.deviceChildren);
      }
    });
  }

  @override
  void initState() {
    this._selectItem = widget.selectItem;
    _listPositionAndDeviceFuture = this._listPositionAndDevice();
    this._shiftController.addListener(() {
      this._allList = [];
      findDeviceByKeyword(_allList, this._shiftController.value.text, _position);
      setState(() {
        print(_allList);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: FutureBuilder(
            future: _listPositionAndDeviceFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return ProgressDialog(
                  loading: this._loading,
                  child: CupertinoPageScaffold(
                    navigationBar: new CupertinoNavigationBar(
                      leading: CupertinoNavigationBarBackButton(
                        onPressed: () {
                          Navigator.of(context).pop({"item": widget.selectItem, "isOk": false});
                        },
                        color: Color.fromRGBO(94, 102, 111, 1),
                      ),
                      middle: Text(
                        "选择设备",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: this._allList.length > 0 ? TextButtonWidget(
                        onTap: () {
                          Navigator.of(context).pop({"item": this._selectItem, "isOk": true});
                        },
                        text: "确定",
                      ) : null,
                    ),
                    child: SafeArea(
                        child: CupertinoScrollbar(
                            child: ListView(
                      children: <Widget>[
                                SearchBar(controller: this._shiftController),
                        ..._createWidgetList(_allList, _position),
                      ],
                    ))),
                  ));
            }),
        onWillPop: () async {
          Navigator.of(context).pop(this._selectItem);
          return false;
        });
  }
}
