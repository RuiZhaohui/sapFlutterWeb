import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/components/ButtonWidget.dart';
import 'package:gztyre/components/painter/AddPicPainter.dart';
import 'package:gztyre/components/BottomUpAction.dart';
import 'package:gztyre/components/CameraWidget.dart';
import 'package:image_picker/image_picker.dart';

typedef TakePhotoCallback(var object);
class TakePhotoAndVideoWidget extends StatefulWidget {
  TakePhotoAndVideoWidget({Key key, this.takePhotoCallback, this.canShoot}) : super(key: key);


  final TakePhotoCallback takePhotoCallback;
  final bool canShoot;

  @override
  State createState() {
    return new _TakePhotoAndVideoWidget();
  }


}

class _TakePhotoAndVideoWidget extends State<TakePhotoAndVideoWidget> {

  var cameras;
  var firstCamera;

  Future<void> initCamera() async {
    // Obtain a list of the available cameras on the device.
    this.cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    this.firstCamera = cameras.first;
  }

  Future<File> getImageFromGallery() async {
    return await ImagePicker.pickImage(source: ImageSource.gallery);
  }


  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showCupertinoDialog(
//            barrierDismissible: true,//是否点击空白区域关闭对话框,默认为true，可以关闭
            context: context,
            builder: (BuildContext context) {
              var list = List();
              list.add('拍摄');
              list.add('从相册选取');
              return SafeArea(
                child: BottomUpAction(
                  list: list,
                  onItemClickListener: (index) async {
                    switch (index) {
                      case 0:
                        print("拍照");
                        Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) {
                          return CameraWidget(camera: this.firstCamera, radius: 35, canShoot: widget.canShoot,);
                        })).then((path) {
                          widget.takePhotoCallback(path);
                        }).whenComplete(() {
                          Navigator.of(context).pop();
                        });
                        break;
                      case 2:
                        print("从相册");
//                      Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) {
//                        return ImagePicker();
//                      }))
                        this.getImageFromGallery().then((image) {
                          widget.takePhotoCallback(image.path);
                        }).whenComplete(() {
                          Navigator.of(context).pop();
                        });
                        break;
                    }
//                  Navigator.pop(context);
                  },
                ),
              );
            });
      },
      child: Container(
        height: 30,
        child: ButtonWidget(
          fontSize: 16,
//                      minSize: 0.1,
          padding: EdgeInsets.only(left: 50, right: 50),
          color: Colors.blueGrey,
          child: Container(
            child: Row(
              children: <Widget>[
                Icon(Icons.add_photo_alternate, color: Colors.blueGrey,),
                Text("照片/视频", style: TextStyle(color: Colors.blueGrey),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}