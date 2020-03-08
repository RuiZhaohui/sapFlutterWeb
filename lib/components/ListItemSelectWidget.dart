import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListItemSelectWidget extends StatelessWidget {

  ListItemSelectWidget({Key key, @required this.title, this.height, @required this.item, this.selectedItem, this.selectedItemList, this.count}) : super(key: key);

  final Text title;
  final double height;
  final item;
  final selectedItem;
  final List selectedItemList;
  final int count;

  final Color _color = Color.fromRGBO(255, 255, 255, 1);

  @override
  Widget build(BuildContext context) {
    if (this.selectedItemList == null) {
      return new Container(
        decoration: BoxDecoration(color: this.item == this.selectedItem ? Color.fromRGBO(205, 205, 205, 1) : _color),
        height: this.height ?? 50.0,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: this.title,
              ),
            ),
            Row(
              children: <Widget>[
                this.count == null ? Container() : Text(this.count.toString()),
                this.item == this.selectedItem ? Icon(CupertinoIcons.check_mark, color: Color.fromRGBO(0, 122, 255, 1),) : Icon(CupertinoIcons.check_mark, color: Color.fromRGBO(0, 0, 0, 0),)
              ],
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      );
    } else {
      return new Container(
        decoration: BoxDecoration(color: this.selectedItemList.contains(this.item) ? Color.fromRGBO(205, 205, 205, 1) : _color),
        height: this.height ?? 50.0,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: this.title,
              ),
            ),
            Row(
              children: <Widget>[
                this.count == null ? Container() : Text(this.count.toString()),
                this.selectedItemList.contains(this.item) ? Icon(CupertinoIcons.check_mark, color: Color.fromRGBO(0, 122, 255, 1),) : Icon(CupertinoIcons.check_mark, color: Color.fromRGBO(0, 0, 0, 0),)
              ],
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      );
    }
  }


}
