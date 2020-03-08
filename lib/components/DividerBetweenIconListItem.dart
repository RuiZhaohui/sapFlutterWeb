import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DividerBetweenIconListItem extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(width: 40, height: 1, color: Colors.white,),
        Container()
      ],
    );
  }
}