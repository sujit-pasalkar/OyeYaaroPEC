import 'dart:io';
import 'dart:ui';
import 'package:oye_yaaro_pec/Components/videoPlayer.dart';
import 'package:oye_yaaro_pec/Provider/ChatService/common.dart';
import 'package:oye_yaaro_pec/Provider/Firebase/firebase_storage_operations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class GChatVideo extends StatefulWidget {
  final Map<String, dynamic> snap;
  final double width;
  GChatVideo({Key key, @required this.snap, @required this.width})
      : super(key: key);

  @override
  _ChatVideoState createState() => _ChatVideoState();
}

class _ChatVideoState extends State<GChatVideo> {
  Directory extDir;
  bool isVidDownloaded = false, downloading = false, isThumbDownloaded = false;

  @override
  void initState() {
    super.initState();
    getDir();
  }

  getDir() async {
    extDir = await getExternalStorageDirectory();
    vidDownloaded();
  }

  @override
  Widget build(BuildContext context) {
    return isVidDownloaded
        ?
        //Yes downloaded
        GestureDetector(
            onLongPress: () {
              // adddeleteMsgIdx(
              //     index, document['timestamp'], document['type']);
              print('longpress');
            },
            onTap: () {
              // audioPlayer.stop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayVideo(
                        videoUrl: extDir.path +
                            "/OyeYaaro/Media/Vid/.${widget.snap['chatId']}/${widget.snap['timestamp'].toString()}.mp4",
                      ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FutureBuilder<String>(
                  future: Common.getTime(int.parse(widget.snap['timestamp'])),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Text(
                            DateFormat('dd MMM kk:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(widget.snap['timestamp']))),
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0,
                                fontStyle: FontStyle.normal));
                      case ConnectionState.active:
                      case ConnectionState.waiting:
                        return Text(
                            DateFormat('dd MMM kk:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(widget.snap['timestamp']))),
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0,
                                fontStyle: FontStyle.normal));
                      case ConnectionState.done:
                        if (snapshot.hasError)
                          return Text(
                              DateFormat('dd MMM kk:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(widget.snap['timestamp']))),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10.0,
                                  fontStyle: FontStyle.normal));
                        return Text(
                          snapshot.data,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                              fontStyle: FontStyle.normal),
                        );
                    }
                    return Text(
                        DateFormat('dd MMM kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(widget.snap['timestamp']))),
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                            fontStyle: FontStyle.normal)); // unreachable
                  },
                ),
                Stack(
                  children: <Widget>[
                    Container(
                      width: (widget.width / 2) - 10,
                      height: (widget.width / 2) + 50,
                      margin: EdgeInsets.fromLTRB(2.0, 1.0, 2.0, 15.0),
                      decoration: BoxDecoration(
                        border: new Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(25.0),
                        color: Colors.white,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(File(extDir.path +
                              "/OyeYaaro/Media/Thumbs/.${widget.snap['chatId']}/${widget.snap['timestamp'].toString()}.jpg")),
                        ),
                      ),
                    ),
                    Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: 0,
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.grey[300],
                          size: 60,
                        )),
                  ],
                )
              ],
            ),
          )
        :
        // not downloaded
        GestureDetector(
            onLongPress: () async {
              // audioPlayer.stop();
              // adddeleteMsgIdx(
              //     index, document['timestamp'], document['type']);
              print('longpress');
              File f = new File(extDir.path +
                  "/OyeYaaro/Media/Thumbs/.${widget.snap['chatId']}/${widget.snap['timestamp'].toString()}.jpg");
              bool exist = await f.exists();
              print('f:${f.path}');
              print('is exist:$exist');
              int len = f.lengthSync();
              print(len);
            },
            onTap: isThumbDownloaded
                ? () {
                    //download video
                    print(widget.snap['mediaUrl']);
                    setState(() {
                      downloading = true;
                    });
                    downloadVid(
                        widget.snap['mediaUrl'],
                        widget.snap['thumbUrl'],
                        widget.snap['timestamp'].toString());
                  }
                : null,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FutureBuilder<String>(
                    future: Common.getTime(int.parse(widget.snap['timestamp'])),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Text(
                              DateFormat('dd MMM kk:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(widget.snap['timestamp']))),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10.0,
                                  fontStyle: FontStyle.normal));
                        case ConnectionState.active:
                        case ConnectionState.waiting:
                          return Text(
                              DateFormat('dd MMM kk:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(widget.snap['timestamp']))),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10.0,
                                  fontStyle: FontStyle.normal));
                        case ConnectionState.done:
                          if (snapshot.hasError)
                            return Text(
                                DateFormat('dd MMM kk:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(widget.snap['timestamp']))),
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10.0,
                                    fontStyle: FontStyle.normal));
                          return Text(
                            snapshot.data,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0,
                                fontStyle: FontStyle.normal),
                          );
                      }
                      return Text(
                          DateFormat('dd MMM kk:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(widget.snap['timestamp']))),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                              fontStyle: FontStyle.normal)); // unreachable
                    },
                  ),
                  Container(
                    width: (widget.width / 2) - 10,
                    height: (widget.width / 2) + 50,
                    margin: const EdgeInsets.fromLTRB(2.0, 1.0, 2.0, 15.0),
                    decoration: isThumbDownloaded
                        ? BoxDecoration(
                            border: new Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(25.0),
                            color: Colors.white,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(File(extDir.path +
                                  "/OyeYaaro/Media/Thumbs/.${widget.snap['chatId']}/${widget.snap['timestamp'].toString()}.jpg")),
                            ),
                          )
                        : BoxDecoration(
                            border: new Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(25.0),
                            color: Colors.white,
                          ),
                    child: isThumbDownloaded
                        ? Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 5.0,
                                      sigmaY: 5.0,
                                    ),
                                    child: Container(
                                        alignment: Alignment.center,
                                        width: (widget.width / 2) - 10,
                                        height: (widget.width / 2) + 50,
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.grey[300],
                                          size: 60,
                                        )),
                                  ),
                                ),
                              ),
                              Positioned(
                                  left: 5,
                                  bottom: 5,
                                  child: Container(
                                    padding: EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.2),
                                        borderRadius:
                                            new BorderRadius.circular(16.0)),
                                    child: Row(
                                      children: <Widget>[
                                        downloading
                                            ? SizedBox(
                                                child: new CircularProgressIndicator(
                                                    valueColor:
                                                        new AlwaysStoppedAnimation(
                                                            Color(0xffb00bae3)),
                                                    strokeWidth: 1.0),
                                                height: 20.0,
                                                width: 20.0,
                                              )
                                            : Icon(
                                                Icons.file_download,
                                                color: Colors.grey[300],
                                                size: 25,
                                              ),
                                        downloading
                                            ? Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8),
                                                child: Text(
                                                  'Downloading...',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13),
                                                ))
                                            : Text(
                                                'Download',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13),
                                              ),
                                      ],
                                    ),
                                  ))
                            ],
                          )
                        : Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.grey[400],
                              size: 50,
                            ),
                          ),
                  )
                ]),
          );
  }

  vidDownloaded() async {
    try {
      File downloadedFile = File(extDir.path +
          "/OyeYaaro/Media/Vid/.${widget.snap['chatId']}/${widget.snap['timestamp'].toString()}.mp4");
      bool fileExist = await downloadedFile.exists();
      if (fileExist) {
        // print('true video is exist');
        setState(() {
          isVidDownloaded = true;
        });
      } else {
        // print(':false..video not exist');
        setState(() {
          isVidDownloaded = false;
        });
        checkVidThumbs();
      }
    } catch (e) {
      print('error in isImgDownloaded function $e');
      setState(() {
        isVidDownloaded = false;
      });
    }
  }

  checkVidThumbs() async {
    print('in checkThumb()..');
    try {
      extDir = await getExternalStorageDirectory();

      File isThumbFile = File(extDir.path +
          "/OyeYaaro/Media/Thumbs/.${widget.snap['chatId']}/${widget.snap['timestamp']}.jpg");
      bool fileExist = await isThumbFile.exists();

      if (fileExist && isThumbFile.lengthSync() != 0) {
        print('true video thumb exist');
        setState(() {
          isThumbDownloaded = true;
        });
      } else {
        if (fileExist) {
          isThumbFile.deleteSync();
        }
        print('false video thumb not exist');
        storage
            .downloadThumb(widget.snap['thumbUrl'], widget.snap['timestamp'],
                widget.snap['chatId'])
            .then((res) {
          print("after vid thumb download:$res");
          if (res) {
            setState(() {
              isThumbDownloaded = true;
            });
            vidDownloaded();
          } else
            setState(() {
              isThumbDownloaded = false;
            });
        }, onError: (e) {
          setState(() {
            isThumbDownloaded = false;
          });
        });
      }
    } catch (e) {
      print('Error while checking img thumbs downloaded.. $e');
    }
  }

  downloadVid(String videoUrl, String videoThumbUrl, String timestamp) async {
    print('d file: $videoUrl ..$timestamp ..$videoThumbUrl');

    await storage
        .downloadChatVideo(
            videoUrl, videoThumbUrl, timestamp, widget.snap['chatId'])
        .then((onValue) async {
      print("downloadVideo res $onValue");
      if (onValue) {
        setState(() {
          downloading = false;
        });
        vidDownloaded();
      } else {
        print('Name already exist.');
        setState(() {
          downloading = false;
        });
      }
    }, onError: (e) {
      Fluttertoast.showToast(msg: 'error while downloading.');
      print('error while downloading.');
      setState(() {
        downloading = false;
      });
    });
  }
}
