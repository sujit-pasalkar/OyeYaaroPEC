// add loadiinig to scaffold
import 'dart:async';
import 'package:oye_yaaro_pec/Provider/SqlCool/database_creator.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:oye_yaaro_pec/View/Group/group_chatScreen.dart';
import 'package:oye_yaaro_pec/View/Profile/myProfile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Models/sharedPref.dart';
import '../../Models/url.dart';

class CreateGroupWithName extends StatefulWidget {
  final List<Map<String, String>> addMembers;
  final List<String> checkAddMembers;
  CreateGroupWithName(
      {@required this.addMembers, @required this.checkAddMembers});

  @override
  _CreateGroupWithNameState createState() => _CreateGroupWithNameState();
}

class _CreateGroupWithNameState extends State<CreateGroupWithName> {
  final globalKey = new GlobalKey<ScaffoldState>();
  TextEditingController _groupName = new TextEditingController();
  bool showLoading = false;

  @override
  void initState() {
    super.initState();
    print(pref.phone);
    // print('addInGroup :${widget.addMembers}');
    // print('membs :${widget.checkAddMembers}');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text('New Group'), //change dynamic
        flexibleSpace: FlexAppbar(),
      ),
      body: !showLoading
          ? Column(children: <Widget>[
              Container(
                margin: EdgeInsets.all(22.0),
                padding: EdgeInsets.fromLTRB(18.0, 0.0, 0.0, 0.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                          autofocus: true,
                          controller: _groupName,
                          cursorColor: Color(0xffb00bae3),
                          maxLength: 25,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                          decoration: InputDecoration(
                              hintText: 'Type group name here..'),
                          onChanged: (input) {
                            print(input);
                          }),
                    ),
                  ],
                ),
              ),
              Divider(height: 5.0),
              Flexible(
                child: ListView.builder(
                  itemCount: widget.addMembers.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Column(children: <Widget>[
                      ListTile(
                        leading: GestureDetector(
                            onTap: () {
                              print(widget.addMembers);
                               Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyProfile(
                            phone: int.parse(widget.addMembers[i]['phone']),
                          ),
                    ),
                  );
                            },
                            child: widget.addMembers[i]['profileUrl'] != ''
                                ? Container(
                                    padding: EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                        color: Color(0xffb00bae3),
                                        shape: BoxShape.circle),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey[300],
                                      radius: 25,
                                      backgroundImage: NetworkImage(widget
                                          .addMembers[i]['profileUrl']
                                          .toString()),
                                    ),
                                  )
                                : CircleAvatar(
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 35,
                                    ),
                                    backgroundColor: Colors.grey[300],
                                    radius: 25,
                                  )),
                        title: Text(
                          '${widget.addMembers[i]['name']}',
                        ),
                        subtitle: Text(
                          '${widget.addMembers[i]['phone']}',
                        ),
                      )
                    ]);
                  },
                ),
              ),
            ])
          : Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Color(0xffb00bae3))),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
              ],
            )),
      floatingActionButton: !showLoading
          ? new FloatingActionButton(
              backgroundColor: Color(0xffb00bae3),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 35,
              ),
              onPressed: () {
                print(_groupName.text);
                if (_groupName.text == "") {
                  Fluttertoast.showToast(msg: 'Add a group name');
                } else {
                  create();
                }
              },
            )
          : SizedBox(height: 0, width: 0),
    );
  }

  Future addMemberInFbGroup(String chatId) {
    Completer _c = new Completer();
    try {
      // add members[] in firebase groupId
      DatabaseReference groupMembersRef =
          database.reference().child('GroupMembers').child(chatId);

      groupMembersRef.push().set(<String, dynamic>{
        'groupName': _groupName.text,
        'members': widget.checkAddMembers,
        'admin': pref.phone.toString(),
      });
      // .catchError((onError){
      //   throw onError;
      // });
      _c.complete('done');
    } catch (e) {
      print('Error in addMemberInFbGroup()');
      _c.completeError(e);
    }
    return _c.future;
  }

  create() async {
    try {
      setState(() {
        showLoading = true;
      });

      var res = await createGroup(_groupName.text);
      print('await createGroup res : $res}');
      //1. add members[] in firebase groupId
      await addMemberInFbGroup(res['msg']['dialog_id'].toString());
      print('await addMemberInFbGroup res ok');

      //2.add into fb groupchatlist
      await fbGroupChatList(
        res['msg']['dialog_id'],
        pref.phone.toString(),
        'created by @${pref.name}',
        DateTime.now().millisecondsSinceEpoch.toString(),
        "0",
        _groupName.text,
      );
      print('await fbGroupChatList res ok');

      //3.now add this group info to grouplist table
      await sqlQuery.addGroupChatList(
          //change start msg
          res['msg']['dialog_id'],
          'created by @${pref.name}',
          '${pref.phone.toString()}',
          DateTime.now().millisecondsSinceEpoch.toString(),
          '0',
          _groupName.text);
      print('await addGroupChatList res ok');

      //4. now navigate to group chat screen
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GroupChatScreen(
                    chatId: res['msg']['dialog_id'],
                    chatType: 'group', //
                    groupName: _groupName.text,
                  )));

      setState(() {
        showLoading = false;
      });
    } catch (e) {
      print('this is final catch : create function failed:$e');
      setState(() {
        showLoading = false;
      });
      Fluttertoast.showToast(
          msg: "something went wrong: check internet connection!");
    }
  }

  Future fbGroupChatList(String chatId, String senderPhone, String msg,
      String timestamp, String count, String gName) async {
    Completer _c = new Completer();
    try {
      print('in FbGroupChatList():');
      DatabaseReference privateChatRef =
          database.reference().child('groupChatList').child(chatId);

      var data = {
        "chatId": chatId,
        "senderPhone": senderPhone,
        "msg": msg,
        "timestamp": timestamp,
        "count": count,
        "groupName": gName,
        "members": widget.checkAddMembers,
        "admin": senderPhone
      };
      // privateChatRef.update(data);
      privateChatRef.set(data).then((onValue) {
        print('uploaded to fb private chat list');
        _c.complete('done');
      }, onError: (e) {
        _c.completeError(e);
      });
    } catch (e) {
      print('err while updating data to fbchatlist');
      _c.completeError(e);
    }
    return _c.future;
  }

  Future createGroup(name) async {
    print('in createGroup : ');
    Completer _c = new Completer();
    try {
      String body = jsonEncode({
        "group_name": name,
        "occupants_ids": widget.checkAddMembers,
        "admin_id": pref.phone.toString()
      });
      await http
          .post("${url.api}createContactsGroup",
              headers: {"Content-Type": "application/json"}, body: body)
          .then((res) {
        var data = jsonDecode(res.body);
        print('res: $data');
        // return data;
        _c.complete(data);
      });
    } catch (e) {
      _c.completeError(e);
    }
    return _c.future;
  }
}
