import 'package:flutter/cupertino.dart';

class TextButtonWidget extends StatefulWidget {
  TextButtonWidget({Key key, this.onTap, @required this.text}) : super(key: key);

  final VoidCallback onTap;
  final String text;

  @override
  State createState() {
    return new _TextButtonWidgetState();
  }
}

class _TextButtonWidgetState extends State<TextButtonWidget> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Text(widget.text, style: TextStyle(color: Color.fromRGBO(0, 122, 255, 1), fontSize: 17),),
    );
  }
}