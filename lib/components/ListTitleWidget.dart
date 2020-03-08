import 'package:flutter/cupertino.dart';

class ListTitleWidget extends StatelessWidget {
  ListTitleWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
      child: Text(this.title, style: TextStyle(color: Color.fromRGBO(142, 142, 147, 1), fontSize: 14),),
    );
  }
}