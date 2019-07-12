import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/material.dart';

class ConfirmSendImg extends StatefulWidget {
  final File img;
  ConfirmSendImg({Key key, @required this.img}) : super(key: key);
  @override
  _ConfirmSendImgState createState() => _ConfirmSendImgState();
}

class _ConfirmSendImgState extends State<ConfirmSendImg> {

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
      appBar: AppBar(backgroundColor: Colors.black.withOpacity(0.5)),
      body: Container(
        alignment: Alignment.center,
        child: PhotoView(
          heroTag: widget.img.path,
          imageProvider: FileImage(File(widget.img.path)),
          minScale: PhotoViewComputedScale.contained * 1,
          maxScale: 4.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xffb00bae3),
          child: Icon(
            Icons.check,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop('ok');
          },
        )
    );
  }
}

// we can make this one file for both showing img and video by checking path(is .jpg / is .mp4)
// but problem is we need to check all type(extensions) of media like .png, .gpeg, .mpe3 etc
// that's why right now i'm creating separate files for showing img and video.