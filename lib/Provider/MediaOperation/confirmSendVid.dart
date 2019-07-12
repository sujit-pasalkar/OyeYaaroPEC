import 'dart:io';
import 'package:oye_yaaro_pec/Components/videoPlayer.dart';
import 'package:flutter/material.dart';

class ConfirmSendVid extends StatefulWidget {
  final File img;
  ConfirmSendVid({Key key, @required this.img}) : super(key: key);
  @override
  _ConfirmSendVidState createState() => _ConfirmSendVidState();
}

class _ConfirmSendVidState extends State<ConfirmSendVid> {
  @override
  void initState() {
    print('media path is: ${widget.img.path}');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        // appBar: AppBar(
        //   backgroundColor: Colors.black.withOpacity(0.5),
        // ),
        body: Container(
            alignment: Alignment.center,
            child: PlayVideo(videoUrl: widget.img.path)),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xffb00bae3),
          child: Icon(
            Icons.check,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop('ok');
          },
        ));
  }
}
