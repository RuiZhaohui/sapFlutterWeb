import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/utils/screen_utils.dart';

class SearchBar extends StatefulWidget {

  SearchBar({
    Key key,
    @required this.controller
}) : super(key: key);

  final TextEditingController controller;

  @override
  State createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(247, 247, 247, 1),
      width: ScreenUtils.screenW(context),
      height: 55,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: CupertinoTextField(
          prefix: Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Icon(CupertinoIcons.search, color: Color.fromRGBO(142, 142, 147, 1), size: 20.0,),
          ),
          showCursor: true,
          cursorColor: Color.fromRGBO(51, 115, 178, 1),
          decoration: BoxDecoration(color: Color.fromRGBO(142, 142, 147, 0.12),
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          controller: widget.controller,
          placeholder: "搜索",
          placeholderStyle: TextStyle(fontSize: 15.0, color: Color.fromRGBO(142, 142, 147, 1)),
        ),
      ),
    );
  }
}