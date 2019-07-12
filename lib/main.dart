// flutter
import 'dart:async';
import 'package:oye_yaaro_pec/View/Profile/profile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/services.dart';
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
          '/profile': (BuildContext context) => Profile(),
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
  static const platform =
      const MethodChannel('com.plmlogix.contacts_chat/platform');
  bool isLoggedIn = false;
  bool permissionButton = true;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  DatabaseReference _onlineStatusReference;
  StreamSubscription<Event> _onlineStatusSubscription;

  @override
  void initState() {
    db.onReady.then((_) async {
      print("STATE: THE DATABASE IS READY");
     await checkPermission();
      pref.getValues().then((onValue) {
        // print('${pref.phone}');
        checkUserProfile();
      });
    });

    _onlineStatusReference = database.reference().child('.info/connected');
    _onlineStatusSubscription =
        _onlineStatusReference.onValue.listen((Event event) {
      print('EVENT has occured:${event.snapshot.value}');
      // pref.connectionListener = event.snapshot.value;
      // connection listener
      // event.snapshot.value
      //     ? Fluttertoast.showToast(msg: 'you are online')
      //     : Fluttertoast.showToast(msg: 'you are offline');
    });

    super.initState();
  }

  @override
  void dispose() {
    // _onlineStatusSubscription.cancel();
    super.dispose();
  }

  Future<String> checkPermission() async {
    try {
      await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
      await SimplePermissions.requestPermission(
          Permission.WriteExternalStorage);
      await SimplePermissions.requestPermission(Permission.Camera);
      await SimplePermissions.requestPermission(Permission.AccessFineLocation);
      await SimplePermissions.requestPermission(Permission.RecordAudio);
      await SimplePermissions.requestPermission(Permission.PhotoLibrary);
      await SimplePermissions.requestPermission(Permission.ReadContacts);
      await SimplePermissions.requestPermission(Permission.WriteContacts);
      await SimplePermissions.requestPermission(Permission.ReadPhoneState);

      return "result";
    } catch (e) {
      // print('Got Error while getting Permissions : $e');
      return e;
    }
  }

  checkUserProfile() async {
    grantPermission();
  }

  grantPermission() async {
    bool checkReadContacts =
        await SimplePermissions.checkPermission(Permission.ReadContacts);
    bool checkReadExternalStorage =
        await SimplePermissions.checkPermission(Permission.ReadExternalStorage);
    bool checkWriteExternalStorage = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);

    print("permission is " + checkReadContacts.toString());
    if (!checkReadContacts ||
        !checkReadExternalStorage ||
        !checkWriteExternalStorage) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('App Permission not Granted.'),
        duration: Duration(seconds: 3),
      ));
      setState(() {
        permissionButton = false;
      });
    } else {
      // setState(() {
      //   permissionButton = true;
      // });

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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
      } else {
        Navigator.of(context).pushReplacementNamed('/loginpage');
      }
    }
  }

  Future<bool> registerusersinch() async {
    var sendMap = <String, dynamic>{
      'from': pref.phone.toString().replaceAll('+91', '').replaceAll('+1', ''),
    };
    String result;
    try {
      result = await platform.invokeMethod('registersinch', sendMap);
    } on PlatformException catch (e) {}
    return true;
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
                    // fontFamily: Font
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
                      await SimplePermissions.requestPermission(
                          Permission.ReadExternalStorage);

                      await SimplePermissions.requestPermission(
                          Permission.WriteExternalStorage);
                      await SimplePermissions.requestPermission(
                          Permission.ReadContacts);

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

// import 'package:flutter/material.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.display1,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
