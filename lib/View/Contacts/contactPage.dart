// add refresh
import 'package:oye_yaaro_pec/Provider/ContactOperations/contact_operations.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:oye_yaaro_pec/View/Personal/personal_chatScreen.dart';
import 'package:oye_yaaro_pec/View/Profile/myProfile.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Models/url.dart';
import '../../Models/sharedPref.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  bool _isLoading = false, searchContacts = false;
  List<Map<String, dynamic>> records = new List<Map<String, dynamic>>();
  List<Map<String, dynamic>> showRecords = new List<Map<String, dynamic>>();

  final TextEditingController _textEditingController = TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    getSqlContacts();
    imageCache.clear();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void searchContactsFunc(String searchText) {
    print('in searchContactsFunc');
    List<Map<String, dynamic>> rec = new List<Map<String, dynamic>>();

    for (int i = 0; i < records.length; i++) {
      if (records[i]['contactsName']
          .toLowerCase()
          .contains(searchText.toLowerCase())) {
        rec.add(records[i]);
      }
    }

    setState(() {
      showRecords = rec;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: Stack(
        children: <Widget>[
          Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: !searchContacts
                    ? Text('Select contact')
                    : TextField(
                        style: new TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: 'Type Contact name..',
                          border: InputBorder.none,
                        ),
                        controller: _textEditingController,
                        autofocus: true,
                        onChanged: (String searchText) {
                          searchContactsFunc(searchText);
                        },
                      ),
                backgroundColor: Color(0xffb00bae3),
                actions: <Widget>[
                  records.length > 0
                      ? !searchContacts
                          ? IconButton(
                              icon: Icon(Icons.search),
                              onPressed: () {
                                setState(() {
                                  searchContacts = !searchContacts;
                                });
                              },
                            )
                          : IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  searchContacts = !searchContacts;
                                  showRecords = records;
                                  _textEditingController.text = '';
                                });
                              },
                            )
                      : SizedBox()
                ],
                flexibleSpace: FlexAppbar(),
              ),
              body: Container(
                child: ListView.builder(
                  itemCount: showRecords?.length,
                  itemBuilder: (BuildContext context, int i) {
                    return _buildListTile(showRecords[i]);
                  },
                ),
              )),
          _isLoading
              ? Container(
                  decoration: BoxDecoration(color: Colors.black54),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Color(0xffb00bae3)),
                    ),
                  ))
              : SizedBox(),
        ],
      ),
    );
  }

  // GestureDetector
  Widget _buildListTile(Map<String, dynamic> r) {
    return GestureDetector(
      onTap: () {},
      child: ListTile(
        leading: r['contactRegistered'] == "1"
            ? GestureDetector(
                onTap: () {
                  print(r['contactsPin']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyProfile(
                        pin: int.parse(r['contactsPin']),
                        // phone:int.parse(r['contactsPhone'])
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: Color(0xffb00bae3), shape: BoxShape.circle),
                  child: ClipOval(
                    child: CircleAvatar(
                      child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl:
                              'http://54.200.143.85:4200/profiles/now/${r['contactsPin']}.jpg',
                          placeholder: (context, url) => Center(
                                child: SizedBox(
                                  height: 20.0,
                                  width: 20.0,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.0),
                                ),
                              ),
                          errorWidget: (context, url, error) =>
                              FadeInImage.assetNetwork(
                                placeholder: 'assets/loading.gif',
                                image:
                                    'http://54.200.143.85:4200/profiles/then/${r['contactsPin']}.jpg',
                              )
                          // Image.network(
                          //   'http://54.200.143.85:4200/profiles/then/${r['contactsPin']}.jpg',
                          //   fit: BoxFit.cover,
                          // ),
                          ),
                      backgroundColor: Colors.grey[300],
                      radius: 25,
                    ),
                  ),
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
              ),
        title: Text(r['contactsName']),
        subtitle: Text(r['contactsPhone'].toString()),
        trailing: r['contactRegistered'] == "1"
            ? FlatButton(
                child: Text(
                  'Chat',
                  style: TextStyle(color: Colors.black),
                ),
                color: Colors.green[300],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  String receiverNumber = r['contactsPhone'].toString();
                  String recPin = r['contactsPin'].toString();
                  // print('recPin:$recPin,,$r');

                  try {
                    String body = jsonEncode({
                      "senderPhone": pref.pin.toString(),
                      "receiverPhone": recPin
                    });

                    var response = await http.post(
                        "${url.api}startChatToContacts",
                        headers: {"Content-Type": "application/json"},
                        body: body);
                    var res = jsonDecode(response.body)["data"][0];
                    var chatId = res["chat_id"];
                    print(chatId);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                            chatId: chatId,
                            chatType: 'private', //
                            receiverName: r['contactsName'].toString(),
                            receiverPhone: receiverNumber,
                            recPin: recPin),
                      ),
                    );

                    setState(() {
                      _isLoading = false;
                    });
                  } catch (e) {
                    Fluttertoast.showToast(
                        msg: 'Check your internet connection');
                    print('error while calling getchild');
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
              )
            : FlatButton(
                child: Text(
                  'Invite',
                  style: TextStyle(color: Colors.white),
                ),
                splashColor: Colors.green,
                color: Color(0xffb00bae3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                onPressed: () {
                  invite(r['contactRegistered']);
                }),
      ),
    );
  }

// call this functioin on refresh
  Future<void> _refresh() async {
    try {
      // setState(() {
      //   _isLoading = true;
      // });
      await co.updateRegisteredContacts();
      // setState(() {
      //   _isLoading = false;
      // });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Contacts Updated Succeessfully.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green));
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Something Went Wrong'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
      ));
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }

  getSqlContacts() async {
    sqlQuery.selectContact().then((onValue) {
      if (onValue.length != 0) {
        setState(() {
          records = onValue;
          showRecords = records;
          _isLoading = false;
        });
      }
    }, onError: (e) {
      print('Error from sqlQuery.selectContact():$e');
      setState(() {
        _isLoading = false;
      });
    });
  }

  invite(String phone) {
    ContactOperation.sharePin(phone);
  }
}
