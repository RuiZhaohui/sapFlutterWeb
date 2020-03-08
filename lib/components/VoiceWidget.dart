import 'package:flutter/material.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:gztyre/components/ButtonWidget.dart';

typedef startRecord = Future Function();
typedef stopRecord = Future Function();

class VoiceWidget extends StatefulWidget {
  final Function startRecord;
  final Function stopRecord;
  final bool hasRecord;

  @override
  _VoiceWidgetState createState() => _VoiceWidgetState();

  /// startRecord 开始录制回调  stopRecord回调
  VoiceWidget({Key key, this.startRecord, this.stopRecord, this.hasRecord}) : super(key: key);
}

class _VoiceWidgetState extends State<VoiceWidget> {
  double starty = 0.0;
  double offset = 0.0;
  bool isUp = false;
  bool isPress = false;
  String textShow = "按住说话";
  String toastShow = "长按录音删除";
  String voiceIco = "images/voice_volume_1.png";
  double time = 0.0;

  ///默认隐藏状态
//  bool voiceState = true;
  OverlayEntry overlayEntry;
  FlutterPluginRecord recordPlugin;

  @override
  void initState() {
    super.initState();
    recordPlugin = new FlutterPluginRecord();


    _init();

    ///初始化方法的监听
    recordPlugin.responseFromInit.listen((data) {
      if (data) {
        print("初始化成功");
      } else {
        print("初始化失败");
      }
    });

    /// 开始录制或结束录制的监听
    recordPlugin.response.listen((data) {
      if (data.msg == "onStop") {
        ///结束录制时会返回录制文件的地址方便上传服务器
        print("onStop  " + data.path);
        time = data.audioTimeLength;
        if (!this.isUp) widget.stopRecord(data.path,data.audioTimeLength, this.isUp);
      } else if (data.msg == "onStart") {
        print("onStart --");
        time = 0.0;
        widget.startRecord();
      }
    });

    ///录制过程监听录制的声音的大小 方便做语音动画显示图片的样式
    recordPlugin.responseFromAmplitude.listen((data) {
      var voiceData = double.parse(data.msg);
      setState(() {
        if (voiceData > 0 && voiceData < 0.1) {
          voiceIco = "images/voice_volume_2.png";
        } else if (voiceData > 0.2 && voiceData < 0.3) {
          voiceIco = "images/voice_volume_3.png";
        } else if (voiceData > 0.3 && voiceData < 0.4) {
          voiceIco = "images/voice_volume_4.png";
        } else if (voiceData > 0.4 && voiceData < 0.5) {
          voiceIco = "images/voice_volume_5.png";
        } else if (voiceData > 0.5 && voiceData < 0.6) {
          voiceIco = "images/voice_volume_6.png";
        } else if (voiceData > 0.6 && voiceData < 0.7) {
          voiceIco = "images/voice_volume_7.png";
        } else if (voiceData > 0.7 && voiceData < 1) {
          voiceIco = "images/voice_volume_7.png";
        } else {
          voiceIco = "images/voice_volume_1.png";
        }
        if (overlayEntry != null) {
          overlayEntry.markNeedsBuild();
        }
      });
    });
  }

  ///显示录音悬浮布局
  buildOverLayView(BuildContext context) {
    if (overlayEntry == null) {
      overlayEntry = new OverlayEntry(builder: (content) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.5 - 80,
          left: MediaQuery.of(context).size.width * 0.5 - 80,
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Opacity(
                opacity: 0.8,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Color(0xff77797A),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: new Image.asset(
                          voiceIco,
                          width: 100,
                          height: 100,
                          package: 'flutter_plugin_record',
                        ),
                      ),
                      Container(
//                      padding: EdgeInsets.only(right: 20, left: 20, top: 0),
                        child: Text(
                          toastShow,
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
      Overlay.of(context).insert(overlayEntry);
    }
  }

  showVoiceView() {
    setState(() {
      textShow = "松开结束";
      toastShow = "长按录音删除";
//      voiceState = false;
    });
    buildOverLayView(context);
    start();
  }

  hideVoiceView() {
    setState(() {
      textShow = "按住说话";
//      voiceState = true;
    });
    stop();
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
    if (isUp) {
      print("取消发送");
    } else {
      if (time < 3) {
        print("进行发送");
      }
    }
  }

  moveVoiceView() {
    // print(offset - start);
    setState(() {
      isUp = starty - offset > 60 ? true : false;
      if (isUp) {
        textShow = "长按录音删除";
        toastShow = textShow;
      }
    });
  }

  ///初始化语音录制的方法
  void _init() async {
    recordPlugin.init();
  }

  ///开始语音录制的方法
  void start() async {
    recordPlugin.start();
  }

  ///停止语音录制的方法
  void stop() {
    recordPlugin.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: !widget.hasRecord ? GestureDetector(
        onVerticalDragStart: (details) {
          if (isPress) {
            starty = details.globalPosition.dy;
          }
        },
        onVerticalDragEnd: (details) {
          if (isPress) {
            hideVoiceView();
          }
        },
        onVerticalDragUpdate: (details) {
          if (isPress) {
            offset = details.globalPosition.dy;
            moveVoiceView();
          }
        },
        onLongPressStart: (details) {
          isPress = true;
          this.isUp = false;
          print("1");
          showVoiceView();
        },
        onLongPressEnd: (details) {
          isPress = false;
          hideVoiceView();
        },
        child: Container(
          height: 30,
          child: ButtonWidget(
            fontSize: 16,
//                      minSize: 0.1,
            padding: EdgeInsets.only(left: 50, right: 50),
            color: Colors.green,
            child: Container(
              child: Row(
                children: <Widget>[
                  Icon(Icons.volume_up, color: Colors.green,),
                  Text(textShow, style: TextStyle(color: Colors.green),)
                ],
              ),
            ),
          ),
        ),
      ) : Container(
        height: 30,
        child: ButtonWidget(
          fontSize: 16,
//                      minSize: 0.1,
          padding: EdgeInsets.only(left: 50, right: 50),
          color: Colors.green,
          child: Container(
            child: Row(
              children: <Widget>[
                Icon(Icons.add_photo_alternate, color: Colors.green,),
                Text(textShow, style: TextStyle(color: Colors.green),)
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (recordPlugin != null) {
      recordPlugin.dispose();
    }
    super.dispose();
  }
}