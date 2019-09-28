// came from new chat floating button (for start new personal chat)
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Models/url.dart';
import 'package:oye_yaaro_pec/Provider/ContactOperations/contact_operations.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:oye_yaaro_pec/View/Personal/personal_chatScreen.dart';
import 'package:oye_yaaro_pec/View/Profile/myProfile.dart';

// import 'createNewGroup.dart';
import 'groupInfoTabsPage.dart';

class CreateGroup extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  //service res
  String val = '';
  List<dynamic> year;
  List<dynamic> branch;

// search related vars
  final globalKey = GlobalKey<ScaffoldState>();
  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerCollege = TextEditingController();

  List<dynamic> collegelist;
  bool typing = false;
  List<dynamic> searchresult = List<dynamic>();
  List<dynamic> searchresultforClg = List<dynamic>();

  List<dynamic> collegeStudentList = List<dynamic>();
  bool showStudentSearch = false;
  bool showSearchGroupDropdown = false;

  List<DropdownMenuItem<String>> _years = [];
  List<DropdownMenuItem<String>> _branches = [];
  double opacity = 1.0;
  bool showLoading = false;
  String _year;
  String _branch;
  bool openGrpButton;

  String token, groupName; //_check,
  int _count = 0;

  @override
  void initState() {
    this.val = "";
    this.year = [];
    this.branch = [];
    values();
    super.initState();
  }

  void values() async {
    collegelist = List();
    String collegeName = pref.collegeName;
    //call getCollegeList Service
    collegelist.addAll([
      collegeName,
    ]);

    for (int i = 0; i < collegelist.length; i++) {
      String data = collegelist[i];
      searchresultforClg.add(data);
    }
    print('clg: $collegelist');
  }

  @override
  Widget build(BuildContext context) {
    loadData();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: FlexAppbar(),
        title: this.val == ''
            ? appBarTitle('Search College')
            : appBarTitle(this.val),
      ),
      body: !showLoading
          ? Column(
              children: <Widget>[
                !showStudentSearch
                    ? Container(
                        margin: EdgeInsets.all(22.0),
                        padding: EdgeInsets.fromLTRB(18.0, 0.0, 0.0, 0.0),
                        child: TextField(
                            autofocus: true,
                            controller: _controllerCollege,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter College Name here..'),
                            onChanged: (input) {
                              searchOperationForCollege(input); //new search op
                            }),
                        decoration: BoxDecoration(
                            color: Colors.grey[350],
                            borderRadius: BorderRadius.circular(50.0)),
                      )
                    : Container(
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
                            this.typing && showStudentSearch
                                ? IconButton(
                                    icon: Icon(Icons.close),
                                    tooltip: 'search',
                                    onPressed: () {
                                      print('close student list');
                                      setState(() {
                                        this.typing = false;
                                        this.showSearchGroupDropdown = true;
                                        this._controller.text = "";
                                      });
                                    },
                                  )
                                : Text('')
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: Colors.grey[350],
                            borderRadius: BorderRadius.circular(50.0)),
                      ),

                Divider(height: 5.0),

                this.typing && showStudentSearch
                    ? Flexible(
                        child: ListView.builder(
                          itemCount: searchresult.length,
                          itemBuilder: (BuildContext context, int index) {
                            bool isActive = searchresult[index]['joined'];
                            return Column(
                              children: <Widget>[
                                ListTile(
                                  leading: GestureDetector(
                                      child: Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration:  BoxDecoration(
                                          color: Color(0xffb00bae3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Container(
                                          margin: EdgeInsets.all(2.5),
                                          decoration:  BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Container(
                                              margin: EdgeInsets.all(1.0),
                                              decoration:  BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[300],
                                              ),
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40.0),
                                                  child: Image.network(
                                                    "http://oyeyaaroapi.plmlogix.com/getAvatarImageNow/${searchresult[index]['PinCode']}",
                                                    fit: BoxFit.cover,
                                                  ))),
                                        ),
                                      ),
                                      onTap: () {
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => MyProfile(
                                        //       pin: int.parse(searchresult[index]
                                        //           ['PinCode']),
                                        //     ),
                                        //   ),
                                        // );
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
                                  trailing: isActive
                                      ? FlatButton(
                                          child: Text(
                                            'Chat',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          splashColor: Colors.green,
                                          color: Color(0xffb00bae3),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0)),
                                          onPressed: () {
                                            print('nav to chat');
                                            chat(
                                                searchresult[index]['PinCode'],
                                                searchresult[index]['Name'],
                                                searchresult[index]['Mobile']);
                                          })
                                      : FlatButton(
                                          child: Text(
                                            'Invite',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          splashColor: Colors.green,
                                          color: Color(0xffb00bae3),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0)),
                                          onPressed: () {
                                            invite(
                                                searchresult[index]['PinCode']);
                                          },
                                        ),
                                ),
                                Divider(height: 5.0),
                              ],
                            );
                          },
                        ),
                      )
                    : this.typing || !showStudentSearch
                        ? Flexible(
                            child: ListView.builder(
                              itemCount: searchresultforClg.length,
                              itemBuilder: (BuildContext context, int index) {
                                String listData = searchresultforClg[index];
                                return Column(
                                  children: <Widget>[
                                    GestureDetector(
                                        child: ListTile(
                                            title: Text(listData.toString())),
                                        onTap: () {
                                          tapOnCollege(listData.toString());
                                        }),
                                    Divider(height: 5.0),
                                  ],
                                );
                              },
                            ),
                          )
                        : Container(),

                //dropdowns
                showSearchGroupDropdown
                    ? Flexible(
                        fit: FlexFit.tight,
                        child: ListView(
                          children: <Widget>[
                            Container(
                              padding:
                                  EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                              child: Form(
                                key: formKey,
                                autovalidate: true,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    FormField(
                                      builder: (FormFieldState state) {
                                        return InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'Branch',
                                          ),
                                          child:
                                              new DropdownButtonHideUnderline(
                                            child: new DropdownButton(
                                              value: _branch,
                                              items: _branches,
                                              hint: new Text('Select branch'),
                                              onChanged: (value) {
                                                _branch = value;
                                                setState(() {
                                                  _count = 0;
                                                  _branch = value;
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    FormField(
                                      builder: (FormFieldState state) {
                                        return InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'Year',
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton(
                                              value: _year,
                                              items: _years,
                                              hint: Text('Select year'),
                                              onChanged: (value) {
                                                _year = value;
                                                setState(() {
                                                  _count = 0;
                                                  _year = value;
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 60.0),
                                    ),
                                    SizedBox(
                                      width: 210.0, // double.infinity / 2,
                                      height: 50.0,
                                      child: FlatButton(
                                        child: Text(
                                          'Search Group', //'Find Group',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),

                                        splashColor: Colors.green,
                                        color: Color(0xffb00bae3),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0)),
                                        onPressed:
                                            _checkGroup, //openGrpButton? _checkGroup :null,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                // Text("drop else")
              ],
            )
          : Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  Color(0xffb00bae3),
                ),
              ),
            ),
    );
  }

  void searchOperationForCollege(String searchText) {
    print('typing..for college');
    setState(() {
      this.typing = true;
    });
    searchresultforClg.clear();
    for (int i = 0; i < collegelist.length; i++) {
      String data = collegelist[i];
      if (data.toLowerCase().contains(searchText.toLowerCase())) {
        //contains
        searchresultforClg.add(data);
      }
    }
  }

  void searchOperation(String searchText) {
    setState(() {
      this.typing = true;
      showSearchGroupDropdown = false;
    });

    searchresult.clear();
    var inviteUsersList = [];
    //now iterate for student list
    for (int i = 0; i < this.collegeStudentList.length; i++) {
      String data = this.collegeStudentList[i]['Name'];
      if (data.toLowerCase().contains(
              searchText.toLowerCase()) // contains(searchText.toLowerCase())
          ) {
        if (this.collegeStudentList[i]['joined']) {
          searchresult.add(this.collegeStudentList[i]);
        } else {
          inviteUsersList.add(this.collegeStudentList[i]);
        }
      }
    }
    // a.compareTo(b)
    searchresult.addAll(inviteUsersList);
    searchresult.sort((a, b) => (a['Name']).compareTo(b['Name']));
    print('searchresult:$searchresult');
  }

  tapOnCollege(value) async {
    print('tapp on clg value: $value');
    setState(() {
      this.val = value;
      showLoading = true;
      this.typing = false;
      this._controllerCollege.text = value;
      this.showStudentSearch = true;
      showSearchGroupDropdown = true;
    });
    var body = jsonEncode({
      "College": "PEC", //"$value",
    });
    http
        .post("http://oyeyaaroapi.plmlogix.com/yearAndBatch",
            headers: {"Content-Type": "application/json"}, body: body)
        .then((response) {
      var res = jsonDecode(response.body);
      print('yearAndBatch res: $res');
      setState(() {
        this.year = res['data']['Years'];
        this.branch = res['data']['Streams'];
      });

      //studentListView service
      getStudentList();
    });
  }

  getStudentList() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String userPin = prefs.getString('userPin');

    http.Response response = await http.post(
      "http://oyeyaaroapi.plmlogix.com/studentList",
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"college": '${this.val}', "userPin": pref.pin}),
    );
    var res = jsonDecode(response.body);
    setState(() {
      this.collegeStudentList = res['data']; //.sort;
      showLoading = false;
    });
    print('student list res:$collegeStudentList');
  }

  Future<void> _checkGroup() async {
    if (this._branch == null) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Please Select branch'),
      ));
    } else if (this._year == null) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Please Select Year'),
      ));
    } else if (formKey.currentState.validate()) {
      formKey.currentState.save();
      setState(() {
        showLoading = true;
        _count = 0;
      });

      // _check = this.val + " " + _branch + " " + _year;
      print('$val,$_branch,$_year');

      var body3 = jsonEncode({
        "clg": "PEC",
        "branch": "$_branch",
        "year": "$_year",
      });

      http
          .post("http://oyeyaaroapi.plmlogix.com/checkGroup",
              headers: {"Content-Type": "application/json"}, body: body3)
          .then((response) {
        var res = jsonDecode(response.body);
        print('checkgroup res : $res');
        setState(() {
          showLoading = false;
        });
        print("res len :$res['data'].length");
        if (res['data'] != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GrpInfoTabsHome(
                    peerId: res['data']['dialog_id'],
                    chatType: 'group',
                    groupName: res['data']['name']),
              ));
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Group not found.'),
          ));
        }
      });
    }
  }

  void loadData() {
    _years = [];
    _branches = [];

    for (var i = 0; i < this.year.length; i++) {
      _years.add(DropdownMenuItem(
          child: Text(this.year[i].toString()),
          value: this.year[i].toString()));
    }

    for (var i = 0; i < this.branch.length; i++) {
      _branches.add(DropdownMenuItem(
          child: Text(this.branch[i].toString()),
          value: this.branch[i].toString()));
    }
  }

  Widget appBarTitle(String val) {
    return Text(
      val,
      style: new TextStyle(color: Colors.white),
    );
  }

  invite(userPin) {
    ContactOperation.sharePin(userPin);
    // Share.share(
    //     'You are invited to join your classmates @OyeYaaro. Download this App using http://oyeyaaro.plmlogix.com/download use PIN #$userPin to login.See you in the room chat!');
  }

  // Future<void> chat(context, id, name, Mobile) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String userpin = prefs.getString('userPin');
    // String userName = prefs.getString('userName');
    // String userNumber = prefs.getString('userPhone');
    // var bodyPMsg = jsonEncode({
    //   "senderPin": userpin,
    //   "receiverPin": id,
    //   "senderName": userName,
    //   "receiverName": name,
    //   "senderNumber": userNumber,
    //   "receiverNumber": Mobile
    // });
    // http
    //     .post("http://oyeyaaroapi.plmlogix.com/startChat",
    //         headers: {"Content-Type": "application/json"}, body: bodyPMsg)
    //     .then((response) {
    //   var res = jsonDecode(response.body);
    //   print(res);
    //   var chatId = res["data"][0]["chat_id"];
    //   print(chatId);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ChatPrivate(
    //         chatId: chatId,
    //         chatType: 'private',
    //         name: name,
    //         receiverPin: id,
    //         mobile: Mobile),
    //   ),
    // );
    // });
  // }

  chat( recPin, name, phone) async {
    setState(() {
      showLoading = true;
    });

    try {
      print('recPhone:$phone , name:$name , pin:$recPin');
      String body = jsonEncode({
        "senderPhone": pref.pin.toString(), 
        "receiverPhone": recPin
      });

      http
          .post("${url.api}startChatToContacts",
              headers: {"Content-Type": "application/json"}, body: body)
          .then((response) {
        var res = jsonDecode(response.body)["data"][0];
        var chatId = res["chat_id"];

        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
              chatId: chatId,
              chatType: 'private',
              receiverName: name,
              receiverPhone: phone,
              // profileUrl: chatList['profileUrl']
              recPin: recPin),
        ));

        setState(() {
          showLoading = false;
        });
      });
    } catch (e) {
      print('error while calling getchild');
      setState(() {
        showLoading = false;
      });
    }
  }

  // Widget _menuBuilder() {
  //   return PopupMenuButton<String>(
  //     icon: Icon(
  //       Icons.more_vert,
  //       color: Colors.white,
  //     ),
  //     tooltip: "Menu",
  //     onSelected: _onMenuItemSelect,
  //     itemBuilder: (BuildContext context) => [
  //       PopupMenuItem<String>(
  //         value: 'Create Group',
  //         child: Text("Create New Group"),
  //       ),
  //     ],
  //   );
  // }

  // _onMenuItemSelect(String option) {
  //   switch (option) {
  //     case 'Create Group':
  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => CreateNewGroup(),
  //         ));
  //   }
  // }
}
