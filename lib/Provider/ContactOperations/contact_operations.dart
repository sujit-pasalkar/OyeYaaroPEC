import 'dart:async';
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/database_creator.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_database/firebase_database.dart';

ContactOperation co = new ContactOperation();

class ContactOperation {
  Future getContacts() async {
    print('in contact operation');
    Completer c = new Completer();
    try {
      var contacts = await ContactsService.getContacts();
      var val = await _populateContacts(contacts);
      c.complete(val);
    } catch (e) {
      print('Error from getContacts() in contact_operation.dart');
      c.completeError(e);
    }
    return c.future;
  }

  Future<dynamic> _populateContacts(Iterable<Contact> contacts) async {
    // Completer c = new Completer();
    print('in _pop');
    try {
      // if (contacts.isNotEmpty) {
      //   print('1st:${contacts.first}');
      //   // loop(list.skip(1));
      // }

      contacts.forEach((f) async {
        if (f.displayName != null && f.phones.toList().length >= 1) {
          f.phones.toList().forEach((ph) {

            String phone = ph.value
                .replaceAll('+91', '')
                .replaceAll('+1', '')
                .replaceAll(new RegExp('[^0-9a-zA-Z]+'), '');

            if (phone != pref.phone.toString()) {
              DatabaseReference profileRef;
              profileRef = database.reference().child('profiles').child(phone);
              profileRef.keepSynced(true);

              profileRef.onValue.listen((Event event) async {
                // print('event data ${event.snapshot.value}');
                if (event.snapshot.value != null) {
                  Map<String, String> row = {
                    "contactsPhone": phone,
                    "contactsName": f.displayName,
                    "contactRegistered": "1",
                    "profileUrl": event.snapshot.value['profileImg']
                  };
                  sqlQuery.addContacts(row, true).then((onValue) {},
                      onError: (e) {
                    print('err while adding :${f.displayName}, :$e');
                  });
                } else {
                  Map<String, String> row = {
                    "contactsPhone": phone,
                    "contactsName": f.displayName,
                    "contactRegistered": '0',
                    "profileUrl": ''
                  };
                  sqlQuery.addContacts(row, false).then((onValue) {},
                      onError: (e) {
                    print('err while adding :${f.displayName}, :$e');
                  });
                }
              }, onError: (Object o) {
                final DatabaseError error = o;
                print('Error in get profle from realtime db: $error');
              });
            }
          });
        }
      });
      print('returninig contacts completed:');
      // c.complete('done');
      return 'done';
    } catch (e) {
      print('Error from _populateContacts() in contact_operation.dart');
      // c.completeError(e);
      throw e;
    }
    // return c.future;
  }
}
