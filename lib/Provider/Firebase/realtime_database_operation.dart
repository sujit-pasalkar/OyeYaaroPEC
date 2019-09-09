import 'dart:async';

import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Models/url.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/database_creator.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';

final RealtimeDB rt = new RealtimeDB();

class RealtimeDB {
  Future checkDefaultGroup(dynamic groupInfo) async {
    print('check group_obj: $groupInfo');
    Completer c = new Completer();
    try {
      // bool group present or not in fb
      bool group = false;
      // check group id present in groupchat list and groupmembers collection
      DatabaseReference groupChatListRef =
          database.reference().child('groupChatList');

      DataSnapshot snapshot = await groupChatListRef.once();
      // print('snapshot: ${snapshot.value.values}');

      for (var value in snapshot.value.values) {
        if (value['chatId'] == groupInfo['dialog_id']) {
          group = true;
        }
      }

      print('group present :$group');
      if (!group) {
        // if not then
        // 1.get occupant_ids of that group api
        List groupMembers = await getGroupsMember(groupInfo['dialog_id']);
        print('group members:${groupMembers.length}');

        // 2.follow create_newGroup.create()
        String res = await addMemberInFbGroup(groupInfo, groupMembers);
        print('res : $res');

        //3.add into fbGroupChatlist
        await fbGroupChatList(
            groupInfo['dialog_id'],
            '',
            'Say Hi',
            DateTime.now().millisecondsSinceEpoch.toString(),
            "0",
            groupInfo['group_name'],
            '',
            groupMembers);
        print('await fbGroupChatList res ok');

        // 4..now add this group info to grouplist table
        Map<String, dynamic> obj = {
          "chatId": groupInfo['dialog_id'],
          "chatListLastMsg": 'Say Hi', //change last msg
          "chatListSenderPhone": '',
          "chatListLastMsgTime":
              DateTime.now().millisecondsSinceEpoch.toString(),
          "chatListMsgCount": '0',
          "chatGroupName": groupInfo['group_name'],
          "chatListSenderPin": ''
        };
        await sqlQuery.addGroupChatList(obj);
        print('await addGroupChatList res ok');
      } else {
        print('gruop already mapped to firebase');
      }

      c.complete('ok....');
    } catch (e) {
      c.completeError(e);
    }
    return c.future;
  }


  Future addNewMembersToFirebase(
      String chatId, List<String> members, String name) {
    // print('in add mem fb function:$chatId,$name');
    // print('in add mem fb mems:$members');

    Completer _c = new Completer();
    try {
      // add members[] in firebase groupId
      DatabaseReference groupMembersRef =
          database.reference().child('GroupMembers').child(chatId);

      groupMembersRef.remove().then((onValue) {
        groupMembersRef.push().set(<String, dynamic>{
          'groupName': name,
          'members': members,
          'admin': pref.phone.toString(),
        });
      });

      _c.complete('added');
    } catch (e) {
      _c.completeError(e);
    }
    return _c.future;
  }

  // default group create re-written functions.......

  // 1. get group memebers api
  Future getGroupsMember(groupId) async {
    Completer _c = new Completer();
    try {
      http.Response response =
          await http.post(
            "http://54.200.143.85:4200/getJoinedArray",
              // "http://54.200.143.85:4200/getJoinedArray",
              // "${url.api}/getJoinedArray",
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"dialog_id": '$groupId'}));
      var groupMembers = jsonDecode(response.body);
      print('g_id : $groupId');
      print('getJoinedArray res : $groupMembers');
      if (groupMembers['success'] == true) {
        // return groupMembers['data'];
        _c.complete(groupMembers['data']);
      } else {
        _c.complete([]);
      }
    } catch (e) {
      _c.completeError(e);
    }
    return _c.future;
  }

  // 2.
  Future addMemberInFbGroup(dynamic groupInfo, List groupMembers) {
    Completer _c = Completer();
    try {
      // add members[] in firebase groupId
      DatabaseReference groupMembersRef = database
          .reference()
          .child('GroupMembers')
          .child(groupInfo['dialog_id']);

      groupMembersRef.push().set(<String, dynamic>{
        'groupName': groupInfo['group_name'],
        'members': groupMembers,
        'admin': '',
      });
      _c.complete('done');
    } catch (e) {
      print('Error in addMemberInFbGroup()');
      _c.completeError(e);
    }
    return _c.future;
  }

  // 3.
  Future fbGroupChatList(
      String chatId,
      String senderPin,
      String msg,
      String timestamp,
      String count,
      String gName,
      String senderPhone,
      List groupMembers) async {
    Completer _c = new Completer();
    try {
      print('in FbGroupChatList():');
      DatabaseReference privateChatRef =
          database.reference().child('groupChatList').child(chatId);

      var data = {
        "chatId": chatId,
        "senderPin": senderPin,
        "msg": msg,
        "timestamp": timestamp,
        "count": count,
        "groupName": gName,
        "members": groupMembers,
        "admin": senderPin,
        "senderPhone": senderPhone
      };
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
}
