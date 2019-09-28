// send from private and group chat page(bottom sheet)
import 'dart:io';
import 'package:oye_yaaro_pec/Provider/MediaOperation/confirmSendVid.dart';
import 'package:oye_yaaro_pec/View/recording/video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

typedef SendCallback = void Function(File recorderVideo);

class SendRecordedVideo extends StatefulWidget {
  final SendCallback sendRecordedVideo;
  const SendRecordedVideo({this.sendRecordedVideo});

  @override
  _SendRecordedVideoState createState() => _SendRecordedVideoState();
}

class _SendRecordedVideoState extends State<SendRecordedVideo> {
  Directory directory=  Directory('/storage/emulated/0');
  List<String> videos = [];

  @override
  void initState() {
    getVideos();
    super.initState();
  }

  Future getVideos() async {
    // directory = await getExternalStorageDirectory();
    print('directory:$directory');
    Directory vidDir = Directory(directory.path + "/OyeYaaro/Videos");

    var exists = await vidDir.exists();

    if (exists) {
      vidDir.listSync(recursive: true, followLinks: true).forEach((f) {
        if (f.path.toString().endsWith('.mp4')) {
          videos.add(f.path);
        }
      });
    }
    print('video length:${videos.length}');
  }

  @override
  Widget build(BuildContext context) {
    return videos.length == 0
        ? Container(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Icon(
                      Icons.error,
                      color: Colors.grey,
                    ),
                    Text(
                      'Seems like you haven\'t recorded any video yet \n let\'s try ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Color(0xffb578de3),
                      ),
                    ),
                  ],
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  splashColor: Color(0xffb4fcce0),
                  color: Color(0xffb578de3),
                  child: Text(
                    'Record New Video',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RecordedVideoScreen()));
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          )
        : Container(
            height: 140,
            child: ListView.builder(
              padding: EdgeInsets.only(right: 4),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: videos.length,
              itemBuilder: (BuildContext context, int i) {
                return GestureDetector(
                  onTap: () async {
                    String val = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConfirmSendVid(
                                  img: File(videos[i]),
                                )));
                    // print('nav : $val');
                    if (val == 'ok') {
                      Navigator.pop(context);
                      widget.sendRecordedVideo(File(videos[i]));
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.all(2),
                    width: 140,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(
                          File('/${directory.path}/OyeYaaro/Thumbnails/' +
                              videos[i]
                                  .split("/")
                                  .last
                                  .replaceAll('mp4', 'png')),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }
}
