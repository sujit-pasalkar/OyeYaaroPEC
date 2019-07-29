//framework
import 'package:oye_yaaro_pec/Provider/Firebase/firebase_storage_operations.dart';
import 'package:oye_yaaro_pec/Provider/MediaOperation/ShowMediaFiles/showMediaFiles.dart';
import 'package:oye_yaaro_pec/Provider/MediaOperation/compressMedia.dart';
import 'package:oye_yaaro_pec/Provider/MediaOperation/confirmSendImg.dart';
import 'package:oye_yaaro_pec/Provider/MediaOperation/confirmSendVid.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:oye_yaaro_pec/View/recording/sendRocordedVideo.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlcool/sqlcool.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
// model
import '../../Models/sharedPref.dart';
// provider
import '../../Provider/SqlCool/database_creator.dart';
import '../../Provider/SqlCool/sql_queries.dart';
import '../../Provider/chatservice/common.dart';
// plugin
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thumbnails/thumbnails.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';

//pages
import '../../Components/imageViwer.dart';
import '../../Components/videoPlayer.dart';
//widgets
import '../InheritedWidget/chatImageDownloaded.dart';
import '../InheritedWidget/chatVideoDownloaded.dart';

enum PlayerState { stopped, playing, paused }

class ChatScreen extends StatefulWidget {
  final String chatId, receiverName, chatType, receiverPhone, recPin;

  ChatScreen({
    Key key,
    @required this.chatId,
    @required this.chatType,
    @required this.receiverName,
    @required this.receiverPhone,
    @required this.recPin,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // static const platform = const MethodChannel('com.plmlogix.oye_yaaro_pec/platform');
  SelectBloc bloc;

  DatabaseReference _messagesreference;
  StreamSubscription<Event> _messagesSubscription;

  final TextEditingController _textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  bool _isComposingMessage = false;
  bool screenOpened = true;
  bool uploading = false;
  int uploadingTimestamp;
  Directory extDir;
  double width;

  //#songList
  bool isSearching = false;
  bool isPlaying = false;
  List searchresult = new List();
  List songSearchresult2 = new List();
  List<dynamic> _songList1 = List();
  List<dynamic> _songList2 = List();

  // #AudioPlayer
  String searchText = "";
  AudioPlayer audioPlayer;
  PlayerState playerState = PlayerState.stopped;
  Duration duration;
  Duration position;
  String playingSongInList;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  initState() {
    print('pref----->${pref.hideMedia},${widget.recPin}');
    this.bloc = SelectBloc(
      table: "privateChatTable",
      orderBy: "timestamp",
      columns: "*",
      verbose: false,
      where: "chatId='${widget.chatId}'",
      database: db,
      reactive: true,
    );

    getDir();

    // firebase chat
    _messagesreference = database
        .reference()
        .child('messages')
        .child('private')
        .child('${widget.chatId}'); //.equalTo(false, key: "read");
    _messagesreference.keepSynced(true);

    _messagesSubscription =
        _messagesreference.onChildAdded.listen((Event event) {
      if (screenOpened) {
        print('1st time get all:screenOpened');
        // 1.download song
        if (event.snapshot.value['msgType'] == '3') {
          Common.isSongDownloaded(event.snapshot.value['msgMedia'], '3');
        } else if (event.snapshot.value['msgType'] == '4') {
          Common.isSongDownloaded(event.snapshot.value['msgMedia'], '4');
        }

        sqlQuery
            .addPrivateChat(
          event.snapshot.value['chatId'],
          event.snapshot.value['msgMedia'],
          event.snapshot.value['msgType'],
          event.snapshot.value['timestamp'],
          event.snapshot.value['senderName'],
          event.snapshot.value['senderPhone'],
          event.snapshot.value['receiverPhone'],
          event.snapshot.value['isUploaded'],
          event.snapshot.value['mediaUrl'],
          event.snapshot.value['thumbPath'],
          event.snapshot.value['thumbUrl'],
          event.snapshot.value['senderPin'],
          event.snapshot.value['recPin'],
        )
            .then((onValue) {
          // print('after adding into sqlchat: $onValue');
        }, onError: (e) {
          print(
              'Error while adding onChildAdded event values into addPrivateChat():1st : $e');
        });
      } else {
        print('2nd time just add:onChildAdded');
        // download song //make one function
        if (event.snapshot.value['msgType'] == '3') {
          Common.isSongDownloaded(event.snapshot.value['msgMedia'], '3');
        } else if (event.snapshot.value['msgType'] == '4') {
          Common.isSongDownloaded(event.snapshot.value['msgMedia'], '4');
        }

        if (event.snapshot.value['senderPin'] == pref.pin.toString()) {
          print('dont add this msg to firebase');
        } else {
          print('add this msg to sqflite');
          sqlQuery
              .addPrivateChat(
            event.snapshot.value['chatId'],
            event.snapshot.value['msgMedia'],
            event.snapshot.value['msgType'],
            event.snapshot.value['timestamp'],
            event.snapshot.value['senderName'],
            event.snapshot.value['senderPhone'],
            event.snapshot.value['receiverPhone'],
            event.snapshot.value['isUploaded'],
            event.snapshot.value['mediaUrl'],
            event.snapshot.value['thumbPath'],
            event.snapshot.value['thumbUrl'],
            event.snapshot.value['senderPin'],
            event.snapshot.value['recPin'],
          )
              .then((onValue) {}, onError: (e) {
            print('show error message if addChat fails: $e');
          });
        }
      }
    }, onError: (Object o) {
      final DatabaseError error = o;
      print(
          'Error while listening data from firebase: ${error.code} ${error.message}');
    });

    _messagesreference.once().then((DataSnapshot snapshot) {
      setState(() {
        screenOpened = false;
      });
    });

    // get services
    getSongs(); //

    _textEditingController.addListener(() {
      if (_textEditingController.text.isEmpty) {
        setState(() {
          isSearching = false;
        });
      } else {
        setState(() {
          isSearching = true;
        });
      }
    });

    // Audio
    _initAudioPlayer();
    super.initState();
  }

  getDir() async {
    extDir = await getExternalStorageDirectory();
    print("getExternalStorageDirectory(): $extDir");
  }

  void _initAudioPlayer() {
    audioPlayer = new AudioPlayer();

    audioPlayer.durationHandler = (d) => setState(() {
          duration = d;
        });

    audioPlayer.positionHandler = (p) => setState(() {
          position = p;
        });

    audioPlayer.completionHandler = () {
      onComplete();
      setState(() {
        position = duration;
      });
    };

    audioPlayer.errorHandler = (msg) {
      print('audioPlayer error : $msg');
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    };
  }

  void onComplete() {
    //on audioplaying complete
    setState(() {
      playerState = PlayerState.stopped;
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.stop();
    _messagesSubscription.cancel();
    // print('personal chat dispose');
  }

  getSongs() async {
    await Common.getSongList1().then((onValue) {
      _songList1.addAll(onValue);
    }, onError: (e) {
      print('Error while calling getSongList1():$e');
    });

    await Common.getSongList2().then((onValue) {
      _songList2.addAll(onValue);
    }, onError: (e) {
      print('Error while calling getSongList2():$e');
    });
  }

  Future<bool> onBackPress() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    return Future.value(false);
  }

  // audioCall() async {
  //   var sendMap = <String, dynamic>{
  //     'to': widget.receiverPhone,
  //     'from': pref.phone.toString()
  //   };
  //   try {
  //     String result;
  //     result = await platform.invokeMethod('audioCall', sendMap);
  //   } on PlatformException catch (e) {
  //     print(e);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        flexibleSpace: FlexAppbar(),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MediaFiles(
                    name: widget.receiverName == ''
                        ? widget.receiverPhone
                        : widget.receiverName,
                    chatId: widget.chatId),
              ),
            );
          },
          child: widget.receiverName == ''
              ? Text(widget.receiverPhone.toString())
              : Text(widget.receiverName),
        ),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.call),
          //   onPressed: () {
          //     audioCall();
          //   },
          // ),
          // IconButton(
          //   icon: Icon(Icons.video_call),
          //   onPressed: () {
          //     audioCall();
          //   },
          // ),
          _menuBuilder(),
        ],
      ),
      body: WillPopScope(
        onWillPop: onBackPress,
        child: Container(
          child: Column(
            children: <Widget>[
              Flexible(
                child: StreamBuilder<List<Map>>(
                  stream: bloc.items,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      // the select query has not found anything
                      if (snapshot.data.length == 0) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              // Padding(
                              //     padding: EdgeInsets.all(10),
                              //     child: Text(
                              //       'lets start chat..',
                              //       style: TextStyle(
                              //         fontWeight: FontWeight.bold,
                              //       ),
                              //     )
                              //     )
                            ],
                          ),
                        );
                      } else {
                        // the select query has results
                        return ListView.builder(
                            reverse: true,
                            controller: listScrollController,
                            padding: EdgeInsets.all(10.0),
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              var item = snapshot.data[
                                  (snapshot.data.length - 1) -
                                      index]; //snapshot.data.length -1
                              return buildChatList(index, item);
                            });
                      }
                    } else {
                      // the select query is still running
                      return Center(
                        //
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // CircularProgressIndicator(),
                            // Text('no data'), //
                            // Padding(
                            //   padding: EdgeInsets.all(10),
                            // )
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
              songList(width),
              songList2(width),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuBuilder() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      tooltip: "Menu",
      onSelected: _onMenuItemSelect,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'Hide Media',
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              children: <Widget>[
                Text(pref.hideMedia == false || pref.hideMedia == null
                    ? "Hide Media"
                    : "Show Media"),
                Spacer(),
                Icon(pref.hideMedia == false || pref.hideMedia == null
                    ? Icons.visibility_off
                    : Icons.remove_red_eye),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _onMenuItemSelect(String option) {
    switch (option) {
      case 'Hide Media':
        hideShow();
        break;
    }
  }

  hideShow() {
    if (pref.hideMedia == null || pref.hideMedia == false) {
      setState(() {
        pref.hideMedia = true;
      });
    } else {
      setState(() {
        pref.hideMedia = false;
      });
    }
  }

  Widget buildChatList(int index, Map<String, dynamic> snap) {
    //msg from this chatId
    if (snap['senderPin'] == pref.pin.toString()) {
      return Stack(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              snap['msgType'] == '0' //text
                  ? GestureDetector(
                      onLongPress: () {
                        // adddeleteMsgIdx(
                        //     index, document['timestamp'], document['type']);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          FutureBuilder<String>(
                            future:
                                Common.getTime(int.parse(snap['timestamp'])),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                  return Text(
                                      DateFormat('dd MMM kk:mm').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(snap['timestamp']))),
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10.0,
                                          fontStyle: FontStyle.normal));
                                case ConnectionState.active:
                                case ConnectionState.waiting:
                                  return Text(
                                      DateFormat('dd MMM kk:mm').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(snap['timestamp']))),
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10.0,
                                          fontStyle: FontStyle.normal));
                                case ConnectionState.done:
                                  if (snapshot.hasError)
                                    return Text(
                                        DateFormat('dd MMM kk:mm').format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(snap['timestamp']))),
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
                                          int.parse(snap['timestamp']))),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10.0,
                                      fontStyle:
                                          FontStyle.normal)); // unreachable
                            },
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.fromLTRB(2.0, 1.0, 2.0, 15.0),
                            decoration: BoxDecoration(
                                color: Color(0xffb00bae3),
                                borderRadius: BorderRadius.circular(30.0)),
                            constraints:
                                BoxConstraints(maxWidth: (width / 2) + 20),
                            child: Text(
                              snap['msgMedia'],
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w300),
                            ),
                          )
                        ],
                      ))
                  : snap['msgType'] == '1' &&
                          (pref.hideMedia == false || pref.hideMedia == null)
                      ? GestureDetector(
                          onLongPress: () {
                            // adddeleteMsgIdx(
                            //     index, document['timestamp'], document['type']);
                            print('longpress');
                          },
                          onTap: () {
                            audioPlayer.stop();
                            print(snap['msgMedia']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageViewer(
                                  imageUrl: snap['msgMedia'],
                                ),
                              ),
                            );
                          },
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                FutureBuilder<String>(
                                  future: Common.getTime(
                                      int.parse(snap['timestamp'])),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.none:
                                        return Text(
                                            DateFormat('dd MMM kk:mm').format(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        int.parse(snap[
                                                            'timestamp']))),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10.0,
                                                fontStyle: FontStyle.normal));
                                      case ConnectionState.active:
                                      case ConnectionState.waiting:
                                        return Text(
                                            DateFormat('dd MMM kk:mm').format(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        int.parse(snap[
                                                            'timestamp']))),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10.0,
                                                fontStyle: FontStyle.normal));
                                      case ConnectionState.done:
                                        if (snapshot.hasError)
                                          return Text(
                                              DateFormat('dd MMM kk:mm').format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          int.parse(snap[
                                                              'timestamp']))),
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
                                                int.parse(snap['timestamp']))),
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10.0,
                                            fontStyle: FontStyle
                                                .normal)); // unreachable
                                  },
                                ),
                                Stack(
                                  children: <Widget>[
                                    Container(
                                      width: (width / 2) + 50,
                                      height: (width / 2) - 10,
                                      margin: EdgeInsets.fromLTRB(
                                          2.0, 1.0, 2.0, 15.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        color: Colors.white,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image:
                                              FileImage(File(snap['msgMedia'])),
                                        ),
                                      ),
                                    ),
                                    snap['isUploaded'] == '0'
                                        ? Positioned(
                                            bottom: 20,
                                            right: 15,
                                            child: Icon(
                                              Icons.schedule,
                                              color: Colors.white,
                                              size: 15,
                                            ))
                                        : SizedBox(height: 0, width: 0),
                                    snap['isUploaded'] == '0' &&
                                            uploading == true &&
                                            uploadingTimestamp ==
                                                int.parse(snap['timestamp'])
                                        ? Positioned(
                                            left: 0,
                                            top: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 5.0),
                                            ))
                                        : snap['isUploaded'] == '0'
                                            ? Positioned(
                                                left: 0,
                                                top: 0,
                                                right: 0,
                                                bottom: 0,
                                                child: Center(
                                                  child: RaisedButton(
                                                    //user animatedbutton
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    textColor: Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0)),
                                                    child: Text('RETRY'),
                                                    onPressed: () {
                                                      uploadImage(
                                                              widget.chatId,
                                                              snap['msgMedia'],
                                                              '1',
                                                              snap['timestamp'],
                                                              pref.name,
                                                              pref.phone
                                                                  .toString(),
                                                              widget
                                                                  .receiverPhone
                                                                  .toString(),
                                                              pref.pin
                                                                  .toString(),
                                                              widget.recPin)
                                                          .then((onValue) {
                                                        print(
                                                            'image uploaded successfully');
                                                      }, onError: (e) {
                                                        print(
                                                            'Error while image uploading :$e');
                                                      });
                                                    },
                                                  ),
                                                ))
                                            : SizedBox(height: 0, width: 0),
                                  ],
                                )
                              ]))
                      //video
                      : snap['msgType'] == '2' &&
                              (pref.hideMedia == false ||
                                  pref.hideMedia == null)
                          ? GestureDetector(
                              onLongPress: () {
                                // adddeleteMsgIdx(
                                //     index, document['timestamp'], document['type']);
                                print('longpress:${snap['thumbPath']}');
                              },
                              onTap: () {
                                audioPlayer.stop();
                                print(snap['msgMedia']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayVideo(
                                      videoUrl: snap['msgMedia'],
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    FutureBuilder<String>(
                                      future: Common.getTime(
                                          int.parse(snap['timestamp'])),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String> snapshot) {
                                        switch (snapshot.connectionState) {
                                          case ConnectionState.none:
                                            return Text(
                                                DateFormat('dd MMM kk:mm')
                                                    .format(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            int.parse(snap[
                                                                'timestamp']))),
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10.0,
                                                    fontStyle:
                                                        FontStyle.normal));
                                          case ConnectionState.active:
                                          case ConnectionState.waiting:
                                            return Text(
                                                DateFormat('dd MMM kk:mm')
                                                    .format(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            int.parse(snap[
                                                                'timestamp']))),
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10.0,
                                                    fontStyle:
                                                        FontStyle.normal));
                                          case ConnectionState.done:
                                            if (snapshot.hasError)
                                              return Text(
                                                  DateFormat('dd MMM kk:mm')
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              int.parse(snap[
                                                                  'timestamp']))),
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10.0,
                                                      fontStyle:
                                                          FontStyle.normal));
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
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        int.parse(snap[
                                                            'timestamp']))),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10.0,
                                                fontStyle: FontStyle
                                                    .normal)); // unreachable
                                      },
                                    ),
                                    Stack(
                                      children: <Widget>[
                                        Container(
                                          width: (width / 2) - 10,
                                          height: (width / 2) + 50,
                                          margin: EdgeInsets.fromLTRB(
                                              2.0, 1.0, 2.0, 15.0),
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            color: Colors.white,
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                  File(snap['thumbPath'])),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            left: 0,
                                            top: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: Center(
                                                child: Icon(
                                              Icons.play_circle_outline,
                                              color: Colors.grey[300],
                                              size: 60,
                                            ))),
                                        snap['isUploaded'] == '0'
                                            ? Positioned(
                                                bottom: 20,
                                                right: 15,
                                                child: Icon(
                                                  Icons.schedule,
                                                  color: Colors.white,
                                                  size: 15,
                                                ))
                                            : SizedBox(height: 0, width: 0),
                                        snap['isUploaded'] == '0' &&
                                                uploading == true &&
                                                uploadingTimestamp ==
                                                    int.parse(snap['timestamp'])
                                            ? Positioned(
                                                left: 0,
                                                top: 0,
                                                right: 0,
                                                bottom: 0,
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 5.0)))
                                            : snap['isUploaded'] == '0'
                                                ? Positioned(
                                                    left: 0,
                                                    top: 0,
                                                    right: 0,
                                                    bottom: 0,
                                                    child: Center(
                                                      child: RaisedButton(
                                                        //use animatedbutton
                                                        color: Colors.black
                                                            .withOpacity(0.5),
                                                        textColor: Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0)),
                                                        child: Text('RETRY'),
                                                        onPressed: () {
                                                          uploadVideo(
                                                                  widget.chatId,
                                                                  File(snap[
                                                                      'msgMedia']),
                                                                  '2',
                                                                  snap[
                                                                      'timestamp'],
                                                                  pref.name,
                                                                  pref.phone
                                                                      .toString(),
                                                                  widget
                                                                      .receiverPhone
                                                                      .toString(),
                                                                  snap[
                                                                      'thumbPath'],
                                                                  pref.pin
                                                                      .toString(),
                                                                  widget.recPin)
                                                              .then((onValue) {
                                                            print(
                                                                'image uploaded successfully');
                                                          }, onError: (e) {
                                                            print(
                                                                'Error while image uploading :$e');
                                                          });
                                                        },
                                                      ),
                                                    ))
                                                : SizedBox(height: 0, width: 0),
                                      ],
                                    )
                                  ]))
                          : snap['msgType'] == '3' //song1
                              ? GestureDetector(
                                  onLongPress: () {
                                    // adddeleteMsgIdx(
                                    //     index,
                                    //     document['timestamp'],
                                    //     document['type']);
                                  },
                                  onTapUp: (TapUpDetails details) {
                                    print("onTapUp");
                                    isPlaying
                                        ? stop()
                                        : play(
                                            extDir.path +
                                                "/OyeYaaro/audio/.3/" +
                                                snap['msgMedia']
                                                    .toString()
                                                    .replaceAll(
                                                        'http://oyeyaaroapi.plmlogix.com/AudioChat/',
                                                        ''),
                                            snap['msgMedia'].toString().replaceAll(
                                                'http://oyeyaaroapi.plmlogix.com/AudioChat/',
                                                ''),
                                          );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      FutureBuilder<String>(
                                        future: Common.getTime(
                                            int.parse(snap['timestamp'])),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          switch (snapshot.connectionState) {
                                            case ConnectionState.none:
                                              return Text(
                                                  DateFormat('dd MMM kk:mm')
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              int.parse(snap[
                                                                  'timestamp']))),
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10.0,
                                                      fontStyle:
                                                          FontStyle.normal));
                                            case ConnectionState.active:
                                            case ConnectionState.waiting:
                                              return Text(
                                                  DateFormat('dd MMM kk:mm')
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              int.parse(snap[
                                                                  'timestamp']))),
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10.0,
                                                      fontStyle:
                                                          FontStyle.normal));
                                            case ConnectionState.done:
                                              if (snapshot.hasError)
                                                return Text(
                                                    DateFormat('dd MMM kk:mm')
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                                int.parse(snap[
                                                                    'timestamp']))),
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10.0,
                                                        fontStyle:
                                                            FontStyle.normal));
                                              return Text(
                                                snapshot.data,
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10.0,
                                                    fontStyle:
                                                        FontStyle.normal),
                                              );
                                          }
                                          return Text(
                                              DateFormat('dd MMM kk:mm').format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          int.parse(snap[
                                                              'timestamp']))),
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10.0,
                                                  fontStyle: FontStyle
                                                      .normal)); // unreachable
                                        },
                                      ),
                                      Container(
                                        height: 60.0,
                                        width: 60.0,
                                        margin: EdgeInsets.fromLTRB(
                                            2.0, 1.0, 2.0, 15.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                        ),

                                        /*
 playPauseIcon(listData)
                        ? position != null && duration != null
                            ? Icon(Icons.pause_circle_outline)
                            : SizedBox(
                                child: new CircularProgressIndicator(
                                    valueColor: new AlwaysStoppedAnimation(
                                        Color(0xffb00bae3)),
                                    strokeWidth: 1.0),
                                height: 20.0,
                                width: 20.0,
                              )
                        : Image.asset('assets/short.png',
                            width: 25.0, height: 25.0),
                                          */
                                        child: playPauseIcon(snap['msgMedia']
                                                .toString()
                                                .replaceAll(
                                                    'http://oyeyaaroapi.plmlogix.com/AudioChat/',
                                                    ''))
                                            ? Container(
                                                margin: EdgeInsets.all(3),
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(8.0),
                                                  ),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    LayoutBuilder(builder:
                                                        (context, constraint) {
                                                      return Icon(
                                                        Icons.pause,
                                                        size: 40.0,
                                                        color: Colors.white,
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                margin: EdgeInsets.all(3),
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(8.0),
                                                  ),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    Image.asset(
                                                        'assets/short.png',
                                                        width: 40.0,
                                                        height: 40.0)
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                )
                              : //song2
                              snap['msgType'] == '4'
                                  ? GestureDetector(
                                      onLongPress: () {
                                        // adddeleteMsgIdx(
                                        //     index,
                                        //     document['timestamp'],
                                        //     document['type']);
                                      },
                                      onTapUp: (TapUpDetails details) {
                                        print("onTapUp");
                                        isPlaying
                                            ? stop()
                                            : play(
                                                extDir.path +
                                                    "/OyeYaaro/audio/.4/" +
                                                    snap['msgMedia']
                                                        .toString()
                                                        .replaceAll(
                                                            'http://oyeyaaroapi.plmlogix.com/Audio/',
                                                            ''),
                                                snap['msgMedia']
                                                    .toString()
                                                    .replaceAll(
                                                        'http://oyeyaaroapi.plmlogix.com/Audio/',
                                                        ''));
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          FutureBuilder<String>(
                                            future: Common.getTime(
                                                int.parse(snap['timestamp'])),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              switch (
                                                  snapshot.connectionState) {
                                                case ConnectionState.none:
                                                  return Text(
                                                      DateFormat('dd MMM kk:mm')
                                                          .format(DateTime
                                                              .fromMillisecondsSinceEpoch(
                                                                  int.parse(snap[
                                                                      'timestamp']))),
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 10.0,
                                                          fontStyle: FontStyle
                                                              .normal));
                                                case ConnectionState.active:
                                                case ConnectionState.waiting:
                                                  return Text(
                                                      DateFormat('dd MMM kk:mm')
                                                          .format(DateTime
                                                              .fromMillisecondsSinceEpoch(
                                                                  int.parse(snap[
                                                                      'timestamp']))),
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 10.0,
                                                          fontStyle: FontStyle
                                                              .normal));
                                                case ConnectionState.done:
                                                  if (snapshot.hasError)
                                                    return Text(
                                                        DateFormat(
                                                                'dd MMM kk:mm')
                                                            .format(DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                                    int.parse(snap[
                                                                        'timestamp']))),
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 10.0,
                                                            fontStyle: FontStyle
                                                                .normal));
                                                  return Text(
                                                    snapshot.data,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10.0,
                                                        fontStyle:
                                                            FontStyle.normal),
                                                  );
                                              }
                                              return Text(
                                                  DateFormat('dd MMM kk:mm')
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              int.parse(snap[
                                                                  'timestamp']))),
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10.0,
                                                      fontStyle: FontStyle
                                                          .normal)); // unreachable
                                            },
                                          ),
                                          Container(
                                            height: 60.0,
                                            width: 60.0,
                                            margin: EdgeInsets.fromLTRB(
                                                2.0, 1.0, 2.0, 15.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                            ),
                                            child: playPauseIcon(snap[
                                                        'msgMedia']
                                                    .toString()
                                                    .replaceAll(
                                                        'http://oyeyaaroapi.plmlogix.com/Audio/',
                                                        ''))
                                                ? Container(
                                                    margin: EdgeInsets.all(3),
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(8.0),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: <Widget>[
                                                        LayoutBuilder(builder:
                                                            (context,
                                                                constraint) {
                                                          return Icon(
                                                            Icons.pause,
                                                            size: 40.0,
                                                            color: Colors.white,
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  )
                                                : Container(
                                                    margin: EdgeInsets.all(3),
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(8.0),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: <Widget>[
                                                        LayoutBuilder(builder:
                                                            (context,
                                                                constraint) {
                                                          return Icon(
                                                            Icons.music_note,
                                                            size: 40.0,
                                                            color: Colors.white,
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox(
                                      height: 0,
                                      width: 0,
                                    )
            ],
          ),
        ],
      );
    } else {
      // Left(peer message)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              (snap['msgType'] == '1' || snap['msgType'] == '2') &&
                      (pref.hideMedia == true)
                  ? SizedBox(
                      width: 35,
                    )
                    // add in gesure detectore//
                  : Container(
                      margin: EdgeInsets.only(right: 8),
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        color: Color(0xffb4fcce0),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          radius: 25,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl:
                                'http://54.200.143.85:4200/profiles/now/${widget.recPin}.jpg',
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                height: 20.0,
                                width: 20.0,
                                child:
                                    CircularProgressIndicator(strokeWidth: 1.0),
                              ),
                            ),
                            errorWidget: (context, url, error) => 
                              FadeInImage.assetNetwork(
                                placeholder: 'assets/loading.gif',
                                image:
                                    'http://54.200.143.85:4200/profiles/then/${widget.recPin}.jpg',
                              ),
                          ),
                        ),
                      ),
                    ),
              snap['msgType'] == '0' //text
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                          FutureBuilder<String>(
                            future:
                                Common.getTime(int.parse(snap['timestamp'])),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                  return Text(
                                      DateFormat('dd MMM kk:mm').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(snap['timestamp']))),
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10.0,
                                          fontStyle: FontStyle.normal));
                                case ConnectionState.active:
                                case ConnectionState.waiting:
                                  return Text(
                                      DateFormat('dd MMM kk:mm').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(snap['timestamp']))),
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10.0,
                                          fontStyle: FontStyle.normal));
                                case ConnectionState.done:
                                  if (snapshot.hasError)
                                    return Text(
                                        DateFormat('dd MMM kk:mm').format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(snap['timestamp']))),
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
                                          int.parse(snap['timestamp']))),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                      fontStyle:
                                          FontStyle.normal)); // unreachable
                            },
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            margin:
                                const EdgeInsets.fromLTRB(2.0, 1.0, 2.0, 15.0),
                            decoration: BoxDecoration(
                                color: Color(0xffb578de3),
                                borderRadius: BorderRadius.circular(30.0)),
                            constraints:
                                BoxConstraints(maxWidth: (width / 2) + 20),
                            child: Text(
                              snap['msgMedia'],
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w300),
                            ),
                          )
                        ])
                  : snap['msgType'] == '1' &&
                          (pref.hideMedia == false || pref.hideMedia == null)
                      ? ChatImage(
                          snap: snap,
                          width: width,
                          receiverName: widget.receiverName)
                      //video
                      : snap['msgType'] == '2' &&
                              (pref.hideMedia == false ||
                                  pref.hideMedia == null)
                          ? ChatVideo(
                              snap: snap,
                              width: width,
                              receiverName: widget.receiverName)
                          : snap['msgType'] == '3' //song1
                              ? GestureDetector(
                                  onLongPress: () {
                                    // adddeleteMsgIdx(
                                    //     index,
                                    //     document['timestamp'],
                                    //     document['type']);
                                  },
                                  onTapUp: (TapUpDetails details) {
                                    print("onTapUp");
                                    isPlaying
                                        ? stop()
                                        : play(
                                            extDir.path +
                                                "/OyeYaaro/audio/.3/" +
                                                snap['msgMedia']
                                                    .toString()
                                                    .replaceAll(
                                                        'http://oyeyaaroapi.plmlogix.com/AudioChat/',
                                                        ''),
                                            snap['msgMedia'].toString().replaceAll(
                                                'http://oyeyaaroapi.plmlogix.com/AudioChat/',
                                                ''));
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      FutureBuilder<String>(
                                        future: Common.getTime(
                                            int.parse(snap['timestamp'])),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          switch (snapshot.connectionState) {
                                            case ConnectionState.none:
                                              return Text(
                                                  DateFormat('dd MMM kk:mm')
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              int.parse(snap[
                                                                  'timestamp']))),
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10.0,
                                                      fontStyle:
                                                          FontStyle.normal));
                                            case ConnectionState.active:
                                            case ConnectionState.waiting:
                                              return Text(
                                                  DateFormat('dd MMM kk:mm')
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              int.parse(snap[
                                                                  'timestamp']))),
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10.0,
                                                      fontStyle:
                                                          FontStyle.normal));
                                            case ConnectionState.done:
                                              if (snapshot.hasError)
                                                return Text(
                                                    DateFormat('dd MMM kk:mm')
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                                int.parse(snap[
                                                                    'timestamp']))),
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10.0,
                                                        fontStyle:
                                                            FontStyle.normal));
                                              return Text(
                                                snapshot.data,
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10.0,
                                                    fontStyle:
                                                        FontStyle.normal),
                                              );
                                          }
                                          return Text(
                                              DateFormat('dd MMM kk:mm').format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          int.parse(snap[
                                                              'timestamp']))),
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10.0,
                                                  fontStyle: FontStyle
                                                      .normal)); // unreachable
                                        },
                                      ),
                                      Container(
                                        height: 60.0,
                                        width: 60.0,
                                        margin: const EdgeInsets.fromLTRB(
                                            2.0, 1.0, 2.0, 15.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                        ),

                                        /*
 playPauseIcon(listData)
                            ? position != null && duration != null
                                ? Icon(Icons.pause_circle_outline)
                                : SizedBox(
                                    child: new CircularProgressIndicator(
                                        valueColor: new AlwaysStoppedAnimation(
                                            Color(0xffb00bae3)),
                                        strokeWidth: 1.0),
                                    height: 20.0,
                                    width: 20.0,
                                  )
                            : Image.asset('assets/short.png',
                                width: 25.0, height: 25.0),
                                              */
                                        child: playPauseIcon(snap['msgMedia']
                                                .toString()
                                                .replaceAll(
                                                    'http://oyeyaaroapi.plmlogix.com/AudioChat/',
                                                    ''))
                                            ? Container(
                                                margin: EdgeInsets.all(3),
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(8.0),
                                                  ),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    LayoutBuilder(builder:
                                                        (context, constraint) {
                                                      return Icon(
                                                        Icons.pause,
                                                        size: 40.0,
                                                        color: Colors.white,
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                margin: EdgeInsets.all(3),
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(8.0),
                                                  ),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    Image.asset(
                                                        'assets/short.png',
                                                        width: 40.0,
                                                        height: 40.0)
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                )
                              : //song2
                              snap['msgType'] == '4'
                                  ? GestureDetector(
                                      onLongPress: () {
                                        // adddeleteMsgIdx(
                                        //     index,
                                        //     document['timestamp'],
                                        //     document['type']);
                                      },
                                      onTapUp: (TapUpDetails details) {
                                        print("onTapUp");
                                        isPlaying
                                            ? stop()
                                            : play(
                                                // snap['msgMedia'],
                                                extDir.path +
                                                    "/OyeYaaro/audio/.4/" +
                                                    snap['msgMedia']
                                                        .toString()
                                                        .replaceAll(
                                                            'http://oyeyaaroapi.plmlogix.com/Audio/',
                                                            ''),
                                                snap['msgMedia']
                                                    .toString()
                                                    .replaceAll(
                                                        'http://oyeyaaroapi.plmlogix.com/Audio/',
                                                        ''),
                                              );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          FutureBuilder<String>(
                                            future: Common.getTime(
                                                int.parse(snap['timestamp'])),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              switch (
                                                  snapshot.connectionState) {
                                                case ConnectionState.none:
                                                  return Text(
                                                      DateFormat('dd MMM kk:mm')
                                                          .format(DateTime
                                                              .fromMillisecondsSinceEpoch(
                                                                  int.parse(snap[
                                                                      'timestamp']))),
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 10.0,
                                                          fontStyle: FontStyle
                                                              .normal));
                                                case ConnectionState.active:
                                                case ConnectionState.waiting:
                                                  return Text(
                                                      DateFormat('dd MMM kk:mm')
                                                          .format(DateTime
                                                              .fromMillisecondsSinceEpoch(
                                                                  int.parse(snap[
                                                                      'timestamp']))),
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 10.0,
                                                          fontStyle: FontStyle
                                                              .normal));
                                                case ConnectionState.done:
                                                  if (snapshot.hasError)
                                                    return Text(
                                                        DateFormat(
                                                                'dd MMM kk:mm')
                                                            .format(DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                                    int.parse(snap[
                                                                        'timestamp']))),
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 10.0,
                                                            fontStyle: FontStyle
                                                                .normal));
                                                  return Text(
                                                    snapshot.data,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10.0,
                                                        fontStyle:
                                                            FontStyle.normal),
                                                  );
                                              }
                                              return Text(
                                                  DateFormat('dd MMM kk:mm')
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              int.parse(snap[
                                                                  'timestamp']))),
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10.0,
                                                      fontStyle: FontStyle
                                                          .normal)); // unreachable
                                            },
                                          ),
                                          Container(
                                            height: 60.0,
                                            width: 60.0,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                            ),
                                            child: playPauseIcon(snap[
                                                        'msgMedia']
                                                    .toString()
                                                    .replaceAll(
                                                        'http://oyeyaaroapi.plmlogix.com/Audio/',
                                                        ''))
                                                ? Container(
                                                    margin: EdgeInsets.all(3),
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(8.0),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: <Widget>[
                                                        LayoutBuilder(builder:
                                                            (context,
                                                                constraint) {
                                                          return Icon(
                                                            Icons.pause,
                                                            size: 40.0,
                                                            color: Colors.white,
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  )
                                                : Container(
                                                    margin: EdgeInsets.all(3),
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(8.0),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: <Widget>[
                                                        LayoutBuilder(builder:
                                                            (context,
                                                                constraint) {
                                                          return Icon(
                                                            Icons.music_note,
                                                            size: 40.0,
                                                            color: Colors.white,
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox(height: 0, width: 0),
            ],
          ),
        ],
      );
    }
  }

  CupertinoButton getIOSSendButton() {
    return CupertinoButton(
      child: Text("Send"),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text.trim())
          : null,
    );
  }

  IconButton getDefaultSendButton() {
    return IconButton(
      icon: Icon(Icons.send, color: Colors.white),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text.trim())
          : null,
    );
  }

  songList(width) {
    if (isSearching == true && searchresult.length > 0) {
      return Container(
          color: Colors.deepPurple[50],
          height: 40.0,
          width: width,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: searchresult.length,
            itemBuilder: (BuildContext context, int index) {
              String listData = searchresult[index];
              return GestureDetector(
                onTapUp: (TapUpDetails details) {
                  print("onTapUp");
                  // playSongAlert();
                  isPlaying
                      ? stop()
                      : play(
                          "http://oyeyaaroapi.plmlogix.com/AudioChat/" +
                              listData,
                          listData);
                },
                onLongPress: () {
                  print("onLongPress sneding toast");
                  Fluttertoast.showToast(
                      msg: 'sent ${listData.replaceAll('.mp3', '')}');
                  sendsong(
                    songurl: "http://oyeyaaroapi.plmlogix.com/AudioChat/" +
                        listData.toString(),
                    senderName: pref.name,
                    senderPhone: pref.phone.toString(),
                    receiverPhone: widget.receiverPhone.toString(),
                    type: '3',
                    timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
                    senderPin: pref.pin.toString(),
                    recPin: widget.recPin.toString(),
                  );
                },
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                    ),
                    playPauseIcon(listData)
                        ? position != null && duration != null
                            ? Icon(Icons.pause_circle_outline)
                            : SizedBox(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                        Color(0xffb00bae3)),
                                    strokeWidth: 1.0),
                                height: 20.0,
                                width: 20.0,
                              )
                        : Image.asset('assets/short.png',
                            width: 25.0, height: 25.0),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                    ),
                    Text(
                      listData.replaceAll('.mp3', ''),
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                    ),
                  ],
                ),
              );
            },
          ));
    } else
      return SizedBox();
  }

  songList2(width) {
    if (isSearching == true && songSearchresult2.length > 0) {
      return Container(
        color: Colors.blue[50],
        height: 40.0,
        width: width,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: songSearchresult2.length,
          itemBuilder: (BuildContext context, int index) {
            String listData = songSearchresult2[index];
            return GestureDetector(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                  ),
                  playPauseIcon(listData)
                      ? position != null && duration != null
                          ? Icon(Icons.pause_circle_outline)
                          : SizedBox(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      Color(0xffb00bae3)),
                                  strokeWidth: 1.0),
                              height: 20.0,
                              width: 20.0,
                            )
                      : Icon(Icons.music_note),
                  Text(
                    listData.replaceAll('.mp3', ''),
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                  )
                ],
              ),
              onTapUp: (TapUpDetails details) {
                print("onTapUp 4");
                isPlaying
                    ? stop()
                    : play(
                        "http://oyeyaaroapi.plmlogix.com/Audio/" +
                            listData.toString(),
                        listData);
              },
              onLongPress: () {
                // print("onLongPress");
                // onTextMessage(
                //     "http://oyeyaaroapi.plmlogix.com/Audio/" +
                //         listData.toString(),
                //     4);
                Fluttertoast.showToast(
                    msg: 'sent ${listData.replaceAll('.mp3', '')}');
                sendsong(
                  songurl: "http://oyeyaaroapi.plmlogix.com/Audio/" +
                      listData.toString(),
                  senderName: 'pref.name',
                  senderPhone: pref.phone.toString(),
                  receiverPhone: widget.receiverPhone.toString(),
                  type: '4',
                  timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
                  senderPin: pref.pin.toString(),
                  recPin: widget.recPin.toString(),
                );
              },
            );
          },
        ),
      );
    } else
      return SizedBox();
  }

  bool playPauseIcon(songName) {
    if (songName == playingSongInList && isPlaying) {
      return true;
    } else
      return false;
  }

  Widget _buildTextComposer(context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
                height: 50,
                margin: EdgeInsets.only(left: 2),
                padding: EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50.0),
                    ),
                    border: Border.all(
                      width: 1,
                      color: Color(0xffb578de3),
                    )),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: _textEditingController,
                        onChanged: (String messageText) {
                          // print(messageText.trim().length);
                          setState(() {
                            _isComposingMessage = messageText.trim().length > 0;
                          });
                          if (_isComposingMessage) {
                            searchSongs(messageText.trim());
                          }
                        },
                        onTap: () {
                          // print('ontapp.');
                          setState(() {
                            this.isSearching = true;
                          });
                          searchSongs('');
                        },
                        decoration: InputDecoration.collapsed(
                            hintText: "Send a message"),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Color(0xffb00bae3)),
                      onPressed: () {
                        openBottomSheet();
                      },
                    ),
                  ],
                )),
          ),
          Padding(
            padding: EdgeInsets.all(2),
            child: Container(
              margin: EdgeInsets.only(left: 2),
              decoration: BoxDecoration(
                  color: Color(0xffb00bae3),
                  borderRadius: BorderRadius.circular(50.0)),
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? getIOSSendButton()
                  : getDefaultSendButton(),
            ),
          ),
        ],
      ),
    );
  }

  void searchSongs(String searchText) {
    searchresult.clear();
    songSearchresult2.clear();
    if (isSearching != null) {
      for (int i = 0; i < _songList1.length; i++) {
        String data = _songList1[i];
        if (data.toLowerCase().contains(searchText.toLowerCase())) {
          searchresult.add(data); //remove .mp4  nt here
        }
      }

      for (int i = 0; i < _songList2.length; i++) {
        String data = _songList2[i];
        if (data.toLowerCase().contains(searchText.toLowerCase())) {
          songSearchresult2.add(data);
        }
      }
      if (searchresult.length == 0 && songSearchresult2.length == 0) {
        isSearching = false;
      }
    }
  }

  recordedVideo() {
    return showModalBottomSheet(
        context: context,
        builder: (builder) {
          return SendRecordedVideo(
            sendRecordedVideo: (File file) {
              sendVid(file);
              listScrollController.animateTo(0.0,
                  duration: Duration(seconds: 2), curve: Curves.ease);
            },
          );
        });
  }

  openBottomSheet() {
    return showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          margin: EdgeInsets.all(10),
          height: 200,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      audioPlayer.stop();
                      camera();
                    },
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Color(0xffb4fcce0),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.photo_camera,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            'Camera \n Image',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      audioPlayer.stop();
                      gallery();
                    },
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Color(0xffb4fcce0),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            'Gallery \n Image',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      audioPlayer.stop();
                      videoCam();
                    },
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Color(0xffb4fcce0),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.videocam,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            'Camera \n video',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          audioPlayer.stop();
                          galleryVideo();
                        },
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Color(0xffb4fcce0),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.video_library,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                'Gallery \n Video',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          audioPlayer.stop();
                          recordedVideo();
                        },
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: Color(0xffb4fcce0),
                                shape: BoxShape.circle,
                              ),
                              child: Image(
                                image: new AssetImage(
                                    "assets/VIDEO_BACKGROUND.png"),
                                color: Colors.white,
                                width: 30.0,
                                height: 30.0,
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                'Recorder \n Video',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Color(0xffb4fcce0),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                'Close',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        );
      },
    );
  }

  camera() async {
    File img = await ImagePicker.pickImage(source: ImageSource.camera);
    print('camera img :$img');

    if (img != null) {
      String val = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConfirmSendImg(
                    img: img,
                  )));
      print('im back with images*************:$val');
      if (val == 'ok') {
        sendImg(img);
      }
    }
  }

  gallery() async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      String val = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConfirmSendImg(
                    img: img,
                  )));
      // print('im back with images*************:$val');
      if (val == 'ok') {
        sendImg(img);
      }
    }
  }

  videoCam() async {
    File vid = await ImagePicker.pickVideo(source: ImageSource.camera);
    if (vid != null) {
      String val = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConfirmSendVid(
                    img: vid,
                  )));
      // print('im back with images*************:$val');
      if (val == 'ok') {
        sendVid(vid);
      }
    }
  }

  galleryVideo() async {
    File vid = await ImagePicker.pickVideo(source: ImageSource.gallery);
    if (vid != null) {
      String val = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConfirmSendVid(
                    img: vid,
                  )));
      // print('im back with images*************:$val');
      if (val == 'ok') {
        sendVid(vid);
      }
    }
  }

  Future<Null> _textMessageSubmitted(String text) async {
    _textEditingController.clear();

    setState(() {
      _isComposingMessage = false;
    });

    sendText(
        messageText: text,
        senderName: pref.name,
        senderPhone: pref.phone.toString(),
        receiverPhone: widget.receiverPhone.toString(),
        type: '0',
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        senderPin: pref.pin.toString(),
        recPin: widget.recPin.toString());
  }

  //send song
  void sendsong({
    String songurl,
    String senderName,
    String senderPhone,
    String receiverPhone,
    String type, //3
    String timestamp,
    // int isUploaded,
    // String chatId
    String senderPin,
    String recPin,
  }) async {
    print('msg: $songurl');
    try {
      Common.isSongDownloaded(songurl, type);
      //add into privatechat
      sqlQuery
          .addPrivateChat(
              widget.chatId,
              songurl,
              type,
              timestamp,
              senderName,
              senderPhone,
              receiverPhone,
              '0', //isuploded
              "senderUrl",
              "thumbpath",
              "thumburl",
              senderPin,
              recPin)
          .then((onValue) {
        // setState(() {
        //   future = getAllChat(widget.chatId);
        // });
        //add sender's msg as last msg to privatechatlisttable sqlite
        sqlQuery
            .addPrivateChatList(widget.chatId, 'Audio', senderPhone,
                receiverPhone, timestamp, '0', senderPin, recPin)
            .then((onValue) {
          print('entry added in sqlite addchatlist');
        }, onError: (e) {
          print('show error message if addChatlist fails : $e');
        });
        print('sendername : $senderName');
        //add into fb privatechat
        addChatFb(
                senderName,
                songurl,
                senderPhone,
                type,
                receiverPhone,
                timestamp,
                '1',
                "senderUrl",
                "thumbpath",
                "thumburl",
                senderPin,
                recPin)
            .then((sent) {
          print('uploaded to fb');
          addChatFbChatList(widget.chatId, senderPhone, 'Audio', timestamp,
                  receiverPhone, "1", senderPin, recPin)
              .then((sent) {
            print('entry added in fb addchatlist');
          });
          // update isUpoaded
          // sqlQuery.updatePrivateChat(widget.chatId,senderName,songurl,);
        });
      }, onError: (e) {
        print('err : $e');
        Fluttertoast.showToast(msg: 'error while adding msg in Sqflite: $e');
      });
    } catch (e) {
      print('error while sending text: $e');
    }
  }

//send text
  void sendText(
      {String messageText,
      String senderName,
      String senderPhone,
      String receiverPhone,
      String type,
      String timestamp,
      String senderPin,
      String recPin}) async {
    print('recPin: $recPin');
    // print('timestamp: $timestamp');
    try {
      sqlQuery
          .addPrivateChat(
              widget.chatId,
              messageText,
              type,
              timestamp,
              senderName,
              senderPhone,
              receiverPhone,
              '1',
              "senderUrl",
              "thumbpath",
              "thumburl",
              senderPin,
              recPin)
          .then((onValue) {
        // setState(() {
        //   future = getAllChat(widget.chatId);
        // });
        print('sendername : $senderName');
        //add sender's msg as last msg to privatechatlisttable sqlite
        sqlQuery
            .addPrivateChatList(
                widget.chatId,
                messageText,
                pref.phone.toString(),
                receiverPhone,
                timestamp,
                '0',
                senderPin,
                recPin)
            .then((onValue) {
          print('entry added in sqflite addchatlist');
        }, onError: (e) {
          print('show error message if addChatlist fails : $e');
        });

        addChatFb(
                senderName,
                messageText,
                senderPhone,
                type,
                receiverPhone,
                timestamp,
                '1',
                "meadiaUrl",
                "thumbpath",
                "thumburl",
                senderPin,
                recPin)
            .then((sent) {
          print('uploaded to fb');
          addChatFbChatList(widget.chatId, senderPhone, messageText, timestamp,
                  receiverPhone, "1", senderPin, recPin)
              .then((sent) {
            print('entry added in fb addchatlist');
          });
        });
      }, onError: (e) {
        print('err : $e');
        Fluttertoast.showToast(msg: 'error while adding msg in Sqflite: $e');
      });
    } catch (e) {
      print('error while sending text: $e');
    }
  }

  //send image
  void sendImg(File img) async {
    try {
      print('galleryImage : ${img.path}');
      int timestamp = DateTime.now().millisecondsSinceEpoch;

      sqlQuery
          .addPrivateChat(
              widget.chatId,
              img.path, //org path
              "1", //msgType
              timestamp.toString(),
              pref.name,
              pref.phone.toString(),
              widget.receiverPhone.toString(),
              "0", //isUpload
              "mediaUrl", //firebase url.here no need
              "thumbpath",
              "thumburl",
              pref.pin.toString(),
              widget.recPin)
          .then((onValue) {
        print('senderName : ${pref.name}');
        //2.add privateChatListTable sqlite
        sqlQuery
            .addPrivateChatList(
                widget.chatId,
                'Image',
                pref.phone.toString(),
                widget.receiverPhone,
                timestamp.toString(),
                '0',
                pref.pin.toString(),
                widget.recPin)
            .then((onValue) {
          print('entry added in sqflite addchatlist:img');
        }, onError: (e) {
          print('show error message if addChatlist fails:img : $e');
        });

        // after adding orginal path in chat table just for showing quick image preview
        //3. now sideby side  do compress this media
        cmprsMedia.compressImage(img).then((compressedImageFile) {
          print('org img file path:${img.path}');
          print('compressedImageFile path :${compressedImageFile.path}');
          //4.now after compress put this file in desired path
          try {
            File newf = File(
                '${extDir.path}/OyeYaaro/Media/Img/.${widget.chatId}/${timestamp.toString()}.jpg');
            newf.createSync(recursive: true);
            compressedImageFile.copy(newf.path);

            //5.change previous path of privateChat table with desire path
            sqlQuery
                .updatePrivateChat(
                    widget.chatId,
                    pref.name,
                    newf.path, //new desired path(may be compressed)
                    pref.phone.toString(),
                    "1", //msgType
                    widget.receiverPhone.toString(),
                    timestamp.toString(),
                    "0", //isUpload
                    "mediaUrl", //firebase url.here no need
                    "thumbpath",
                    "thumburl",
                    pref.pin.toString(),
                    widget.recPin)
                .then((onValue) {
              print('updated res:$onValue');
            }, onError: (e) {
              print(
                  'Error while updating previous path of privateChat to desired path:$e');
            });

            // uplaod to fb
            uploadImage(
                    widget.chatId,
                    newf.path,
                    '1',
                    timestamp.toString(),
                    pref.name, //user profile name
                    pref.phone.toString(),
                    widget.receiverPhone,
                    pref.pin.toString(),
                    widget.recPin)
                .then((onValue) {
              print('image uploaded successfully');
            }, onError: (e) {
              print('Error while image uploading :$e');
            });
          } catch (e) {
            print('Error while copying compressed file:$e');
          }
        }, onError: (e) {
          print('Error from cmprsMedia.CompressImage():$e');
        });
      }, onError: (e) {
        print('err : $e');
        Fluttertoast.showToast(msg: 'error while adding Img in Sqlite:$e');
      });
    } catch (e) {
      print('error while uploading imge: $e');
    }
  }

  //send video
  void sendVid(File vid) async {
    try {
      print('org path :${vid.path}');
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      print('sendVid timestamp: $timestamp');

//vid thum folder
      String thumbPath = await Thumbnails.getThumbnail(
          thumbnailFolder:
              '${extDir.path}/OyeYaaro/Media/Thumbs/.${widget.chatId}', //$timestamp.jpg
          videoFile: vid.path,
          imageType: ThumbFormat.JPEG,
          quality: 30);
      print('sendVid thumbPath1: $thumbPath');

      //1. rename default thumbnail name to desired
      File newThumb = await File(thumbPath).rename(
        '${extDir.path}/OyeYaaro/Media/Thumbs/.${widget.chatId}/$timestamp.jpg',
      );
      print('sendVid thumbPath(rename): ${newThumb.path}'); //same

// 2.add in chat
      sqlQuery
          .addPrivateChat(
              widget.chatId,
              vid.path,
              '2',
              timestamp.toString(),
              pref.name,
              pref.phone.toString(),
              widget.receiverPhone.toString(),
              '0',
              "mediaUrl",
              newThumb.path,
              "thumbUrl",
              pref.pin.toString(),
              widget.recPin)
          .then((onValue) {
        // show loading
        setState(() {
          uploading = true;
          uploadingTimestamp = timestamp;
        });
        //3.add sender's msg as last msg to privatechatlisttable sqlite
        sqlQuery
            .addPrivateChatList(
                widget.chatId,
                'Video',
                pref.phone.toString(),
                widget.receiverPhone,
                timestamp.toString(),
                '0',
                pref.pin.toString(),
                widget.recPin)
            .then((onValue) {
          print('entry added in sqflite addchatlist');
        }, onError: (e) {
          print('show error message if addChatlist fails : $e');
        });

        // 4.call compress function
        cmprsMedia
            .compressVideo(
                vid,
                '${extDir.path}/OyeYaaro/Media/Vid/.${widget.chatId}',
                '$timestamp')
            .then((compressedVideoFile) {
          print('org img file path:${vid.path}');
          print(
              'compressedImageFile path :${compressedVideoFile.path}'); //compressed and copied to desired path

          //5.change previous path of privateChat table with desire path
          sqlQuery
              .updatePrivateChat(
                  widget.chatId,
                  pref.name,
                  compressedVideoFile.path, //new desired path(compressed)
                  pref.phone.toString(),
                  "2", //msgType
                  widget.receiverPhone.toString(),
                  timestamp.toString(),
                  "0", //isUpload
                  "mediaUrl", //firebase url.here no need
                  newThumb.path,
                  "thumburl",
                  pref.pin.toString(),
                  widget.recPin)
              .then((onValue) {
            print('updated to compressed vid path:$onValue');
          }, onError: (e) {
            print(
                'Error while updating previous path of privateChat to desired path:$e');
          });

          // uplaod to fb
          uploadVideo(
                  widget.chatId,
                  compressedVideoFile,
                  '2',
                  timestamp.toString(),
                  pref.name,
                  pref.phone.toString(),
                  widget.receiverPhone.toString(),
                  newThumb.path,
                  pref.pin.toString(),
                  widget.recPin)
              .then((onValue) {
            print('Video uploaded successfully');
          }, onError: (e) {
            print('Error while Video uploading :$e');
          });
        }, onError: (e) {
          print('Error from cmprsMedia.CompressImage():$e');
        });
      }, onError: (e) {
        print('err : $e');
        Fluttertoast.showToast(msg: 'error while adding Img in Sqlite:$e');
      });
    } catch (e) {
      print('error while uploading imge: $e');
    }
  }

  Future uploadImage(
      String chatId,
      String imgPath, //newPath
      String type,
      String timestamp,
      String senderName,
      String senderPhone,
      String receiverPhone,
      String senderPin,
      String recPin) async {
    try {
      setState(() {
        uploading = true;
        uploadingTimestamp = int.parse(timestamp);
      });

      Future.delayed(const Duration(seconds: 30), () {
        setState(() {
          uploading = false;
          uploadingTimestamp = 0;
        });
      });

      //call firebase storeage
      storage.uploadImage(timestamp.toString(), File(imgPath)).then(
          (firebaseUrl) {
        print('firebase mediaUrl : $firebaseUrl');
        setState(() {
          uploading = false;
          uploadingTimestamp = 0;
        });
        //add url to fb
        addChatFb(
                senderName,
                imgPath,
                senderPhone,
                type,
                receiverPhone,
                timestamp,
                '1',
                firebaseUrl.toString(),
                "",
                "",
                senderPin,
                recPin)
            .then((sent) {
          print('img path uploaded to fb');
          //now update query for isUploaded = 1 on this chatId row
          sqlQuery
              .updatePrivateChat(
                  widget.chatId,
                  senderName,
                  imgPath,
                  senderPhone,
                  type,
                  receiverPhone,
                  timestamp,
                  '1',
                  firebaseUrl.toString(),
                  "",
                  "",
                  senderPin,
                  recPin)
              .then((onValue) async {
            print('updated data timestamp: $timestamp');
          }, onError: (e) {
            print('error while updating chat: $e');
          });

          //add image as last msg to fb chatlist
          addChatFbChatList(widget.chatId, senderPhone, 'Image', timestamp,
                  receiverPhone, "1", senderPin, recPin)
              .then((sent) {
            print('entry added in fb addchatlist');
          });
        });
      }, onError: (e) {
        print('error while uploading to fb_storage : $e');
      });
    } catch (e) {
      print('Err in upload image function: ' + e);
    }
  }

  Future uploadVideo(
      String chatId,
      File vidFile,
      String type,
      String timestamp,
      String senderName,
      String senderPhone,
      String receiverPhone,
      String thumbPath,
      String senderPin,
      String recPin) async {
    try {
      setState(() {
        uploading = true;
        uploadingTimestamp = int.parse(timestamp);
      });

      Future.delayed(const Duration(seconds: 30), () {
        setState(() {
          uploading = false;
          uploadingTimestamp = 0;
        });
      });

      // File videoFile = new File(vidPath);
      // show in chatscreen //to add text below the image redirect path to new screen and write get text logic

      //call firebase storage
      //get thumb url
      String thumbUrl =
          await storage.uploadImage(timestamp.toString(), File(thumbPath));

      print('videos thumbUrl : $thumbUrl ................');
      storage.uploadVideo(timestamp.toString(), vidFile).then((firebaseUrl) {
        print('firebase VideoUrl : $firebaseUrl');

        setState(() {
          uploading = false;
          uploadingTimestamp = 0;
        });

        //add url to fb
        addChatFb(
                senderName,
                vidFile.path,
                senderPhone,
                type,
                receiverPhone,
                timestamp,
                '1',
                firebaseUrl.toString(),
                thumbPath,
                thumbUrl,
                senderPin,
                recPin)
            .then((sent) {
          print('vid path uploaded to fb:$thumbPath');
          //now update query for isUploaded = 1 on this chatId row
          sqlQuery
              .updatePrivateChat(
                  widget.chatId,
                  senderName,
                  vidFile.path,
                  senderPhone,
                  type,
                  receiverPhone,
                  timestamp,
                  '1',
                  firebaseUrl.toString(),
                  thumbPath,
                  thumbUrl,
                  senderPin,
                  recPin)
              .then((onValue) async {
            print('updated data vid timestamp: $timestamp');
          }, onError: (e) {
            print('error while updating chat: $e'); //show UI msg ex.toast
          });

          // add to fb chatlist
          addChatFbChatList(widget.chatId, senderPhone, 'Video', timestamp,
                  receiverPhone, "1", senderPin, recPin)
              .then((sent) {
            print('entry added in fb addchatlist');
          });
        });
      }, onError: (e) {
        print('error while uploading to fb_storage : $e');
        // throw e//change whole send video function structure with completer
      });
    } catch (e) {
      print('Err in getCameraImage: ' + e);
    }
  }

// put this fun in provider to make common for Pchat and sharedVideo
  Future addChatFb(
      senderName,
      messageText,
      senderPhone,
      type,
      receiverPhone,
      timestamp,
      isUploaded,
      mediaUrl,
      thumbPath,
      thumbUrl,
      senderPin,
      recPin) async {
    print('thumbPath : $thumbPath');
    //make common
    _messagesreference.push().set(<String, String>{
      'chatId': widget.chatId,
      'senderName': senderName,
      'msgMedia': messageText,
      'senderPhone': senderPhone,
      'msgType': type,
      'receiverPhone': receiverPhone,
      'timestamp': timestamp,
      'isUploaded': isUploaded,
      'mediaUrl': mediaUrl,
      'thumbPath': thumbPath,
      'thumbUrl': thumbUrl,
      'chatType': 'private',
      'senderPin': senderPin,
      'recPin': recPin
    });
  }

  Future addChatFbChatList(
      String chatId,
      String senderPhone,
      String msg,
      String timestamp,
      String receiverPhone,
      String count,
      String senderPin,
      String recPin) async {
    print('in addChatFbChatList():');
    DatabaseReference privateChatRef = FirebaseDatabase.instance
        .reference()
        .child('privateChatList')
        .child(chatId);

    var data = {
      "chatId": chatId,
      "senderPhone": senderPhone,
      "msg": msg,
      "timestamp": timestamp,
      'recPhone': receiverPhone,
      "count": count,
      "senderPin": senderPin,
      "recPin": recPin
    };
    try {
      privateChatRef.set(data).then((onValue) {
        print('uploaded to fb private chat list');
        return '';
      });
    } catch (e) {
      print('err while updating data to fbchatlist');
    }
  }

  //song play stop pause
  Future<int> play(url, songName) async {
    try {
      print('in play() url:$url');
      print('in play() songName:$songName');

      setState(() {
        position = null;
        duration = null;
      });
      final result = await audioPlayer.play(url, isLocal: true);
      if (result == 1)
        setState(() {
          playerState = PlayerState.playing;
          isPlaying = true;
          playingSongInList = songName;
          print('playing');
        });
      return result;
    } catch (e) {
      print('Error while playing song:$e');
      return e;
    }
  }

  Future<int> pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) setState(() => playerState = PlayerState.paused);
    return result;
  }

  Future<int> stop() async {
    final result = await audioPlayer.stop();
    if (result == 1) {
      setState(() {
        playerState = PlayerState.stopped;
        position = new Duration();
        isPlaying = false;
      });
    }
    return result;
  }
}
