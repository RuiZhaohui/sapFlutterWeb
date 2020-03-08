import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/components/DisplayPictureWidget.dart';
import 'package:gztyre/components/VideoPlayWidget.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CameraWidget extends StatefulWidget {
  final CameraDescription camera;
  final double radius;
  final bool canShoot;

  const CameraWidget({
    Key key,
    @required this.radius,
    @required this.camera,
    this.canShoot
  }) : super(key: key);

  @override
  TCameraWidgetState createState() => TCameraWidgetState();
}

class TCameraWidgetState extends State<CameraWidget> with SingleTickerProviderStateMixin {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  String path;
  bool longPress = false;
  AnimationController _animationController;
  Animation<double> _animation;
  String _tips = "长按录制视频，点击按钮拍照";


  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    this._animationController =
    AnimationController(vsync: this, duration: Duration(seconds: 15))
      ..addListener(() {
        setState(() {});
      });
    this._animation = Tween(begin: 0.0, end: 1.0).animate(this._animationController);
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    this._animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
//      navigationBar: CupertinoNavigationBar(
//        middle: Text("Take a picture"),
//      ),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      child: Stack(
        children: <Widget>[
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicator.
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(this._tips, style: TextStyle(color: Colors.grey, fontSize: 14),),
                Padding(
                  padding: EdgeInsets.all(30),
                  child: Container(
                    width: widget.radius * 2,
                    height: widget.radius * 2,
                    child: FloatingActionButton(
                      backgroundColor: Color.fromRGBO(218, 211, 200, 1),
                      child: GestureDetector(
                        child: this.longPress ? Container(
                          height: (widget.radius + 20) * 2,
                          width: (widget.radius + 20) * 2,
                          child: CircularProgressIndicator(backgroundColor: Color.fromRGBO(0, 0, 0, 0), valueColor: AlwaysStoppedAnimation(Colors.blue), strokeWidth: 10, value: this._animation.value,) ,
                        ) : null,
                        onLongPress: () async {
                          if (!widget.canShoot) return;
                          this.longPress = true;
                          this._animationController.forward();
                          setState(() {
                            this._tips = '';
                          });
                          try {
                            print('长按');
                            // Ensure that the camera is initialized.
                            await _initializeControllerFuture;

                            // Construct the path where the image should be saved using the
                            // pattern package.
                            this.path = join(
                              // Store the picture in the temp directory.
                              // Find the temp directory using the `path_provider` plugin.
                              (await getTemporaryDirectory()).path,
                              '${DateTime.now()}.mp4',
                            );

                            // Attempt to take a picture and log where it's been saved.
                            await _controller.startVideoRecording(path);

                            // If the picture was taken, display it on a new screen.
//              await Navigator.push(
//                context,
//                MaterialPageRoute(
//                  builder: (context) => VideoPlayerScreen(videoPath: path),
//                ),
//              );
                          } catch (e) {
                            // If an error occurs, log the error to the console.
                            print(e);
                          }
                        },
                        onLongPressEnd: (details) async {
                          if (!widget.canShoot) return;
                          this.longPress = false;
                          this._animationController.reverse(from: 0);
                          this.setState(() {
                            this._tips = "长按录制视频，点击按钮拍照";
                          });
                          print("长按结束");
                          try {
                            await _controller.stopVideoRecording();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoPlayWidget(videoPath: path),
                              ),
                            ).then((value) {
                              if (value) {
                                Navigator.of(context).pop(path);
                              }
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        onTap: () async {
                          // Take the Picture in a try / catch block. If anything goes wrong,
                          // catch the error.
                          try {
                            // Ensure that the camera is initialized.
                            await _initializeControllerFuture;

                            // Construct the path where the image should be saved using the
                            // pattern package.
                            final path = join(
                              // Store the picture in the temp directory.
                              // Find the temp directory using the `path_provider` plugin.
                              (await getTemporaryDirectory()).path,
                              '${DateTime.now()}.png',
                            );

                            // Attempt to take a picture and log where it's been saved.
                            await _controller.takePicture(path);

                            // If the picture was taken, display it on a new screen.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DisplayPictureWidget(imagePath: path),
                              ),
                            ).then((value) {
                              if (value) {
                                Navigator.of(context).pop(path);
                              }
                            });
                          } catch (e) {
                            // If an error occurs, log the error to the console.
                            print(e);
                          }
                        },
                      ),
                      // Provide an onPressed callback.
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}