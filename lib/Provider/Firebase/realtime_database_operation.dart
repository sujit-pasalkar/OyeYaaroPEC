import 'dart:async';

import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/database_creator.dart';
import 'package:firebase_database/firebase_database.dart';

final RealtimeDB rt = new RealtimeDB();

class RealtimeDB {
  Future getPrivateChatListData() {
    Completer c = new Completer();
    try {
      c.complete('');
    } catch (e) {
      c.completeError(e);
    }
    return c.future;
  }

  Future addNewMembersToFirebase(String chatId, List<String> members, String name) {
    print('in add mem fb function:$chatId,$name');
    print('in add mem fb mems:$members');

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
}
