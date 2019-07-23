import 'package:oye_yaaro_pec/Provider/Firebase/firebase_storage_operations.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class S3Image extends StatefulWidget {
  final AlignmentGeometry alignment;
  final Rect centerSlice;
  final Color color;
  final BlendMode colorBlendMode;
  final bool excludeFromSemantics;
  final String filename; //url
  final FilterQuality filterQuality;
  final BoxFit fit;
  final bool gaplessPlayback;
  final double height;
  final Key key;
  final bool matchTextDirection;
  final Widget placeholder;
  final ImageRepeat repeat;
  final String semanticLabel;
  final double width;
  final int timestamp;
  final int posterPhone;

  S3Image({
    @required this.filename, //postUrl
    @required this.timestamp,
    @required this.posterPhone,
    this.alignment,
    this.centerSlice,
    this.color,
    this.colorBlendMode,
    this.excludeFromSemantics,
    this.filterQuality,
    this.fit,
    this.gaplessPlayback,
    this.height,
    this.key,
    this.matchTextDirection,
    this.placeholder,
    this.repeat,
    this.semanticLabel,
    this.width,
  });

  _S3Image createState() => _S3Image();
}

class _S3Image extends State<S3Image> {
  bool downloading;
  File file;
  Widget s3image;

  @override
  initState() {
    print('in S3Image.dart...................');
    downloading = true;
    _getImage();
    super.initState();
  }

  @override
  dispose() {
    file = null;
    s3image = null;
    super.dispose();
  }

  _getImage() async {
    Directory extDir = await getExternalStorageDirectory();
    File downloadedFile = File(extDir.path +
        "/OyeYaaro/.posts/" +
        widget.timestamp.toString() +
        ".jpg");
    bool fileExist = await downloadedFile.exists();

    if (fileExist) {
      print('${widget.timestamp.toString()}.jpg file exist');
      file = downloadedFile;
    } else {
      // print('${widget.timestamp.toString()}.jpg file not exist');
      bool downloaded = await storage.downloadImage(
          //can pass direcr downloaded file path instead of bool
          widget.filename,
          widget.timestamp.toString(),
          feedsImage: true);
      print('storage.downloadImage() response: $downloaded');
      file = File(extDir.path +
          "/OyeYaaro/.posts/" +
          widget.timestamp.toString() +
          ".jpg");
    }

    s3image = Container(
      decoration: BoxDecoration(
        // border: new Border.
        // all(color: Colors.grey),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
        image: DecorationImage(fit: BoxFit.cover, image: FileImage(file)),
        // ),
      ),
      // child:
      // Image.file(file)
      // Text('${file.path}')
      /*  Image(
          alignment:
              widget.alignment != null ? widget.alignment : Alignment.center,
          centerSlice: widget.centerSlice,
          color: widget.color,
          colorBlendMode: widget.colorBlendMode,
          excludeFromSemantics: widget.excludeFromSemantics != null
              ? widget.excludeFromSemantics
              : false,
          filterQuality: widget.filterQuality != null
              ? widget.filterQuality
              : FilterQuality.low,
          fit: BoxFit.cover,
          // widget.fit,
          gaplessPlayback:
              widget.gaplessPlayback != null ? widget.gaplessPlayback : false,
          height: widget.height,
          image: FileImage(file), //
          key: widget.key,
          matchTextDirection: widget.matchTextDirection != null
              ? widget.matchTextDirection
              : false,
          repeat: widget.repeat != null ? widget.repeat : ImageRepeat.noRepeat,
          semanticLabel: widget.semanticLabel,
          width: widget.width,
        ) */
    );

    if (this.mounted == true)
      setState(() {
        downloading = false;
      });
  }

  Widget build(BuildContext context) {
    return downloading
        ? widget.placeholder == null ? Container(child: Text('null'),) : widget.placeholder
        : s3image;
  }
}
