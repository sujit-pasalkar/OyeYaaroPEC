// create Group
import 'package:oye_yaaro_pec/Provider/ContactOperations/contact_operations.dart';
import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';
import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:oye_yaaro_pec/View/Group/create_newGroup.dart';
import 'package:oye_yaaro_pec/View/Profile/myProfile.dart';
import 'package:flutter/material.dart';
// import 'package:share/share.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContactsGroup extends StatefulWidget {
  @override
  _ContactsGroupState createState() => _ContactsGroupState();
}

class _ContactsGroupState extends State<ContactsGroup> {
  List<ContactDetails> phoneBook = List<ContactDetails>();
  List<ContactDetails> phoneBookCopy = List<ContactDetails>(); //for cl issue

  List<Map<String, dynamic>> records = List<Map<String, dynamic>>();

  bool isLoading = false, searchContacts = false;

  List<String> addInGroup = List<String>();

  final TextEditingController _textEditingController = TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    getSqlContacts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void searchContactsFunc(String searchText) {
    print('in searchContactsFunc');
    List<ContactDetails> searched = List<ContactDetails>();

    for (int i = 0; i < records.length; i++) {
      if (records[i]['contactsName']
          .toLowerCase()
          .contains(searchText.toLowerCase())) {
        if (addInGroup.contains(records[i]['contactsPin'].toString())) {
          searched.add(
            ContactDetails(
                name: records[i]['contactsName'],
                phone: records[i]['contactsPhone'].toString(),
                registered: int.parse(records[i]['contactRegistered']),
                checked: true,
                // profileUrl: records[i]['profileUrl'],
                contactsPin: records[i]['contactsPin']),
          );
        } else {
          searched.add(ContactDetails(
              name: records[i]['contactsName'],
              phone: records[i]['contactsPhone'].toString(),
              registered: int.parse(records[i]['contactRegistered']),
              checked: false,
              // profileUrl: records[i]['profileUrl']
              contactsPin: records[i]['contactsPin']));
        }
      }
    }
    setState(() {
      phoneBook = searched;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: Stack(
        children: <Widget>[
          Scaffold(
            key: _scaffoldKey,
              appBar: AppBar(
                title: !searchContacts
                    ? Text('Create Group')
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
                                  List<ContactDetails> l = List<ContactDetails>();
                                  records.forEach((f) {
                                    if (addInGroup
                                        .contains(f['contactsPin'].toString())) {
                                      l.add(
                                        ContactDetails(
                                          name: f['contactsName'],
                                          phone: f['contactsPhone'].toString(),
                                          registered:
                                              int.parse(f['contactRegistered']),
                                          checked: true,
                                          // profileUrl: f['profileUrl']
                                          contactsPin: f['contactsPin'],
                                        ),
                                      );
                                    } else {
                                      l.add(
                                        ContactDetails(
                                          name: f['contactsName'],
                                          phone: f['contactsPhone'].toString(),
                                          registered:
                                              int.parse(f['contactRegistered']),
                                          checked: false,
                                          // profileUrl: f['profileUrl']
                                          contactsPin: f['contactsPin'],
                                        ),
                                      );
                                    }
                                  });
                                  l.sort((a, b) => a.name.compareTo(b.name));
                                  phoneBook = l;
                                  _textEditingController.text = '';
                                });
                              },
                            )
                      : SizedBox(),
                  addInGroup.length > 0
                      ? IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            print('goto create group');
                            List<Map<String, String>> cl =
                                List<Map<String, String>>();
                            phoneBookCopy.forEach((f) {
                              if (addInGroup.contains(f.contactsPin)) {
                                cl.add({
                                  'name': f.name,
                                  'phone': f.phone,
                                  // 'profileUrl': f.profileUrl
                                  'pin': f.contactsPin
                                });
                              }
                            });
                            print('addInGroup : $addInGroup');
                            print('cl : $cl');

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateGroupWithName(
                                    addMembers: cl, checkAddMembers: addInGroup),
                              ),
                            );
                          },
                        )
                      : SizedBox()
                ],
                flexibleSpace: FlexAppbar(),
              ),
              body: Container(
                child: ListView.builder(
                  itemCount: phoneBook?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildListTile(phoneBook[index]);
                  },
                ),
              )),
          isLoading
              ? Container(
                  decoration: BoxDecoration(color: Colors.black54),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xffb00bae3)),
                    ),
                  ))
              : SizedBox(),
        ],
      ),
    );
  }

  // GestureDetector
  Widget _buildListTile(ContactDetails i) {
    return GestureDetector(
      onTap: () {
        if (i.registered == 1) {
          setState(() {
            i.checked = !i.checked;
          });
          if (i.checked) {
            addInGroup.add(i.contactsPin);
          } else {
            addInGroup.remove(i.contactsPin);
          }
        } else {
          print('not registered');
        }
      },
      child: ListTile(
        leading: i.registered == 1
            ? GestureDetector(
                onTap: () {
                  print(i.contactsPin);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyProfile(
                        pin: int.parse(i.contactsPin),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: Color(0xffb00bae3), shape: BoxShape.circle),
                  child: ClipOval(
                    child: CircleAvatar(
                      child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl:
                              'http://54.200.143.85:4200/profiles/now/${i.contactsPin}.jpg',
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
                                    'http://54.200.143.85:4200/profiles/then/${i.contactsPin}.jpg',
                              )

                          //  Image.network(
                          //   'http://54.200.143.85:4200/profiles/then/${i.contactsPin}.jpg',
                          //   fit: BoxFit.cover,
                          // ),

                          ),
                      backgroundColor: Colors.grey[300],
                      radius: 25,
                    ),
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
        title: Text(i.name),
        subtitle: Text(i.phone),
        trailing: i.registered == 1
            ? i.checked == true
                ? FlatButton(
                    child: Text(
                      'Remove',
                      style: TextStyle(color: Colors.black),
                    ),
                    color: Colors.red[200],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    onPressed: () {
                      if (i.registered == 1) {
                        setState(() {
                          i.checked = !i.checked;
                        });
                        if (i.checked) {
                          addInGroup.add(i.contactsPin);
                        } else {
                          addInGroup.remove(i.contactsPin);
                        }
                      } else {
                        print('not registered');
                      }
                    },
                  )
                : FlatButton(
                    child: Text(
                      'Add',
                      style: TextStyle(color: Colors.black),
                    ),
                    color: Colors.green[300],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    onPressed: () {
                      if (i.registered == 1) {
                        setState(() {
                          i.checked = !i.checked;
                        });
                        if (i.checked) {
                          addInGroup.add(i.contactsPin);
                        } else {
                          addInGroup.remove(i.contactsPin);
                        }
                      } else {
                        print('not registered');
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
                  invite(i.phone);
                }),
        selected: i.checked,
      ),
    );
  }

// call this functioin on refresh
  Future<void> _refresh() async {
    try {
      // setState(() {
      //   _isLoading = true;
      // });
      await co.updateRegisteredContacts();
      // setState(() {
      //   _isLoading = false;
      // });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Contacts Updated Succeessfully.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green));
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Something Went Wrong'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
      ));
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }

  getSqlContacts() async {
    sqlQuery.selectContact().then((onValue) {
      // print('sqlQuery.selectContact() : $onValue');
      if (onValue.length != 0) {
        records = onValue;
        records.forEach((f) {
          phoneBookCopy.add(
            ContactDetails(
                name: f['contactsName'],
                phone: f['contactsPhone'].toString(),
                registered: int.parse(f['contactRegistered']),
                checked: false,
                // profileUrl: f['profileUrl'],
                contactsPin: f['contactsPin']),
          );
        });
        // print('now phonebook : $phoneBook');
        phoneBookCopy.sort((a, b) => a.name.compareTo(b.name));
        setState(() {
          phoneBook = phoneBookCopy;
        });
        print('now phonebook : $phoneBook');
      } else {
        print('phone contacts is empty');
      }
    }, onError: (e) {
      print('Error from sqlQuery.selectContact():$e');
    });
  }

  invite(String phone) {
    ContactOperation.sharePin(phone);
  }
}

class ContactDetails {
  String name; //contactsPin
  String phone, contactsPin;
  int registered;
  bool checked;
  ContactDetails(
      {this.name, this.phone, this.checked, this.registered, this.contactsPin});
}
