import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

class ImageViewer extends StatefulWidget {
  final String imageUrl;

  ImageViewer({@required this.imageUrl});

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  void initState() {
    super.initState();
    print(widget.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return
        Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xffb4fcce0).withOpacity(0.6),
            flexibleSpace: FlexAppbar(),
          ),
          body:
        // Positioned(
        //   left: 10,
        //   top: 10,
        //   child: 
        //   AppBar()
          // IconButton(
          //     icon: Icon(
          //   Icons.arrow_back,
          //   color: Colors.white,
          //   size: 50,
          // ),
          // onPressed: (){
          //   Navigator.pop(context);
          // },
          // ),
        // ),
        Container(
          child: Container(
            child: PhotoView(
              heroTag: widget.imageUrl,
              imageProvider: FileImage(File(widget.imageUrl)),
              minScale: PhotoViewComputedScale.contained * 1,
              maxScale: 4.0,
            ),
          ),
          ),
    );
  }
}
