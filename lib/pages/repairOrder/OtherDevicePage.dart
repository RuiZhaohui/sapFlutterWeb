import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/model/Device.dart';
import 'package:gztyre/api/model/Order.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';

class OtherDevicePage extends StatefulWidget {
  OtherDevicePage({Key key,@required this.AUFNR}) : super(key: key);
  final String AUFNR;

  @override
  State createState() => _OtherDevicePageState();


}

class _OtherDevicePageState extends State<OtherDevicePage> {
  bool _loading = false;

  var _otherDeviceFuture;
  List<Device> _list = [];

  Future _otherDevice(String AUFNR) async {
    setState(() {
      this._loading = true;
    });
    return await HttpRequest.otherDevice(AUFNR,
            (List<Device> list) async {
          this._list = list;
          setState(() {
            this._loading = false;
          });
          return true;
//          this._getPic(order);
        }, (err) {
          setState(() {
            this._loading = false;
          });
          return false;
        });
  }

  List<Widget> buildList(List<Device> list) {
    List<Widget> widgetList = new List();
    list.forEach((item) {
      widgetList.add(
        ListItemWidget(
          title: Text(item.deviceName,),
          actionArea: Container(),
        ),
      );
      widgetList.add(Divider(height: 1,));
    });
    if (widgetList.length > 0) widgetList.removeLast();
    return widgetList;
  }


  @override
  void initState() {
    super.initState();
    this._otherDeviceFuture = this._otherDevice(widget.AUFNR);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: this._otherDeviceFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
      return new ProgressDialog(
          loading: this._loading,
          child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              leading: CupertinoNavigationBarBackButton(
                onPressed: () => Navigator.pop(context),
                color: Color.fromRGBO(94, 102, 111, 1),
              ),
              middle: Text(
                "其他设备",
                style: TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            child: SafeArea(
              child: ListView(
                children: <Widget>[
                  ...buildList(this._list)
                ],
              ),
            ),
          ));
    },);
  }
}