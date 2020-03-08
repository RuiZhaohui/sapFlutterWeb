import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  Badge({Key key, @required this.child, @required this.color, this.fill = true, this.size = 20}) : super(key: key);

  final Widget child;
  final Color color;
  final bool fill;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: this.child,
      ),
      height: this.size,
      constraints: BoxConstraints(
        minWidth: this.size,
      ),
      decoration: BoxDecoration(
        color: this.fill ? this.color : Colors.white,
        borderRadius: BorderRadius.circular(this.size),
        border: Border.all(color: this.color),
      ),
    );
  }
}