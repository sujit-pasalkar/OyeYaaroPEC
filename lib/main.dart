// flutter
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
//pages
import './Theme/theme.dart';
import './View/Login/login.dart';
import './View/home.dart';
import './View/Login/pin.dart';
//model
import './Models/sharedPref.dart';
//provider
import './Provider/SqlCool/database_creator.dart';

void main() async {
  DatabaseCreator().initDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: defaultTargetPlatform == TargetPlatform.iOS
            ? Themes.kIOSTheme
            : Themes.kDefaultTheme,
        home: MainPage(),
        routes: <String, WidgetBuilder>{
          '/loginpage': (BuildContext context) => LoginPage(),
          '/home': (BuildContext context) => HomePage(),
        });
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isLoggedIn = false;
  bool permissionButton = true;
  Map<PermissionGroup, PermissionStatus> permissions;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    db.onReady.then((_) async {
      print("STATE: THE DATABASE IS READY");
      await requestPermission();
      pref.getValues()
      .then((onValue) {
        checkUserProfile();
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> requestPermission() async {
    try {

      permissions = await PermissionHandler()
          .requestPermissions([PermissionGroup.storage]);
      await PermissionHandler().requestPermissions([PermissionGroup.camera]);
      await PermissionHandler()
          .requestPermissions([PermissionGroup.microphone]);
      await PermissionHandler()
          .requestPermissions([PermissionGroup.speech]); //ios
      await PermissionHandler().requestPermissions([PermissionGroup.photos]);
      await PermissionHandler()
          .requestPermissions([PermissionGroup.mediaLibrary]); //ios
      await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
      await PermissionHandler().requestPermissions([PermissionGroup.phone]);
      await PermissionHandler().requestPermissions([PermissionGroup.sensors]);
    } catch (e) {
      print('Got Error while getting Permissions : $e');
    }
  }

  checkUserProfile() async {
    grantPermission();
  }

  grantPermission() async {
    PermissionStatus permission1 = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    PermissionStatus permission2 = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (permission1.value == 0 || permission2.value == 0) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('App Permission not Granted.'),
        duration: Duration(seconds: 1),
      ));
      setState(() {
        permissionButton = false;
      });
    } else {
      if (pref.phone != null) {
        print('Phone Verified.');
        if (pref.pin == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Pin(),
            ),
          );
        } else
           Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/loginpage');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.3, 0.4, 0.5, 0.6, 0.7, 0.8],
                colors: [
                  Color(0xffb00ddf0),
                  Color(0xffb00dcf2),
                  Color(0xffb00bae3),
                  Color(0xffb008bd0),
                  Color(0xffb0081cc),
                  Color(0xffb0082cd),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Oye Yaaro",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 40.0,
                  ),
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                Text(
                  "Relive Nostalgia!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
          !permissionButton
              ? Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: FlatButton.icon(
                    textColor: Colors.white,
                    icon: Icon(Icons.chevron_right),
                    label: Text('Allow Permission'),
                    onPressed: () async {
                      await PermissionHandler()
                          .requestPermissions([PermissionGroup.contacts]);
                      await PermissionHandler()
                          .requestPermissions([PermissionGroup.storage]);

                      grantPermission();
                    },
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }
}