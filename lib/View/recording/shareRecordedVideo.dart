// share to private and group chatlist from video.dart page
// add recName remainig
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Models/url.dart';
import 'package:oye_yaaro_pec/Provider/Firebase/firebase_storage_operations.dart';
import 'package:oye_yaaro_pec/Provider/MediaOperation/compressMedia.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/database_creator.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:oye_yaaro_pec/View/Group/group_chatScreen.dart';
import 'package:oye_yaaro_pec/View/Personal/personal_chatScreen.dart';
import 'package:oye_yaaro_pec/View/Profile/myProfile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqlcool/sqlcool.dart';
import 'package:thumbnails/thumbnails.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShareRecordedVideo extends StatefulWidget {
  final List<String> selectedIndexes;
  ShareRecordedVideo({key: Key, @required this.selectedIndexes})
      : super(key: key);

  @override
  _ShareRecordedVideoState createState() => _ShareRecordedVideoState();
}

class _ShareRecordedVideoState extends State<ShareRecordedVideo> {
  SelectBloc privateChatListBloc, groupChatListBlock;
  bool isLoading = false;
  int uploaded = 1;
  String to;
  Directory extDir;

  @override
  void initState() {
    getDir();

    this.groupChatListBlock = SelectBloc(
      table: "groupChatListTable",
      orderBy: "chatListLastMsgTime",
      verbose: false,
      database: db,
      reactive: true,
    );

    this.privateChatListBloc = SelectBloc(
      table: "privateChatListTable", //"contactsTable",
      columns: "*",
      // where: "contactRegistered='1'",
      verbose: false,
      database: db,
      reactive: true,
    );
    super.initState();
  }

  getDir() async {
    extDir = await getExternalStorageDirectory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share with'),
        flexibleSpace: FlexAppbar(),
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            physics: ClampingScrollPhysics(),
            children: <Widget>[
              Container(
                width: double.maxFinite,
                child: ListTile(
                  leading: Icon(
                    Icons.group,
                    color: Colors.blue,
                    size: 35,
                  ),
                  title: Text(
                    'Groups',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Divider(
                height: 0.0,
              ),
              StreamBuilder<List<Map>>(
                stream: groupChatListBlock.items,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length == 0) {
                      return Container(
                          width: double.maxFinite,
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Icon(
                              Icons.error,
                              color: Colors.red[200],
                            ),
                            title: Text('No groups found !',
                                style: TextStyle(
                                  fontSize: 17,
                                )),
                            subtitle: Text('Group\'s list will appear here..',
                                style: TextStyle(
                                    fontSize: 15, fontStyle: FontStyle.italic)),
                          ));
                    } else
                      return Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height / 3,
                        ),
                        child: ListView.builder(
                            reverse: false,
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              var item = snapshot
                                  .data[(snapshot.data.length - 1) - index];
                              return _buildGroupList(item);
                            }),
                      );
                  } else {
                    return Container(
                      height: 200,
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              Container(
                  width: double.maxFinite,
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: 35,
                    ),
                    title: Text('Contact chat',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  )),
              Divider(
                height: 0.0,
              ),
              StreamBuilder<List<Map>>(
                stream: privateChatListBloc.items,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length == 0) {
                      return ListTile(
                        leading: Icon(
                          Icons.error,
                          color: Colors.red[200],
                        ),
                        title: Text('No Contact\'s chat found !',
                            style: TextStyle(
                              fontSize: 17,
                            )),
                        subtitle: Text(
                            'Your one-one chat\'s list will appear here..',
                            style: TextStyle(
                                fontSize: 15, fontStyle: FontStyle.italic)),
                      );
                    } else
                      return
                          // Column(
                          //   children: <Widget>[
                          //     Flexible(
                          //       flex:snapshot.data.length,
                          //       child:
                          Container(
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height / 2.5),
                        child: ListView.builder(
                          reverse: false,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            var item = snapshot
                                .data[(snapshot.data.length - 1) - index];
                            return _buildContactList(item);
                          },
                        ),
                      );
                    //     ),
                    //   ],
                    // );
                  } else {
                    return Container(
                      height: 200,
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ],
          ),
          isLoading
              ? Container(
                  decoration:
                      BoxDecoration(color: Colors.black.withOpacity(0.5)),
                  child: Center(
                    child: Container(
                      height: 110,
                      child: Card(
                        margin: EdgeInsets.all(15),
                        child: Row(
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator()),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Sending to $to',
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Sending $uploaded / ${widget.selectedIndexes.length}',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

// GroupList view
  Widget _buildGroupList(Map<String, dynamic> chatList) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.all(5),
          onTap: () {
            // print('chatId:${chatList['chatId']}');
            sendToGroup(chatList);
          },
          leading: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: Color(0xffb00bae3), shape: BoxShape.circle),
            child: CircleAvatar(
              child: Icon(
                Icons.group,
                color: Colors.white,
                size: 35,
              ),
              backgroundColor: Colors.grey[300],
              radius: 25,
            ),
          ),
          title: Text(chatList['chatGroupName']),
        ),
        Divider(height: 0.0, indent: 75.0)
      ],
    );
  }

// priavte chat list view
  Widget _buildContactList(Map<String, dynamic> chatList) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.all(5),
          onTap: () {
            // check contact in chat list if not then call startchat service
            // print(chatList['contactsPin']);
            sendToPrivate(chatList);
          },
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyProfile(
                    pin: pref.pin.toString() == chatList['chatListSenderPin']
                        ? int.parse(chatList['chatListRecPin'])
                        : int.parse(chatList['chatListSenderPin']),
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: Color(0xffb00bae3), shape: BoxShape.circle),
              child: ClipOval(
                child: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 25,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: 'http://54.200.143.85:4200/profiles/now/' +
                        chatList['contactsPin'].toString() +
                        '.jpg',
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: CircularProgressIndicator(strokeWidth: 1.0),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      String urlPin =
                          pref.pin.toString() == chatList['chatListSenderPin']
                              ? chatList['chatListRecPin']
                              : chatList['chatListSenderPin'];
                      // chatList['contactsPin'];
                      return FadeInImage.assetNetwork(
                        placeholder: 'assets/loading.gif',
                        image:
                            'http://54.200.143.85:4200/profiles/then/$urlPin.jpg',
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          title: Text(
              // chatList['contactsName']
              pref.pin.toString() == chatList['chatListSenderPin']
                  ? chatList['chatListRecName']
                  : chatList['chatListSenderName']),
          subtitle: Text(pref.pin.toString() == chatList['chatListSenderPin']
                  ? chatList['chatListRecPhone']
                  : chatList['chatListSenderPhone']
              // chatList['contactsPhone']
              ),
        ),
        Divider(height: 0.0, indent: 75.0)
      ],
    );
  }

// Group(send)
  sendToGroup(Map<String, dynamic> chatList) async {
    setState(() {
      isLoading = true;
      to = chatList['chatGroupName'];
    });

    try {
      DatabaseReference _membersReference = database
          .reference()
          .child('GroupMembers')
          .child('${chatList['chatId']}');
      List members = List();
      String admin;

      _membersReference.once().then((DataSnapshot snapshot) async {
        //1.firebase group members
        for (var value in snapshot.value.values) {
          print('FB groupMember val:$value');
          members.addAll(value['members']);
          admin = value['admin'];
        }
      });
      print('1.succeessfully took members and admin value from firebase');

      Future<void> upload(int i) async {
        print('2.inside for loop:count== $i');

        int timestamp = DateTime.now().millisecondsSinceEpoch;

        //2.vid thum folder
        String thumbPath = await Thumbnails.getThumbnail(
            thumbnailFolder:
                '${extDir.path}/OyeYaaro/Media/Thumbs/.${chatList['chatId']}',
            videoFile: widget.selectedIndexes[i],
            imageType: ThumbFormat.JPEG,
            quality: 30);
        print('3.sendVid thumbPath: $thumbPath');

        //3.rename default thumbnail name to desired
        File newThumb = await File(thumbPath).rename(
          '${extDir.path}/OyeYaaro/Media/Thumbs/.${chatList['chatId']}/$timestamp.jpg',
        );

        //4.add in chat
        var addGroupChatValue = await sqlQuery.addGroupChat(
            chatList['chatId'],
            widget.selectedIndexes[i],
            '2',
            timestamp.toString(),
            pref.name,
            pref.phone.toString(),
            '0',
            "mediaUrl", //firebaseUrl
            newThumb.path,
            "thumbUrl",
            pref.pin.toString());
        print('4.addGroupChatValue passed:$addGroupChatValue');

        //5.add sender's msg as last msg to privatechatlisttable sqlite

        Map<String, dynamic> obj = {
          "chatId": chatList['chatId'],
          "chatListLastMsg": 'Video',
          "chatListSenderPhone": pref.phone.toString(),
          "chatListLastMsgTime": timestamp.toString(),
          "chatListMsgCount": '0',
          "chatGroupName": chatList['chatGroupName'],
          "chatListSenderPin": pref.pin.toString()
        };

        var addGroupChatListValue = await sqlQuery.addGroupChatList(obj);
        print('5.addGroupChatListValue passed:$addGroupChatListValue');

        // 6.call compress function
        var compressedVideoFile = await cmprsMedia.compressVideo(
            File(widget.selectedIndexes[i]),
            '${extDir.path}/OyeYaaro/Media/Vid/.${chatList['chatId']}',
            '$timestamp');
        print('6.video compressed successfully:$compressedVideoFile');

        print('6.1 org img file path:${widget.selectedIndexes[i]}');
        print('6.2 compressedImageFile path :${compressedVideoFile.path}');

        var updateGroupChatValue = await sqlQuery.updateGroupChat(
            chatList['chatId'],
            pref.name,
            compressedVideoFile.path, //new desired path(compressed)
            pref.phone.toString(),
            "2", //msgType
            timestamp.toString(),
            "0", //isUpload
            "mediaUrl", //firebase url.here no need
            newThumb.path,
            "thumbUrl",
            pref.pin.toString());
        print('7: updateGroupChatValue passed : $updateGroupChatValue');

        //7.uplaod to fb
        var uploadVideoValue = await uploadVideo(
            chatList['chatId'],
            compressedVideoFile,
            '2',
            timestamp.toString(),
            pref.name,
            pref.phone.toString(),
            newThumb.path,
            chatList['chatGroupName'],
            members,
            admin,
            pref.pin.toString());

        print('8 end .Video uploaded successfully:$uploadVideoValue');
        setState(() {
          uploaded += 1;
        });
      }

      List<Future> futures = [];
      for (int index = 0; index < widget.selectedIndexes.length; index++) {
        futures.add(upload(index));
      }

      await Future.wait(futures);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GroupChatScreen(
                    chatId: chatList['chatId'],
                    chatType: 'group',
                    groupName: chatList['chatGroupName'],
                  )));
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('final Error while uploading video : $e');
      Fluttertoast.showToast(msg: 'Check internet connection');
      Fluttertoast.showToast(
          msg:
              'sending ${widget.selectedIndexes.length} videos to $to in background.}');
      setState(() {
        isLoading = false;
      });
    }
  }

// Group(upload)
  Future uploadVideo(
      String chatId,
      File vidFile,
      String type,
      String timestamp,
      String senderName,
      String senderPhone,
      String thumbPath,
      String groupName,
      List members,
      String admin,
      String senderPin) async {
    Completer _c = new Completer();
    try {
      print('8.1 status uploading started');

      //get thumb url
      String thumbUrl =
          await storage.uploadImage(timestamp.toString(), File(thumbPath));

      print('8.2 videos thumbUrl : $thumbUrl');
      var firebaseUrl =
          await storage.uploadVideo(timestamp.toString(), vidFile);

      print('8.3 firebase VideoUrl : $firebaseUrl');

      //add url to fb
      var addGroupChatFbVal = await addGroupChatFb(
          chatId,
          senderName,
          vidFile.path,
          senderPhone,
          type,
          timestamp,
          '1',
          firebaseUrl.toString(),
          thumbPath,
          thumbUrl,
          groupName,
          members,
          admin,
          senderPin);

      print('8.4 vid path uploaded to fb:$thumbPath,$addGroupChatFbVal');
      //now update query for isUploaded = 1 on this chatId row
      var updateGroupChatVal = await sqlQuery.updateGroupChat(
          chatId,
          senderName,
          vidFile.path,
          senderPhone,
          type,
          timestamp,
          '1',
          firebaseUrl.toString(),
          thumbPath,
          thumbUrl,
          senderPin);

      print('8.5 updated data vid to groupchat sql: $updateGroupChatVal');

      // add to fb chatlist
      var fbGroupChatListVal = await fbGroupChatList(chatId, senderPhone,
          'Video', timestamp, "1", groupName, members, admin, senderPin);
      print('8.6 end: entry added in fb fbGroupChatList:$fbGroupChatListVal');
      _c.complete('uploaded..');
    } catch (e) {
      print('Err in getCameraImage: ' + e);
      _c.completeError(e);
    }
    _c.future;
  }

// Group(addFB)
  Future addGroupChatFb(
      chatId,
      senderName,
      messageText,
      senderPhone,
      type,
      timestamp,
      isUploaded,
      mediaUrl,
      thumbPath,
      thumbUrl,
      gName,
      List member,
      admin,
      String senderPin) async {
    //make common
    Completer _c = new Completer();
    try {
      // firebase database
      DatabaseReference _groupMessagesreference = database
          .reference()
          .child('messages')
          .child('group')
          .child('$chatId');
      _groupMessagesreference.keepSynced(true);

      _groupMessagesreference.push().set(<String, dynamic>{
        'chatId': chatId,
        'senderName': senderName,
        'msgMedia': messageText,
        'senderPhone': senderPhone,
        'msgType': type,
        'timestamp': timestamp,
        'isUploaded': isUploaded,
        'mediaUrl': mediaUrl,
        'thumbPath': thumbPath,
        'thumbUrl': thumbUrl,
        'chatType': 'group',
        'groupName': gName,
        'members': member.toSet().toList(),
        'admin': admin,
        "senderPin": senderPin
      }).then((onValue) {
        print('9.22222 uploaded to fb private chat list');
        _c.complete('ok');
      });
    } catch (e) {
      print('Error in addGroupChatFb $e');
      _c.completeError(e);
    }
    return _c.future;
  }

// Group(FB chatList)
  Future fbGroupChatList(
      String chatId,
      String senderPhone,
      String msg,
      String timestamp,
      String count,
      String gName,
      List members,
      String adminPhone,
      String senderPin) async {
    Completer _c = new Completer();
    try {
      print('9.1 in FbGroupChatList():');

      DatabaseReference groupChatRef =
          database.reference().child('groupChatList').child(chatId);

      var data = {
        "chatId": chatId,
        "senderPhone": senderPhone,
        "msg": msg,
        "timestamp": timestamp,
        "count": count,
        "groupName": gName,
        "members": members.toSet().toList(),
        "admin": adminPhone,
        "senderPin": senderPin
      };
      groupChatRef.set(data).then((onValue) {
        print('9.2 uploaded to fb private chat list');
        _c.complete('ok');
      });
    } catch (e) {
      print('err while updating data to fbchatlist');
      _c.completeError(e);
    }
    _c.future;
  }

//...........................................................private
  sendToPrivate(Map<String, dynamic> chatList) async {
    setState(() {
      isLoading = true;
      to = pref.pin.toString() == chatList['chatListSenderPin']
          ? chatList['chatListRecName']
          : chatList['chatListSenderName'];
      // chatList['contactsName'];
    });
    String toPin = pref.pin.toString() == chatList['chatListSenderPin']
        ? chatList['chatListRecPin']
        : chatList['chatListSenderPin'];
    String toPhone = pref.pin.toString() == chatList['chatListSenderPin']
        ? chatList['chatListRecPhone']
        : chatList['chatListSenderPhone'];

    try {
      // 1.get chatId
      String body = jsonEncode({
        "senderPhone": pref.pin.toString(),
        "receiverPhone": pref.pin.toString() == chatList['chatListSenderPin']
            ? chatList['chatListRecPin']
            : chatList['chatListSenderPin']
        // chatList['contactsPin'].toString()
      });
      // print('recPin:${chatList['contactsPin']}');

      var response = await http.post("${url.api}startChatToContacts",
          headers: {"Content-Type": "application/json"}, body: body);
      var res = jsonDecode(response.body)["data"][0];
      print('res: $res');

      String chatId = res["chat_id"].toString();
      print('chatID: $chatId');

      // future upload
      Future<void> upload(int i) async {
        print('2.inside for loop:count== $i');

        int timestamp = DateTime.now().millisecondsSinceEpoch;

        //2.vid thum folder
        String thumbPath = await Thumbnails.getThumbnail(
            thumbnailFolder: '${extDir.path}/OyeYaaro/Media/Thumbs/.$chatId',
            videoFile: widget.selectedIndexes[i],
            imageType: ThumbFormat.JPEG,
            quality: 30);
        print('3.sendVid thumbPath: $thumbPath');

        //3.rename default thumbnail name to desired
        File newThumb = await File(thumbPath).rename(
          '${extDir.path}/OyeYaaro/Media/Thumbs/.$chatId/$timestamp.jpg',
        );
        print('thumb renamed: ${newThumb.path}');

        //4.add in chat
        var addPrivateChatValue = await sqlQuery.addPrivateChat(
            chatId,
            widget.selectedIndexes[i], //
            '2',
            timestamp.toString(),
            pref.name,
            pref.phone.toString(),
            toPhone, //chatList['contactsPhone'],
            '0',
            "mediaUrl", //firebaseUrl
            newThumb.path,
            "thumbUrl",
            // pref.profileUrl
            pref.pin.toString(),
            toPin,
            // chatList['contactsPin'],
            to);
        print('4.addGroupChatValue passed:$addPrivateChatValue');

        //5.add sender's msg as last msg to privatechatlisttable sqlite
        var addPrivateChatListValue = await sqlQuery.addPrivateChatList(
            chatId,
            'Video',
            pref.phone.toString(),
            toPhone, // chatList['contactsPhone'],
            timestamp.toString(),
            '0',
            // chatList['profileUrl']
            pref.pin.toString(),
            toPin, // chatList['contactsPin'],
            pref.name,
            to);
        print('5.addGroupChatListValue passed:$addPrivateChatListValue');

        // 6.call compress function
        var compressedVideoFile = await cmprsMedia.compressVideo(
            File(widget.selectedIndexes[i]),
            '${extDir.path}/OyeYaaro/Media/Vid/.$chatId',
            '$timestamp');
        print('6.video compressed successfully:$compressedVideoFile');

        print('6.1 org img file path:${widget.selectedIndexes[i]}');
        print('6.2 compressedImageFile path :${compressedVideoFile.path}');

        var updatePrivateChatValue = await sqlQuery.updatePrivateChat(
            chatId,
            pref.name,
            compressedVideoFile.path, //new desired path(compressed)
            pref.phone.toString(),
            "2", //msgType
            toPhone, //chatList['contactsPhone'],
            timestamp.toString(),
            "0", //isUpload
            "mediaUrl", //firebase url.here no need
            newThumb.path,
            "thumbUrl",
            pref.pin.toString(),
            toPin, //chatList['contactsPin']
            to);
        print('7: updateGroupChatValue passed : $updatePrivateChatValue');

        //7.uplaod to fb
        var uploadVideoValue = await uploadVideoPrivate(
            chatId,
            compressedVideoFile,
            '2',
            timestamp.toString(),
            pref.name,
            pref.phone.toString(),
            toPhone, //chatList['contactsPhone'].toString(),
            newThumb.path,
            pref.pin.toString(),
            toPin, //chatList['contactsPin']
            to);

        print('8 end .Video uploaded successfully:$uploadVideoValue');
        setState(() {
          uploaded += 1;
        });
      }

      //check if dir exist if not create

      // if(!Directory('${extDir.path}/OyeYaaro/Media/Thumbs/').existsSync()){
      //   Directory('${extDir.path}/OyeYaaro/Media/Thumbs/').createSync(recursive: true);
      //   print('/');
      // }

      // if(!Directory('${extDir.path}/OyeYaaro/Media/Vid/').existsSync()){
      //   Directory('${extDir.path}/OyeYaaro/Media/Vid/').createSync(recursive: true);
      // }

      List<Future> futures = [];
      for (int index = 0; index < widget.selectedIndexes.length; index++) {
        // print('adding video:$index');
        futures.add(upload(index));
      }
      await Future.wait(futures);
      // print('now got to private chat');
      goToPrivateChat(chatId, chatList);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('final Error while uploading video : $e');
      Fluttertoast.showToast(msg: 'Check internet connection');
      Fluttertoast.showToast(
          msg:
              'sending ${widget.selectedIndexes.length} videos to $to in background.}');

      setState(() {
        isLoading = false;
      });
    }
  }

  // Private(uploadVideo)
  Future uploadVideoPrivate(
      String chatId,
      File vidFile,
      String type,
      String timestamp,
      String senderName,
      String senderPhone,
      String receiverPhone,
      String thumbPath,
      String senderPin,
      String recPin,
      String recName) async {
    Completer _c = new Completer();
    try {
      print('8.1 status uploading started');

      //get thumb url
      String thumbUrl =
          await storage.uploadImage(timestamp.toString(), File(thumbPath));

      print('8.2 videos thumbUrl : $thumbUrl');
      var firebaseUrl =
          await storage.uploadVideo(timestamp.toString(), vidFile);

      print('8.3 firebase VideoUrl : $firebaseUrl');

      //add url to fb
      var addPrivateChatFbVal = await addPrivateChatFb(
          chatId,
          senderName,
          vidFile.path,
          senderPhone,
          type,
          receiverPhone,
          timestamp,
          '1',
          firebaseUrl.toString(),
          thumbPath,
          thumbUrl,
          senderPin,
          recPin);

      print('8.4 vid path uploaded to fb:$thumbPath,$addPrivateChatFbVal');
      //now update query for isUploaded = 1 on this chatId row
      var updatePrivateChatVal = await sqlQuery.updatePrivateChat(
          chatId,
          senderName,
          vidFile.path,
          senderPhone,
          type,
          receiverPhone,
          timestamp,
          '1',
          firebaseUrl.toString(),
          thumbPath,
          thumbUrl,
          senderPin,
          recPin,
          recName);

      print('8.5 updated data vid to groupchat sql: $updatePrivateChatVal');

      // add to fb chatlist
      var fbPrivateChatListVal = await fbPrivateChatList(chatId, senderPhone,
          'Video', timestamp, receiverPhone, "1", senderPin, recPin);
      print('8.6 end: entry added in fb fbGroupChatList:$fbPrivateChatListVal');
      _c.complete('uploaded..');
    } catch (e) {
      print('Err in getCameraImage: ' + e);
      _c.completeError(e);
    }
    _c.future;
  }

  // put this fun in provider to make common for Pchat and sharedVideo
  Future addPrivateChatFb(
      String chatId,
      String senderName,
      String messageText,
      String senderPhone,
      String type,
      String receiverPhone,
      String timestamp,
      String isUploaded,
      String mediaUrl,
      String thumbPath,
      String thumbUrl,
      String senderPin,
      String recPin) async {
    print('8.3.1 thumbPath : $thumbPath');
    //make common
    //firebase database
    Completer _c = new Completer();
    try {
      DatabaseReference _messagesreference = database
          .reference()
          .child('messages')
          .child('private')
          .child(chatId); //.equalTo(false, key: "read");
      _messagesreference.keepSynced(true);

      _messagesreference.push().set(<String, String>{
        'chatId': chatId,
        'senderName': senderName,
        'msgMedia': messageText,
        'senderPhone': senderPhone,
        'msgType': type,
        'receiverPhone': receiverPhone,
        'timestamp': timestamp,
        'isUploaded': isUploaded,
        'mediaUrl': mediaUrl,
        'thumbPath': thumbPath,
        'thumbUrl': thumbUrl,
        'chatType': 'private',
        'senderPin': senderPin,
        'recPin': recPin
      }).then((onValue) {
        print('8.3.2 uploaded to fb private chat list');
        _c.complete('ok');
      });
    } catch (e) {
      print('Error in addPrivateChatFb :$e');
      _c.completeError(e);
    }
    return _c.future;
  }

  Future fbPrivateChatList(
      String chatId,
      String senderPhone,
      String msg,
      String timestamp,
      String receiverPhone,
      String count,
      String senderPin,
      String recPin) async {
    print('8.5.1 in fbPrivateChatList():');
    Completer _c = new Completer();
    try {
      DatabaseReference privateChatRef = FirebaseDatabase.instance
          .reference()
          .child('privateChatList')
          .child(chatId);

      var data = {
        "chatId": chatId,
        "senderPhone": senderPhone,
        "msg": msg,
        "timestamp": timestamp,
        'recPhone': receiverPhone,
        "count": count,
        "senderPin": senderPin,
        "recPin": recPin
      };
      privateChatRef.set(data).then((onValue) {
        print('8.5.2 uploaded to fb private chat list');
        _c.complete('ok');
      });
    } catch (e) {
      _c.completeError(e);
    }
    return _c.future;
  }

  goToPrivateChat(String chatId, Map<String, dynamic> chatList) async {
    print('opposite user profile pic url :${chatList['profileUrl']}');
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
              chatId: chatId,
              chatType: 'private',
              receiverName: chatList['contactsName'],
              receiverPhone: chatList['contactsPhone'],
              // profileUrl: chatList['profileUrl']
              recPin: chatList['contactsPin']),
        ));
  }
}
