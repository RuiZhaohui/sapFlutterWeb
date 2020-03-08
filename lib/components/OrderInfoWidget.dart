import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/model/Order.dart';
import 'package:gztyre/api/model/RepairOrder.dart';
import 'package:gztyre/api/model/ReportOrder.dart';

class OrderInfoWidget extends StatelessWidget {
  OrderInfoWidget({Key key, this.order, this.reportOrder, this.repairOrder}): super(key: key);

  final ReportOrder reportOrder;
  final RepairOrder repairOrder;
  final Order order;

//  DateTime _reportTime;
//  DateTime _acceptTime;
//  DateTime _completeTime;
  String _accept = '无';
  String _complete = '无';

//  DateTime _getDateTime(String date, String time) {
//    int year = int.parse(date.substring(0, 4));
//    int month = int.parse(date.substring(5, 7));
//    int day = int.parse(date.substring(8, 10));
//    int hour = int.parse(time.substring(0, 2));
//    int minute = int.parse(time.substring(3, 5));
//    int second = int.parse(time.substring(6, 8));
//    return DateTime(year, month, day, hour, minute, second);
//  }

  String _getTime(String date, String time) {
    return "${date.substring(2, 10)} ${time.substring(0, 5)}";
  }

  @override
  Widget build(BuildContext context) {

//    if (order.ERDAT == "0000-00-00") {
//      this._reportTime = null;
//    } else {
//      this._reportTime =
//          this._getDateTime(order.ERDAT, order.ERTIM);
//    }
    if (order.ERDAT2 == "0000-00-00") {
      this._accept = "无";
    } else {
      this._accept =
          this._getTime(order.ERDAT2, order.ERTIM2);
    }
    if (order.ERDAT3 == "0000-00-00" ||
        order.ERDAT3 + order.ERTIM3 ==
            order.ERDAT2 + order.ERTIM2) {
      this._complete = "无";
    } else {
      this._complete =
          this._getTime(order.ERDAT3, order.ERTIM3);
    }


    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10, top: 6, bottom: 6, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: order.QMNUM != "" && order.QMNUM != null ? Text("报修单号：${order.QMNUM}", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.45),
                    fontSize: 12,),) : Container(),
                ),
                Expanded(
                  child: order.AUFNR != "" && order.AUFNR != null ? Text("维修单号：${order.AUFNR}", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.45),
                    fontSize: 12,),) : Container(),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: Text('接   单   人：${order.PERNR1 == '' || order.PERNR1 == null ? '无' : order.PERNR1}', style: TextStyle(fontSize: 14),),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: Text('接单时间：$_accept', style: TextStyle(fontSize: 14),),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: Text('功能位置：${order.PLTXT ?? '无'}', style: TextStyle(fontSize: 14),),
                      ),
                    ],
                  ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only( right: 10, top: 10),
                      child: Text('工单进度：${order.ASTTX ?? '无'}', style: TextStyle(fontSize: 14),),
                    ),
                    Padding(
                      padding: EdgeInsets.only( right: 10, top: 10),
                      child: Text('完工时间：$_complete', style: TextStyle(fontSize: 14),),
                    ),
                    Padding(
                      padding: EdgeInsets.only( right: 10, top: 10),
                      child: Text('是否停机：${reportOrder.MSAUS == true ? '是' : "否"}', style: TextStyle(fontSize: 14),),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            child: Text('故障设备：${order.EQKTX ?? '无'}', style: TextStyle(fontSize: 14),),
          )
        ],
      ),
    );
  }
}
