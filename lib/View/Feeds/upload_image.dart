import 'dart:async';
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Provider/Firebase/firebase_storage_operations.dart';
import 'package:oye_yaaro_pec/Provider/MediaOperation/compressMedia.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
// import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UploadImage extends StatefulWidget {
  final String tag;

  UploadImage({@optionalTypeArgs this.tag});

  _UploadImage createState() => _UploadImage();
}

class _UploadImage extends State<UploadImage> {
  File file;
  TextEditingController captionController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool uploading = false;

  Privacy privacy = Privacy();

  @override
  initState() {
    super.initState();
    privacy.changePrivacy('Public');
    captionController.text = widget.tag;
    _load();
  }

  _load() async {
    await Future.delayed(Duration(milliseconds: 50));
    _selectImage();
  }

  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("Post Feed"),
            flexibleSpace: FlexAppbar(),
          ),
          bottomNavigationBar: FlatButton(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            color: Color(0xffb578de3),
            disabledColor: Colors.grey,
            child: Text(
              "POST",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: (file == null || uploading) ? null : _postFeed,
          ),
          body: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(
                      color: Colors.grey,
                      width: 0.3,
                    ))),
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.only(bottom: 5.0),
                child: ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffb00bae3), width: 2.0),
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                      // image: DecorationImage(
                      //   fit: BoxFit.cover,
                      //   image: NetworkImage(pref.profileUrl),
                      // ),
                    ),
                    height: 50.0,
                    width: 50.0,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        // imageBuilder: (context,img)=>Center(
                        //   child: Text('data'),
                        // ),
                        imageUrl: pref.profileUrl,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                              height: 20.0,
                              width: 20.0,
                              child:
                                  CircularProgressIndicator(strokeWidth: 1.0)),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    pref.name,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 0.5,
                            bottom: 0.5,
                            left: 10.0,
                            right: 5.0,
                          ),
                          margin: EdgeInsets.only(top: 4.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Row(
                            children: <Widget>[
                              Text(privacy.visibility),
                              SizedBox(
                                width: 2.5,
                              ),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                        onTap: _changePrivacy,
                      ),
                    ],
                  ),
                ),
              ),
              file != null
                  ? Container(
                      padding: EdgeInsets.only(
                          top: 3.0, bottom: 3.0, left: 8.0, right: 8.0),
                      color: Colors.white,
                      child: TextFormField(
                        controller: captionController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "Write a caption...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade800,
                          ),
                          border: InputBorder.none,
                        ),
                        enabled: file != null,
                        autovalidate: true,
                        validator: _validateCaption,
                      ),
                    )
                  : SizedBox(
                      height: 0.0,
                      width: 0.0,
                    ),
              Expanded(
                child: file == null
                    ? Container(
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: RaisedButton.icon(
                          color: Colors.green,
                          icon: Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Select Image",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: _selectImage,
                        ),
                      )
                    : Stack(
                        children: <Widget>[
                          Image.file(
                            file,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0.0,
                            right: 0.0,
                            child: Container(
                              color: Colors.black.withOpacity(0.50),
                              child: IconButton(
                                icon: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.white,
                                ),
                                tooltip: "Change Image",
                                onPressed: _selectImage,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
        uploading
            ? Container(
                alignment: Alignment.center,
                color: Colors.black.withOpacity(0.50),
                child: CircularProgressIndicator(),
              )
            : SizedBox(
                width: 0.0,
                height: 0.0,
              ),
      ],
    );
  }

  String _validateCaption(String value) {
    if (value.length > 0) {
      return null;
    } else {
      return '';
    }
  }

  Future _selectImage() {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "Select source...",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FlatButton(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: <Widget>[
                    Text("Camera"),
                    Spacer(),
                    Icon(
                      Icons.camera_alt,
                      color: Colors.blue,
                    ),
                  ],
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  File imageFile =
                      await ImagePicker.pickImage(source: ImageSource.camera);
                  if (imageFile != null) {
                    File compressedImageFile =
                        await cmprsMedia.compressImage(imageFile);
                    setState(() {
                      file = compressedImageFile;
                    });
                  }
                },
              ),
              Divider(),
              FlatButton(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: <Widget>[
                    Text("Gallery"),
                    Spacer(),
                    Icon(
                      Icons.photo_library,
                      color: Colors.blue,
                    ),
                  ],
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  File imageFile =
                      await ImagePicker.pickImage(source: ImageSource.gallery);
                  if (imageFile != null) {
                    File compressedImageFile =
                        await cmprsMedia.compressImage(imageFile);
                    setState(() {
                      file = compressedImageFile;
                    });
                  }
                },
              ),
              Divider(),
              file != null
                  ? FlatButton(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: <Widget>[
                          Text("Remove"),
                          Spacer(),
                          Icon(Icons.delete_forever),
                        ],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteImage();
                      },
                    )
                  : FlatButton(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: <Widget>[
                          Text("Cancel"),
                          Spacer(),
                          Icon(Icons.close),
                        ],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  void _deleteImage() {
    setState(() {
      file = null;
    });
  }

  Future _changePrivacy() {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "Share with...",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FlatButton(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: <Widget>[
                    Text("Class"),
                    Spacer(),
                    Icon(Icons.group),
                  ],
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  privacy.changePrivacy('Class');
                  setState(() {});
                },
              ),
              Divider(),
              FlatButton(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: <Widget>[
                    Text("College"),
                    Spacer(),
                    Icon(Icons.location_city),
                  ],
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  privacy.changePrivacy('College');
                  setState(() {});
                },
              ),
              Divider(),
              FlatButton(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: <Widget>[
                    Text("Public"),
                    Spacer(),
                    Icon(Icons.public),
                  ],
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  privacy.changePrivacy('Public');
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _postFeed() async {
    try {
      setState(() {
        uploading = true;
      });
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      // File compressedImage = await cmprsMedia.compressImage(file);

      // put this file in path = 'ext.dir+"/OyeYaaro/.post/"+timestamp+".jpg"
      // print('compress file path :${compressedImage.path}');
      // print(file.lengthSync());
      // print(compressedImage.lengthSync());

      // if (file.lengthSync() == compressedImage.lengthSync()) {
      //   print('same file');
      // }

      String mediaUrl = await storage.uploadImage(
          timestamp.toString(), file, true);

      print("mediaUrl: " + mediaUrl);

      await saveToFireStore(
          mediaUrl: mediaUrl,
          description: captionController.text,
          timestamp: timestamp);
      setState(() {
        file = null;
        uploading = false;
      });
      Fluttertoast.showToast(msg: 'New Post Posted on wall');
      Navigator.pop(context);
    } catch (e) {
      print(e);
      setState(() {
        uploading = false;
      });
    }
  }

  Future saveToFireStore(
      {String mediaUrl, String description, int timestamp}) async {
    Completer _c = new Completer();
    print('in saveToFireStore()');
    try {
      var reference = Firestore.instance.collection('insta_posts');

      DocumentReference tagReference =
          Firestore.instance.collection('insta_tags').document("tags");

      List<String> hashtags = List<String>();
      description
          .replaceAll("\\n", " ")
          .split(" ")
          .where((value) {
            value.replaceAll(" ", "");
            return value.startsWith("#");
          })
          .toList()
          .forEach((value) {
            hashtags.add(value.replaceAll("#", "").toLowerCase());
          });

      reference.add({
        "username": pref.name,
        "likes": {},
        "mediaUrl": mediaUrl,
        "description": description,
        "ownerId": pref.pin,
        "visibility": privacy.visibleTo,
        "timestamp": timestamp,
        "tags": hashtags,
      }).then((DocumentReference doc) {
        String docId = doc.documentID;
        reference.document(docId).updateData({"postId": docId});
        print('post added to firestore :$docId --');
      });

      Map<String, bool> tags = Map<String, bool>();
      hashtags.forEach((tag) {
        tags.putIfAbsent(tag, () => true);
      });

      await tagReference.setData(tags, merge: true).then((onValue) {
        print('tags added in tagReference');
      });
      _c.complete(true);
    } catch (e) {
      _c.completeError(e);
    }
    return _c.future;
  }
}

class Privacy {
  String visibleTo;
  IconData icon;
  String visibility;

  Privacy();

  changePrivacy(String visibleTo) {
    switch (visibleTo) {
      case 'Class':
        this.visibleTo = pref.groupId;
        this.icon = Icons.group;
        this.visibility = 'Class';
        break;
      case 'College':
        this.visibleTo = pref.collegeName;
        this.icon = Icons.location_city;
        this.visibility = 'College';
        break;
      case 'Public':
        this.visibleTo = "Public";
        this.icon = Icons.public;
        this.visibility = 'Public';
        break;
    }
  }
}
