import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:flutter/material.dart';
import 'addNewMembers.dart';
import 'groupInfo.dart';
import 'imageFiles.dart';
import 'videoFiles.dart';

class MediaFiles extends StatefulWidget {
  final String name, chatId, admin;
  final List members; //

  MediaFiles(
      {Key key,
      @required this.name,
      @required this.chatId,
      this.members, //
      this.admin})
      : super(key: key);

  @override
  _MediaFilesState createState() => _MediaFilesState();
}

class _MediaFilesState extends State<MediaFiles> {
  @override
  void initState() {
    print('chatId-->>:${widget.chatId}');
    print('admin-->>:${widget.admin}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: widget.admin == null ? 2 : 3,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            bottom: TabBar(
              tabs: widget.admin == null
                  ? [
                      Tab(icon: Icon(Icons.image)),
                      Tab(icon: Icon(Icons.videocam)),
                    ]
                  : [
                      Tab(icon: Icon(Icons.group)),
                      Tab(icon: Icon(Icons.image)),
                      Tab(icon: Icon(Icons.videocam)),
                    ],
            ),
            title: Text(widget.name),
            actions: <Widget>[
              widget.admin == pref.phone.toString()
                  ? IconButton(
                      padding: EdgeInsets.only(right: 15.0),
                      icon: Icon(Icons.group_add),
                      onPressed: () {
                        // Navigator.push(context, route)
                        print('modifi your add new memeber functionality');
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => AddMember(
                        //           chatId: widget.chatId,
                        //           name: widget.name,
                        //         ),
                        //   ),
                        // );
                      },
                    )
                  : SizedBox()
            ],
            flexibleSpace: FlexAppbar(),
          ),
          body: TabBarView(
            children: widget.admin == null
                ? [
                    ImageFiles(
                        chatId: widget.chatId,
                        admin: widget.admin //to show group / personal
                        ),
                    VideoFiles(
                        chatId: widget.chatId,
                        admin: widget.admin 

                        ),
                  ]
                : [
                    GroupInfo(
                        // members: widget.members,//
                        admin: widget.admin, //
                        name: widget.name,
                        chatId: widget.chatId),
                    ImageFiles(chatId: widget.chatId,admin: widget.admin),
                    VideoFiles(chatId: widget.chatId,admin: widget.admin),
                  ],
          ),
        ),
      ),
    );
  }
}
