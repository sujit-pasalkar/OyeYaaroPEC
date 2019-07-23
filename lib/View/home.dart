// dart
import 'package:oye_yaaro_pec/Components/logout.dart';
import 'package:oye_yaaro_pec/View/Feeds/feeds.dart';
import 'package:oye_yaaro_pec/View/recording/video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'dart:async';
// pub
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// page
import '../View/Personal/chat_list.dart';
import '../View/Group/group_list.dart';
import 'imageProcessor/dashboard2.dart';

// mvp
import '../Models/sharedPref.dart';
import 'package:gradient_bottom_navigation_bar/gradient_bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController hideButtonController;

  bool _isBottomBarVisible, exitApp = false;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  PageStorageKey feedsKey = PageStorageKey('Feeds');
  PageStorageKey personalKey = PageStorageKey('personalKey');
  PageStorageKey groupsKey = PageStorageKey('groupsKey');
  PageStorageKey recordingsKey = PageStorageKey('RecordingsKey');

  @override
  void initState() {
    super.initState();

    //fcm
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.getToken().then((token) {
      print('${pref.phone}:$token added.');
      var documentReference = Firestore.instance
          .collection('userTokens')
          .document(pref.phone.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {'token': token, 'id': pref.phone},
        );
      });
    });

    _isBottomBarVisible = false;
    hideButtonController = new ScrollController();
    hideButtonController.addListener(() {
      if (hideButtonController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _isBottomBarVisible = false;
        });
      }
      if (hideButtonController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _isBottomBarVisible = true;
        });
      }
      if (hideButtonController.offset == 0.0) {
        setState(() {
          _isBottomBarVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    print('home dispose called');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: WillPopScope(
          child: buildBody(),
          onWillPop: onBackPress,
        ),
        bottomNavigationBar:
            //  !_isBottomBarVisible ?
            bottomBar()
        // : SizedBox(),
        );
  }

  buildBody() {
    switch (pref.currentIndex) {
      case 0:
        return Feeds(
          hideButtonController: hideButtonController,
          key: feedsKey,
        );
        break;

      case 1:
        return RecordedVideoScreen(
          hideButtonController: hideButtonController,
          key: recordingsKey,
        );
        break;

      case 2:
        return ChatList(
          hideButtonController: hideButtonController,
          key: personalKey,
          // isBottomBarVisible:_isBottomBarVisible
        );
        break;

      case 3:
        return GroupList(
          hideButtonController: hideButtonController,
          key: groupsKey,
        );
        break;

      case 4:
        return ImageProcessor();
        break;
    }
  }

  bottomBar() {
    return GradientBottomNavigationBar(
      backgroundColorStart: Color(0xffb578de3).withOpacity(0.9),
      backgroundColorEnd: Color(0xffb4fcce0).withOpacity(0.9),
      currentIndex: pref.currentIndex,
      type: BottomNavigationBarType.fixed,
      fixedColor: Colors.white,
      iconSize: 30,
      onTap: (int index) {
        // if (index == 4) {
        //   Navigator.of(context)
        //       .push(MaterialPageRoute(builder: (context) => ImageProcessor()));
        // } else {
        setState(() {
          pref.currentIndex = index;
        });
        // }
      },
      items: <BottomNavigationBarItem>[
        // 1
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: Colors.white,
          ),
          activeIcon: Icon(
            Icons.home,
            color: Colors.black,
          ),
          title: SizedBox(
            height: 0.0,
            width: 0.0,
          ),
        ),
        // 2
        BottomNavigationBarItem(
          icon: Image(
            image: new AssetImage("assets/VIDEO_BACKGROUND.png"),
            color: Colors.white,
            width: 40.0,
            height: 40.0,
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
          ),
          activeIcon: Image(
            image: AssetImage("assets/VIDEO_BACKGROUND.png"),
            color: Colors.black,
            width: 40.0,
            height: 40.0,
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
          ),
          title: SizedBox(
            height: 0.0,
            width: 0.0,
          ),
        ),
        // 3
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: Colors.white,
          ),
          activeIcon: Icon(
            Icons.person,
            color: Colors.black,
          ),
          title: SizedBox(
            height: 0.0,
            width: 0.0,
          ),
        ),
          //4
        BottomNavigationBarItem(
          icon: Image(
            image: new AssetImage("assets/GROUP.png"),
            color: Colors.white,
            width: 40.0,
            height: 40.0,
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
          ),
          activeIcon: Image(
            image: new AssetImage("assets/GROUP.png"),
            color: Colors.black,
            width: 40.0,
            height: 40.0,
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
          ),
          title: SizedBox(
            height: 0.0,
            width: 0.0,
          ),
        ),
          //5
        BottomNavigationBarItem(
          icon: Icon(
            Icons.movie_filter,
            color: Colors.white,
          ),
          activeIcon: Icon(
            Icons.movie_filter,
            color: Colors.black,
          ),
          title: SizedBox(
            height: 0.0,
            width: 0.0,
          ),
        ),
      ],
    );
  }

  Future<bool> onBackPress() {
    closeApp();
    return Future.value(false);
  }

  Future<Null> closeApp() async {
    //change to double tapp exit
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: Color(0xffb00bae3),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                  LogoutWidget();
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }
}
