import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ButtonBarWidget.dart';
import 'package:gztyre/components/ButtonWidget.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/components/TakePhotoAndVideoWidget.dart';
import 'package:gztyre/components/ViewDialog.dart';
import 'package:gztyre/components/VoiceWidget.dart';
import 'package:gztyre/utils/ListController.dart';
import 'package:gztyre/utils/screen_utils.dart';
import 'package:video_player/video_player.dart';
import 'dart:html' as html;

typedef VideoAndPicCallback(List<String> list);

class TextareaWithPicAndVideoForWebWidget extends StatefulWidget {
  TextareaWithPicAndVideoForWebWidget(
      {Key key,
        @required this.textEditingController,
        this.placeholder,
        this.lines,
        this.callback,
        @required this.listController,
        @required this.rootContext})
      : super(key: key);

  final TextEditingController textEditingController;
  final String placeholder;
  final int lines;
  final BuildContext rootContext;
  final VideoAndPicCallback callback;
  final ListController listController;

  @override
  State createState() {
    return _TextareaWithPicAndVideoForWebWidgetState();
  }
}

class _TextareaWithPicAndVideoForWebWidgetState
    extends State<TextareaWithPicAndVideoForWebWidget> {
  var icon = Icon(Icons.play_arrow);
  bool _hasRecord = false;


  _selectFile() {
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = false;
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      var fileItem = UploadFileItem(files[0]);
      if (!(Global.videoType.contains(fileItem.file.name.split(".").last.toLowerCase()) ||
          Global.audioType.contains(fileItem.file.name.split(".").last.toLowerCase()) ||
              Global.picType.contains(fileItem.file.name.split(".").last.toLowerCase()))) {
        showCupertinoDialog(
            context: widget.rootContext,
            builder:
                (BuildContext context) {
              return CupertinoAlertDialog(
                content: Text(
                  "文件格式不正确",
                  style: TextStyle(
                      fontSize: 18),
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(
                          context)
                          .pop();
                    },
                    child: Text("好"),
                  ),
                ],
              );
            });
        setState(() {
        });
      } else if (widget.listController.value.length >= 9) {
        showCupertinoDialog(
            context: widget.rootContext,
            builder:
                (BuildContext context) {
              return CupertinoAlertDialog(
                content: Text(
                  "超过上传文件上限",
                  style: TextStyle(
                      fontSize: 18),
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(
                          context)
                          .pop();
                    },
                    child: Text("好"),
                  ),
                ],
              );
            });
        setState(() {
        });
      }
      else if ((Global.videoType.contains(fileItem.file.name.split(".").last.toLowerCase()) &&
      !widget.listController.value.every((item) => !Global.videoType.contains(item.file.name.split(".").last.toLowerCase()))) ||
          (Global.audioType.contains(fileItem.file.name.split(".").last.toLowerCase()) &&
              !widget.listController.value.every((item) => !Global.audioType.contains(item.file.name.split(".").last.toLowerCase())))
      ) {
        showCupertinoDialog(
            context: widget.rootContext,
            builder:
                (BuildContext context) {
              return CupertinoAlertDialog(
                content: Text(
                  "最多一条视频与音频",
                  style: TextStyle(
                      fontSize: 18),
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(
                          context)
                          .pop();
                    },
                    child: Text("好"),
                  ),
                ],
              );
            });
        setState(() {

        });
      } else {
        setState(() {
          widget.listController.value.add(fileItem);
          print(widget.listController.value);
          print(fileItem.file.type);
        });
      }
    });
  }

  List<Widget> _buildFileList(List list) {
    List<Widget> fileList = [];
    print(list);
    fileList = list.map((item) {
      return Container(
        color: Colors.grey,
        child: ListItemWidget(
          title: Text(item.file.name, style: TextStyle(color: Colors.lightBlueAccent),),
          actionArea: GestureDetector(
            child: Icon(Icons.delete, color: Colors.redAccent,),
            onTap: () {
              setState(() {
                list.remove(item);
              });
            },
          ),
        ),
      );
    }).toList();
    return fileList;
  }

  void appendList(List list, String path) {
    list.add(path);
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  void initState() {
    if (widget.listController.value.length == 0) setState(() {
      this._hasRecord = false;
    });
    super.initState();
  }



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
              keyboardType: TextInputType.text,
              obscureText: false,
              showCursor: true,
              cursorColor: Color.fromRGBO(51, 115, 178, 1),
              placeholder: widget.placeholder,
              maxLength: 40,
              placeholderStyle:
              TextStyle(fontSize: 14, color: Color.fromRGBO(0, 0, 0, 0.25)),
              decoration: BoxDecoration(border: Border()),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  ..._buildFileList(widget.listController.value)
                ],
              ),
            ),
            Container(
                    width: ScreenUtils.screenW(context),
                      child: ButtonWidget(
                          padding: EdgeInsets.only(left: 0, right: 0),
                          child: Text('选择文件',
                              style: TextStyle(color: Color.fromRGBO(40, 180, 110, 1))),
                          color: Color.fromRGBO(40, 180, 110, 1),
                          onPressed: () async {
                            _selectFile();
                          }),
                    ),
          ],
        ),
      ),
    );
  }
}



enum FileStatus {
  normal,
  uploading,
  success,
  fail,
}

class UploadFileItem {
  html.File file;
  FileStatus fileStatus;
  double progress = 0.0;

  UploadFileItem(this.file) {
    fileStatus = FileStatus.normal;
  }
}