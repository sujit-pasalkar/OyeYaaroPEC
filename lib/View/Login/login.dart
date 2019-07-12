//flutter
import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart' as prefix0;
import 'package:oye_yaaro_pec/Components/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// plugins
import 'package:firebase_auth/firebase_auth.dart';
// pages
import 'pin.dart';
// models
import '../../Models/sharedPref.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _otpCtrl = TextEditingController();
  TextEditingController _phone = TextEditingController();

  List<DropdownMenuItem<String>> _countryCodes = [];
  String phoneNo, smsCode = '', verificationId, _countryCode;
  bool userVerified = false,
      loading = false,
      smsCodeSent = false,
      verifybtn,
      allowExit = false;
  Timer _timer;
  int _start = 45;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void loadData() {
    _countryCodes = [];
    _countryCodes.add(
      new DropdownMenuItem(
          child: new Text(
            'India',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          value: '+91'),
    );
    
    _countryCodes.add(new DropdownMenuItem(
        child: new Text(
          'United States',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        value: '+1'));
  }

  void timer() {
    print('in timer');
    setState(() {
      _start = 45;
    });
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
            () {
              if (_start < 1) {
                timer.cancel();
              } else {
                _start = _start - 1;
                print('time remain $_start');
              }
            },
          ),
    );
  }

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
      print('**.AutoRetrivalTimeOut**');
    };

    final PhoneCodeSent smsCodeSent =
        (String verId, [int forceCodeResend]) async {
      this.verificationId = verId;
      print("2.smsSent_verifyid" + this.verificationId);
      setState(() {
        this.loading = false;
        this.smsCodeSent = true;
      });
      timer();
    };

    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser user) {
      // print('**4.verified**');
      setState(() {
        this.loading = false;
      });
      register();
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      // print('*5*Err ${exception.message}');
      setState(() {
        this.loading = false;
      });
      final snackBar = SnackBar(
        content: Text(exception.message),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    };

    await FirebaseAuth.instance
        .verifyPhoneNumber(
            phoneNumber: this._countryCode + this.phoneNo,
            codeAutoRetrievalTimeout: autoRetrieve,
            codeSent: smsCodeSent,
            timeout: const Duration(seconds: 45),
            verificationCompleted: verifiedSuccess,
            verificationFailed: veriFailed)
        .then((value) {
      // print('AFTER Verification');
    });
  }

 

  Future<void> register() async {
    print('register $phoneNo');
    _timer.cancel();
    pref.setPhone(int.parse(phoneNo));

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        '$_countryCode $phoneNo Verified Successfully.',
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green[400],
    ));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Pin(),
      ),
    );
  }

  signIn(String smscode) async {
    FirebaseAuth.instance
        .signInWithPhoneNumber(verificationId: verificationId, smsCode: smscode)
        .then((user) {
      print('auth user is ----> $user');
      this.register();
    }, onError: (e) {
      print('incorrect otp :$e');
      final snackBar = SnackBar(
          content: Text('We couldn\'t verify your code, please try again!'),
          backgroundColor: Colors.redAccent);
      _scaffoldKey.currentState.showSnackBar(snackBar);
      setState(() {
        this.loading = false;
      });
    });
  }

  phoneConfirmAlert() async {
    if (formKey.currentState.validate()) {
      if (this._countryCode == null) {
        final snackBar = SnackBar(
            content: Text("Select country code!"),
            backgroundColor: Colors.redAccent);
        _scaffoldKey.currentState.showSnackBar(snackBar);
      } else {
        setState(() {
          this.loading = true;
          verifybtn = false;
        });
        formKey.currentState.save();
        verifyPhone();
      }
    } else
      print("invalid form");
  }

  @override
  Widget build(BuildContext context) {
    loadData();
    return new Scaffold(
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
            smsCodeSent
                ? SafeArea(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          smsCodeSent = false;
                          smsCode = '';
                          _otpCtrl.text = '';
                          verifybtn = true;
                          _timer.cancel();
                          _start = 45;
                        });
                      },
                    ),
                  )
                : SizedBox(),
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
    if (smsCodeSent) {
      setState(() {
        smsCodeSent = false;
      });
      return Future.value(false);
    }
    if (allowExit) {
      return Future.value(true);
    }
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Container(
        child: Text(
          "Press again to exit from appliction",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      duration: Duration(seconds: 4),
    ));
    setState(() {
      allowExit = true;
    });
    Timer(Duration(seconds: 4), () {
      setState(() {
        allowExit = false;
      });
    });
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
                child: !smsCodeSent
                    ? Column(
                        children: <Widget>[
                          Text(
                            "Verify your phone number",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0,
                                color: Colors.white),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                          ),
                          Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.only(left: 10.0),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1.0, color: Colors.white))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                style: TextStyle(color: Colors.white),
                                value: _countryCode,
                                items: _countryCodes,
                                hint: Text(
                                  'Select Country',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onChanged: (value) {
                                  _countryCode = value;
                                  setState(() {
                                    _countryCode = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10.0),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1.0, color: Colors.white))),
                            child: Form(
                                key: formKey,
                                autovalidate: true,
                                child: Column(children: <Widget>[
                                  Table(
                                    columnWidths: {1: FractionColumnWidth(.8)},
                                    children: [
                                      TableRow(children: [
                                        Container(
                                          padding: EdgeInsets.fromLTRB(
                                              10.0, 11.0, 0.0, 0.0),
                                          child: Text(
                                            (_countryCode == null)
                                                ? ('+1')
                                                : _countryCode,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        TextField(
                                          controller: _phone,
                                          style: TextStyle(color: Colors.white),
                                          maxLength:
                                              10, //_countryCode == null?  US_len :IND_len,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Enter Phone Number',
                                            hintStyle:
                                                TextStyle(color: Colors.white),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (input) {
                                            print(input);
                                            if (input.length == 10) {
                                              setState(() {
                                                verifybtn = true;
                                                this.phoneNo = input;
                                              });
                                            } else {
                                              setState(() {
                                                verifybtn = false;
                                              });
                                            }
                                          },
                                        ),
                                      ]),
                                    ],
                                  ),
                                ])),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Center(
                              child: Text(
                                'You will receive OTP on this number',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          )
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          Text(
                            "Verification Code",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18.0,
                                color: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14.0,
                                    color: Colors.grey[350]),
                                children: <TextSpan>[
                                  TextSpan(text: 'One '),
                                  TextSpan(text: 'time '),
                                  TextSpan(text: 'password '),
                                  TextSpan(text: 'has '),
                                  TextSpan(text: 'been '),
                                  TextSpan(text: 'send '),
                                  TextSpan(text: 'to \n'),
                                  TextSpan(
                                    text: '$_countryCode $phoneNo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontStyle: prefix0.FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextField(
                            controller: _otpCtrl,
                            style: TextStyle(color: Colors.white, fontSize: 30),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                              ),
                              counterStyle: TextStyle(
                                color: Colors.white,
                              ),
                              hintText: "--- ---",
                              hintStyle:
                                  TextStyle(color: Colors.white, fontSize: 40),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            onChanged: (otp) {
                              setState(() {
                                smsCode = otp;
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                FlatButton(
                                    color: Colors.white30,
                                    child: Text(
                                      _start < 1
                                          ? 'Resend'
                                          : 'Resend ($_start sec)',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontStyle: FontStyle.italic),
                                    ),
                                    onPressed: _start < 1
                                        ? () {
                                            setState(() {
                                              _start = 45;
                                            });
                                            verifyPhone();
                                          }
                                        : null),
                                RaisedButton(
                                  child: Text(
                                    'Verify',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.indigo,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  onPressed: () {
                                    if (smsCode.length == 6) {
                                      setState(() {
                                      loading = true;
                                    });

                                      FirebaseAuth.instance
                                          .currentUser()
                                          .then((user) {
                                        print('user $user');
                                        if (user != null) {
                                          register();
                                          print('user:$user');
                                          print("phone" + this.phoneNo);
                                        } else {
                                          signIn(this.smsCode);
                                        }
                                      });
                                    } else {
                                      // setState(() {
                                      //   this.loading = false;
                                      // });
                                      final snackBar = SnackBar(
                                        content: Text("Enter 6-digit OTP"),
                                        backgroundColor: Colors.redAccent,
                                      );
                                      _scaffoldKey.currentState
                                          .showSnackBar(snackBar);
                                    }
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
              ),
            ],
          ),
        ),
        smsCodeSent
            ? SizedBox()
            : Container(
                padding: EdgeInsets.fromLTRB(60, 0, 60, 30),
                child: SizedBox(
                  height: 50.0,
                  child: RaisedButton(
                    child: Text(
                      'Verify',
                      style: TextStyle(color: Colors.indigo, fontSize: 18),
                    ),
                    splashColor: Colors.white,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    onPressed: () {
                      if (verifybtn == null) {
                        setState(() {
                          verifybtn = false;
                        });
                        // print('${this._countryCode}-$phoneNo');
                      } else if (verifybtn) {
                        // print('${this._countryCode}-$phoneNo');
                        phoneConfirmAlert();
                      } 
                      // else {
                      //   print('${this._countryCode}-$phoneNo');
                      // }
                    },
                  ),
                ),
              ),
      ],
    );
  }
}
