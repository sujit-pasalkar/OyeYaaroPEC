// import 'dart:io';

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Models/url.dart';
import 'package:oye_yaaro_pec/Provider/Firebase/realtime_database_operation.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/database_creator.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';
import 'package:oye_yaaro_pec/View/Profile/myProfile.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqlcool/sqlcool.dart';
import 'package:vibrate/vibrate.dart';
import 'package:http/http.dart' as http;

class GroupInfo extends StatefulWidget {
  final String admin, name, chatId;
  GroupInfo(
      {Key key,
      @required this.admin,
      @required this.name,
      @required this.chatId})
      : super(key: key);

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  bool isLoading = false;
  SelectBloc bloc;

  @override
  void initState() {
    this.bloc = SelectBloc(
      table: "groupMembersTable",
      columns: "*",
      verbose: false,
      where: "chatId='${widget.chatId}'",
      database: db,
      reactive: true,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        StreamBuilder<List<Map>>(
            stream: bloc.items,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                print('data:${snapshot.data}');
                return memberGrid(snapshot.data);
              } else {
                return Center(child: Text(''));
              }
            }),
        isLoading
            ? Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(child: CircularProgressIndicator()),
              )
            : SizedBox()
      ],
    );
  }

  void vibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    canVibrate ? Vibrate.feedback(FeedbackType.medium) : null;
  }

  Widget memberGrid(snapshot) {
    return GridView.builder(
      itemBuilder: (context, position) {
        return GestureDetector(
          onTap: () {
            print('show profile');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyProfile(
                  pin: int.parse(snapshot[position]['memberPin']),
                ),
              ),
            );
          },
          onLongPress: widget.admin == pref.pin.toString() &&
                  snapshot[position]['memberPin'] != widget.admin
              ? () {
                  // print('long press..');
                  vibrate();
                  // _showPopupMenu(snapshot[position]);
                }
              : null,
          child: FutureBuilder<String>(
            future: getProfile(snapshot[position]['memberPin']),
            builder: (BuildContext context, AsyncSnapshot<String> snap) {
              switch (snap.connectionState) {
                case ConnectionState.none:
                  return Text('loading');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Text('loading');
                case ConnectionState.done:
                  if (snap.hasError) 
                  return 
                  Text('loading');
                  return 

                   Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white)),
                      child: Stack(
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              ClipOval(
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  radius: 50,
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        'http://54.200.143.85:4200/profiles/now/${snapshot[position]['memberPin']}.jpg',
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
                                          'http://54.200.143.85:4200/profiles/then/${snapshot[position]['memberPin']}.jpg',
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  snap.data.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              snapshot[position]['userType'] == 'admin'
                                  ? Text(
                                      'Admin',
                                      style: TextStyle(
                                        color: Colors.green,
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ],
                      ),
                      );
                  
                  // Text(
                  //   snap.data,
                  //   style: TextStyle(
                  //       color: Colors.grey,
                  //       fontSize: 10.0,
                  //       fontStyle: FontStyle.normal),
                  // );
              }
              return Text('loading'); // unreachable
            },
          ),
        );
      },
      itemCount: snapshot.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 0.0, mainAxisSpacing: 0.0),
    );
  }

  _showPopupMenu(snap) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(110, 50, 10, 100),
      items: [
        PopupMenuItem(
          child: GestureDetector(
              onTap: () {
                openAlert(snap);
                Navigator.pop(context);
              },
              child: Text("Remove ${snap['memberName']}")),
        ),
      ],
      elevation: 8.0,
    );
  }

  void openAlert(snap) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Remove ${snap['memberName']} ?'),
            content: Text(
                '${snap['memberName']} will be removed from this group',
                style: TextStyle(color: Colors.grey)),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL',
                    style: TextStyle(
                      color: Color(0xffb00bae3),
                    )),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('REMOVE',
                    style: TextStyle(
                      color: Color(0xffb00bae3),
                    )),
                onPressed: () {
                  removeMember(snap);
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  removeMember(snap) async {
    setState(() {
      isLoading = true;
    });

    // get group mem make [] and remove only selected from that [] and push[] to fb
    List<String> allMems = new List<String>();

    var res = await sqlQuery.selectGroupMembers(widget.chatId);
    // print('sqlQuery.selectGroupMembers res : $res');

    for (var i in res) {
      allMems.add(i['memberPhone']);
    }
    print('mem:$allMems');
    allMems.remove(snap['memberPhone']);
    allMems.remove(widget.admin);

    print('now:$allMems');
    rt
        .addNewMembersToFirebase(
      widget.chatId,
      allMems,
      widget.name,
    )
        .then((onValue) async {
      // delete from group member sql
      var val = await SqlQuery.deleteGroupMemberId(
          widget.chatId, snap['memberPhone'].toString());
      if (val == 1) {
        print('user deleted');
      } else {
        print('user not deleted ');
      }
    }, onError: (e) {
      print('Error while removing member from firebase:$e');
      Fluttertoast.showToast(msg: 'Something went wrong $e');
    });

    setState(() {
      isLoading = false;
    });
  }

  // make common API
  Future<String> getProfile(String pin) async {
    try {
      http.Response response = await http.post("${url.api}getProfile",
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"pin": '$pin'}));

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print('result:$result');
        print('success:${result['data'][0]['Name']}');
        return result['data'][0]['Name'];
      } else {
        return '';
      }
    } catch (e) {
      print('Error in checkUser():$e');
      return '';
    }
  }
}
