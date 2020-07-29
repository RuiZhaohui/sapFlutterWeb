//import 'dart:io';
//
//import 'package:audioplayers/audioplayers.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:gztyre/components/ButtonBarWidget.dart';
//import 'package:gztyre/components/ButtonWidget.dart';
//import 'package:gztyre/components/TakePhotoAndVideoWidget.dart';
//import 'package:gztyre/components/ViewDialog.dart';
//import 'package:gztyre/components/VoiceWidget.dart';
//import 'package:gztyre/utils/ListController.dart';
//import 'package:gztyre/utils/screen_utils.dart';
//import 'package:video_player/video_player.dart';
//
//typedef VideoAndPicCallback(List<String> list);
//
//class TextareaWithPicAndVideoWidget extends StatefulWidget {
//  TextareaWithPicAndVideoWidget(
//      {Key key,
//      @required this.textEditingController,
//      this.placeholder,
//      this.lines,
//      this.callback,
//      @required this.listController,
//      @required this.rootContext})
//      : super(key: key);
//
//  final TextEditingController textEditingController;
//  final String placeholder;
//  final int lines;
//  final BuildContext rootContext;
//  final VideoAndPicCallback callback;
//  final ListController listController;
//
//  @override
//  State createState() {
//    return _TextareaWithPicAndVideoWidgetState();
//  }
//}
//
//class _TextareaWithPicAndVideoWidgetState
//    extends State<TextareaWithPicAndVideoWidget> {
//  VideoPlayerController _controller;
//  Future<void> _initializeVideoPlayerFuture;
//  AudioPlayer audioPlayer;
//  var icon = Icon(Icons.play_arrow);
//  var _audioPlayerStateSubscription;
//  bool _hasRecord = false;
//
//
//  startRecord(){
//    print("111开始录制");
//  }
//
//  stopRecord(String path,double audioTimeLength, bool isCancel){
//    print("结束束录制");
//    print("音频文件位置"+path);
//    print("音频录制时长"+audioTimeLength.toString());
//    if (audioTimeLength > 2.0) {
//      this.appendList(widget.listController.value, path);
//      this._hasRecord = true;
//    } else {
//      this._hasRecord = false;
//    }
//    setState(() {
//
//    });
//  }
//
//  playLocal(path) async {
//    await audioPlayer.play(path, isLocal: true);
//  }
//
//  pauseLocal(path) async {
//    await audioPlayer.pause();
//  }
//
//
////  List<String> list = [];
//
//  List<Widget> _buildPic(List list) {
//    List<Widget> imgList = [];
//    print(list);
//    for (int i = 0; i < list.length; i++) {
//      if (list[i].endsWith('mp4')) {
//        imgList.add(Padding(
//          padding: EdgeInsets.all(2),
//          child: FutureBuilder(
//            future: _initializeVideoPlayerFuture,
//            builder: (context, snapshot) {
//              if (snapshot.connectionState == ConnectionState.done) {
//                // If the VideoPlayerController has finished initialization, use
//                // the data it provides to limit the aspect ratio of the video.
//                return Stack(
//                  children: <Widget>[
//                    FittedBox(
//                      fit: BoxFit.cover,
//                      child: Container(
//                        height: ScreenUtils.screenW(context) - 20 - 4,
//                        width: ScreenUtils.screenW(context) - 20 - 4,
//                        child: VideoPlayer(_controller),
//                      ),
//                    ),
//                    Align(
//                      alignment: Alignment.center,
//                      child: FloatingActionButton(
//                        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
//                        onPressed: () {
//                          var imgs = new List();
//                          int count = 0;
//                          int position = 0;
//                          list.asMap().keys.toList().forEach((index) {
//                            if (list[index].endsWith("mp4")) {
//                              imgs.add({
//                                'key': count,
//                                'videoFile': File(list[index])
//                              });
//                              count++;
//                            } else if (list[index].endsWith("wav")) {
//                              position = index;
//                            } else {
//                              imgs.add({'key': count, 'file': File(list[index])});
//                              count++;
//                            }
//                          });
//                          Navigator.of(widget.rootContext)
//                              .push(new CupertinoPageRoute(
//                                  builder: (context) => new ViewDialog(
//                                        img: {
//                                          'key': i > position ? i-1 : i,
//                                          'videoFile': File(list[i])
//                                        },
//                                        imgs: imgs,
//                                        width:
//                                            MediaQuery.of(context).size.width,
//                                        controller: this._controller,
//                                        initializeVideoPlayerFuture:
//                                            this._initializeVideoPlayerFuture,
//                                        onlyView: false,
//                                      )))
//                              .then((index) {
//                            if (this._controller != null) {
//                              this._controller.pause();
//                            }
//                            if (index != null) {
//                              if (list[index - 1].endsWith("mp4")) {
//                                this._controller.initialize();
//                              }
//                              widget.listController.value.removeAt(index - 1);
////                              widget.callback(this.list);
//                            }
//                          });
//                        },
//                        // Display the correct icon depending on the state of the player.
//                        child: Icon(
//                          Icons.play_arrow,
//                        ),
//                      ),
//                    ),
//                  ],
//                );
//              } else {
//                // If the VideoPlayerController is still initializing, show a
//                // loading spinner.
//                return Center(child: CircularProgressIndicator());
//              }
//            },
//          ),
//        ));
//      } else if (list[i].endsWith('wav')) {
//        imgList.add(GestureDetector(
//          child: Padding(
//            padding: EdgeInsets.all(2),
//            child: Container(
//              color: Colors.grey,
//              child: icon,
//            ),
//          ),
//          onTap: () {
//            if (audioPlayer.state != AudioPlayerState.PLAYING) {
//              this.playLocal(list[i]);
//              setState(() {
////                icon = Icon(Icons.pause);
//              });
//            } else {
//              this.pauseLocal(list[i]);
//              setState(() {
////                icon = Icon(Icons.play_arrow);
//              });
//            }
//          },
//          onLongPress: () {
//            showCupertinoDialog(
//                context: context,
//                builder: (BuildContext context) {
//                  return CupertinoAlertDialog(
//                    content: Text(
//                      "是否删除语音",
//                      style: TextStyle(fontSize: 18),
//                    ),
//                    actions: <Widget>[
//                      CupertinoDialogAction(
//                        onPressed: () {
//                          Navigator.of(context).pop();
//                        },
//                        child: Text("取消"),
//                      ),
//                      CupertinoDialogAction(
//                        onPressed: () {
//                          widget.listController.value.removeAt(i);
//                          setState(() {
//                            this._hasRecord = false;
//                          });
//                          Navigator.of(context).pop();
//                        },
//                        child: Text("是"),
//                      )
//                    ],
//                  );
//                });
//          },
//        ));
//      } else {
//        imgList.add(GestureDetector(
//          child: Padding(
//            padding: EdgeInsets.all(2),
//            child: Image.file(
//              File(list[i]),
//              fit: BoxFit.cover,
//            ),
//          ),
//          onTap: () {
//            var imgs = new List();
//            int count = 0;
//            int position = 0;
//            list.asMap().keys.toList().forEach((index) {
//              if (list[index].endsWith("mp4")) {
//                imgs.add({'key': count, 'videoFile': File(list[index])});
//                count++;
//              } else if (list[index].endsWith("wav")) {
//                position = index;
//              } else {
//                imgs.add({'key': count, 'file': File(list[index])});
//                count++;
//              }
//            });
//            Navigator.of(widget.rootContext)
//                .push(new CupertinoPageRoute(
//                    builder: (context) => new ViewDialog(
//                          img: {'key': i > position ? i-1 : i, 'file': File(list[i])},
//                          imgs: imgs,
//                          width: MediaQuery.of(context).size.width,
//                          controller: this._controller,
//                          initializeVideoPlayerFuture:
//                              this._initializeVideoPlayerFuture,
//                          onlyView: false,
//                        )))
//                .then((index) {
//              if (this._controller != null) {
//                this._controller.pause();
//              }
//              if (index != null) {
//                if (list[index - 1].endsWith("mp4")) {
//                  this._controller.initialize();
//                  setState(() {
//
//                  });
//                }
//                widget.listController.value.removeAt(index - 1);
////                widget.callback(this.list);
//              }
//            });
//          },
//        ));
//      }
//    }
//    return imgList;
//  }
//
//  void appendList(List list, String path) {
//    list.add(path);
//  }
//
//  @override
//  void dispose() {
//    if (this._controller != null) this._controller.dispose();
//    this._audioPlayerStateSubscription = null;
////    widget.textEditingController.dispose();
//    super.dispose();
//  }
//
//
//  @override
//  void initState() {
//    audioPlayer = new AudioPlayer();
//    _audioPlayerStateSubscription = audioPlayer.onPlayerStateChanged.listen((s) {
//      if (s == AudioPlayerState.PLAYING) {
//        setState(() => icon = Icon(Icons.pause));
//      } else {
//        setState(() {
//          icon = Icon(Icons.play_arrow);
//        });
//      }
//    }, onError: (msg) {
//      setState(() {
//        icon = Icon(Icons.play_arrow);
//      });
//    });
//    if (widget.listController.value.length == 0) setState(() {
//      this._hasRecord = false;
//    });
//    super.initState();
//  }
//
//
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      color: Colors.white,
//      child: Padding(
//        padding: EdgeInsets.all(10),
//        child: Column(
//          children: <Widget>[
//            CupertinoTextField(
//              maxLines: widget.lines,
//              autofocus: false,
//              controller: widget.textEditingController,
//              keyboardType: TextInputType.text,
//              obscureText: false,
//              showCursor: true,
//              cursorColor: Color.fromRGBO(51, 115, 178, 1),
//              placeholder: widget.placeholder,
//              maxLength: 40,
//              placeholderStyle:
//                  TextStyle(fontSize: 14, color: Color.fromRGBO(0, 0, 0, 0.25)),
//              decoration: BoxDecoration(border: Border()),
//            ),
//            Padding(
//              padding: EdgeInsets.only(left: 10, right: 10),
//              child: GridView.count(
//                shrinkWrap: true,
//                physics: NeverScrollableScrollPhysics(),
//                crossAxisCount: 3,
//                children: <Widget>[
//                  ..._buildPic(widget.listController.value),
//                ],
//              ),
//            ),
//            ButtonBarWidget(
//              button: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Container(
//                    child: new VoiceWidget(startRecord: startRecord,stopRecord: stopRecord, hasRecord: this._hasRecord,),
//                  ),
//                  Container(
//                    child: widget.listController.value.length < 6 ? TakePhotoAndVideoWidget(
//                      canShoot: !widget.listController.value.any((item) {
//                        return item.endsWith('mp4');
//                      }),
//                      takePhotoCallback: (path) {
//                        if (path.endsWith('mp4')) {
//                          print(path);
//                          this._controller =
//                              VideoPlayerController.file(File(path));
//                          this._initializeVideoPlayerFuture =
//                              this._controller.initialize();
//                          this._controller.setLooping(true);
//                          this.appendList(widget.listController.value, path);
//                        } else {
//                          this.appendList(widget.listController.value, path);
//                        }
//                        setState(() {});
//                      },
//                    ) : Container(
//                      height: 30,
//                      child: ButtonWidget(
//                        fontSize: 16,
////                      minSize: 0.1,
//                        padding: EdgeInsets.only(left: 50, right: 50),
//                        color: Colors.blueGrey,
//                        child: Container(
//                          child: Row(
//                            children: <Widget>[
//                              Icon(Icons.add_photo_alternate, color: Colors.blueGrey,),
//                              Text("照片/视频", style: TextStyle(color: Colors.blueGrey),)
//                            ],
//                          ),
//                        ),
//                      ),
//                    ),
//                  ),
//                ],
//              ),
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}
