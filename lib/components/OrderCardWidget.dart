import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/model/Order.dart';

class OrderCardWidget extends StatefulWidget {
  OrderCardWidget(
      {Key key,
      @required this.title,
      @required this.level,
      @required this.status,
      @required this.description,
      @required this.position,
      @required this.device,
      @required this.isStop,
      @required this.order,
        @required this.color,
      this.onTap})
      : super(key: key);

  final String color;
  final VoidCallback onTap;
  final String title;
  final String level;
  final String status;
  final String description;
  final String position;
  final String device;
  final bool isStop;
  final Order order;

  @override
  State createState() => OrderCardWidgetState();
}

class OrderCardWidgetState extends State<OrderCardWidget> {
  DateTime _reportTime;
  DateTime _acceptTime;
  DateTime _completeTime;
  String report = '无';
  String wait = '无';

  DateTime _getDateTime(String date, String time) {
    int year = int.parse(date.substring(0, 4));
    int month = int.parse(date.substring(5, 7));
    int day = int.parse(date.substring(8, 10));
    int hour = int.parse(time.substring(0, 2));
    int minute = int.parse(time.substring(3, 5));
    int second = int.parse(time.substring(6, 8));
    return DateTime(year, month, day, hour, minute, second);
  }

  String _getTime(DateTime start, DateTime end) {
    Duration duration = end.difference(start);
    int sum = duration.inMinutes;
    int minutes = sum % 60;
    sum = sum ~/ 60;
    int hours = sum % 24;
    sum = sum ~/ 24;
    return "$sum天$hours小时$minutes分";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                  offset: Offset.zero,
                  spreadRadius: 1,
                  color: Color.fromRGBO(225, 225, 225, 1))
            ],
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10, top: 6, bottom: 6, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text("维修类型：${widget.order.ILATX != "" && widget.order.ILATX != null ? widget.order.ILATX : "未知"}", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.45),
                        fontSize: 12,),),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, top: 6, bottom: 6, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: widget.order.QMNUM != "" && widget.order.QMNUM != null ? Text("报修单号：${widget.order.QMNUM}", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.45),
                        fontSize: 12,),) : Container(),
                    ),
                    Expanded(
                      child: widget.order.AUFNR != "" && widget.order.AUFNR != null ? Text("维修单号：${widget.order.AUFNR}", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.45),
                        fontSize: 12,),) : Container(),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
//            Expanded(
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          widget.level != "" ? Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Text(
                              widget.level,
                              style: TextStyle(
                                  color: (widget.color == "A")
                                      ? Colors.red
                                      : (widget.color == "B"
                                      ? Colors.yellow : (
                                      widget.color == "C" ? Colors.blueAccent : (
                                          widget.color == "D" ? Colors.green : Colors.black
                                      )
                                  )),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ) : Container(),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                  color: (widget.color == "A")
                                      ? Colors.red
                                      : (widget.color == "B"
                                          ? Colors.yellow : (
                                  widget.color == "C" ? Colors.blueAccent : (
                                  widget.color == "D" ? Colors.green : Colors.black
                                  )
                                  )),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  widget.status,
                                  style: TextStyle(
                                      color: (widget.status == "新建" ||
                                              widget.status == "新工单")
                                          ? Color.fromRGBO(218, 4, 27, 1)
                                          : (widget.status == "维修中"
                                              ? Color.fromRGBO(80, 140, 100, 1)
                                              : Color.fromRGBO(36, 84, 154, 1)),
                                      fontSize: 14),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 10, left: 10),
                          child: Text(
                            widget.description,
                            style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 0.65),
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1,
              ),
              Container(
                decoration: BoxDecoration(
//                  color: Color.fromRGBO(225, 225, 225, 1),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5))),
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
//                      flex: 3,
                      child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "位置：",
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 0.45),
                                    fontSize: 12),
                              ),
                              Expanded(
                                child: Text(
                                  widget.position,
                                  style: TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          )),
                    ),
                    Expanded(
//                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "设备：",
                              style: TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 0.45),
                                  fontSize: 12),
                            ),
                            Expanded(
                              child: Text(
                                widget.device,
                                style: TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "接单：",
                                    style: TextStyle(
                                        color: Color.fromRGBO(0, 0, 0, 0.45),
                                        fontSize: 12),
                                  ),
                                  Expanded(
                                    child: Text(
                                      wait,
                                      style: TextStyle(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "报修：",
                                    style: TextStyle(
                                        color: Color.fromRGBO(0, 0, 0, 0.45),
                                        fontSize: 12),
                                  ),
                                  Expanded(
                                    child: Text(
                                      report,
                                      style: TextStyle(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    if (widget.order.ERDAT == "0000-00-00") {
      this._reportTime = null;
    } else {
      this._reportTime =
          this._getDateTime(widget.order.ERDAT, widget.order.ERTIM);
    }
    if (widget.order.ERDAT2 == "0000-00-00") {
      this._acceptTime = null;
    } else {
      this._acceptTime =
          this._getDateTime(widget.order.ERDAT2, widget.order.ERTIM2);
    }
    if (widget.order.ERDAT3 == "0000-00-00" ||
        widget.order.ERDAT3 + widget.order.ERTIM3 ==
            widget.order.ERDAT2 + widget.order.ERTIM2) {
      this._completeTime = null;
    } else {
      this._completeTime =
          this._getDateTime(widget.order.ERDAT3, widget.order.ERTIM3);
    }
    if (this._reportTime != null && this._completeTime == null) {
      this.report = this._getTime(this._reportTime, DateTime.now());
    }  else if (this._reportTime != null && this._completeTime != null) {
      this.wait = this._getTime(this._acceptTime, this._completeTime);
    }
    if (this._acceptTime != null && this._completeTime != null) {
      this.wait = this._getTime(this._reportTime, this._completeTime);
    } else if (this._acceptTime != null && this._completeTime == null) {
      this.wait = this._getTime(this._acceptTime, DateTime.now());
    }
    super.initState();
  }
}
