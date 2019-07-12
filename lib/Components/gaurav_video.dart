// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:system_shortcuts/system_shortcuts.dart';
// // import '../providers/media-provider.dart';
// // import 'image_view.dart';

// // enum SourceType { Network, Device }

// class PlayVideo extends StatefulWidget {
//   final String videoPath,videoThumb;
//   PlayVideo({Key key, @required this.videoPath,@required this.videoThumb})
//       : super(key: key);

//   @override
//   _PlayScreenState createState() => _PlayScreenState();
// }

// class _PlayScreenState extends State<PlayVideo> {
//   Image image;
//   File videoFile;

//   VideoPlayerController _controller;
//   VoidCallback listener;
//   dynamic imageListner;

//   double aspectRatio;

//   bool inView = true;

//   double percentage = 0.0;
//   bool showThumb = false;
//   bool showVideo = false;
//   bool showingControls = false;
//   bool first = true;
//   bool fullScreen = false;
//   bool stop = true;

//   double volume = 0.0;

//   @override
//   void initState() {
//     aspectRatio = 1.0;
//     listener = () {
//       if (_controller.value.initialized) {
//         setState(() {
//           showVideo = true;
//         });
//         if (first) {
//           first = false;
//           volume = _controller.value.volume;
//         }
//       }
//       // if (_controller.value.position.inSeconds ==
//       //         _controller.value.duration.inSeconds &&
//       //     stop) {
//       //   stop = false;
//       //   Navigator.of(context).pop();
//       // }
//     };
//     imageListner = (ImageInfo info, bool _) {
//       aspectRatio = info.image.width / info.image.height;
//       setState(() {
//         if (aspectRatio > 1.0) {
//           _fullScreen();
//         }
//       });
//       image.image.resolve(ImageConfiguration()).removeListener(imageListner);
//     };
//     initialize();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     SystemShortcuts.orientPortrait();
//     _controller.dispose();
//     super.dispose();
//   }

//   initialize() async {
//     try {
//         File imageFile = File(widget.videoThumb);
//         // await mediaProvider.getImage(
//         //     widget.mediaUrl.replaceAll(".mp4", ".jpg"), (onProgress) {});
//         image = Image.file(
//           imageFile,
//           fit: BoxFit.fill,
//         );
//         image.image.resolve((ImageConfiguration())).addListener(imageListner);
//         setState(() {
//           showThumb = true;
//         });
//         videoFile = File(widget.videoPath);
//         // await mediaProvider.getVideo(widget.mediaUrl, (onProgress) {
//         //   setState(() {
//         //     percentage = onProgress.percentage;
//         //   });
//         // });
//       if (inView) {
//           _controller = VideoPlayerController.file(videoFile)
//             ..initialize()
//             ..setLooping(false)
//             ..addListener(listener)
//             ..play();
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: showVideo
//             ? Stack(
//                 children: <Widget>[
//                   Center(
//                     child: AspectRatio(
//                       aspectRatio: _controller.value.aspectRatio,
//                       child: VideoPlayer(_controller),
//                     ),
//                   ),
//                   Column(
//                     children: <Widget>[
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: showControl,
//                           onHorizontalDragUpdate: _onSeekTo,
//                           onVerticalDragUpdate: _onValumeChange,
//                         ),
//                       ),
//                       showingControls
//                           ? Container(
//                               padding: EdgeInsets.all(2.5),
//                               color: Colors.black.withOpacity(0.35),
//                               child: Row(
//                                 children: <Widget>[
//                                   IconButton(
//                                     icon: _controller.value.isPlaying
//                                         ? Icon(
//                                             Icons.pause,
//                                             color: Colors.white,
//                                             size: 35.0,
//                                           )
//                                         : Icon(
//                                             Icons.play_arrow,
//                                             color: Colors.white,
//                                             size: 35.0,
//                                           ),
//                                     onPressed: _play,
//                                   ),
//                                   Expanded(
//                                     child: Container(
//                                       margin: EdgeInsets.only(
//                                           left: 2.5, right: 2.5),
//                                       child: Slider(
//                                         value: _controller
//                                             .value.position.inMilliseconds
//                                             .toDouble(),
//                                         onChanged: (v) {},
//                                         onChangeEnd: _seekTo,
//                                         min: 0.0,
//                                         max: _controller
//                                             .value.duration.inMilliseconds
//                                             .toDouble(),
//                                       ),
//                                     ),
//                                   ),
//                                   fullScreen
//                                       ? Text(
//                                           _controller.value.position
//                                                   .toString()
//                                                   .split(".")
//                                                   .first +
//                                               "/" +
//                                               _controller.value.duration
//                                                   .toString()
//                                                   .split(".")
//                                                   .first,
//                                           style: TextStyle(color: Colors.white),
//                                         )
//                                       : SizedBox(),
//                                   IconButton(
//                                     icon: fullScreen
//                                         ? Icon(
//                                             Icons.fullscreen,
//                                             color: Colors.white,
//                                             size: 35.0,
//                                           )
//                                         : Icon(
//                                             Icons.fullscreen_exit,
//                                             color: Colors.white,
//                                             size: 35.0,
//                                           ),
//                                     onPressed: _fullScreen,
//                                   ),
//                                 ],
//                               ),
//                             )
//                           : SizedBox(),
//                     ],
//                   )
//                 ],
//               )
//             : showThumb
//                 ? Stack(
//                     children: <Widget>[
//                       Center(
//                         child: AspectRatio(
//                           aspectRatio: aspectRatio,
//                           child: image,
//                         ),
//                       ),
//                       percentage > 0.0
//                           ? Container(
//                               color: Colors.black.withOpacity(0.35),
//                               alignment: Alignment.center,
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: <Widget>[
//                                   CircularProgressIndicator(
//                                     strokeWidth: 10.0,
//                                     value: percentage / 100,
//                                   ),
//                                   SizedBox(
//                                     height: 20.0,
//                                   ),
//                                   Text(
//                                     "loading: $percentage%",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12.0,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           : SizedBox(),
//                     ],
//                   )
//                 : Center(
//                     child: CircularProgressIndicator(),
//                   ),
//       ),
//     );
//   }

//   showControl() async {
//     setState(() {
//       showingControls = !showingControls;
//     });
//     if (showingControls) {
//       await Future.delayed(Duration(seconds: 2));
//       setState(() {
//         showingControls = false;
//       });
//     }
//   }

//   _play() {
//     setState(() {
//       _controller.value.isPlaying ? _controller.pause() : _controller.play();
//     });
//   }

//   _fullScreen() {
//     fullScreen = !fullScreen;
//     if (fullScreen) {
//       SystemShortcuts.orientLandscape();
//     } else {
//       SystemShortcuts.orientPortrait();
//     }
//   }

//   _seekTo(double seek) {
//     _controller.seekTo(Duration(milliseconds: seek.toInt()));
//   }

//   _onSeekTo(DragUpdateDetails d) {
//     int seekTo =
//         _controller.value.position.inSeconds - (d.primaryDelta * -1 ~/ 5);
//     if (seekTo >= 0) if (seekTo <= _controller.value.duration.inSeconds)
//       _controller.seekTo(Duration(seconds: seekTo));
//   }

//   _onValumeChange(DragUpdateDetails d) async {
//     if ((d.delta.dy / 3) * -1 > 0) {
//       SystemShortcuts.volUp();
//     } else {
//       SystemShortcuts.volDown();
//     }
//     volume += (d.delta.dy / 3) * -1;
//     if (volume < 0.0) volume = 0.0;
//     if (volume > 1.0) volume = 1.0;
//     _controller.setVolume(volume);
//   }
// }
