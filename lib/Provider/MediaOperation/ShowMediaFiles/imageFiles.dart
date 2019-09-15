import 'dart:io';
import 'package:oye_yaaro_pec/Components/imageViwer.dart';
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'filters.dart';

class ImageFiles extends StatefulWidget {
  final String chatId, admin;
  ImageFiles({Key key, @required this.chatId, @required this.admin})
      : super(key: key);

  @override
  _ImageFilesState createState() => _ImageFilesState();
}

class _ImageFilesState extends State<ImageFiles> {
  List<Map<String, String>> images = [];
  List<Map<String, String>> all = [];

  @override
  void initState() {
    print('in get images page:${widget.admin}');
    getDir();
    super.initState();
  }

  getDir() async {
    List<Map<String, dynamic>> res = await sqlQuery.getMediaFiles(
        1,
        widget.chatId,
        widget.admin == null ? 'privateChatTable' : 'groupChatTable');
    print('getMediaFile res:$res');

    // 2
    res.forEach((f) async {
      print(f['msgMedia']);
      File downloadedFile = File(f['msgMedia']);
      bool fileExist = await downloadedFile.exists();
      print('isExist:$fileExist');
      if (fileExist) {
        if (f['senderPin'].toString() == pref.pin.toString()) {
          images.add({
            'timestamp': f['timestamp'].toString(),
            'path': f['msgMedia'],
            'senderName': 'You'
          });
        } else {
          // List<Map<String, dynamic>> data =
          //     await sqlQuery.getContactName(f['senderPhone'].toString());
          // print('senderName:$data');
          // if (data.length == 0) {
          //   images.add({
          //     'timestamp': f['timestamp'].toString(),
          //     'path': f['msgMedia'].toString(),
          //     'senderName': f['senderPhone'].toString()
          //   });
          // } else {
            images.add({
              'timestamp': f['timestamp'].toString(),
              'path': f['msgMedia'],
              'senderName': f['senderName']
            });
          // }
        }
        print(images.toString());
        all = images;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: images.length == 0
          ? Center(
              child: Container(
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
                      "No Images Found",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.75),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: Text(
                        "downloaded and shared images by you will appear here..",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black.withOpacity(0.50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              itemCount: images.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15.0,
                  mainAxisSpacing: 15.0),
              padding: EdgeInsets.all(15),
              itemBuilder: (context, position) {
                // return Text('data');
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ImageViewer(imageUrl: images[position]['path']),
                      ),
                    );
                  },
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Material(
                          color: Colors.white,
                          elevation: 14.0,
                          shadowColor: Colors.grey,
                          borderRadius: BorderRadius.circular(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                Image.file(
                                  File(images[position]['path']),
                                  fit: BoxFit.cover,
                                  width: double.maxFinite,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: EdgeInsets.only(right: 5),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Colors.black38,
                                          Colors.black.withOpacity(0)
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      DateFormat('dd MMM yyyy').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(images[position]
                                                  ['timestamp']))),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 1),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${images[position]['senderName']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ))
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: all.length == 0
          ? SizedBox()
          : FloatingActionButton(
              backgroundColor: Color(0xffb00bae3),
              child: Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 25.0,
              ),
              // Text('Filters'),
              onPressed: () async {
                List<Map<String, String>> filterRes = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Filters(
                              media: all,
                            )));
                if (filterRes != null || filterRes.length != 0) {
                  images = filterRes;
                  setState(() {});
                }
              }),
    );
  }
}
