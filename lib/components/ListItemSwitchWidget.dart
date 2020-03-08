import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListItemSwitchWidget extends StatefulWidget {

  ListItemSwitchWidget({Key key, @required this.onChanged, @required this.isStop, @required this.title, this.height}) : super(key: key);

  final ValueChanged<bool> onChanged;
  final Widget title;
  final double height;
  final bool isStop;

  @override
  State createState() {
    return ListItemSwitchWidgetState();
  }


}

class ListItemSwitchWidgetState extends State<ListItemSwitchWidget> {

  Color _color = Color.fromRGBO(255, 255, 255, 1);

  @override
  Widget build(BuildContext context) {
    return new Container(
        decoration: BoxDecoration(color: _color),
        height: widget.height ?? 50.0,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: widget.title,
              ),
            ),
            CupertinoSwitch(value: widget.isStop, onChanged: widget.onChanged),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      );
  }
}