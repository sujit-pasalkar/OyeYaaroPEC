import 'package:oye_yaaro_pec/Components/videoPlayer.dart';
// import 'package:oye_yaaro_pec/Components/gaurav_video.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:oye_yaaro_pec/View/recording/shareRecordedVideo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../cameraModule/views/recordClip.dart';
import 'package:vibrate/vibrate.dart';
// import 'package:share_extend/share_extend.dart';

class RecordedVideoScreen extends StatefulWidget {
  final ScrollController hideButtonController;

  RecordedVideoScreen({this.hideButtonController, Key key}) : super(key: key);
  @override
  _VedioRecordingScreenState createState() => _VedioRecordingScreenState();
}

class _VedioRecordingScreenState extends State<RecordedVideoScreen> {
  ScrollController _scrollController = new ScrollController();
  Directory directory = new Directory('/storage/emulated/0/OyeYaaro/Videos');
  Directory thumbailDirectory;

  List<bool> showShareVideoCheckBox = <bool>[];
  File videoFile;
  SharedPreferences prefs;
  String myId;
  String myName;
  String userPhone;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  //share video to group
  List<String> selectedIndexes = [];
  List<String> allVideos = [];
  bool loading;

  @override
  void initState() {
    super.initState();
    loading = false;
  }

  Future<List<String>> listDir() async {
    List<String> videos = <String>[];
    var exists = await directory.exists();

    if (exists) {
      directory.listSync(recursive: true, followLinks: true).forEach((f) {
        if (f.path.toString().endsWith('.mp4')) {
          videos.add(f.path);
          showShareVideoCheckBox.add(false);
        }
      });
      print('videos:$videos');
      videos.sort();

      return videos;
    } else {
      videos.add('empty');
      return videos;
    }
  }

  void removeVideosAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete selected videos ?'),
            content: Text('All selected videos will be removed permanently',
                style: TextStyle(color: Colors.grey)),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL',
                    style: TextStyle(
                      color: Color(0xffb00bae3),
                    )),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('DELETE',
                    style: TextStyle(
                      color: Color(0xffb00bae3),
                    )),
                onPressed: () {
                  deleteVideos();
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: this.selectedIndexes.length == 0
          ? AppBar(
              flexibleSpace: FlexAppbar(),
              title: Text('Record Video'),
            )
          : AppBar(
              flexibleSpace: FlexAppbar(),
              title: Text("Record Video"),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    removeVideosAlert();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    print('selected indexes:$selectedIndexes');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShareRecordedVideo(
                                key: widget.key,
                                selectedIndexes: selectedIndexes)));
                  },
                ),
                this.selectedIndexes.length == 1
                    ? IconButton(
                        icon: Icon(Icons.mobile_screen_share),
                        onPressed: () {
                          share();
                        },
                      )
                    : SizedBox(height: 0, width: 0),
                selectedIndexes.length > 0 &&
                        selectedIndexes.length < allVideos.length
                    ? FlatButton(
                        child: Text(
                          'Check All',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedIndexes = [];
                            for (var i = 0; i < allVideos.length; i++) {
                              selectedIndexes.add(allVideos[i]);
                              showShareVideoCheckBox[i] = true;
                            }
                          });
                        },
                      )
                    : FlatButton(
                        child: Text(
                          'Clear All',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          print(
                              'uncheck all videos: ${showShareVideoCheckBox.length} ,${allVideos.length}');
                          for (var i = 0;
                              i < this.showShareVideoCheckBox.length;
                              i++) {
                            this.showShareVideoCheckBox[i] = false;
                          }
                          setState(() {
                            this.selectedIndexes.clear();
                          });
                        },
                      ),
              ],
            ),
      body: !loading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: new FutureBuilder<List<String>>(
                    future: listDir(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError)
                        return Text("Error => ${snapshot.error}");
                      return snapshot.hasData
                          ? body(snapshot.data)
                          : Center(
                              child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Color(0xffb00bae3)),
                            ));
                    },
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(Color(0xffb00bae3)),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Sending..',
                  style: TextStyle(fontSize: 20, color: Color(0xffb00bae3)),
                )
              ],
            )),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Color(0xffb00bae3),
        child: Image(
          image: new AssetImage("assets/VIDEO_BACKGROUND.png"),
          color: Colors.white,
          width: 40.0,
          height: 40.0,
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
        ),
        onPressed: () {
          opneCamera();
        },
      ),
    );
  }

  void vibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    canVibrate ? Vibrate.feedback(FeedbackType.medium) : null;
  }

  share() async {
    // ShareExtend.share(selectedIndexes[0], "video");
    var platform = const MethodChannel("com.plmlogix.oye_yaaro_pec/platform");
    for (var video in this.selectedIndexes) {
      print('share: $video');
      var data = <String, String>{
        'title': 'shareVideo',
        'path': video,
      };
      try {
        await platform.invokeMethod('shareVideo', data);
      } catch (e) {
        print(e);
      }
    }
  }

  Widget body(dataList) {
    // print('dataList  : $dataList');
    if (dataList.length != 0) {
      if (dataList[0] == 'empty') {
        return noVideoFound();
      } else {
        return GridView.count(
          reverse: false,
          primary: false,
          padding: EdgeInsets.all(8.0),
          crossAxisSpacing: 8.0,
          crossAxisCount: 2,
          controller: _scrollController,
          //  widget.hideButtonController,
          children: videoGrid(dataList),
        );
      }
    } else {
      return noVideoFound();
    }
  }

  Widget noVideoFound() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Image(
              image: AssetImage("assets/no-activity.png"),
            ),
          ),
          Text(
            "No Videos Found",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            "Hey you can record new video by \n tapping on below camera button.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black.withOpacity(0.50),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> videoGrid(dataList) {
    List<Widget> btnlist = List<Widget>();
    for (var i = 0; i < dataList.length; i++) {
      // print('dataList : ${dataList[i]}');
      btnlist.add(
        GestureDetector(
          onLongPress: this.showShareVideoCheckBox[i] != true
              ? () {
                  vibrate();
                  print('adding : $i, ${dataList[i]}');
                  setState(() {
                    allVideos = dataList;
                  });
                  print('allVideosCount : ${allVideos.length}');
                  print('datalist : $dataList');
                  addToSelectedIndexes(dataList[i], i);
                }
              : () {
                  print('removing : $i');
                  this.removeFromSelectedIndexes(dataList[i], i);
                },
          onTap: this.selectedIndexes.length == 0
              ? () {
                  print('videoName::${dataList[i]}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          // PlayVideo(
                          //     videoPath: dataList[i],
                          //     videoThumb:
                          //         '/storage/emulated/0/OyeYaaro/Thumbnails/' +
                          //             (dataList[i].toString().split("/").last)
                          //                 .replaceAll('mp4', 'png')),

                          PlayVideo(
                            videoUrl: dataList[i],
                          ),
                    ),
                  );
                }
              : this.showShareVideoCheckBox[i] != true
                  ? () {
                      print('adding : $i, ${dataList[i]}');
                      addToSelectedIndexes(dataList[i], i);
                    }
                  : () {
                      print('removing : $i');
                      this.removeFromSelectedIndexes(dataList[i], i);
                    },
          child: Container(
            margin: EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        border: new Border.all(
                          color: Colors.indigo[50],
                          width: showShareVideoCheckBox[i] == true ? 10 : 0,
                        ),
                        image: DecorationImage(
                          image: FileImage(
                            File('/storage/emulated/0/OyeYaaro/Thumbnails/' +
                                (dataList[i].toString().split("/").last)
                                    .replaceAll('mp4', 'png')),
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  Positioned(
                    left: 0.0,
                    right: 0.0,
                    top: 0.0,
                    bottom: 0.0,
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 0.0,
                    top: 0.0,
                    child: showShareVideoCheckBox[i] == true
                        ? Icon(Icons.check_circle, color: Color(0xffb00bae3))
                        : SizedBox(
                            height: 0,
                            width: 0,
                          ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
    return btnlist;
  }

  //new
  addToSelectedIndexes(video, i) {
    setState(() {
      showShareVideoCheckBox[i] = !showShareVideoCheckBox[i];
    });
    this.selectedIndexes.add(video);
    print('selected vid: ${this.selectedIndexes}');
  }

  removeFromSelectedIndexes(video, i) {
    setState(() {
      showShareVideoCheckBox[i] = !showShareVideoCheckBox[i];
    });
    this.selectedIndexes.remove(video);
    print('${video.runtimeType}');
  }

  deleteVideos() {
    print('in delete vid');
    for (var video in this.selectedIndexes) {
      print('videos to delete : $video');
      File f = new File.fromUri(Uri.file(video));
      f.delete();
    }

    for (var i = 0; i < this.showShareVideoCheckBox.length; i++) {
      this.showShareVideoCheckBox[i] = false;
    }

    setState(() {
      this.selectedIndexes = [];
      print('after rm : $selectedIndexes');
    });
  }

  Future<void> opneCamera() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecordClip()),
    );
  }
}
