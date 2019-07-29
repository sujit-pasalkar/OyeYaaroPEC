import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:oye_yaaro_pec/Components/videoPlayer.dart';
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/View/Feeds/playVideo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MediaAndComment extends StatefulWidget {
  final int timestamp, postOwner, type;
  final String imageUrl, postId, description; //profileUrl;

  MediaAndComment(
      {@required this.timestamp,
      @required this.imageUrl,
      @required this.postOwner,
      @required this.postId,
      @required this.description,
      // @required this.profileUrl,
      @required this.type});

  @override
  _MediaAndCommentState createState() => _MediaAndCommentState();
}

class _MediaAndCommentState extends State<MediaAndComment> {
  Directory extDir;
  File f;
  final TextEditingController _commentController = TextEditingController();
  bool _isComposingMessage = false;
  @override
  void initState() {
    getDir();
    super.initState();
  }

  getDir() async {
    extDir = await getExternalStorageDirectory();
    print('path:${extDir.path}');
    f = new File(extDir.path +
        "/OyeYaaro/.posts/" +
        widget.timestamp.toString() +
        ".jpg");
    print('f:${f.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: futureBody(),
    );
  }

  Widget futureBody() {
    return FutureBuilder<List<Comment>>(
        future: getComments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return CustomScrollView(
              slivers: <Widget>[
                sliverAppBar(),
                commentInput(),
              ],
            );
          return CustomScrollView(
            slivers: <Widget>[
              sliverAppBar(),
              commentInput(),
              buildComments(snapshot.data),
            ],
          );
        });
  }

  Future<List<Comment>> getComments() async {
    List<Comment> comments = [];

    QuerySnapshot data = await Firestore.instance
        .collection("insta_comments")
        .document(widget.postId)
        .collection("comments")
        .getDocuments();
    data.documents.forEach((DocumentSnapshot doc) {
      comments.add(Comment.fromDocument(doc));
    });
    print('getComment data:${comments[0].username}');
    return comments;
  }

  buildComments(List<Comment> data) {
    List<Widget> comments = new List<Widget>();
    data.forEach((f) {
      comments.add(f);
    });
    return SliverList(
      delegate: SliverChildListDelegate(comments),
    );
  }

  addComment(String comment) async {
    _commentController.clear();
    await Firestore.instance
        .collection("insta_comments")
        .document(widget.postId)
        .collection("comments")
        .add({
      "username": pref.name,
      "comment": comment,
      "timestamp": DateTime.now().toString(),
      "avatarUrl": pref.profileUrl,
      "userId": pref.pin.toString()
    });
    setState(() {});

    Firestore.instance
        .collection("insta_a_feed")
        .document(widget.postOwner.toString())
        .collection("items")
        .add({
      "username": pref.name,
      "userId": pref.pin.toString(),
      "type": "comment",
      "userProfileImg": pref.profileUrl,
      "commentData": comment,
      "timestamp": DateTime.now().toString(),
      "postId": widget.postId,
      "mediaUrl": widget.imageUrl,
    });
  }

  sliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      expandedHeight: 550.0, //use screen mediaQuery
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
          background: f == null
              ? Center(
                  child: SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                )
              : widget.type == 1
                  ? Image.file(f, fit: BoxFit.cover)
                  : PlayVideo(
                      mediaUrl: widget.imageUrl,
                      timestamp: widget.timestamp,
                      posterPhone: widget.postOwner)),
    );
  }

  commentInput() {
    //and Description
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          widget.description == ''
              ? SizedBox()
              : Row(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      child: widget.postOwner == pref.pin
                          ? Container(
                              padding: EdgeInsets.all(1.0),
                              decoration: new BoxDecoration(
                                color: Color(0xffb00bae3),
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(pref.profileUrl),
                                backgroundColor: Colors.grey[300],
                                radius: 18,
                                // child: Text('${pref.profileUrl}'),
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.all(1.0),
                              decoration: new BoxDecoration(
                                color: Color(0xffb00bae3),
                                shape: BoxShape.circle,
                              ),
                              child:
                                  // CircleAvatar(
                                  //   child: Icon(
                                  //     Icons.person,
                                  //     color: Colors.white,
                                  //     size: 20,
                                  //   ),
                                  //   backgroundColor: Colors.grey[300],
                                  //   radius: 25,
                                  // ),

                                  CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl:
                                    'http://54.200.143.85:4200/profiles/now/${widget.postOwner}.jpg',
                                placeholder: (context, url) => Center(
                                  child: SizedBox(
                                    height: 40.0,
                                    width: 40.0,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.0),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                 FadeInImage.assetNetwork(
                                placeholder: 'assets/loading.gif',
                                image:
                                    'http://54.200.143.85:4200/profiles/then/${widget.postOwner}.jpg',
                              )
                                //  Image.network(
                                //     'http://54.200.143.85:4200/profiles/then/${widget.postOwner}.jpg'),
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${widget.description}'),
                    ),
                  )
                ]),
          widget.description == '' ? SizedBox() : Divider(height: 0.0),
          Container(
            margin: const EdgeInsets.all(2),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    alignment: Alignment(0.0, 0.0),
                    height: 40,
                    margin: EdgeInsets.only(left: 2),
                    padding: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(50.0),
                        ),
                        border: Border.all(
                          width: 1,
                          color: Color(0xffb578de3),
                        )),
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _commentController,
                      onChanged: (String messageText) {
                        print(messageText.trim().length);
                        setState(() {
                          _isComposingMessage = messageText.trim().length > 0;
                        });
                      },
                      decoration: InputDecoration.collapsed(
                          hintText: "Add a comment..."),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(0),
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? getIOSSendButton()
                      : getDefaultSendButton(),
                ),
              ],
            ),
          ),
          Divider(height: 0.0),
        ],
      ),
    );
  }

  _textMessageSubmitted(String text) {
    // print('send comment : $text');
    addComment(_commentController.text.trim());
    setState(() {
      _isComposingMessage = false;
    });
    _commentController.clear();
  }

  CupertinoButton getIOSSendButton() {
    return CupertinoButton(
      child: Text(
        "Post",
        style: TextStyle(color: Colors.blue),
      ),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_commentController.text.trim())
          : null,
    );
  }

  FlatButton getDefaultSendButton() {
    return FlatButton(
      child: Text(
        "Post",
        style: TextStyle(color: Colors.blue),
      ),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_commentController.text.trim())
          : null,
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final String timestamp;

  Comment(
      {this.username,
      this.userId,
      this.avatarUrl,
      this.comment,
      this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot document) {
    return Comment(
      username: document['username'],
      userId: document['userId'],
      comment: document["comment"],
      timestamp: document["timestamp"],
      avatarUrl: document["avatarUrl"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: Stack(
            alignment: Alignment.topLeft,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(1.0),
                decoration: new BoxDecoration(
                  color: Color(0xffb00bae3),
                  shape: BoxShape.circle,
                ),
                child: 
                GestureDetector(
                  onTap: (){
                    print('avatar:$avatarUrl');
                    print('userId:$userId');
                  },
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundColor: Colors.grey[300],
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl:
                          'http://54.200.143.85:4200/profiles/now/$userId.jpg',
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          height: 10.0,
                          width: 10.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.network(
                          'http://54.200.143.85:4200/profiles/then/$userId.jpg'),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(comment),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
