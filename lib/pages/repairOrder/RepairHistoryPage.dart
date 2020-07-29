import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/model/Order.dart';
import 'package:gztyre/api/model/RepairHistory.dart';
import 'package:gztyre/api/model/RepairOrder.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/components/painter/TimeLinePainter.dart';
import 'package:gztyre/pages/userCenter/UserInfoPage.dart';

class RepairHistoryPage extends StatefulWidget {
  RepairHistoryPage({Key key, this.order}) : super(key: key);
  final Order order;
  @override
  State createState() {
    return _RepairHistoryPageState();
  }
}

class _RepairHistoryPageState extends State<RepairHistoryPage> {
  int num =0;

  bool _loading = false;
  List<RepairHistory> _repairOrderList = new List();
  var _repairOrderHistoryFuture;

  Future _repairOrderHistory(Order order) async {
    setState(() {
      this._loading = true;
    });
    return await HttpRequest.repairOrderHistory(order.AUFNR,
            (List<RepairHistory> list) async {
          this._repairOrderList = list;
          this.num = list.length;
          setState(() {
            this._loading = false;
//        return true;
          });
//          this._getPic(order);
        }, (err) {
          print(err);
          setState(() {
            this._loading = false;
//        return false;
          });
        });
  }

  List<Widget> _buildList() {
    List<Widget> list = [];
    for (int i = 0; i < num; i++) {
      list.add(Padding(
        padding: EdgeInsets.only(bottom: 15, top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            this._repairOrderList[i].ERDAT == "0000-00-00" ? Container() : Text("${this._repairOrderList[i].ERDAT.substring(2, 10)} ${this._repairOrderList[i].ERTIM.substring(0, 5)}", textAlign: TextAlign.left,),
            this._repairOrderList[i].PERNR != '' ? GestureDetector(
              onTap: () async {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (BuildContext context) {
                  return UserInfoPage(
                    PERNR: this._repairOrderList[i].PERNR,
                  );
                }));
              },
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  this._repairOrderList[i].KTEXT,
                  style: TextStyle(color: Color.fromRGBO(36, 98, 204, 1)),
                ),
              ),
            ) : Container(),
            Text("${this._repairOrderList[i].APPSTATUS}"),
            this._repairOrderList[i].PERNR1 != '' ? GestureDetector(
              onTap: () async {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (BuildContext context) {
                  return UserInfoPage(
                    PERNR: this._repairOrderList[i].PERNR1,
                  );
                }));
              },
              child: Text(
                this._repairOrderList[i].KTEXT2,
                style: TextStyle(color: Color.fromRGBO(36, 98, 204, 1)),
              ),
            ) : Container(),
            this._repairOrderList[i].MAKTX != '' ? Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  '${this._repairOrderList[i].MAKTX} ${this._repairOrderList[i].ENMG}',
                ),
              ),
            ) :
            Container(),
          ],
        ),
      ));
    }
    return list;
  }


  @override
  void initState() {
    super.initState();
    this._repairOrderHistoryFuture = this._repairOrderHistory(widget.order);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: this._repairOrderHistoryFuture,
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
                    "维修记录",
                    style: TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                child: SafeArea(
                    child: this._repairOrderList.length > 0 ? Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: ListView(
//                      children: <Widget>[
//                        Row(
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          children: <Widget>[
//                            Padding(
//                              padding: EdgeInsets.only(
//                                top: 22,
//                                left: 20,
//                              ),
//                              child: Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[..._buildList()],
//                              ),
//                            ),
//                          ],
//                        )
//                      ],
                      ),
                    ) : Container()),
              ));
        });
  }
}
