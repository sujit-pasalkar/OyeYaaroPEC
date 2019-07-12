import 'dart:io';

import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Provider/Firebase/realtime_database_operation.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/database_creator.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';
import 'package:oye_yaaro_pec/View/Profile/myProfile.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqlcool/sqlcool.dart';
import 'package:vibrate/vibrate.dart';

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
                print('data:${snapshot.hasData}');
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
                      phone: int.parse(snapshot[position]['memberPhone']),
                    ),
              ),
            );
          },
          onLongPress: widget.admin == pref.phone.toString() &&
                  snapshot[position]['memberPhone'] != widget.admin
              ? () {
                  // print('long press..');
                  vibrate();
                  _showPopupMenu(snapshot[position]);
                }
              : null,
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.white)),
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    snapshot[position]['profileUrl'] == ''
                        ? CircleAvatar(
                            child: Icon(
                              Icons.person,
                              color: Color(0xffb00bae3),
                              size: 80,
                            ),
                            backgroundColor: Colors.grey[300],
                            radius: 55,
                          )
                        : CircleAvatar(
                            backgroundImage:
                                NetworkImage(snapshot[position]['profileUrl']),
                            backgroundColor: Colors.grey[300],
                            radius: 50,
                          ),
//                           FadeInImage.memoryNetwork(
//   placeholder: kTransparentImage,
//   image: 'https://picsum.photos/250?image=9',
// );
                    Center(
                      child: Text(
                        snapshot[position]['memberName'],
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
        // PopupMenuItem(
        //   child: Text("View ${snap['memberName']}"),
        // ),
        // PopupMenuItem(
        //   child: Text("Chat with ${snap['memberName']}"),
        // ),
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
}
