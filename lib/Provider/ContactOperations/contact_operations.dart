import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Models/url.dart';
// import 'package:oye_yaaro_pec/Provider/SqlCool/database_creator.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';
import 'package:contacts_service/contacts_service.dart';
// import 'package:firebase_database/firebase_database.dart';

ContactOperation co = new ContactOperation();

class ContactOperation {
  Future getContacts() async {
    print('in contact operation');
    Completer _c = new Completer();
    try {
      Iterable<Contact> contacts =
          await ContactsService.getContacts(withThumbnails: false);
      var val = await _populateContacts(contacts);
      _c.complete(val);
    } catch (e) {
      print('Error from getContacts() in contact_operation.dart:$e');
      _c.completeError(e);
    }
    return _c.future;
  }

  Future _populateContacts(Iterable<Contact> contacts) async {
    Completer _c = new Completer();
    print('in _pop');
    try {
      for (int c = 0; c < contacts.toList().length; c++) {
        if (contacts.toList()[c].displayName != null &&
            contacts.toList()[c].phones.toList().length >= 1) {
          for (int i = 0;
              i < contacts.toList()[c].phones.toList().length;
              i++) {
            String phone = contacts
                .toList()[c]
                .phones
                .toList()[i]
                .value
                .replaceAll('+91', '')
                .replaceAll('+1', '')
                .replaceAll(new RegExp('[^0-9a-zA-Z]+'), '');
            print('$c.$phone');

            if (phone != pref.phone.toString()) {
              Map<String, String> row = {
                "contactsPhone": phone,
                "contactsName": contacts.toList()[c].displayName,
                "contactRegistered": '0',
                "profileUrl": '',
                "contactsPin": ''
              };
              await sqlQuery.addContacts(row, false);
            }
          }
        }
      }
      print('returninig contacts completed:');
      _c.complete('done');
    } catch (e) {
      print('Error from _populateContacts() in contact_operation.dart');
      _c.completeError(e);
    }
    return _c.future;
  }

  Future updateRegisteredContacts() async {
    print('in updateRegisteredContacts :');
    Completer _c = new Completer();
    try {
      List<Map<String, dynamic>> row = await sqlQuery.getPhonesfromContact();
      List<String> contactsList = List<String>();
      row.forEach((f) {
        contactsList.add(f['contactsPhone'].toString());
      });
      print('after for:${contactsList.length}');

    // need changes in service response res = [{phone:'',pin:''}]
      http.Response res = await http.post('${url.api}matchPhoneContacts',
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"contacts": contactsList}));

      if (res.statusCode == 200) {
        var result = jsonDecode(res.body);
        // print('result:$result');

        for (var number in result['matching']) {
          List<Map<String, dynamic>> rows =
              await sqlQuery.getContactRow(number);
          Map<String, String> update = {
            "contactsPhone": rows[0]['contactsPhone'],
            "contactsName": rows[0]['contactsName'],
            "contactRegistered": '1',
            "profileUrl": '',
            "contactsPin": ''
          };
          await sqlQuery.updateContactRow(update);
          // check
          // List<Map<String, dynamic>> updatedRow =
          //     await sqlQuery.getContactRow(number);
          // print('updated row:$updatedRow');
        }
        _c.complete('res');
      } else
        _c.completeError('res failed');
    } catch (e) {
      print('err in catch');
      _c.completeError(e);
    }
    return _c.future;
  }
}
