import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogoutWidget extends StatefulWidget {
  // final BuildContext context ;

  // LogoutWidget({this.context, Key key}) : super(key: key);

  @override
  _LogoutWidgetState createState() => _LogoutWidgetState();
}

class _LogoutWidgetState extends State<LogoutWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: Color(0xffb00bae3),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 80.0,
                child: Column(
                  children: <Widget>[
                    Text(
                      'Logout',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                    ),
                    Text(
                      'Are you sure to logout from app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                child: Row(
                  children: <Widget>[
                    SimpleDialogOption(
                      onPressed: () {
                        print('pressed cancel');
                        Navigator.pop(context, 0);
                      },
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Icon(
                              Icons.cancel,
                              color: Color(0xffb00bae3),
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
                        print('pressed yes');
                        // DatabaseOperation.deleteChatList();
                        FirebaseAuth.instance.signOut().then((action) {
                          pref.clearUser();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/loginpage', (Route<dynamic> route) => false);
                        });
                      },
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Icon(
                              Icons.check_circle,
                              color: Color(0xffb00bae3),
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
                ),
              )
            ],
          ),
    );
  }
}