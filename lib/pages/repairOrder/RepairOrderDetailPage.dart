
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequestRest.dart';
import 'package:gztyre/api/model/ReportOrder.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/components/ViewDialog.dart';
import 'package:gztyre/utils/screen_utils.dart';
import 'package:video_player/video_player.dart';

class RepairOrderDetailPage extends StatefulWidget {
  RepairOrderDetailPage({Key key, this.reportOrder}) : super(key: key);
  final ReportOrder reportOrder;

  @override
  State createState() => _RepairOrderDetailPageState();
}

class _RepairOrderDetailPageState extends State<RepairOrderDetailPage> {
  Future<void> _getPicFuture;
  bool _loading = false;
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  List _imgList = [];
  String _video;
  String _audio;
  var _audioPlayerStateSubscription;


  AudioPlayer audioPlayer = new AudioPlayer();
  var icon = Icon(Icons.play_arrow);

  playNet(path) async {
    await audioPlayer.play(path, isLocal: false);
  }

  pauseNet(path) async {
    await audioPlayer.pause();
  }

  _getPic() async {
    setState(() {
      this._loading = true;
    });
    return await HttpRequestRest.getMalfunction(widget.reportOrder.QMNUM, (res) {
      if (res != null && res["pictures"] != null && res["pictures"].length > 0) {
        this._imgList = res["pictures"].where((item) {
          return item != '' && item != null;
        }).toList();
      }
      if (res != null && res["video"] != null && res["video"].length > 0) {
        this._video = res["video"];
        this._imgList.add(this._video);
        this._controller = VideoPlayerController.network(this._video);
        this._initializeVideoPlayerFuture = this._controller.initialize();
      }
      if (res != null && res["audio"] != null && res["audio"].length > 0) {
        this._audio = res["audio"];
        this._imgList.add(this._audio);
      }
      setState(() {
        this._loading = false;
      });
    }, (err) {
      setState(() {
        this._loading = false;
      });
    });
  }

  List<Widget> _buildPic(List list) {
    List<Widget> imgList = [];
    print(list);
    for (int i = 0; i < list.length; i++) {
      if (Global.videoType.contains(list[i].split(".").last.toLowerCase())) {
        imgList.add(Padding(
          padding: EdgeInsets.all(2),
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: <Widget>[
                    FittedBox(
                      fit: BoxFit.cover,
                      child: Container(
                        height: ScreenUtils.screenW(context) - 20 - 4,
                        width: ScreenUtils.screenW(context) - 20 - 4,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: FloatingActionButton(
                        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                        onPressed: () {
                          var imgs = new List();
                          int count = 0;
                          int position = 0;
                          list.asMap().keys.toList().forEach((index) {
                            if (Global.videoType.contains(list[index].split(".").last.toLowerCase())) {
                              imgs.add({'key': count, 'videoFile': list[index]});
                              count++;
                            } else if (Global.audioType.contains(list[index].split(".").last.toLowerCase())) {
                              position = index;
                            } else {
                              imgs.add({'key': count, 'url': list[index]});
                              count++;
                            }
                          });
                          Navigator.of(context)
                              .push(new CupertinoPageRoute(
                              builder: (context) => new ViewDialog(
                                img: {'key': i > position ? i-1 : i, 'videoFile': list[i]},
                                imgs: imgs,
                                width:
                                MediaQuery.of(context).size.width,
                                controller: this._controller,
                                initializeVideoPlayerFuture:
                                this._initializeVideoPlayerFuture,
                                onlyView: true,
                              )))
                              .then((index) {
                            if (this._controller != null) {
                              this._controller.pause();
                            }
                            if (index != null) {
                              if (Global.videoType.contains(list[index - 1].split(".").last.toLowerCase())) {
                                this._controller.initialize();
                              }
//                              widget.callback(this.list);
                            }
                          });
                        },
                        // Display the correct icon depending on the state of the player.
                        child: Icon(
                          Icons.play_arrow,
                        ),
                      ),
                    ),
                  ],
                );
              }
              else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ));
      }  else if (Global.audioType.contains(list[i].split(".").last.toLowerCase())) {
        imgList.add(GestureDetector(
          child: Padding(
            padding: EdgeInsets.all(2),
            child: Container(
              color: Colors.grey,
              child: icon,
            ),
          ),
          onTap: () async {
            if (audioPlayer.state != AudioPlayerState.PLAYING) {
              await this.playNet(list[i]);
              setState(() {
              });
            } else {
              await this.pauseNet(list[i]);
            }
          },
        ));
      } else if (Global.picType.contains(list[i].split(".").last.toLowerCase())) {
        imgList.add(GestureDetector(
          child: Padding(
            padding: EdgeInsets.all(2),
            child: Image.network(
              list[i],
              fit: BoxFit.cover,
            ),
          ),
          onTap: () {
            var imgs = new List();
            int count = 0;
            int position = 0;
            list.asMap().keys.toList().forEach((index) {
              if (Global.videoType.contains(list[index].split(".").last.toLowerCase())) {
                imgs.add({'key': count, 'videoFile': list[index]});
                count++;
              } else if (Global.audioType.contains(list[index].split(".").last.toLowerCase())) {
                position = index;
              } else {
                imgs.add({'key': count, 'url': list[index]});
                count++;
              }
            });
            Navigator.of(context)
                .push(new CupertinoPageRoute(
                builder: (context) => new ViewDialog(
                  img: {'key': i > position ? i-1 : i, 'url': list[i]},
                  imgs: imgs,
                  width: MediaQuery.of(context).size.width,
                  controller: this._controller,
                  initializeVideoPlayerFuture:
                  this._initializeVideoPlayerFuture,
                  onlyView: true,
                )))
                .then((index) {
              if (this._controller != null) {
                this._controller.pause();
              }
              if (index != null) {
                if (Global.videoType.contains(list[index - 1].split(".").last.toLowerCase())) {
                  this._controller.initialize();
                }
              }
            });
          },
        ));
      }
    }
    return imgList;
  }

  @override
  void initState() {
    this._getPicFuture = this._getPic();
    _audioPlayerStateSubscription = audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => icon = Icon(Icons.pause));
      } else {
        setState(() {
          icon = Icon(Icons.play_arrow);
        });
      }
    }, onError: (msg) {
      setState(() {
        icon = Icon(Icons.play_arrow);
      });
    });
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
    if (this._controller != null) {
      this._controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: this._getPicFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return ProgressDialog(
              loading: this._loading,
              child: CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  leading: CupertinoNavigationBarBackButton(
                    onPressed: () => Navigator.pop(context),
                    color: Color.fromRGBO(94, 102, 111, 1),
                  ),
                  middle: Text(
                    "工单详情",
                    style: TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                backgroundColor: Colors.white,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 30, bottom: 20, left: 10, right: 10),
                        child: Text(
                          widget.reportOrder.FETXT,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            children: <Widget>[
                              ..._buildPic(this._imgList ?? List()),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ));
        });
  }
}
