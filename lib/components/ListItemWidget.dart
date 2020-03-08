import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListItemWidget extends StatefulWidget {

  ListItemWidget({Key key, this.onTap, @required this.title, this.height, this.count, this.actionArea = const Icon(CupertinoIcons.right_chevron, color: Color.fromRGBO(94, 102, 111, 1),)}) : super(key: key);

  final VoidCallback onTap;
  final Widget title;
  final double height;
  final int count;
  final Widget actionArea;

  @override
  State createState() {
    return _ListItemWidgetState();
  }


}

class _ListItemWidgetState extends State<ListItemWidget> {

  Color _color = Color.fromRGBO(255, 255, 255, 1);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: widget.onTap != null ?  (tapDownDetails) {
        this._color = Color.fromRGBO(142, 142, 147, 0.12);
        setState(() {});
      } : (tapDownDetails){},
      onTapUp: widget.onTap != null ? (tapUpDetails) {
        this._color = Color.fromRGBO(255, 255, 255, 1);
        setState(() {});
      } : (tapUpDetails){},
      onTapCancel: widget.onTap != null ? () {
        this._color = Color.fromRGBO(255, 255, 255, 1);
        setState(() {});
      } : (){},
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(color: _color),
        constraints: BoxConstraints(minHeight: widget.height ?? 50.0),
//        height: widget.height ?? 50.0,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: widget.title,
              ),
            ),
            Row(
              children: <Widget>[
                widget.count == null ? Container() : Text(widget.count.toString()),
                widget.actionArea
              ],
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}