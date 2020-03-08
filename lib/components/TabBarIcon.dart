import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabBarIcon extends StatelessWidget {

  TabBarIcon({
    Key key,
    this.image,
    this.title,
    this.isActive = false
  }) : assert(image != null),
  assert(title != null),
  super(key: key);

  final AssetImage image;
  final String title;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ImageIcon(
              image,
              color: isActive ? Colors.blue : Colors.grey,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12.0, color: isActive ? Colors.blue : Colors.grey,),
          )
        ],
      ),
    );
  }
}