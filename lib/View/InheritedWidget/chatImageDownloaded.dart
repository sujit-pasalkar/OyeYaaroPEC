import 'dart:io';
import 'dart:ui';
import 'package:oye_yaaro_pec/Components/imageViwer.dart';
import 'package:oye_yaaro_pec/Provider/ChatService/common.dart';
import 'package:oye_yaaro_pec/Provider/Firebase/firebase_storage_operations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ChatImage extends StatefulWidget {
  final Map<String, dynamic> snap;
  final double width;
  final String receiverName;
  ChatImage(
      {Key key,
      @required this.snap,
      @required this.width,
      @required this.receiverName})
      : super(key: key);

  @override
  _ChatImageState createState() => _ChatImageState();
}

class _ChatImageState extends State<ChatImage> {
  Directory extDir;
  bool isImgDownloaded = false, downloading = false, isThumbDownloaded = false;

  @override
  void initState() {
    super.initState();
    getDir();
    print('width:${widget.width},$isImgDownloaded');
  }

  getDir() async {
    extDir = await getExternalStorageDirectory();
    imgDownloaded();
  }

  @override
  Widget build(BuildContext context) {
    return isImgDownloaded
        ?
        //yes downloaded
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
                  builder: (context) => ImageViewer(
                        //send type file and downloaded file path means timestamp and on imagev page in type file get dir path
                        imageUrl: extDir.path +
                            "/OyeYaaro/Media/Img/.${widget.snap['chatId']}/${widget.snap['timestamp'].toString()}.jpg",
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
                        width: (widget.width / 2) + 50,
                        height: (widget.width / 2) - 10,
                        margin: const EdgeInsets.fromLTRB(2.0, 1.0, 2.0, 15.0),
                        decoration: BoxDecoration(
                          border: new Border.all(color: Colors.grey),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25.0),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(File(extDir.path +
                                "/OyeYaaro/Media/Img/.${widget.snap['chatId']}/${widget.snap['timestamp'].toString()}.jpg")),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]))
        :
        // not downloaded
        GestureDetector(
            onLongPress: () {
              // adddeleteMsgIdx(
              //     index, document['timestamp'], document['type']);
              print('longpress :${extDir.path}/OyeYaaro/Media/Thumbs/.${widget.snap['chatId']}/${widget.snap['timestamp'].toString()}.jpg');
              print('group name:${widget.snap['chatId']}:$isThumbDownloaded');
            },
            onTap: () {
              // audioPlayer.stop();
              print(widget.snap['msgMedia']);
              setState(() {
                downloading = true;
              });
              downloadImg(
                  widget.snap['mediaUrl'], widget.snap['timestamp'].toString());
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
                  Container(
                      width: (widget.width / 2 + 50),
                      height: (widget.width / 2 - 10),
                      margin: EdgeInsets.fromLTRB(2.0, 1.0, 2.0, 15.0),
                      decoration: BoxDecoration(
                        border: new Border.all(color: Colors.grey, width: 0.5),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.0),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: 
                          !isThumbDownloaded
                              ? NetworkImage(widget.snap['mediaUrl'])
                              : FileImage(File(extDir.path +
                                  "/OyeYaaro/Media/Thumbs/.${widget.snap['chatId']}/${widget.snap['timestamp'].toString()}.jpg")),
                        ),
                      ),
                      child: Stack(
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
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  alignment: Alignment.center,
                                  width: (widget.width / 2) + 50,
                                  height: (widget.width / 2) - 10,
                                  child: !downloading
                                      ? Icon(
                                          Icons.file_download,
                                          color: Colors.white,
                                          size: 40,
                                        )
                                      : CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                ]));
  }

  imgDownloaded() async {
    try {
      File downloadedFile = File(extDir.path +
          "/OyeYaaro/Media/Img/.${widget.snap['chatId']}/${widget.snap['timestamp'].toString()}.jpg");
      bool fileExist = await downloadedFile.exists();
      if (fileExist) {
        print('true...exist');
        setState(() {
          isImgDownloaded = true;
        });
      } else {
        print(':false..not Exist');
        // print(':false..$downloadedFile');
        setState(() {
          isImgDownloaded = false;
        });
        await checkThumbs(); 
      }
      print('so is image downloaded : $isImgDownloaded');
    } catch (e) {
      print('error in isImgDownloaded function $e');
      // throw e;
      setState(() {
        isImgDownloaded = false;
      });
    }
  }

  checkThumbs() async {
    print('in checkThumb()..');
    try {
      // extDir = await getExternalStorageDirectory();
      

      File isThumbFile = File(extDir.path +
          "/OyeYaaro/Media/Thumbs/.${widget.snap['chatId']}/${widget.snap['timestamp'].toString()}.jpg");
      bool fileExist = await isThumbFile.exists();

      if (fileExist) {
        print('true...thumb exist');
        setState(() {
          isThumbDownloaded = true;
        });
      } else {
        print(':false..thumb not exist');
        // print(':false..$downloadedFile');
        // compressedImageFile = await FlutterNativeImage.compressImage(f.path,
        //     percentage: 75, quality: 75);
        storage
            .downloadThumb(widget.snap['mediaUrl'],
                widget.snap['timestamp'].toString(), widget.snap['chatId'])
            .then((res) {
          print("after img thumb download:$res");
          if (res) {
            setState(() {
              isThumbDownloaded = true;
            });
            imgDownloaded();
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

  downloadImg(String filename, String timestamp) async {
    print('d file: $filename ..$timestamp');

    storage.downloadImage(filename, timestamp,chatId:widget.snap['chatId']).then((res) {
      print("after imge downloaded res:$res");
      if (res) {
        setState(() {
          downloading = false;
        });
        imgDownloaded();
      } else
        setState(() {
          downloading = false;
        });
    }, onError: (e) {
      Fluttertoast.showToast(msg: 'error while downloading.');
      setState(() {
        downloading = false;
      });
    });
  }
}
