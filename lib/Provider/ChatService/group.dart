// not used
import 'dart:async';
import 'dart:convert';
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:http/http.dart' as http;
import '../../Models/url.dart';

class Group {
  static Future fetchGroupChat() async {
    Completer _c = new Completer();
    var arr = [];
    // print('you are in fetch GroupChat: ${pref.phone.toString()} ');
    var body = jsonEncode({"senderPhone": "${pref.pin.toString()}"});

    try {
      final response = await http.post("${url.api}getContactsGroups",
          headers: {"Content-Type": "application/json"}, body: body);
      var data = jsonDecode(response.body);
      arr = data["data"];
      print('chat list data : $arr');
      print('occupants_ids : ${arr[0]['occupants_ids'].runtimeType}');
      _c.complete(arr);
    } catch (e) {
      print('error in fetchchatsfromcontacts service : $e');
      _c.completeError(e);
    }
    return _c.future;
  }
}
