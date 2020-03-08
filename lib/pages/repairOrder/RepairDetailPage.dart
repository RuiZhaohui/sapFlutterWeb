
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/HttpRequestRest.dart';
import 'package:gztyre/api/model/Order.dart';
import 'package:gztyre/api/model/RepairOrder.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/components/ListTitleWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/components/ViewDialog.dart';
import 'package:gztyre/pages/repairOrder/OtherDevicePage.dart';
import 'package:gztyre/utils/screen_utils.dart';
import 'package:video_player/video_player.dart';

class RepairDetailPage extends StatefulWidget {

  RepairDetailPage({Key key, this.order}) : super(key: key);

  final Order order;

  @override
  State createState() => _RepairDetailPageState();
}

class _RepairDetailPageState extends State<RepairDetailPage> {

  bool _loading = true;
  RepairOrder _repairOrder = new RepairOrder();
  var _repairOrderFuture;

  var _getPicFuture;
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  List _imgList = [];
  String _video;
  String _addDesc;
  String _desc;
  String _audio;
  var _audioPlayerStateSubscription;


  AudioPlayer audioPlayer = new AudioPlayer();
  var icon = Icon(Icons.play_arrow);

  playNet(path) async {
    await audioPlayer.play(path);
  }

  pauseNet(path) async {
    await audioPlayer.pause();
  }

  _getPic() async {
    setState(() {
      this._loading = true;
    });
    await HttpRequestRest.getMalfunction(widget.order.AUFNR, (res) {
      if (res != null && res["pictures"] != null && res["pictures"].length > 0) {
        this._imgList = res["pictures"];
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
      if (res != null) {
        this._addDesc = res["addDesc"];
        this._desc = res["desc"];
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
                // If the VideoPlayerController has finished initialization, use
                // the data it provides to limit the aspect ratio of the video.
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
                                onlyView: false,
                              )))
                              .then((index) {
                            if (this._controller != null) {
                              this._controller.pause();
                            }
                            if (index != null) {
                              if (Global.videoType.contains(list[index - 1].split(".").last.toLowerCase())) {
                                this._controller = null;
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
              } else {
                // If the VideoPlayerController is still initializing, show a
                // loading spinner.
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
          onTap: () {
            if (audioPlayer.state != AudioPlayerState.PLAYING) {
              this.playNet(list[i]);
              setState(() {
              });
            } else {
              this.pauseNet(list[i]);
            }
          },
        ));
      } else {
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
                  this._controller = null;
                }
              }
            });
          },
        ));
      }
    }
    return imgList;
  }

  List<Widget> _buildBomInfo(RepairOrder repairOrder) {
    List<Widget> list = [];
    if (repairOrder.materielList == null) return [];
    repairOrder.materielList.forEach((item) {
      list.add(Text(item.MAKTX + "(" + item.MATNR + ")" + " x " + item.ENMNG.toString() + "  ", style: TextStyle(fontSize: 14)));
    });
    return list;
  }


  Future _repairOrderDetail(Order order) async {
    setState(() {
      this._loading = true;
    });
    return await HttpRequest.repairOrderDetail(order.AUFNR,
            (RepairOrder order) async {
          this._repairOrder = order;
          setState(() {
            this._loading = false;
          });
          return true;
//          this._getPic(order);
        }, (err) {
          setState(() {
            this._loading = false;
          });
          return false;
        });
  }


  @override
  void dispose() {
    if (this._controller != null) {
      this._controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    this._repairOrderFuture = this._repairOrderDetail(widget.order).then((val) {
      if (val) this._getPic();
    });
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
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this._repairOrderFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return new ProgressDialog(
            loading: this._loading,
            child: CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                leading: CupertinoNavigationBarBackButton(
                  onPressed: () => Navigator.pop(context),
                  color: Color.fromRGBO(94, 102, 111, 1),
                ),
                middle: Text(
                  "维修详情",
                  style: TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              child: SafeArea(
                child: ListView(
                  children: <Widget>[
                    ListTitleWidget(
                      title: "维修部件",
                    ),
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 20, bottom: 20, left: 10, right: 10),
                        child: _buildBomInfo(this._repairOrder).length == 0 ? Text(
                           "无",
                          style: TextStyle(fontSize: 14),
                        ) : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ..._buildBomInfo(this._repairOrder)
                          ],
                        ),
                      ),
                    ),
                    ListTitleWidget(
                      title: "维修描述",
                    ),
                    Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                top: 20, bottom: 20, left: 10, right: 10),
                            child: Text(
                              this._repairOrder.KTEXT_AUFNR ?? "",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              children: <Widget>[..._buildPic(this._imgList ?? List())],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTitleWidget(
                      title: "故障原因",
                    ),
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 20, bottom: 20, left: 10, right: 10),
                        child: Text(
                          this._repairOrder.KURZTEXT1?? "",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    widget.order.ILART == "N06" ? ListTitleWidget(
                      title: "",
                    ) : Container(),
                    widget.order.ILART == "N06" ? ListItemWidget(title: Text("其他设备"), onTap: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (BuildContext context) {
                            return OtherDevicePage(
                              AUFNR: this._repairOrder.AUFNR,
                            );
                          }));
                    },) : Container()
                  ],
                ),
//        child: Column(
//          children: <Widget>[
//            ListTitleWidget(title: "维修部件",)
//          ],
//        ),
              ),
            ));
      },
    );
  }
}
