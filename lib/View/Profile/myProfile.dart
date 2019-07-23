// show your's and others profile 
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Models/url.dart';
import 'package:oye_yaaro_pec/Provider/Firebase/firebase_storage_operations.dart';
import 'package:oye_yaaro_pec/Provider/MediaOperation/compressMedia.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/database_creator.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:oye_yaaro_pec/View/Feeds/userFeedBuilder.dart';
import 'package:oye_yaaro_pec/View/Personal/personal_chatScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class MyProfile extends StatefulWidget {
  final int phone;
  MyProfile({@required this.phone});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<MyProfile> {
  static const platform =
      const MethodChannel('com.plmlogix.oye_yaaro_pec/platform');

      final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // profile
  DatabaseReference _profileReference;
  TextEditingController _textEditingController = new TextEditingController();
  String photoPath, firebaseUrl = '';
  bool _isLoading = false, edit = false, textEdit = false;
  int postCount;

// your post
  List<UserFeedBuilder> feedData = [];
  List<Map<String, dynamic>> originalData;
  bool postLoading = true;
  ScrollController hideButtonController;

// screen
  GlobalKey<State> profileContainer = GlobalKey<State>();
  double width, height;

  @override
  void initState() {
    // print('${pref.phone} and ${widget.phone}');
    // profile
    _profileReference =
        database.reference().child('profiles').child(widget.phone.toString());

    // post
    hideButtonController = new ScrollController();
    this._loadFeed();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              pref.phone == widget.phone ? 'Your Profile' : 'Profile Info',
              style: TextStyle(color: Colors.white),
            ),
            actions: <Widget>[
              pref.phone == widget.phone
                  ? !edit
                      ? IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              edit = !edit;
                            });
                          },
                        )
                      : IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            upload(context);
                          },
                        )
                  : SizedBox(),
                  // IconButton(
                    //   icon: Icon(Icons.call),
                    //   onPressed: () {
                    //     audioCall();
                    //   },
                    // ),
              pref.phone != widget.phone
                  ? IconButton(
                      icon: Icon(Icons.message),
                      onPressed: () async {
                        List<Map<String, dynamic>> row;
                        try {
                          // get contact name
                          row = await sqlQuery
                              .getContactName(widget.phone.toString());
                          // print('name res:${row[0]['contactsName']}');
                          chat(row[0]['contactsName']);
                        } catch (e) {
                          // print('i dont have this number :$e');
                          chat(widget.phone.toString());
                        }
                      },
                    )
                  : SizedBox(),
              _menuBuilder(),
            ],
            flexibleSpace: FlexAppbar(),
          ),
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover, image: AssetImage('assets/login.png'))),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    StreamBuilder(
                      stream: _profileReference.onValue,
                      builder: (context, snap) {
                        if (snap.hasData &&
                            !snap.hasError &&
                            snap.data.snapshot.value != null) {
                          // has data old user
                          firebaseUrl =
                              snap.data.snapshot.value['profileImg'].toString();
                          if (!textEdit) {
                            _textEditingController.text =
                                snap.data.snapshot.value['name'].toString();
                          }
                          textEdit = true;
                          return Container(
                            height: MediaQuery.of(context).size.height / 3,
                            padding: EdgeInsets.fromLTRB(10, 15, 10, 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                edit
                                    ? Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(15),
                                          child: TextField(
                                            style:
                                                TextStyle(color: Colors.white),
                                            autofocus: !_isLoading,
                                            cursorColor: Colors.white,
                                            maxLength: 25,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            controller: _textEditingController,
                                            decoration: InputDecoration(
                                              hintText: "Type your name here",
                                              hintStyle: TextStyle(
                                                  color: Colors.white70),
                                            ),
                                            onChanged: (messageText) {
                                              print(messageText);
                                            },
                                            onTap: () {
                                              print('ontapp.');
                                            },
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              '${_textEditingController.text}',
                                              softWrap: true,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 30),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20),
                                              child: Text(
                                                '${widget.phone}',
                                                softWrap: true,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 20),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                GestureDetector(
                                    onTap: edit
                                        ? () {
                                            openBottomSheet();
                                          }
                                        : (){
                                          print('firebaseUrl : $firebaseUrl');
                                        },
                                    child: photoPath != null
                                        ? Container(
                                            // padding: EdgeInsets.zero,
                                            height: 150,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color(0xffb00bae3),
                                                  width: 2.0),
                                              color: Colors.grey[300],
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: //CachedNetworkImageProvider
                                                      FileImage(
                                                          File(photoPath))),
                                            ),
                                          )
                                        : firebaseUrl != ''
                                            ? Container(
                                                height: 150,
                                                width: 150,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Color(0xffb00bae3),
                                                      width: 2.0),
                                                  color: Colors.grey[300],
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: //CachedNetworkImageProvider //use fade in image
                                                        NetworkImage(
                                                            firebaseUrl),
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                height: 150,
                                                width: 150,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color:
                                                            Color(0xffb00bae3),
                                                        width: 2.0)),
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                  size: 90,
                                                ),
                                              ),),
                              ],
                            ),
                          );
                        } else {
                          // no data new user
                          return Center(
                            child: Text(
                              'Something Went Wrong \n found snap.data.snapshot.value == null',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                      },
                    ),
                    buildFeed()
                  ],
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height / 3 - 25,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    color: Colors.white.withOpacity(0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Color(0xffb4fcce0),
                          radius: 55,
                          child: Image(
                            image: new AssetImage("assets/GROUP.png"),
                            color: Colors.white,
                            width: 50.0,
                            height: 50.0,
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Color(0xffb4fcce0),
                          radius: 55,
                          child: Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Color(0xffb4fcce0),
                          radius: 55,
                          child: Icon(
                            Icons.contacts,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 2
                Positioned(
                  top: MediaQuery.of(context).size.height / 3 + 10,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    color: Colors.white.withOpacity(0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('- Groups        '),
                        Text('${feedData.length} Post '),
                        Text('- Connections'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _isLoading
            ? Container(
                decoration: BoxDecoration(color: Colors.black54),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Color(0xffb00bae3)),
                  ),
                ))
            : SizedBox(),
      ],
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
              value: 'Logout',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: <Widget>[
                    Text("Logout"),
                    Spacer(),
                    Icon(Icons.power_settings_new),
                  ],
                ),
              ),
            ),
          ],
    );
  }

  _onMenuItemSelect(String option) {
    switch (option) {
      case 'Logout':
        logout();
        break;
    }
  }

  //confirm logout //make one
  logout() {
    showDialog(
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
                        // print('pressed yes');
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
          );
        });
  }

  audioCall() async {
    var sendMap = <String, dynamic>{
      'to': widget.phone.toString(),
      'from': pref.phone.toString()
    };
    try {
      String result;
      result = await platform.invokeMethod('audioCall', sendMap);
    } on PlatformException catch (e) {
      print(e);
    }
  }

  chat(String name) async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('receiverNumber:${widget.phone.toString()}');
      String body = jsonEncode({
        "senderPhone": pref.phone.toString(),
        "receiverPhone": widget.phone.toString()
      });

      http
          .post("${url.api}startChatToContacts",
              headers: {"Content-Type": "application/json"}, body: body)
          .then((response) {
        var res = jsonDecode(response.body)["data"][0];
        var chatId = res["chat_id"];

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                  chatId: chatId,
                  chatType: 'private',
                  receiverName: name,
                  receiverPhone: widget.phone.toString(),
                  profileUrl: firebaseUrl),
            ));

        setState(() {
          _isLoading = false;
        });
      });
    } catch (e) {
      print('error while calling getchild');
      setState(() {
        _isLoading = false;
      });
    }
  }

  buildFeed() {
    if (feedData == null || feedData.isEmpty) {
      return Expanded(
        // child: ListView(
        // children: <Widget>[
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              Column(
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
                    "No Feeds Yet",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.75),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    "Your friend's feeds are visible here\nJoin your college group now",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black.withOpacity(0.50),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // ],
        // ),
      );
    } else {
      return Expanded(
          child: Container(
        // padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        padding: EdgeInsets.only(top: 60),
        width: double.infinity,
        color: Colors.white,
        child: StaggeredGridView.count(
          controller: hideButtonController,
          crossAxisCount: 2,
          staggeredTiles: generateStaggeredTiles(feedData.length),
          children: feedData,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          padding: EdgeInsets.all(4.0),
        ),
      ));
    }
  }

  List<StaggeredTile> generateStaggeredTiles(int count) {
    List<StaggeredTile> _staggeredTiles = [];
    num one = 1.80;
    num two = 1.50;
    int loop = 0;
    for (int i = 0; i < count; i++) {
      if (i % 2 == 0) {
        _staggeredTiles.add(new StaggeredTile.count(1, one));
      } else {
        _staggeredTiles.add(new StaggeredTile.count(1, two));
      }
      loop = loop + 1;
    }
    return _staggeredTiles;
  }

  Future uploadImg(imgPath) async {
    Completer c = new Completer();
    try {
      File imageFile;
      int fileSize =
          await File(imgPath).length(); //make compresser common function
      print('original img file size : $fileSize');

      if ((fileSize / 1024) > 500) {
        print('compressing img');
        imageFile = await FlutterNativeImage.compressImage(imgPath,
            percentage: 75, quality: 75);
        int fileSize = await imageFile.length();
        print('compress img file size : $fileSize');
      } else {
        print('no img compression');
        imageFile = File(imgPath);
      }

      // storage
      storage.uploadImage(pref.phone.toString(), imageFile).then((url) {
        print('prfile url----------------------------: $url');
        c.complete(url);
      }, onError: (e) {
        print('Error while uploading profile image throw:$e');
        throw e;
      });
    } catch (e) {
      print('Error while uploading profile image :$e');
      c.completeError(e);
    }
    return c.future;
  }

  upload(BuildContext context) async {
    print('img path:$photoPath');
    print('name : ${_textEditingController.text}');
    if (_textEditingController.text.trim() == '') {
      Fluttertoast.showToast(msg: 'Enter your name ');
    } else {
      setState(() {
        _isLoading = true;
      });
      if (photoPath != null) {
        uploadImg(photoPath).then((url) {
          var data = {
            "name": _textEditingController.text,
            "profileImg": url.toString()
          };
          try {
            _profileReference.set(data).then((onValue) {
              print('profile info uploaded to fb ');

              //instag
              CollectionReference ref =
                  Firestore.instance.collection('insta_users');
              ref.document(pref.phone.toString()).setData({
                "userId": pref.phone,
                "username": _textEditingController.text,
                "photoUrl": url,
                "following": {
                  "Public": true,
                },
              }).then((onValue) {
                setState(() {
                  _isLoading = false;
                  edit = !edit;
                  firebaseUrl = url;
                  pref.setName(_textEditingController.text);
                  pref.setProfile(firebaseUrl.toString());
                });
              Fluttertoast.showToast(msg: 'profile Updated');
              });
            });
          } catch (e) {
            print('err while setting profile info $e : ');
              Fluttertoast.showToast(msg: 'Try Again');
            
            setState(() {
              _isLoading = false;
              edit = !edit;
            });
            throw e; //not throwing
          }
        }, onError: (e) {
          print('Error: $e');
          setState(() {
            _isLoading = false;
            edit = !edit;
          });
        });
      } else {
        var data = {
          "name": _textEditingController.text,
          "profileImg": firebaseUrl
        };
        try {
          _profileReference.set(data).then((onValue) {
            print('profile info uploaded to fb :$firebaseUrl');
            //instag
            CollectionReference ref =
                Firestore.instance.collection('insta_users');
            ref.document(pref.phone.toString()).setData({
              "userId": pref.phone,
              "username": _textEditingController.text,
              "photoUrl": '',
              "following": {
                "Public": true,
              },
            }).then((onValue) {
              setState(() {
                _isLoading = false;
                edit = !edit;
                pref.setName(_textEditingController.text);
                pref.setProfile(firebaseUrl);
              });
              Fluttertoast.showToast(msg: 'profile Updated');
            });
          });
        } catch (e) {
          print('err while updatingrpfile info new:$e');
          setState(() {
            _isLoading = false;
            edit = !edit;
          });
        }
      }
    }
  }

  //
  openBottomSheet() {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.photo_camera,
                  color: Theme.of(context).accentColor,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  camera();
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.image,
                  color: Theme.of(context).accentColor,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  gallery();
                },
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
    if (img != null) getImg(img);
  }

  gallery() async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    print('gall img :$img');
    if (img != null) getImg(img);
  }

  getImg(File f) {
     // compress file
    cmprsMedia.compressImage(f).then((compressedImageFile) {
      print('comress:${compressedImageFile.path}');
      setState(() {
        photoPath = compressedImageFile.path;
      });
    });
  }

  // post
  _loadFeed() async {
    setState(() {
      postLoading = true;
    });
    await _getFeed(silent: false);
    setState(() {
      postLoading = false;
    });
  }

  _getFeed({@required bool silent}) async {
    if (!silent) {
      setState(() {
        postLoading = true;
      });
    }

    String uri =
        '${url.api}getFeeds?userId=' + widget.phone.toString();
    HttpClient httpClient = new HttpClient();

    try {
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(uri));
      HttpClientResponse response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String json = await response.transform(utf8.decoder).join();
        originalData = jsonDecode(json).cast<Map<String, dynamic>>();
        print('original data:$originalData');
        _generateFeed(silent: false);
      } else {
        print('Error getting a feed:\nHttp status ${response.statusCode}');
      }
    } catch (exception) {
      print('Failed invoking the getFeed function. Exception: $exception');
    }
    setState(() {
      postLoading = false;
    });
  }

  _generateFeed({@required bool silent}) async {
    if (!silent) {
      setState(() {
        postLoading = true;
        feedData = [];
      });
    }
    List<UserFeedBuilder> listOfPosts = [];
    for (Map<String, dynamic> postData in originalData) {
      print('for---->>$postData');
      if (postData['ownerId'] == widget.phone) {
        listOfPosts.add(UserFeedBuilder.fromJSON(postData));
      }
    }

    setState(() {
      feedData = listOfPosts;
      postLoading = false;
    });

    print('so i got feed data :$feedData');
  }

  Future<Null> refresh() async {
    await _getFeed(silent: true);
    setState(() {});
  }
}
