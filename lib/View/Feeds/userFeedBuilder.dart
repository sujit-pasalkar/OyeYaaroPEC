import 'package:oye_yaaro_pec/Components/feeds_image.dart';
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';
import 'package:oye_yaaro_pec/View/Feeds/mediaAndComment.dart';
// import 'package:oye_yaaro_pec/View/Profile/myProfile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'comments.dart';
import 'playVideo.dart';

class UserFeedBuilder extends StatefulWidget {
  final String username;
  final String description;
  final String mediaUrl; //posturl
  final String postId; //firebase doc id
  final int ownerId; //phone
  final int timestamp;
  final likes;

  UserFeedBuilder(
      {this.username,
      this.description,
      this.mediaUrl,
      this.likes,
      this.postId,
      this.ownerId,
      this.timestamp})
      : super(key: UniqueKey());

  factory UserFeedBuilder.fromJSON(Map data) {
    return UserFeedBuilder(
      username: data['username'],
      description: data['description'],
      mediaUrl: data['mediaUrl'],
      likes: data['likes'],
      ownerId: data['ownerId'],
      postId: data['postId'],
      timestamp: data['timestamp'],
    );
  }

  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }
    var vals = likes.values;
    int count = 0;
    for (var val in vals) {
      if (val == true) {
        count = count + 1;
      }
    }
    return count;
  }

  _FeedBuilder createState() => _FeedBuilder(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        timestamp: this.timestamp,
        likeCount: this.getLikeCount(this.likes),
      );
}

class _FeedBuilder extends State<UserFeedBuilder> {
  final String mediaUrl;
  final String username;
  final String description;
  final String postId;
  final int ownerId; //userphone
  final int timestamp;
  String time;
  Map likes;
  int likeCount;

  String profileUrl;

  bool liked;
  bool showHeart = false;
  bool _processing = false;

  CollectionReference reference = Firestore.instance.collection('insta_posts');

  _FeedBuilder({
    this.postId,
    this.ownerId,
    this.username,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likeCount,
    this.timestamp,
  });

  @override
  void initState() {
    time = _calculateTime();
    getProfileUrl();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getProfileUrl() async {
    print('in feedbuilder-$username');
    try {
      sqlQuery.getContactRow(widget.ownerId.toString()).then((onValue) {
        if (onValue.length == 0) {
          setState(() {
            profileUrl = 'add';
          });
        } else {
          setState(() {
            profileUrl = onValue[0]['profileUrl'];
          });
        }
      });
    } catch (e) {
      print('Error in getProfileUrl() :$e');
    }
  }

  _likePost() async {
    if (!_processing) {
      _processing = true;
      String userId = pref.phone.toString(); //phone

      bool _liked = likes[userId] == true;

      if (_liked) {
        await reference.document(postId).updateData({
          'likes.$userId': false,
        });
        await removeActivityFeedItem();
        _processing = false;

        setState(() {
          likeCount = likeCount - 1;
          liked = false;
          likes[userId] = false;
        });
      } else if (!_liked) {
        await reference.document(postId).updateData({'likes.$userId': true});
        await addActivityFeedItem();
        setState(() {
          likeCount = likeCount + 1;
          liked = true;
          likes[userId] = true;
          showHeart = true;
        });
        _processing = false;
        Timer(const Duration(milliseconds: 500), () {
          setState(() {
            showHeart = false;
          });
        });
      }
    }
  }

  addActivityFeedItem() async {
    String userId = pref.phone.toString();
    String username = pref.name;
    String photoUrl = pref.profileUrl;
    await Firestore.instance
        .collection("insta_a_feed")
        .document(ownerId.toString())
        .collection("items")
        .document(postId)
        .setData({
      "username": username,
      "userId": userId,
      "type": "like",
      "userProfileImg": photoUrl,
      "mediaUrl": mediaUrl,
      "timestamp": DateTime.now().toString(),
      "postId": postId,
    });
  }

  removeActivityFeedItem() async {
    await Firestore.instance
        .collection("insta_a_feed")
        .document(ownerId.toString())
        .collection("items")
        .document(postId)
        .delete();
  }

  _showImage(int type) {
    print(mediaUrl);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaAndComment(
            timestamp: timestamp,
            imageUrl: mediaUrl,
            postOwner: ownerId,
            postId: postId,
            description: description,
            profileUrl: profileUrl,
            type: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    liked = (likes[pref.phone.toString()] == true);
    return Material(
      color: Colors.white,
      elevation: 14.0,
      shadowColor: Colors.grey,
      borderRadius: BorderRadius.circular(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Expanded(
              child: Stack(children: <Widget>[
            mediaUrl.contains(".jpg")
                ? GestureDetector(
                    child: S3Image(
                        //your image showing logic class
                        filename: mediaUrl,
                        placeholder: Image(
                            image: AssetImage("assets/loading.gif"),
                            fit: BoxFit.cover,
                            alignment: Alignment.center),
                        timestamp: timestamp,
                        posterPhone: widget.ownerId),
                    onTap: () {
                      _showImage(1);
                    },
                    onDoubleTap: _likePost,
                  )
                : GestureDetector(
                    child: Stack(
                      children: <Widget>[
                        S3Image(
                            filename: mediaUrl,
                            placeholder: Image(
                              image: AssetImage("assets/loading.gif"),
                              fit: BoxFit.cover,
                            ),
                            timestamp: timestamp,
                            posterPhone: widget.ownerId),
                        Center(
                          child: IconButton(
                            icon: Icon(
                              Icons.play_arrow,
                              color: Colors.white70,
                            ),
                            iconSize: 80.0,
                            onPressed: () {
                              _showImage(2);
                            },
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _showImage(2);
                    },
                    onDoubleTap: _likePost,
                  ),
            showHeart
                ? Positioned(
                    bottom: 0,
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: 0.90,
                      child: Icon(
                        Icons.favorite,
                        size: 80.0,
                        color: Colors.white,
                      ),
                    ),
                  )
                : SizedBox(
                    width: 0.0,
                    height: 0.0,
                  ),
            Positioned(
              right: 0.0,
              bottom: 0.0,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.red : Colors.white, size: 30),
                onPressed: _likePost,
              ),
            ),
            pref.phone == ownerId
                ? Positioned(right: -10, top: -5, child: _menuBuilder())
                : SizedBox(),
          ])),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "$likeCount likes",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  time,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ]),
          Divider(
            indent: 0.0,
            height: 2.0,
          ),
          description == ''
              ? SizedBox(width: 0.0, height: 5.0)
              : Container(
                  padding: EdgeInsets.fromLTRB(5, 2, 2, 2),
                  child: Text(
                    description,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
          description == ''
              ? SizedBox(width: 0.0, height: 0.0)
              : Divider(
                  indent: 0.0,
                  height: 2.0,
                ),
          Row(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.fromLTRB(8, 2, 2, 2),
                  padding: EdgeInsets.all(1.0),
                  decoration: new BoxDecoration(
                    color: Color(0xffb00bae3),
                    shape: BoxShape.circle,
                  ),
                  child: widget.ownerId == pref.phone
                      ?
                      //  GestureDetector(
                      //     onTap: () {
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (context) => MyProfile(
                      //                 phone: widget.ownerId,
                      //               ),
                      //         ),
                      //       );
                      //     },
                      //     child:
                           CircleAvatar(
                            backgroundImage: NetworkImage(pref.profileUrl),
                            backgroundColor: Colors.grey[300],
                            radius: 18,
                          )
                        // )
                      : profileUrl == '' || profileUrl == null
                          ? 
                          // GestureDetector(
                          //     onTap: () {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) => MyProfile(
                          //                 phone: widget.ownerId,
                          //               ),
                          //         ),
                          //       );
                          //     },
                          //     child: 
                              CircleAvatar(
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                backgroundColor: Colors.grey[300],
                                radius: 18,
                              )
                            // )
                          : profileUrl == 'add'
                              ? GestureDetector(
                                  onTap: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => MyProfile(
                                    //           phone: widget.ownerId,
                                    //         ),
                                    //   ),
                                    // );
                                    print('Add user logic');
                                  },
                                  child: CircleAvatar(
                                    child: Icon(
                                      Icons.person_add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    backgroundColor: Colors.grey[300],
                                    radius: 18,
                                  ),
                                )
                              : 
                              // GestureDetector(
                              //     onTap: () {
                              //       Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //           builder: (context) => MyProfile(
                              //                 phone: widget.ownerId,
                              //               ),
                              //         ),
                              //       );
                              //     },
                              //     child:
                                   CircleAvatar(
                                    backgroundImage: NetworkImage(profileUrl),
                                    backgroundColor: Colors.grey[300],
                                    radius: 18,
                                  ),
                                // ),
                                ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.fromLTRB(5, 2, 2, 2),
                  child: Text(
                    username,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: 8))
        ],
      ),
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
              value: 'Delete Post',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: <Widget>[
                    Text("Delete Post"),
                    Spacer(),
                    Icon(Icons.delete),
                  ],
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'Copy',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: <Widget>[
                    Text("Copy Link"),
                    Spacer(),
                    Icon(Icons.content_copy),
                  ],
                ),
              ),
            ),
          ],
    );
  }

  _onMenuItemSelect(String option) async {
    switch (option) {
      case 'Delete Post':
        await reference.document(postId).delete();
        // widget.ref();
        setState(() {});
        break;
      case 'Copy':
        Clipboard.setData(ClipboardData(text: mediaUrl));
        break;
    }
  }

  showVideo() {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) {
          return PlayVideo(
            mediaUrl: mediaUrl,
            timestamp: timestamp,
            posterPhone: widget.ownerId,
          );
        },
      ),
    );
  }

  String _calculateTime() {
    int now = DateTime.now().toUtc().millisecondsSinceEpoch.ceil();
    int differenceInSeconds = ((now - timestamp) / 1000).round();
    // print('timestamp :$timestamp');
    print('now :$now');

    // print('differenceInSeconds :$differenceInSeconds--> ${differenceInSeconds.toString()}');

    if (differenceInSeconds < 10) {
      return 'Few seconds ago';
    } else if (differenceInSeconds < 59) {
      return differenceInSeconds.toString() + ' seconds ago';
    } else if (differenceInSeconds < 3599) {
      return (differenceInSeconds / 60).floor().toString() + ' minutes ago';
    } else if (differenceInSeconds < 86399) {
      return (differenceInSeconds / 3600).floor().toString() + ' hours ago';
    } else if (differenceInSeconds > 86399 && differenceInSeconds < 31535999) {
      return (differenceInSeconds / 86400).floor().toString() + ' days ago';
    }
    return (differenceInSeconds / 31536000).floor().toString() + ' years ago';
  }
}

goToComments(
    {BuildContext context, String postId, int ownerId, String mediaUrl}) {
  Navigator.of(context).push(
    MaterialPageRoute<bool>(
      builder: (BuildContext context) {
        return Comments(
          postId: postId,
          postOwner: ownerId,
          postMediaUrl: mediaUrl,
        );
      },
    ),
  );
}
