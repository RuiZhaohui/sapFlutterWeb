import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/components/ButtonBarWidget.dart';
import 'package:gztyre/components/ButtonWidget.dart';

class DisplayPictureWidget extends StatelessWidget {
  final String imagePath;

  const DisplayPictureWidget({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
//          F(
            Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
//          ),
          Align(
              alignment: Alignment.bottomRight,
              child: ButtonBarWidget(
                color: Color.fromRGBO(0,0,0,0),
                button: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ButtonWidget(
                      child: Text('取消', style: TextStyle(color: Color.fromRGBO(163, 6, 6, 1)),),
                      color: Color.fromRGBO(163, 6, 6, 1),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    ButtonWidget(
                      child: Text('确定', style: TextStyle(color: Color.fromRGBO(76, 129, 235, 1)),),
                      color: Color.fromRGBO(76, 129, 235, 1),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    )
                  ],
                ),
              ))
        ],
      );
  }
}
