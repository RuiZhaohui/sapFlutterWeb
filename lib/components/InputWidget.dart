import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputWidget extends StatefulWidget {

  InputWidget({
    Key key,
    this.controller,
    this.prefixText,
    this.placeholderText,
    this.keyboardType,
    this.obscureText = false,
    this.prifixMode
  }) : assert(controller != null),
  assert(placeholderText != null),
//  assert(prefixText != null),
  assert(keyboardType != null),super(key: key);

  final TextEditingController controller;

  final String prefixText;

  final String placeholderText;

  final TextInputType keyboardType;

  final bool obscureText;

  final OverlayVisibilityMode prifixMode;


  @override
  _InputWidgetState createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 20.0),
      child: CupertinoTextField(
        autofocus: false,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        showCursor: true,
        cursorColor: Color.fromRGBO(51, 115, 178, 1),
        prefixMode: widget.prifixMode == null ? OverlayVisibilityMode.always : widget.prifixMode,
        prefix: widget.prefixText != null ? Padding(
          padding: EdgeInsets.only(left: 20, right: 40),
          child: Text(
            widget.prefixText,
            style: TextStyle(fontSize: 20),
          ),
        ) : null,
        placeholder: widget.placeholderText,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.3, style: BorderStyle.solid)
            )
        ),
      ),
    );
  }
}