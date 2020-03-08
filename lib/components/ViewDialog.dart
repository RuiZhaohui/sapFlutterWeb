//图片查看
import 'package:flutter/material.dart';
import 'package:gztyre/utils/screen_utils.dart';
import 'package:video_player/video_player.dart';

/*
 * imgs 格式[{url:'',file:File}]
 * img 当前点击进入的图片
 * width 屏幕宽度
 */

class ViewDialog extends StatefulWidget {
  ViewDialog({Key key, this.img, this.imgs, this.width, this.onlyView, this.controller, this.initializeVideoPlayerFuture})
      : super(key: key);
  final img;
  final imgs;
  final width;
  final bool onlyView;
  final VideoPlayerController controller;

  final Future<void> initializeVideoPlayerFuture;

  @override
  _PageStatus createState() => _PageStatus();
}

class _PageStatus extends State<ViewDialog> {
  var image;
  var w;
  var index = 1;
  var _scrollController;
  var down = 0.0; //触开始的时候的left
  var half = false; //是否超过一半

  last() {
    if (1 == index) {
    } else {
      setState(() {
        image = widget.imgs[index - 2];
        index = index - 1;
      });
    }
  }

  next() {
    if (widget.imgs.length == index) {
    } else {
      setState(() {
        image = widget.imgs[index];
        index = index + 1;
      });
    }
  }

  delete(int i) {
    Navigator.of(context).pop(i);
  }

  @override
  void initState() {
    //页面初始化
    super.initState();

//    if (widget.controller != null) {
//      this._initializeVideoPlayerFuture = widget.controller.initialize();
//      widget.controller.setLooping(false);
//    }

    var n = 0;
    var nn;
    widget.imgs.forEach((i) {
      n = n + 1;
      if (i['key'] == widget.img['key']) {
        nn = n;
      }
    });
    print(nn);
    if (nn > 1) {
      print(widget.width);
      _scrollController =
          ScrollController(initialScrollOffset: widget.width * (nn - 1));
    } else {
      _scrollController = ScrollController(
        initialScrollOffset: 0,
      );
    }
    setState(() {
      image = widget.img;
      index = nn;
    });
  }

  nextPage(w) {
    setState(() {
      index = index + 1;
      _scrollController.animateTo(
        (index - 1) * w,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    });
  }

  lastPage(w) {
    setState(() {
      index = index - 1;
      _scrollController.animateTo(
        (index - 1) * w,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    });
  }

  moveEnd(e, w, l) {
    var end = e.primaryVelocity;
    if (end > 10 && index > 1) {
      lastPage(w);
    } else if (end < -10 && index < l) {
      nextPage(w);
    } else if (half == true) {
      if (down > w / 2 && index < l) {
        //右边开始滑动超过一半,则下一张
        nextPage(w);
      } else if (down < w / 2 && index > 1) {
        lastPage(w);
      } else {
        _scrollController.animateTo(
          (index - 1) * w,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeIn,
        );
      }
    } else {
      _scrollController.animateTo(
        (index - 1) * w,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    }
  }

  imgMove(e, w, l) {
    //down 为起点
    var left = e.position.dx;
    var now = (index - 1) * w;
    var move = left - down; //移动距离
    if (left - down > w / 2 || down - left > w / 2) {
      half = true;
    } else {
      half = false;
    }
    _scrollController.jumpTo(now - move);
  }

  Widget list(w, l) {
    List<Widget> array = [];
    widget.imgs.forEach((i) {
      array.add(
        Listener(
          onPointerMove: (e) {
            imgMove(e, w, l);
          },
          onPointerDown: (e) {
            down = e.position.dx;
          },
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop(null);
            },
            onHorizontalDragEnd: (e) {
              moveEnd(e, w, l);
            },
            child: Container(
              width: w,
              child: i['url'] != null
                  ? Image.network(i['url'])
                  : (i['file'] != null
                      ? Image.file(i['file'])
                      : (i['asset'] != null ? Image.asset(i['asset']) :
              FutureBuilder(
                future: widget.initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the VideoPlayerController has finished initialization, use
                    // the data it provides to limit the aspect ratio of the video.
                    return Stack(
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.cover,
                          child: Container(
                            height: ScreenUtils.screenH(context),
                            width: ScreenUtils.screenW(context),
                            child: VideoPlayer(widget.controller),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: FloatingActionButton(
                            backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                            onPressed: () {
                              print(widget.controller.value.isPlaying);
                              // Wrap the play or pause in a call to `setState`. This ensures the
                              // correct icon is shown.
                              setState(() {
                                // If the video is playing, pause it.
                                if (widget.controller.value.isPlaying) {
                                  widget.controller.pause();
                                } else {
                                  // If the video is paused, play it.
                                  widget.controller.play();
                                }
                              });
                            },
                            // Display the correct icon depending on the state of the player.
                            child: Icon(
                              widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
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
              ))),
            ),
          ),
        ),
      );
    });
    return ListView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      children: array,
    );
  }


//  @override
//  void dispose() {
//    widget.controller.dispose();
//  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    var l = widget.imgs.length;
    return SafeArea(
      child: Container(
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            list(w, l),
            Positioned(
              top: 20,
              child: Container(
                  alignment: Alignment.center,
                  width: w,
                  child: Text('$index/$l',
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        shadows: [
                          Shadow(color: Colors.black, offset: Offset(1, 1)),
                        ],
                      ))),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                  alignment: Alignment.topLeft,
                  width: w,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(null);
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white,),
                  ),
              ),
            ),
            widget.onlyView
                ? Container()
                : Positioned(
              top: 20,
              right: 20,
              child: Container(
                alignment: Alignment.centerLeft,
                width: 20,
                child: GestureDetector(
                  onTap: () {
                    delete(this.index);
                  },
                  child: Icon(Icons.delete, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
