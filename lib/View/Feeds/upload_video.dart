import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Provider/Firebase/firebase_storage_operations.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:thumbnails/thumbnails.dart';
// import 'package:cached_network_image/cached_network_image.dart';


class UploadVideo extends StatefulWidget {
  final String tag;
  final String filePath;

  UploadVideo({@optionalTypeArgs this.tag, @optionalTypeArgs this.filePath});

  _UploadVideo createState() => new _UploadVideo();
}

class _UploadVideo extends State<UploadVideo> {
  TextEditingController captionController = new TextEditingController();

  VideoPlayerController _controller;

  bool uploading = false;

  // Privacy privacy = Privacy();

  File videoFile;

  @override
  initState() {
    super.initState();
    // if(widget.filePath != null){
    //   videoFile = File(widget.filePath);
    //   _controller = VideoPlayerController.file(videoFile);
    //   await _controller.initialize();
    // }
    // privacy.changePrivacy('Public');
    captionController.text = widget.tag;
    _load();
  }

  _load() async {
    await Future.delayed(Duration(milliseconds: 50));
    _pickVideo();
  }

  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: Text("Post Feed"),
            // backgroundColor: Color(0xffb00bae3),
            flexibleSpace: FlexAppbar(),
          ),
          // backgroundColor: Colors.grey.shade400,
          bottomNavigationBar: FlatButton(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            color: Color(0xffb578de3),
            child: Text(
              "POST",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed:
                (videoFile == null || uploading) ? null : () => _postFeed(),
          ),
          body: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.only(bottom: 5.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(
                      color: Colors.grey,
                      width: 0.3,
                    ))),
                child: ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffb00bae3), width: 2.0),
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: //CachedNetworkImageProvider(pref.profileUrl), //use fade in image
                            NetworkImage(pref.profileUrl),
                      ),
                    ),
                    height: 50.0,
                    width: 50.0,
                  ),
                  title: Text(
                    pref.name,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  // subtitle: Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: <Widget>[
                  //     InkWell(
                  //       child: Container(
                  //         padding: EdgeInsets.only(
                  //           top: 0.5,
                  //           bottom: 0.5,
                  //           left: 10.0,
                  //           right: 5.0,
                  //         ),
                  //         margin: EdgeInsets.only(top: 4.0),
                  //         decoration: BoxDecoration(
                  //           border: Border.all(color: Colors.grey),
                  //           borderRadius: BorderRadius.circular(5.0),
                  //         ),
                  //         child: Row(
                  //           children: <Widget>[
                  //             Text(privacy.visibility),
                  //             SizedBox(
                  //               width: 2.5,
                  //             ),
                  //             Icon(Icons.arrow_drop_down),
                  //           ],
                  //         ),
                  //       ),
                  //       // onTap: _changePrivacy,
                  //     ),
                  //   ],
                  // ),
                ),
              ),
              videoFile != null
                  ? Container(
                      padding: EdgeInsets.only(
                          top: 3.0, bottom: 3.0, left: 8.0, right: 8.0),
                      color: Colors.white,
                      child: TextFormField(
                        // focusNode:FocusNode(),
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
                        enabled: videoFile != null,
                        autovalidate: true,
                        validator: _validateCaption,
                      ),
                    )
                  : SizedBox(
                      height: 0.0,
                      width: 0.0,
                    ),
              Expanded(
                child: _controller == null
                    ? Container(
                        alignment: Alignment.center,
                        // height: 200.0,
                        color: Colors.white,
                        child: RaisedButton.icon(
                          color: Colors.green,
                          icon: Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Select Video",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: _pickVideo,
                        ),
                      )
                    : Stack(
                        children: <Widget>[
                          AspectRatio(
                            aspectRatio: 1,
                            child: VideoPlayer(_controller),
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
                                tooltip: "Change Video",
                                onPressed: _pickVideo,
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

  Future _pickVideo() {
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
                    Icon(Icons.camera_alt,color: Colors.blue,),
                  ],
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  videoFile =
                      await ImagePicker.pickVideo(source: ImageSource.camera);
                  _controller = VideoPlayerController.file(videoFile);
                  await _controller.initialize();
                  setState(() {});
                },
              ),
              Divider(),
              FlatButton(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: <Widget>[
                    Text("Gallery"),
                    Spacer(),
                    Icon(Icons.photo_library,color: Colors.blue,),
                  ],
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  videoFile =
                      await ImagePicker.pickVideo(source: ImageSource.gallery);
                  _controller = VideoPlayerController.file(videoFile);
                  await _controller.initialize();
                  setState(() {});
                },
              ),
              Divider(),
              // FlatButton(
              //   padding: EdgeInsets.symmetric(vertical: 10.0),
              //   child: Row(
              //     children: <Widget>[
              //       Text("Recorded Videos"),
              //       Spacer(),
              //       Image(
              //         color: Colors.black,
              //         image: new AssetImage("assets/video_call.png"),
              //         width: 21.0,
              //         height: 21.0,
              //         fit: BoxFit.scaleDown,
              //       )
              //     ],
              //   ),
              //   onPressed: () async {
              //     Navigator.pop(context);
              //     final recordedVideoPath = await Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => GetVideo(),
              //       ),
              //     );

              //     if (recordedVideoPath != null) {
              //       print('selected record  video path  : $recordedVideoPath');
              //       videoFile = new File(recordedVideoPath);
              //       _controller = VideoPlayerController.file(videoFile);
              //       await _controller.initialize();
              //       setState(() {});
              //     }     await ImagePicker.pickVideo(source: ImageSource.gallery);
              //   },
              // ),
              // Divider(),
              videoFile != null
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
                        _removeVideo();
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

  void _removeVideo() {
    setState(() {
      videoFile = null;
      _controller = null;
    });
  }

  // Future _changePrivacy() {
  //   return showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //         padding: EdgeInsets.all(15.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             Container(
  //               alignment: Alignment.centerLeft,
  //               padding: EdgeInsets.only(bottom: 10.0),
  //               child: Text(
  //                 "Share with...",
  //                 style: TextStyle(
  //                   fontSize: 16.0,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //             FlatButton(
  //               padding: EdgeInsets.symmetric(vertical: 10.0),
  //               child: Row(
  //                 children: <Widget>[
  //                   Text("Class"),
  //                   Spacer(),
  //                   Icon(Icons.group),
  //                 ],
  //               ),
  //               onPressed: () async {
  //                 Navigator.pop(context);
  //                 privacy.changePrivacy('Class');
  //                 setState(() {});
  //               },
  //             ),
  //             Divider(),
  //             FlatButton(
  //               padding: EdgeInsets.symmetric(vertical: 10.0),
  //               child: Row(
  //                 children: <Widget>[
  //                   Text("College"),
  //                   Spacer(),
  //                   Icon(Icons.location_city),
  //                 ],
  //               ),
  //               onPressed: () async {
  //                 Navigator.pop(context);
  //                 privacy.changePrivacy('College');
  //                 setState(() {});
  //               },
  //             ),
  //             Divider(),
  //             FlatButton(
  //               padding: EdgeInsets.symmetric(vertical: 10.0),
  //               child: Row(
  //                 children: <Widget>[
  //                   Text("Public"),
  //                   Spacer(),
  //                   Icon(Icons.public),
  //                 ],
  //               ),
  //               onPressed: () async {
  //                 Navigator.pop(context);
  //                 privacy.changePrivacy('Public');
  //                 setState(() {});
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  _postFeed() async {
    try {
      setState(() {
        uploading = true;
      });

      File compressedVideo;
      int fileSize = await videoFile.length();
      int timestamp = DateTime.now().millisecondsSinceEpoch;

      print("Original file size: " + (fileSize / 1024).toString() + " KB");

      // if ((fileSize / 1024) > 2048) {
        // print('compressing your post video..');
        // cmprsMedia
        //     .compressVideo(
        //         videoFile,
        //         '/storage/emulated/0/OyeYaaro/Posts/.vid/',
        //         '$timestamp')
        //     .then((compressedVideoFile) {
        //   compressedVideo = compressedVideoFile;
        // });
      // } else {
        compressedVideo = videoFile;
      // }

      fileSize = await compressedVideo.length();

      // print("Compressed file size: " + (fileSize / 1024).toString() + " KB");
      // print('Compressed file ${compressedVideo.path}');

      // String uuid = Uuid().v1();
      String mediaUrl = await storage.uploadVideo(
          timestamp.toString(), compressedVideo, true);
      print('video uploaded to fb storage');

      String thumb = await Thumbnails.getThumbnail(
          thumbnailFolder: '/storage/emulated/0/OyeYaaro/.thumbnails',
          videoFile: compressedVideo.path,
          imageType: ThumbFormat.PNG,
          quality: 30);

      await storage.uploadImage(timestamp.toString(), File(thumb), true);
      print('video thumbnail uploaded to fb');

      print("mediaUrl: " + mediaUrl);

      await saveToFireStore(
          mediaUrl: mediaUrl,
          description: captionController.text,
          timestamp: timestamp);

      setState(() {
        videoFile = null;
        uploading = false;
      });
      Fluttertoast.showToast(msg: 'New Post Posted on wall');
      Navigator.pop(context);
    } catch (e) {
      print('err : $e');
      setState(() {
        uploading = false;
      });
    }
  }

  Future<bool> saveToFireStore(
      {String mediaUrl, String description, int timestamp}) async {
    CollectionReference reference =
        Firestore.instance.collection('insta_posts');

    DocumentReference tagReference =
        Firestore.instance.collection('insta_tags').document("tags");

    List<String> hashtags = List<String>();
    description
        .split(" ")
        .where((value) {
          value.replaceAll("\\n", "");
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
      "ownerId": pref.phone,
      "visibility": 'Public', // privacy.visibleTo,
      "timestamp": timestamp,
      "tags": hashtags,
    }).then((DocumentReference doc) {
      String docId = doc.documentID;
      reference.document(docId).updateData({"postId": docId});
    });

    Map<String, bool> tags = Map<String, bool>();
    hashtags.forEach((tag) {
      tags.putIfAbsent(tag, () => true);
    });

    await tagReference.setData(tags, merge: true);
    return true;
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
        this.visibleTo = 'currentUser.groupId'; //
        this.icon = Icons.group;
        this.visibility = 'Class';
        break;
      case 'College':
        this.visibleTo = 'currentUser.collegeName'; //
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
