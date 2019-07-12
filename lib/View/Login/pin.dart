//flutter
import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// pages
import 'package:oye_yaaro_pec/Components/loader.dart';
import './userService.dart';
import '../../View/home.dart';
import 'package:oye_yaaro_pec/Provider/ContactOperations/contact_operations.dart';

class Pin extends StatefulWidget {
  @override
  _PinState createState() => _PinState();
}

class _PinState extends State<Pin> {
  final formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _pin = TextEditingController();

  String pin = '';
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: true,
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/login.png'))),
              child: body(),
            ),
            Loader(
              loading: loading,
            ),
          ],
        ),
        onWillPop: _onBackPress,
      ),
    );
  }

  Future<bool> _onBackPress() {
    return Future.value(false);
  }

  Widget body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: 35),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(15.0),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.zero,
                    child: Text(
                      'Oye',
                      style: TextStyle(
                        letterSpacing: 0.9,
                        color: Colors.white,
                        fontSize: 60.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.zero,
                    child: Text(
                      'Yaaro',
                      style: TextStyle(
                        letterSpacing: 0.9,
                        color: Colors.white,
                        fontSize: 60.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 50.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Login with your PIN",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18.0,
                          color: Colors.white),
                    ),
                    Padding(
                      padding: EdgeInsets.all(18.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14.0,
                              color: Colors.grey[350]),
                          children: <TextSpan>[
                            TextSpan(text: 'Use '),
                            TextSpan(text: 'your '),
                            TextSpan(text: 'unique '),
                            TextSpan(text: 'numeric '),
                            TextSpan(text: 'PIN '),
                            TextSpan(text: 'to '),
                            TextSpan(text: 'login \n'),
                            TextSpan(text: 'into the App \n'),
                          ],
                        ),
                      ),
                    ),
                    TextField(
                      controller: _pin,
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white, fontSize: 30),
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        counterStyle: TextStyle(
                          color: Colors.white,
                        ),
                        hintText: "Enter your PIN",
                        hintStyle: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      onChanged: (val) {
                        setState(() {
                          pin = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(60, 0, 60, 30),
          child: SizedBox(
            height: 50.0,
            child: RaisedButton(
              child: Text(
                'Login',
                style: TextStyle(color: Colors.indigo, fontSize: 18),
              ),
              splashColor: Colors.white,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              onPressed: () async {
                if (pin.length == 6) {
                  setState(() {
                    loading = true;
                  });
                  // verify
                  try {
                    String res = await UserService.checkUser(pin);
                    print('res:$res');
                    if (res == 'true') {
                     String val = await co.getContacts();
                      print('go to home:$val');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    } else {
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text("Incorrect PIN."),
                        backgroundColor: Colors.redAccent,
                      ));
                    }
                    setState(() {
                      loading = false;
                    });
                  } catch (e) {
                    print('Error:$e');
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text("Error while login"),
                      backgroundColor: Colors.redAccent,
                    ));
                    setState(() {
                      loading = false;
                    });
                  }
                } else {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text("Enter 6-digit PIN"),
                    backgroundColor: Colors.redAccent,
                  ));
                }
              },
            ),
          ),
        )
      ],
    );
  }
}
