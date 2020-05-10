import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextareaWidget extends StatefulWidget {
  TextareaWidget({Key key, @required this.textEditingController, this.placeholder, this.lines, this.type = TextInputType.text}) : super(key: key);

  final TextEditingController textEditingController;
  final String placeholder;
  final int lines;
  final TextInputType type;

  @override
  State createState() {
    return _TextareaWidgetState();
  }
}

class _TextareaWidgetState extends State<TextareaWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            CupertinoTextField(
              maxLines: widget.lines,
              autofocus: false,
              controller: widget.textEditingController,
              keyboardType: widget.type,
              obscureText: false,
              showCursor: true,
              cursorColor: Color.fromRGBO(51, 115, 178, 1),
              placeholder: widget.placeholder,
              placeholderStyle: TextStyle(fontSize: 14, color: Color.fromRGBO(0, 0, 0, 0.25)),
              decoration: BoxDecoration(
                  border: Border()
              ),
            )
          ],
        ),
      ),
    );
  }
}