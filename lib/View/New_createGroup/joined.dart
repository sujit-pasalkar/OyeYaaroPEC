import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Models/url.dart';
import 'package:oye_yaaro_pec/View/Personal/personal_chatScreen.dart';
// import 'package:oye_yaaro_pec/View/Profile/myProfile.dart';
// import '../../HomePage/ChatPage/PrivateChatPage/privateChatePage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../ProfilePage/profile.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class JoinedUsers {
  final String Name;
  final String Stream;
  final String College;
  final String thumbnail;
  final String imageNow;
  final String Mobile;
  final String UserPin;
  JoinedUsers(
      {this.Name,
      this.thumbnail,
      this.imageNow,
      this.Stream,
      this.College,
      this.Mobile,
      this.UserPin});

  factory JoinedUsers.fromJson(Map<String, dynamic> json) {
    return JoinedUsers(
        Name: json['Name'] as String,
        thumbnail: json['ImageThen'] as String,
        imageNow: json['ImageNow'] as String,
        Stream: json['Stream'] as String,
        College: json['College'] as String,
        Mobile: json['Mobile'] as String,
        UserPin: json['PinCode'] as String);
  }
}

removeSelf(pin, arrs) {
  var arr = [];
  for (var i = 0; i < arrs.length; i++) {
    if (arrs[i]['PinCode'] != pin) {
      arr.add(arrs[i]);
    }
  }
  return arr;
}

Future<List<JoinedUsers>> fetchUsers(peerId, http.Client client) async {
  var arr = [];
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  String userPin = pref.pin.toString();

  var bodyData = jsonEncode({"dialog_id": "$peerId"});
  print('JOINED FETCHED DATA:: $bodyData');
  final response = await client.post(
      'http://oyeyaaroapi.plmlogix.com/getJoined',
      headers: {"Content-Type": "application/json"},
      body: bodyData);
  var res = jsonDecode(response.body);
  print('RES-------->$res');
  arr = await removeSelf(userPin, res["users"]);
  return compute(parseUsers, jsonEncode(arr));
}

// A function that will convert a response body into a List<Photo>
List<JoinedUsers> parseUsers(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<JoinedUsers>((json) => JoinedUsers.fromJson(json)).toList();
}

class JoinedPage extends StatelessWidget {
  final String peerId;
  JoinedPage({Key key, this.peerId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<JoinedUsers>>(
        future: fetchUsers(this.peerId, http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? UsersList(users: snapshot.data)
              : Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                      Color(0xffb00bae3),
                    ),
                  ),
                );
        },
      ),
    );
  }
}

class UsersList extends StatelessWidget {
  final List<JoinedUsers> users;
  UsersList({Key key, this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
          itemCount: users.length,
          padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
          itemBuilder: (context, position) {
            return Column(
              children: <Widget>[
                ListTile(
                    leading: GestureDetector(
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: Color(0xffb00bae3),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            margin: EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              margin: EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40.0),
                                child: Image.network(
                                    'http://oyeyaaroapi.plmlogix.com/getAvatarImageNow/${users[position].UserPin}',
                                    fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => MyProfile(
                          //       pin: int.parse(users[position].UserPin),
                          //     ),
                          //   ),
                          // );
                        }),
                    title: GestureDetector(
                      child: Text(
                        '${users[position].Name[0].toUpperCase()}${users[position].Name.substring(1)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        _onTapChatUser(context, users[position].UserPin,
                            users[position].Name, users[position].Mobile);
                      },
                    ),),
                Divider(height: 5.0),
              ],
            );
          }),
    );
  }

  Future<void> _onTapChatUser(context,recPin, name, phone) async {

    try {
      print('recPhone:$phone , name:$name , pin:$recPin');
      String body = jsonEncode({
        "senderPhone": pref.pin.toString(), 
        "receiverPhone": recPin
      });

      http
          .post("${url.api}startChatToContacts",
              headers: {"Content-Type": "application/json"}, body: body)
          .then((response) {
        var res = jsonDecode(response.body)["data"][0];
        var chatId = res["chat_id"];

        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
              chatId: chatId,
              chatType: 'private',
              receiverName: name,
              receiverPhone: phone,
              recPin: recPin),
        ),);

        // setState(() {
        //   showLoading = false;
        // });
      });
    } catch (e) {
      print('error while calling getchild');
      // setState(() {
      //   showLoading = false;
      // });
    }
  }

  // Future<void> _onTapChatUser(id, name, phone) async {
    // print(id);
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String userpin = prefs.getString('userPin');
    // String userName = prefs.getString('userName');
    // String userNumber = prefs.getString('userPhone');
    // var bodyPMsg = jsonEncode({
    //   "senderPin": userpin,
    //   "receiverPin": id,
    //   "senderName": userName,
    //   "receiverName": name,
    //   "senderNumber": userNumber,
    //   "receiverNumber": Mobile
    // });
    // http
    //     .post("http://oyeyaaroapi.plmlogix.com/startChat",
    //         headers: {"Content-Type": "application/json"}, body: bodyPMsg)
    //     .then((response) {
    //   var res = jsonDecode(response.body);
    //   print(res);
    //   var chatId = res["data"][0]["chat_id"];
    //   print(chatId);
    //   // Navigator.push(
    //   //   context,
    //   //   MaterialPageRoute(
    //   //     builder: (context) => ChatPrivate(
    //   //         chatId: chatId,
    //   //         chatType: 'private',
    //   //         name: name,
    //   //         receiverPin: id,
    //   //         mobile: Mobile),
    //   //   ),
    //   // );
    // });
  // }
}
