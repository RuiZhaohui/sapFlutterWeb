import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/components/ButtonBarWidget.dart';
import 'package:gztyre/components/ButtonWidget.dart';
import 'package:gztyre/utils/screen_utils.dart';
import 'package:video_player/video_player.dart';

class VideoPlayWidget extends StatefulWidget {
  VideoPlayWidget({Key key, this.videoPath}) : super(key: key);

  final String videoPath;

  @override
  _VideoPlayWidgetState createState() => _VideoPlayWidgetState();
}

class _VideoPlayWidgetState extends State<VideoPlayWidget> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.file(File(widget.videoPath));

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(true);

    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    if (this._controller != null) _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the VideoPlayerController has finished initialization, use
                // the data it provides to limit the aspect ratio of the video.
                return FittedBox(
                  fit: BoxFit.cover,
                  child: Container(
                    height: ScreenUtils.screenH(context),
                    width: ScreenUtils.screenW(context),
                    child: VideoPlayer(_controller),
                  ),
//                  child: AspectRatio(
//                    aspectRatio: _controller.value.aspectRatio,
//                    // Use the VideoPlayer widget to display the video.
//                    child: VideoPlayer(_controller),
//                  ),
                );
              } else {
                // If the VideoPlayerController is still initializing, show a
                // loading spinner.
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Align(
            alignment: Alignment.center,
            child: FloatingActionButton(
              backgroundColor: Color.fromRGBO(0, 0, 0, 0),
              onPressed: () {
                // Wrap the play or pause in a call to `setState`. This ensures the
                // correct icon is shown.
                setState(() {
                  // If the video is playing, pause it.
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    // If the video is paused, play it.
                    _controller.play();
                  }
                });
              },
              // Display the correct icon depending on the state of the player.
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: ButtonBarWidget(
                color: Color.fromRGBO(0, 0, 0, 0),
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
