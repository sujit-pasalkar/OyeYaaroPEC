import 'dart:async';
import 'dart:convert';
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:http/http.dart' as http;
import '../../Models/url.dart';
class Private{

//#2.private services
  Future getChatId(String receiverNumber) async {
    //err
    print('in common getchatid:$receiverNumber');
    Completer _c = new Completer();
    try {
      String body = jsonEncode({
        "senderNumber": pref.phone.toString(),
        "receiverNumber": receiverNumber
      });
      http
          .post("http://oyeyaaroapi.plmlogix.com/startChat",
              headers: {"Content-Type": "application/json"}, body: body)
          .then((response) {
        var res = jsonDecode(response.body)["data"][0];
        var chatId = res["chat_id"];
        print("chatId:" + chatId);
        _c.complete(chatId);
      });
    } catch (e) {
      _c.completeError(e);
    }
    return _c.future;
  }

  // static Future getChatList() async {
  //   // print('in common getChatList:');
  //   // Completer _c = new Completer();
  //   try {
  //     String body = jsonEncode({
  //       "senderPhone": pref.phone.toString(),
  //     });
  //     http
  //         .post("${url.api}fetchChatsFromContacts",
  //             headers: {"Content-Type": "application/json"}, body: body)
  //         .then((response) {
  //       var res = jsonDecode(response.body);
  //       // print("chatList: ${res.runtimeType}");
  //       print("chatList: $res");
  //       // _c.complete(res);
  //       return res;
  //     });
  //   } catch (e) {
  //     print('err in getchatlist(): $e');
  //     // _c.completeError(e);
  //     return e;
  //   }
  //   // _c.future;
  // }

 static Future fetchPrivateChat() async {
    Completer _c = new Completer();
    var arr = [];
    print('you are in fetch PrivateChat service: ${pref.phone.toString()} ');
    var body = jsonEncode({"senderPhone": "${pref.phone.toString()}"});

    try {
      final response = await http.post(
          "${url.api}fetchChatsFromContacts",
          headers: {"Content-Type": "application/json"},
          body: body);
      var data = jsonDecode(response.body);
      arr = data["data"];
      print('fetchPrivateChat res: $arr');
      _c.complete(arr);
    } catch (e) {
      print('error in fetchchatsfromcontacts service : $e');
      _c.completeError(e);
    }
    return _c.future;
  }
}