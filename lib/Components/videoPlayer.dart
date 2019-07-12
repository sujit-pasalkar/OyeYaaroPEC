import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class PlayVideo extends StatefulWidget {
  final String videoUrl;
  // final int type;
  PlayVideo({Key key, this.videoUrl/* ,this.type */}) : super(key: key);

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayVideo> {
  VideoPlayerController _controller;
  ChewieController _chewieController;
  VoidCallback listener;
  double aspect = 1.0;

  bool showVideo = false;


  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  initialize() async {
    File file = File(widget.videoUrl);
      _controller = VideoPlayerController.file(file);

      _controller.initialize().then((onValue) {
        aspect = _controller.value.aspectRatio;
        _chewieController = ChewieController(
          videoPlayerController: _controller,
          aspectRatio: aspect,
          autoPlay: false,
          looping: false,
        );

        _controller.addListener(() {
          if (_controller.value.position.inMilliseconds >=
              _controller.value.duration.inMilliseconds) {
          }
        });

        setState(() {
          showVideo = true;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title:Text(''),backgroundColor: Colors.black.withOpacity(0.5)),
      body: Center(
        child: showVideo
            ? Chewie(
                controller: _chewieController,
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
