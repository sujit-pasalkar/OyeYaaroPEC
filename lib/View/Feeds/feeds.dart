import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:oye_yaaro_pec/View/Profile/myProfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'feedBuilder.dart';
import 'upload_image.dart';
import 'upload_video.dart';
import 'searchFeedByTag.dart';
import '../../Models/url.dart';
// plugins
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Feeds extends StatefulWidget {
  final ScrollController hideButtonController;

  Feeds({@required this.hideButtonController, Key key}) : super(key: key);
  @override
  _FeedsState createState() => new _FeedsState();
}

class _FeedsState extends State<Feeds> with SingleTickerProviderStateMixin {
  List<FeedBuilder> feedData;
  List<Map<String, dynamic>> originalData;

  bool showMenu = false;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    this._loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Oye Yaaro"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _onMenuItemSelect('Search'),
          ),
          // IconButton(
          //   icon: Icon(Icons.filter_list),
          //   onPressed: () => _onMenuItemSelect('Filters'),
          // ),
          _menuBuilder(),
        ],
        flexibleSpace:FlexAppbar()
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          buildFeedBody(),
          loading ? Center(child: CircularProgressIndicator()) : SizedBox(),
        ],
      ),
    );
  }

  Widget _menuBuilder() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      tooltip: "Menu",
      onSelected: _onMenuItemSelect,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
              value: 'My Profile',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: <Widget>[
                    Text("My Profile"),
                    Spacer(),
                    Icon(Icons.person),
                  ],
                ),
              ),
            ),
          ],
    );
  }

  _onMenuItemSelect(String option) {
    switch (option) {
        case 'Search':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchFeedByTag(),
          ),
        );
        break;

        case 'My Profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyProfile(phone: pref.phone,),
          ),
        );
        break;
    }
  }

  

  Widget buildFeedBody() {
    return RefreshIndicator(
      onRefresh: refresh,
      child: Stack(
        children: <Widget>[
          buildFeed(),
          Positioned(
            right: 0.0,
            bottom: 0.0,
            child: Container(
              padding: EdgeInsets.only(left: 15.0, top: 5.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.black38, Colors.black.withOpacity(0)],
                ),
              ),
              child: showMenu
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.image,
                            color: Colors.white,
                          ),
                          iconSize: 35.0,
                          onPressed: () async {
                            setState(() {
                              showMenu = false;
                            });
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadImage(),
                              ),
                            );
                            refresh();
                          },
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.video_call,
                            color: Colors.white,
                          ),
                          iconSize: 35.0,
                          onPressed: () async {
                            setState(() {
                              showMenu = false;
                            });
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadVideo(),
                              ),
                            );
                            refresh();
                          },
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          iconSize: 35.0,
                          onPressed: () {
                            setState(() {
                              showMenu = false;
                            });
                          },
                        ),
                      ],
                    )
                  : IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.add_circle,
                        color: Colors.white,
                      ),
                      iconSize: 35.0,
                      onPressed: () {
                        setState(() {
                          showMenu = true;
                        });
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  buildFeed() {
    if (feedData == null || feedData.isEmpty) {
      return Container(
        width: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Image(
                image: AssetImage("assets/no-activity.png"),
              ),
            ),
            Text(
              "No Feeds Yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.75),
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "Your Contact's feeds are visible here\n",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black.withOpacity(0.50),
              ),
            ),
          ],
        ),
      );
    } else {
      return
          StaggeredGridView.count(
            // key: widget.key,
            controller: widget.hideButtonController,
            crossAxisCount: 2,
            staggeredTiles: generateStaggeredTiles(feedData.length),
            children: feedData,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            padding: EdgeInsets.all(4.0),
          );
    }
  }

  List<StaggeredTile> generateStaggeredTiles(int count) {
    List<StaggeredTile> _staggeredTiles = [];
    num one = 1.80;
    num two = 1.50;
    int loop = 0;
    for (int i = 0; i < count; i++) {
      if (i % 2 == 0) {
        // print('i:$i,$one');
        _staggeredTiles.add(new StaggeredTile.count(1, one));
      } else {
        _staggeredTiles.add(new StaggeredTile.count(1, two));
      }
      loop = loop + 1;
      // print('loop+1:$loop');
    }
    return _staggeredTiles;
  }

  Future<Null> refresh() async {
    await _getFeed(silent: true);
    setState(() {});
  }

  _loadFeed() async {
    setState(() {
      loading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString("feed");

    if (json != null) {
      originalData = jsonDecode(json).cast<Map<String, dynamic>>();
      _generateFeed(silent: true);
      _getFeed(silent: true);
    } else {
      _getFeed(silent: false);
    }
    setState(() {
      loading = false;
    });
  }

  _getFeed({@required bool silent}) async {
    //service returned unsorted response
    if (!silent) {
      setState(() {
        loading = true;
      });
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = pref.pin.toString();
    // print('userId:${pref.pin},phone : ${pref.phone}');
    String uri = '${url.api}getFeeds?userId=' + userId;
    HttpClient httpClient = new HttpClient();
    // print(uri);

    try {
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(uri));
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String json = await response.transform(utf8.decoder).join();
        prefs.setString("feed", json);
        originalData = jsonDecode(json).cast<Map<String, dynamic>>();
        print('original data ------>: $originalData');
        _generateFeed(silent: false);
      } else {
        print('Error getting a feed:\nHttp status ${response.statusCode}');
      }
    } catch (exception) {
      print('Failed invoking the getFeed function. Exception: $exception');
    }
    setState(() {
      loading = false;
    });
  }

  _generateFeed({@required bool silent}) async {
    if (!silent) {
      setState(() {
        loading = true;
        feedData = [];
      });
    }
    List<FeedBuilder> listOfPosts = [];

    originalData.sort((a, b) {
      if (a['timestamp'] > b['timestamp']) return 0;
      return 1;
    });

    for (Map<String, dynamic> postData in originalData) {
      // if (postData['visibility'] == currentUser.filterActive ||
      //     currentUser.filterActive == "All") {
      listOfPosts.add(FeedBuilder.fromJSON(postData));
      // }
    }

    setState(() {
      feedData = listOfPosts;
      loading = false;
    });
  }

  // Future _filterPost() {
  //   return showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //         padding: EdgeInsets.all(15.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             Container(
  //               alignment: Alignment.centerLeft,
  //               padding: EdgeInsets.only(bottom: 10.0),
  //               child: Text(
  //                 "See post of...",
  //                 style: TextStyle(
  //                   fontSize: 16.0,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //             FlatButton(
  //               padding: EdgeInsets.symmetric(vertical: 10.0),
  //               child: Row(
  //                 children: <Widget>[
  //                   Text("All Posts"),
  //                   currentUser.filterActive == "All"
  //                       ? Text('  (active)')
  //                       : SizedBox(),
  //                   Spacer(),
  //                   Icon(Icons.filter_none),
  //                 ],
  //               ),
  //               onPressed: () async {
  //                 Navigator.pop(context);
  //                 await currentUser.changeFilter('All');
  //                 _generateFeed(silent: false);
  //               },
  //             ),
  //             Divider(),
  //             FlatButton(
  //               padding: EdgeInsets.symmetric(vertical: 10.0),
  //               child: Row(
  //                 children: <Widget>[
  //                   Text("Class"),
  //                   currentUser.filterActive == currentUser.groupId
  //                       ? Text('  (active)')
  //                       : SizedBox(),
  //                   Spacer(),
  //                   Icon(Icons.group),
  //                 ],
  //               ),
  //               onPressed: () async {
  //                 Navigator.pop(context);
  //                 await currentUser.changeFilter(currentUser.groupId);
  //                 _generateFeed(silent: false);
  //               },
  //             ),
  //             Divider(),
  //             FlatButton(
  //               padding: EdgeInsets.symmetric(vertical: 10.0),
  //               child: Row(
  //                 children: <Widget>[
  //                   Text("College"),
  //                   currentUser.filterActive == currentUser.collegeName
  //                       ? Text('  (active)')
  //                       : SizedBox(),
  //                   Spacer(),
  //                   Icon(Icons.location_city),
  //                 ],
  //               ),
  //               onPressed: () async {
  //                 Navigator.pop(context);
  //                 await currentUser.changeFilter(currentUser.collegeName);
  //                 _generateFeed(silent: false);
  //               },
  //             ),
  //             Divider(),
  //             FlatButton(
  //               padding: EdgeInsets.symmetric(vertical: 10.0),
  //               child: Row(
  //                 children: <Widget>[
  //                   Text("Public"),
  //                   currentUser.filterActive == 'Public'
  //                       ? Text('  (active)')
  //                       : SizedBox(),
  //                   Spacer(),
  //                   Icon(Icons.public),
  //                 ],
  //               ),
  //               onPressed: () async {
  //                 Navigator.pop(context);
  //                 await currentUser.changeFilter('Public');
  //                 _generateFeed(silent: false);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _menuBuilder() {
  //   return PopupMenuButton<String>(
  //     icon: Icon(
  //       Icons.more_vert,
  //       color: Colors.white,
  //     ),
  //     tooltip: "Menu",
  //     onSelected: _onMenuItemSelect,
  //     itemBuilder: (BuildContext context) => [
  //           PopupMenuItem<String>(
  //             value: 'Profile',
  //             child: Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 5.0),
  //               child: Row(
  //                 children: <Widget>[
  //                   Text("Profile"),
  //                   Spacer(),
  //                   Icon(Icons.person),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //   );
  // }

  // _onMenuItemSelect(String option) {
  //   switch (option) {
  // case 'Profile':
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ProfilePage(
  //             userPin: currentUser.userId,
  //           ),
  //     ),
  //   );
  // break;
  // case 'Filters':
  //   _filterPost();
  //   break;

  // case 'Search':
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => SearchFeedByTag(),
  //     ),
  //   );
  //   break;
  //   }
  // }
}
