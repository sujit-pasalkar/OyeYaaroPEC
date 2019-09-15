import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:oye_yaaro_pec/View/Group/create_newGroup.dart';
import 'createNewGroupModel.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:connect_yaar/home.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../../../ProfilePage/profile.dart';
// import 'createNewGroupWithName.dart';

class CreateNewGroup extends StatefulWidget {
  final String appBarName, groupName, groupId;
  CreateNewGroup({@required this.appBarName, this.groupName, this.groupId});

  @override
  _CreateNewGroupState createState() => _CreateNewGroupState();
}

class _CreateNewGroupState extends State<CreateNewGroup> {
  List<dynamic> collegeStudentList = [];

  final globalKey = new GlobalKey<ScaffoldState>();
  TextEditingController _controller = new TextEditingController();

  bool typing = false;
  List<dynamic> searchresult = List<dynamic>();
  bool showLoading = true;
  String val = "Loading  Student List";
  List<String> addInGroup = [];
  List<Map<String, String>> cl = List<Map<String, String>>();

  @override
  void initState() {
    super.initState();
    getStudent();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getStudent() async {
    collegeStudentList = await createNewGroup.getStudentList();
    print('collegeStudentList : $collegeStudentList');
    setState(() {
      searchresult = collegeStudentList;
      showLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text(widget.appBarName),
        backgroundColor: Color(0xffb00bae3),
        actions: <Widget>[
          !showLoading
              ? widget.appBarName == 'New Group'
                  ? FlatButton(
                      child: Text('Create',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      onPressed: addInGroup.length != 0
                          ? () {

                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateGroupWithName(
                                    addMembers: cl, checkAddMembers: addInGroup),
                              ),
                            );
                            }
                          : null,
                    )
                  : FlatButton(
                      //add new member to created grp direct call addmem service
                      child: Text('Add',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      onPressed: () {
                        setState(() {
                          showLoading = true;
                        });
                        createNewGroup
                            .addNewMembers(
                                widget.groupId, widget.groupName, addInGroup)
                            .then((res) {
                          print('added $res');
                          setState(() {
                            showLoading = false;
                          });
                          Fluttertoast.showToast(
                              msg: 'Added in ${widget.groupName}');
                          Navigator.of(context).pop();
                        });
                      })
              : SizedBox(height: 0, width: 0),
        ],
         flexibleSpace: FlexAppbar(),
      ),
      body: !showLoading
          ?
          Column(children: <Widget>[
              Container(
                margin: EdgeInsets.all(22.0),
                padding: EdgeInsets.fromLTRB(18.0, 0.0, 0.0, 0.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                          autofocus: false,
                          controller: _controller,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search by student name..'),
                          onChanged: (input) {
                            searchOperation(input);
                          }),
                    ),
                    this.typing
                        ? IconButton(
                            icon: Icon(Icons.close),
                            tooltip: 'search',
                            onPressed: () {
                              print('close student list');
                              setState(() {
                                this.typing = false;
                                this._controller.text = "";
                                searchresult = collegeStudentList;
                              });
                            },
                          )
                        : SizedBox(
                            height: 0,
                            width: 0,
                          )
                  ],
                ),
                decoration: BoxDecoration(
                    color: Colors.grey[350],
                    borderRadius: BorderRadius.circular(50.0)),
              ),
              Divider(height: 5.0),
              Flexible(
                child: ListView.builder(
                  itemCount: searchresult.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          if (addInGroup
                              .contains(searchresult[index]['PinCode'])) {
                            int ind;

                            for (int i = 0; i < cl.length; i++) {
                              if (cl[i]['pin'] ==
                                  searchresult[index]['PinCode']) {
                                ind = i;
                              }
                            }

                            cl.removeAt(ind);
                            addInGroup.remove(searchresult[index]['PinCode']);
                          } else {
                            addInGroup.add(searchresult[index]['PinCode']);

                            cl.add({
                              'name': searchresult[index]['Name'],
                              'phone': searchresult[index]['Mobile'],
                              'pin': searchresult[index]['PinCode']
                            });
                          }
                          setState(() {});
                        },
                        child: ListTile(
                            leading: GestureDetector(
                                child: Container(
                                  width: 50.0,
                                  height: 50.0,
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
                                          borderRadius:
                                              BorderRadius.circular(40.0),
                                          child: 
                                        CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl:
                                    'http://54.200.143.85:4200/profiles/now/${searchresult[index]['PinCode']}.jpg',
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
                                      'http://54.200.143.85:4200/profiles/then/${searchresult[index]['PinCode']}.jpg',
                                ),
                              ),

                                          // Image.network(
                                          //   'http://oyeyaaroapi.plmlogix.com/getAvatarImageNow/${searchresult[index]['PinCode']}',
                                          //   fit: BoxFit.cover,
                                          // ),
                                          ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  print("${searchresult[index]['PinCode']}");
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => ProfilePage(
                                  //             userPin: searchresult[index]
                                  //                 ['PinCode'])));
                                }),
                            title: searchresult[index]['Name'] == null
                                ? Text(
                                    'Name not found',
                                  )
                                : Text(searchresult[index]['Name']),
                            subtitle: searchresult[index]['Groups'][0]
                                        ['group_name'] ==
                                    null
                                ? Text(
                                    'College not found',
                                  )
                                : Text(searchresult[index]['Groups'][0]
                                    ['group_name']),
                            trailing: addInGroup
                                    .contains(searchresult[index]['PinCode'])
                                ? Icon(
                                    Icons.check_circle,
                                    color: Color(0xffb00bae3),
                                    size: 30,
                                  )
                                : Icon(
                                    Icons.radio_button_unchecked,
                                    color: Color(0xffb00bae3),
                                    size: 30,
                                  )),
                      ),
                      Divider(height: 5.0),
                    ]);
                  },
                ),
              ),
            ])
          : Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Color(0xffb00bae3))),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                Text('$val')
              ],
            )),
    );
  }

  void searchOperation(String searchText) {
    setState(() {
      this.typing = true;
      searchresult = [];
    });

    //now iterate for student list
    print(searchresult.length);
    print(collegeStudentList.length);

    for (int i = 0; i < this.collegeStudentList.length; i++) {
      String data = this.collegeStudentList[i]['Name'];
      print('$data');

      if (data.toLowerCase().contains(searchText.toLowerCase())) {
        searchresult.add(this.collegeStudentList[i]);
      }
    }
    print('added..');
  }
}
