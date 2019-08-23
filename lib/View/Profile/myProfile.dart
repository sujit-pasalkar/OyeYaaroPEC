// show your's and others profile
// remove widget.phone
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';

import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Models/url.dart';
import 'package:oye_yaaro_pec/Provider/MediaOperation/compressMedia.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/database_creator.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:oye_yaaro_pec/View/Feeds/userFeedBuilder.dart';
import 'package:oye_yaaro_pec/View/Personal/personal_chatScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyProfile extends StatefulWidget {
  final int pin;
  MyProfile({@required this.pin});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<MyProfile> {
  // static const platform =
  //     const MethodChannel('com.plmlogix.oye_yaaro_pec/platform');

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _textEditingController = new TextEditingController();
  String photoPath;
  bool _isLoading = true, edit = false, textEdit = false;
  int postCount;

// your post
  List<UserFeedBuilder> feedData = [];
  List<Map<String, dynamic>> originalData;
  bool postLoading = true;
  ScrollController hideButtonController;

  String phone = '', name = '';

// screen
  // GlobalKey<State> profileContainer = GlobalKey<State>();
  // double width, height;

  @override
  void initState() {
    getProfile();

    // print('${pref.phone} and ${widget.phone}');
    // profile
    // _profileReference =
    //     database.reference().child('profiles').child(widget.pin.toString());

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
              pref.pin == widget.pin ? 'Your Profile' : 'Profile Info',
              style: TextStyle(color: Colors.white),
            ),
            actions: <Widget>[
              pref.pin == widget.pin
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
              pref.pin != widget.pin
                  ? IconButton(
                      icon: Icon(Icons.message),
                      onPressed: () async {
                        List<Map<String, dynamic>> row;
                        try {
                          // get contact name
                          row = await sqlQuery.getContactName(phone);
                          chat(row[0]['contactsName']);
                        } catch (e) {
                          chat(phone);
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
                fit: BoxFit.cover,
                image: AssetImage('assets/login.png'),
              ),
            ),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 2.5,
                      padding: EdgeInsets.fromLTRB(10, 15, 10, 25),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            right: 0,
                            child: Container(
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xffb00bae3), width: 3.5),
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: ClipOval(
                                  child:
                                  // Image.network(),
                                   CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        'http://54.200.143.85:4200/profiles/then/${widget.pin}.jpg',
                                    placeholder: (context, url) => Center(
                                      child: SizedBox(
                                        height: 30.0,
                                        width: 30.0,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.0),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person,
                                      color: Colors.grey[400],
                                      size: 40,
                                    ),
                                    // cacheManager: ,
                                  ),

                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 45,
                            right: 25,
                            child: GestureDetector(
                              onTap: edit
                                  ? () {
                                      openBottomSheet();
                                    }
                                  : null,
                              child: photoPath != null
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
                                            image: FileImage(File(photoPath))),
                                      ),
                                    )
                                  : Container(
                                      height: 150,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xffb00bae3),
                                            width: 3.5),
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl:
                                                'http://54.200.143.85:4200/profiles/now/${widget.pin}.jpg',
                                            placeholder: (context, url) =>
                                                Center(
                                              child: SizedBox(
                                                height: 40.0,
                                                width: 40.0,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2.0),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.person,
                                              color: Colors.grey[400],
                                              size: 90,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 25,
                            child: edit
                                ? Container(
                                    width:
                                        MediaQuery.of(context).size.width - 180,
                                    child: TextField(
                                      style: TextStyle(color: Colors.white),
                                      autofocus: !_isLoading,
                                      cursorColor: Colors.white,
                                      maxLength: 25,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      controller: _textEditingController,
                                      decoration: InputDecoration(
                                        hintText: "Type your name here",
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                      ),
                                      onChanged: (nameText) {
                                        print(nameText);
                                      },
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                180,
                                        child: Text(
                                          '${_textEditingController.text}',
                                          softWrap: true,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 40),
                                        child: Text(
                                          '$phone',
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
                        ],
                      ),
                    ),
                    buildFeed()
                  ],
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height / 2.5 - 25,
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
                  top: MediaQuery.of(context).size.height / 2.5 + 10,
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

  chat(String name) async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('receiverNumber:$phone');
      String body = jsonEncode({
        "senderPhone": pref.pin.toString(), //
        "receiverPhone": widget.pin.toString()
      });

      http
          .post("${url.api}startChatToContacts",
              headers: {"Content-Type": "application/json"}, body: body)
          .then((response) {
        var res = jsonDecode(response.body)["data"][0];
        var chatId = res["chat_id"];

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ChatScreen(
        //         chatId: chatId,
        //         chatType: 'private',
        //         receiverName: name,
        //         receiverPhone: widget.phone.toString(),
        //         // profileUrl: firebaseUrl
        //         receiverPin: widget.pin),
        //   ),
        // );

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
      );
    } else {
      return Expanded(
          child: Container(
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

  // Future uploadImg(imgPath) async {
  //   Completer c = new Completer();
  //   try {
  //     File imageFile;
  //     int fileSize =
  //         await File(imgPath).length(); //make compresser common function
  //     print('original img file size : $fileSize');

  //     if ((fileSize / 1024) > 500) {
  //       print('compressing img');
  //       imageFile = await FlutterNativeImage.compressImage(imgPath,
  //           percentage: 75, quality: 75);
  //       int fileSize = await imageFile.length();
  //       print('compress img file size : $fileSize');
  //     } else {
  //       print('no img compression');
  //       imageFile = File(imgPath);
  //     }

  //     // storage
  //     storage.uploadImage(pref.phone.toString(), imageFile).then((url) {
  //       print('prfile url----------------------------: $url');
  //       c.complete(url);
  //     }, onError: (e) {
  //       print('Error while uploading profile image throw:$e');
  //       throw e;
  //     });
  //   } catch (e) {
  //     print('Error while uploading profile image :$e');
  //     c.completeError(e);
  //   }
  //   return c.future;
  // }

  upload(BuildContext context) async {
    print('img path:$photoPath');
    print('name : ${_textEditingController.text}');
    if (_textEditingController.text.trim() == '') {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Enter your name'),
        duration: Duration(seconds: 4),
      ));
    } else {
      setState(() {
        _isLoading = true;
      });

      // 1.update name in mongodb
      try {
        await updateNameDB();
        //2.instag
        CollectionReference ref = Firestore.instance.collection('insta_users');

        await ref.document(pref.phone.toString()).setData({
          "userId": pref.phone,
          "username": _textEditingController.text,
          "photoUrl": "http://oyeyaaroapi.plmlogix.com/profiles/now/" +
              widget.pin.toString() +
              ".jpg", //
          "following": {
            "Public": true,
          },
        });

        // ProfileImage
        if (photoPath != null) {
          print("upload this photo");
          // upadate to profileiImage server
          String res = await uploadProfileImage();
          print('profile iamge uploaded:$res');
        }

        setState(() {
          _isLoading = false;
          edit = !edit;
          pref.setName(_textEditingController.text);
        });

        imageCache.clear();

        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('profile Updated'),
          duration: Duration(seconds: 4),
        ));
      } catch (e) {
        print('err while updating profile info :$e');
        setState(() {
          _isLoading = false;
          edit = !edit;
        });
      }
    }
  }

  Future uploadProfileImage() async {
    Completer _c = new Completer();
    try {
      http.ByteStream stream = new http.ByteStream(
          DelegatingStream.typed(File(photoPath).openRead()));

      var length = await File(photoPath).length();

      Uri uri = Uri.parse("${url.api}uploadProfileImage");

      http.MultipartRequest request = new http.MultipartRequest("POST", uri);
      request.headers["pin"] = pref.pin.toString();
      http.MultipartFile multipartFile =
          new http.MultipartFile('file', stream, length, filename: "profile");

      request.files.add(multipartFile);

      http.StreamedResponse response = await request.send();

      response.stream.transform(utf8.decoder).listen((value) {
        _c.complete('uploaded');
      });
    } catch (e) {
      _c.completeError(e);
    }
    return _c.future;
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

    String uri = '${url.api}getFeeds?userId=' + widget.pin.toString();
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
      if (postData['ownerId'] == widget.pin) {
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

  Future getProfile() async {
    try {
      http.Response response =
          await http.post("${url.api}getProfile", //another url
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"pin": '${widget.pin}'}));

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print('result:$result');
        if (result['success'] == true) {
          setState(() {
            _isLoading = false;
            name = result['data'][0]['Name'];
            _textEditingController.text = name;
            phone = result['data'][0]['Mobile'];
          });
          print('success:$name');
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Response null'),
            duration: Duration(seconds: 4),
          ));
        }
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Response failed'),
          duration: Duration(seconds: 4),
        ));
      }
    } catch (e) {
      print('Error in checkUser():$e');
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Error'),
        duration: Duration(seconds: 4),
      ));
    }
  }

  Future updateNameDB() async {
    Completer _c = Completer();
    try {
      http.Response response = await http.post("${url.api}updateProfile",
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {"Name": _textEditingController.text, "Pin": widget.pin}));

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print('updateNameDB res:$result');
        _c.complete(result);
      }
    } catch (e) {
      print('object:$e');
      _c.completeError(e);
    }
    return _c.future;
  }
}
