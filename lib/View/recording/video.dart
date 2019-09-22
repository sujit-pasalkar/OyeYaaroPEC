// make vibrate common
import 'package:oye_yaaro_pec/Components/videoPlayer.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:oye_yaaro_pec/View/recording/shareRecordedVideo.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../cameraModule/views/recordClip.dart';
import 'package:vibrate/vibrate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

class RecordedVideoScreen extends StatefulWidget {
  final ScrollController hideButtonController;

  RecordedVideoScreen({this.hideButtonController, Key key}) : super(key: key);
  @override
  _VedioRecordingScreenState createState() => _VedioRecordingScreenState();
}

class _VedioRecordingScreenState extends State<RecordedVideoScreen> {
  ScrollController _scrollController = ScrollController();
  Directory directory; 
  // Directory thumbnailDirectory;

  List<bool> showShareVideoCheckBox = <bool>[];
  File videoFile;
  SharedPreferences prefs;
  String myId;
  String myName;
  String userPhone;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  //share video to group
  List<String> selectedIndexes = [];
  List<String> allVideos = [];
  bool loading;

  @override
  void initState() {
    loading = false;
    super.initState();
  }

  Future<List<String>> listDir() async {
    print('in listDir');
    directory = await getExternalStorageDirectory();
    print('directory:$directory');

    List<String> videos = <String>[];
    Directory vidDir = Directory(directory.path + "/OyeYaaro/Videos");
    var exists = await vidDir.exists();
    print('exists: $exists');
    if (!exists) {
      vidDir.createSync(recursive: true);
    }

    // if (exists) {
    vidDir.listSync(recursive: true, followLinks: true).forEach((f) {
      if (f.path.toString().endsWith('.mp4')) {// || f.path.toString().endsWith('.mkv')
        videos.add(f.path);
        showShareVideoCheckBox.add(false);
      }
    });
    videos.sort();
    print('videos:$videos');
    return videos;
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
                    print('selected indexes:$selectedIndexes:share with Chats');
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
                          print('share from messaging apps');
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
                  child: FutureBuilder<List<String>>(
                    future: listDir(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError)
                        return Text("Error => ${snapshot.error}");
                      return snapshot.hasData
                          ? body(snapshot.data)
                          : Center(
                              child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
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
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xffb00bae3)),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xffb00bae3),
        child: Image(
          image: AssetImage("assets/VIDEO_BACKGROUND.png"),
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
    print('share: ${selectedIndexes[0]}');
    ShareExtend.share(selectedIndexes[0], "video");
  }

  Widget body(dataList) {
    print('dataList: $dataList');
    if (dataList.length != 0) {
      return GridView.count(
        reverse: false,
        primary: false,
        padding: EdgeInsets.all(8.0),
        crossAxisSpacing: 8.0,
        crossAxisCount: 2,
        controller: _scrollController,
        children: videoGrid(dataList),
      );
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
                      builder: (context) => PlayVideo(
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
                        border: Border.all(
                          color: Colors.indigo[50],
                          width: showShareVideoCheckBox[i] == true ? 10 : 0,
                        ),
                        image: DecorationImage(
                          image: FileImage(
                            File('${directory.path}/OyeYaaro/Thumbnails/' +
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
