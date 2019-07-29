import 'dart:async';
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Provider/ChatService/common.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/database_creator.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:oye_yaaro_pec/View/Contacts/contactPage.dart';
import 'package:oye_yaaro_pec/View/Personal/personal_chatScreen.dart';
import 'package:oye_yaaro_pec/View/Profile/myProfile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqlcool/sqlcool.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatList extends StatefulWidget {
  final ScrollController hideButtonController;
  //  bool isBottomBarVisible;
  ChatList({@required this.hideButtonController, Key key}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  SelectBloc bloc;

  DatabaseReference _privateListReference;
  StreamSubscription<Event> _privateListChildChangedSubscription;
  StreamSubscription<Event> _privateListChildAddedSubscription;

  @override
  void initState() {
    this.bloc = SelectBloc(
      table: "privateChatListTable",
      orderBy: "chatListLastMsgTime",
      verbose: false,
      database: db,
      reactive: true,
    );

    // get data from firebase chatlist event(.onChildChanged)
    _privateListReference = database.reference().child('privateChatList');
    _privateListReference.keepSynced(true);

    _privateListChildChangedSubscription =
        _privateListReference.onChildChanged.listen((Event event) async {
      try {
        // check is msg for me
        if (event.snapshot.value['recPin'] == pref.pin.toString()) {
          await sqlQuery.addPrivateChatList(
            event.snapshot.value['chatId'],
            event.snapshot.value['msg'],
            event.snapshot.value['senderPhone'],
            event.snapshot.value['recPhone'],
            event.snapshot.value['timestamp'],
            event.snapshot.value['count'],
            event.snapshot.value['senderPin'],
            event.snapshot.value['recPin'],
          );
        } else {
          print('onChildChanged:this msg is not for me');
        }
      } catch (e) {
        print('Error in onChildChanged:addPrivateChatList():$e');
      }
    });

    // new chat created(.onChildAdded)
    _privateListReference = database.reference().child('privateChatList');
    _privateListReference.keepSynced(true);

    _privateListChildAddedSubscription =
        _privateListReference.onChildAdded.listen((Event event) async {
      print('getPrivateChatHistory:${pref.getPrivateChatHistory}');
      // getprivateChatHistory
      try {
        if (pref.getPrivateChatHistory == null) {
          if (event.snapshot.value['recPin'] == pref.pin.toString() ||
              event.snapshot.value['senderPin'] == pref.pin.toString()) {
            await sqlQuery.addPrivateChatList(
              event.snapshot.value['chatId'],
              event.snapshot.value['msg'],
              event.snapshot.value['senderPhone'],
              event.snapshot.value['recPhone'],
              event.snapshot.value['timestamp'],
              event.snapshot.value['count'],
              event.snapshot.value['senderPin'],
              event.snapshot.value['recPin'],
            );
          }
        }

        if (event.snapshot.value['recPin'] == pref.pin.toString()) {
          await sqlQuery.addPrivateChatList(
            event.snapshot.value['chatId'],
            event.snapshot.value['msg'],
            event.snapshot.value['senderPhone'],
            event.snapshot.value['recPhone'],
            event.snapshot.value['timestamp'],
            event.snapshot.value['count'],
            event.snapshot.value['senderPin'],
            event.snapshot.value['recPin'],
          );
        } else {
          print('onChildAdded: this added msg is not for me');
        }
      } catch (e) {
        print('Error in onChildAdded: addPrivateChatList()1:$e');
      }

      // 2
      try {
        if (event.snapshot.value['recPin'] == pref.pin.toString()) {
          await sqlQuery.addPrivateChatList(
            event.snapshot.value['chatId'],
            event.snapshot.value['msg'],
            event.snapshot.value['senderPhone'],
            event.snapshot.value['recPhone'],
            event.snapshot.value['timestamp'],
            event.snapshot.value['count'],
            event.snapshot.value['senderPin'],
            event.snapshot.value['recPin'],
          );
        } else {
          print('onChildAdded: this added msg is not for me');
        }
      } catch (e) {
        print('Error in onChildAdded: addPrivateChatList()2:$e');
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _privateListChildChangedSubscription.cancel();
    _privateListChildAddedSubscription.cancel();
    pref.setPrivateChatHistory(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Oye Yaaro"),
          flexibleSpace: FlexAppbar(),
        ),
        body: StreamBuilder<List<Map>>(
            stream: bloc.items,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                // the select query has not found anything
                if (snapshot.data.length == 0) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: new AssetImage("assets/CHAT.png"),
                          width: 150.0,
                          height: 150.0,
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Start New Chat',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 50, right: 50, top: 10),
                          child: Text(
                            'By tapping on below floating button, you can start a new chat with your contacts.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black.withOpacity(0.50)),
                          ),
                        )
                      ],
                    ),
                  );
                }
                // the select query has results
                return ListView.builder(
                    controller: widget.hideButtonController,
                    reverse: false,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      var item =
                          snapshot.data[(snapshot.data.length - 1) - index];
                      // snapshot.data[index]; //(snapshot.data.length -1) -
                      return _buildListTile(item);
                    });
              } else {
                // the select query is still running
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // CircularProgressIndicator(),
                      Padding(
                        padding: EdgeInsets.all(10),
                      )
                    ],
                  ),
                );
              }
            }),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xffb00bae3),
          child: Icon(
            Icons.chat,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Contacts(),
              ),
            );
          },
        ));
  }

  Widget _buildListTile(Map<String, dynamic> chatList) {
    return Column(
      children: <Widget>[
        ListTile(
          onTap: () {
            chat(chatList);
          },
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyProfile(
                    pin: pref.pin.toString() == chatList['chatListSenderPin']
                        ? int.parse(chatList['chatListRecPin'])
                        : int.parse(chatList['chatListSenderPin']),
                  ),
                ),
              );
              // print(pref.pin.toString() == chatList['chatListSenderPin']
              //     ? 'http://54.200.143.85:4200/profiles/now/' +
              //         chatList['chatListRecPin'].toString() +
              //         '.jpg'
              //     : 'http://54.200.143.85:4200/profiles/now/' +
              //         chatList['chatListSenderPin'].toString() +
              //         '.jpg');
              // String urlPin =
              //     pref.pin.toString() == chatList['chatListSenderPin']
              //         ? chatList['chatListRecPin']
              //         : chatList['chatListSenderPin'];
              // print('http://54.200.143.85:4200/profiles/then/$urlPin.jpg');
            },
            child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: Color(0xffb00bae3), shape: BoxShape.circle),
                child: ClipOval(
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 25,
                    child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl:
                            pref.pin.toString() == chatList['chatListSenderPin']
                                ? 'http://54.200.143.85:4200/profiles/now/' +
                                    chatList['chatListRecPin'].toString() +
                                    '.jpg'
                                : 'http://54.200.143.85:4200/profiles/now/' +
                                    chatList['chatListSenderPin'].toString() +
                                    '.jpg',
                        placeholder: (context, url) => Center(
                              child: SizedBox(
                                height: 20.0,
                                width: 20.0,
                                child:
                                    CircularProgressIndicator(strokeWidth: 1.0),
                              ),
                            ),
                        errorWidget: (context, url, error) {
                          String urlPin = pref.pin.toString() ==
                                  chatList['chatListSenderPin']
                              ? chatList['chatListRecPin']
                              : chatList['chatListSenderPin'];
                          return 
                            FadeInImage.assetNetwork(
                                placeholder: 'assets/loading.gif',
                                image:
                                    'http://54.200.143.85:4200/profiles/then/$urlPin.jpg',
                              )
                          // Image.network(
                          //   'http://54.200.143.85:4200/profiles/then/$urlPin.jpg',
                          //   fit: BoxFit.cover,
                          // )
                          ;
                        }),
                  ),
                ),),
          ),
          title: FutureBuilder<dynamic>(
            future: sqlQuery.getContactName(
                pref.pin.toString() == chatList['chatListSenderPin']
                    ? chatList['chatListRecPhone']
                    : chatList['chatListSenderPhone']),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text(
                      pref.pin.toString() == chatList['chatListSenderPin']
                          ? chatList['chatListRecPhone']
                          : chatList['chatListSenderPhone']);
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Text(
                      pref.pin.toString() == chatList['chatListSenderPin']
                          ? chatList['chatListRecPhone']
                          : chatList['chatListSenderPhone']);
                case ConnectionState.done:
                  if (snapshot.hasError)
                    return Text(
                        pref.pin.toString() == chatList['chatListSenderPin']
                            ? chatList['chatListRecPhone']
                            : chatList['chatListSenderPhone']);
                  return snapshot.data.length == 0
                      ? Text(
                          pref.pin.toString() == chatList['chatListSenderPin']
                              ? chatList['chatListRecPhone']
                              : chatList['chatListSenderPhone'])
                      : Text('${snapshot.data[0]['contactsName']}'); //show
              }
              return Text(pref.pin.toString() == chatList['chatListSenderPin']
                  ? chatList['chatListRecPhone']
                  : chatList['chatListSenderPhone']); // unreachable
            },
          ),
          subtitle: Text(chatList['chatListLastMsg'],
              overflow: TextOverflow.ellipsis),
          trailing: chatList['chatListLastMsgTime'] == ''
              ? Text('')
              : Column(
                  children: <Widget>[
                    FutureBuilder<String>(
                      future: Common.getTime(
                          int.parse(chatList['chatListLastMsgTime'])),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return Text(
                                DateFormat('dd MMM kk:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(
                                            chatList['chatListLastMsgTime']))),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.0,
                                    fontStyle: FontStyle.normal));
                          case ConnectionState.active:
                          case ConnectionState.waiting:
                            return Text(
                                DateFormat('dd MMM kk:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(
                                            chatList['chatListLastMsgTime']))),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.0,
                                    fontStyle: FontStyle.normal));
                          case ConnectionState.done:
                            if (snapshot.hasError)
                              return Text(
                                  DateFormat('dd MMM kk:mm').format(DateTime
                                      .fromMillisecondsSinceEpoch(int.parse(
                                          chatList['chatListLastMsgTime']))),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.0,
                                      fontStyle: FontStyle.normal));
                            return Text(
                              snapshot.data,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.0,
                                  fontStyle: FontStyle.normal),
                            );
                        }
                        return Text(
                            DateFormat('dd MMM kk:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(int.parse(
                                    chatList['chatListLastMsgTime']))),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.0,
                                fontStyle: FontStyle.normal)); // unreachable
                      },
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(top: 10),
                    //   child:
                    //   chatList['chatListMsgCount'] == '1' ?
                    //   Icon(Icons.brightness_1,size: 10,color: Colors.green,)
                    //  : SizedBox()
                    // )
                  ],
                ),
        ),
        Divider(height: 0.0, indent: 75.0)
      ],
    );
  }

  chat(Map<String, dynamic> chatList) async {
    // print('opposite user profile pic url :${chatList['chatListProfile']}');
    List<Map<String, dynamic>> data = await sqlQuery.getContactName(
        pref.pin.toString() == chatList['chatListSenderPin']
            ? chatList['chatListRecPhone']
            : chatList['chatListSenderPhone']);
    print('get data in chatlist: $chatList');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatList['chatId'],
          chatType: 'private', //
          receiverName: data.length == 0
              ? pref.pin.toString() == chatList['chatListSenderPin']
                  ? chatList['chatListRecPhone']
                  : chatList['chatListSenderPhone']
              : data[0]['contactsName'],
          receiverPhone: pref.pin.toString() == chatList['chatListSenderPin']
              ? chatList['chatListRecPhone']
              : chatList['chatListSenderPhone'],
          recPin: pref.pin.toString() == chatList['chatListSenderPin']
              ? chatList['chatListRecPin']
              : chatList['chatListSenderPin'],
          // profileUrl: chatList['chatListProfile']
        ),
      ),
    );
  }
}
