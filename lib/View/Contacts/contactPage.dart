// import 'package:oye_yaaro_pec/Provider/ContactOperations/contact_operations.dart';
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
import 'package:share/share.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  bool _isLoading = false, searchContacts = false; // reGetContacts = true;
  List<Map<String, dynamic>> records = new List<Map<String, dynamic>>();
  List<Map<String, dynamic>> showRecords = new List<Map<String, dynamic>>();

  final TextEditingController _textEditingController =
      new TextEditingController();

  @override
  void initState() {
    getSqlContacts();
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
    return Stack(
      children: <Widget>[
        Scaffold(
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
                            phone: int.parse(r['contactsPin']),
                          ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: Color(0xffb00bae3), shape: BoxShape.circle),
                  child: CircleAvatar(
                    child: ClipOval(
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl:
                            'http://54.200.143.85:4200/profiles/now/${r['contactsPin']}.jpg',
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: CircularProgressIndicator(strokeWidth: 1.0),
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.network(
                          'http://54.200.143.85:4200/profiles/then/${r['contactsPin']}.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    backgroundColor: Colors.grey[300],
                    radius: 25,
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

                  try {
                    String body = jsonEncode({
                      "senderPhone": pref.phone.toString(),
                      "receiverPhone": receiverNumber
                    });

                    var response = await http.post(
                        "${url.api}startChatToContacts",
                        headers: {"Content-Type": "application/json"},
                        body: body);
                    var res = jsonDecode(response.body)["data"][0];
                    var chatId = res["chat_id"];

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                              chatId: chatId,
                              chatType: 'private',
                              receiverName: r['contactsName'].toString(),
                              receiverPhone: receiverNumber,
                              profileUrl: r['profileUrl']),
                        ));

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
  // getAllContacts() async {
  //   // get
  //   co.getContacts().then((onValue) {
  //     print('i got contacts supplys');
  //     getSqlContacts();
  //     setState(() {
  //       reGetContacts = false;
  //     });
  //   }, onError: (e) {
  //     print('Error from co.getContacts():$e');
  //   });
  // }

  getSqlContacts() async {
    sqlQuery.selectContact().then((onValue) {
      if (onValue.length != 0) {
        // print('no record found');
        // if (reGetContacts) {
        //   getAllContacts();
        // }

        setState(() {
          records = onValue;
          showRecords = records;
          _isLoading = false;
        });
        //again for new
        // if (reGetContacts) {
        //   getAllContacts();
        // }
      }
      // else {

      // }
    }, onError: (e) {
      print('Error from sqlQuery.selectContact():$e');
      setState(() {
        _isLoading = false;
      });
    });
  }

  invite(phone) {
    //make common
    Share.share(
        'You are invited to join OyeYaaro. Download this App using following url http://oyeyaaro.plmlogix.com/download ');
  }
}
