import 'package:flutter/material.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'joined.dart';
import 'missed.dart';

class GrpInfoTabsHome extends StatefulWidget {
  final String peerId;
  // final String peerAvatar;
  final String chatType;
  final String groupName;

  GrpInfoTabsHome(
      {Key key,
      @required this.peerId,
      @required this.chatType,
      @required this.groupName})
      : super(key: key);

  @override
  _GrpInfoTabsHomeState createState() =>  _GrpInfoTabsHomeState();
}

class _GrpInfoTabsHomeState extends State<GrpInfoTabsHome>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =  TabController(vsync: this, initialIndex: 0, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  AppBar(
        title:  Text("${widget.groupName}"),
        elevation: 0.7,
        bottom:  TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: <Widget>[
             Tab(
              child: Text(
                "Active", style: TextStyle(
                      fontSize: 18.0,
                      fontStyle: FontStyle.normal,
                    ),
              ),
            ),
             Tab(
               child: Text(
                "Missing", style:  TextStyle(
                      fontSize: 18.0,
                      fontStyle: FontStyle.normal,
                    ),
              ),
            ),
          ],
        ),

        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.home),
        //     onPressed: () {
        //        Navigator.of(context).pushNamedAndRemoveUntil(
        //                 '/homepage', (Route<dynamic> route) => false);
        //     },
        //   ),
        // ],
         flexibleSpace: FlexAppbar(),
      ),
      body:  TabBarView(
        controller: _tabController,
        children: <Widget>[
           JoinedPage(peerId: widget.peerId),
           MissedPage(peerId: widget.peerId),
        ],
      ),
    );
  }
}
