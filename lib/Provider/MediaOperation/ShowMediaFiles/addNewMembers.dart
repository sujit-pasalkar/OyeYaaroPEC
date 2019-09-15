// // modifi your add new member functionality
// import 'dart:async';
// import 'package:oye_yaaro_pec/Models/sharedPref.dart';
// import 'package:oye_yaaro_pec/Provider/SqlCool/sql_queries.dart';
// import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// import '../../Firebase/realtime_database_operation.dart';

// class AddMember extends StatefulWidget {
//   final String chatId, name;
//   AddMember(
//       {@required this.chatId, @required this.name});

//   @override
//   _AddMemberState createState() => _AddMemberState();
// }

// class _AddMemberState extends State<AddMember> {
//   List<ContactDetails> phoneBook = List<ContactDetails>();
//   List<Map<String, dynamic>> records =  List<Map<String, dynamic>>();

//   bool isLoading = true, searchContacts = false; 

//   List<String> addInGroup =  List<String>();
//   List<String> mem =  List<String>();
//   // String admin ;

//   final TextEditingController _textEditingController =
//        TextEditingController();

//   @override
//   void initState() {
//     getSqlContacts();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   void searchContactsFunc(String searchText) {
//     print('in searchContactsFunc');
//     List<ContactDetails> searched = List<ContactDetails>();

//     for (int i = 0; i < records.length; i++) {
//       if (records[i]['contactsName']
//           .toLowerCase()
//           .contains(searchText.toLowerCase())) {
//         if (addInGroup.contains(records[i]['contactsPhone'].toString())) {
//           searched.add(ContactDetails(
//               name: records[i]['contactsName'],
//               phone: records[i]['contactsPhone'].toString(),
//               // registered: int.parse(records[i]['contactRegistered']),
//               checked: true,
//               profileUrl: records[i]['profileUrl']));
//         } else {
//           searched.add(ContactDetails(
//               name: records[i]['contactsName'],
//               phone: records[i]['contactsPhone'].toString(),
//               // registered: int.parse(records[i]['contactRegistered']),
//               checked: false,
//               profileUrl: records[i]['profileUrl']));
//         }
//       }
//     }
//     setState(() {
//       phoneBook = searched;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         Scaffold(
//           appBar: AppBar(
//             title: !searchContacts
//                 ? Text('Add new members')
//                 : TextField(
//                     style: new TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.bold),
//                     decoration: InputDecoration(
//                       hintText: 'Type Contact name..',
//                       border: InputBorder.none,
//                     ),
//                     controller: _textEditingController,
//                     autofocus: true,
//                     onChanged: (String searchText) {
//                       searchContactsFunc(searchText);
//                     },
//                   ),
//             backgroundColor: Color(0xffb00bae3),
//             actions: <Widget>[
//               records.length > 0
//                   ? !searchContacts
//                       ? IconButton(
//                           icon: Icon(Icons.search),
//                           onPressed: () {
//                             setState(() {
//                               searchContacts = !searchContacts;
//                             });
//                           },
//                         )
//                       : IconButton(
//                           icon: Icon(Icons.close),
//                           onPressed: () {
//                             setState(() {
//                               searchContacts = !searchContacts;
//                               List<ContactDetails> l = List<ContactDetails>();

//                               records.forEach((f) {
//                                 if (addInGroup
//                                     .contains(f['contactsPhone'].toString())) {
//                                   l.add(ContactDetails(
//                                       name: f['contactsName'],
//                                       phone: f['contactsPhone'].toString(),
//                                       checked: true,
//                                       profileUrl: f['profileUrl']));
//                                 } else {
//                                   l.add(ContactDetails(
//                                       name: f['contactsName'],
//                                       phone: f['contactsPhone'].toString(),
//                                       checked: false,
//                                       profileUrl: f['profileUrl']));
//                                 }
//                               });
//                               l.sort((a, b) => a.name.compareTo(b.name));
//                               phoneBook = l;
//                               _textEditingController.text = '';
//                             });
//                           },
//                         )
//                   : SizedBox(),
//             ],
//             flexibleSpace: FlexAppbar(),
//           ),
//           body: Container(
//             child: phoneBook.length == 0
//                 ?  Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Icon(Icons.person_add,size: 80,color: Color(0xffb00bae3),),
//                       Padding(
//                         padding: EdgeInsets.all(10),
//                         child: Text(
//                           '',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 25),
//                         ),
//                       ),
//                       Container(
//                         alignment: Alignment.centerLeft,
//                         padding: EdgeInsets.only(left: 50, right: 50, top: 10),
//                         child: Text(
//                           'Looks like your all oye yaaro contacts are already \n in ${widget.name}. \n Invite more friends from contacts.',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                               fontSize: 16.0,
//                               color: Colors.black.withOpacity(0.50)),
//                         ),
//                       )
//                     ],
//                   ),
//                 )
//                 : ListView.builder(
//                     itemCount: phoneBook?.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       return _buildListTile(phoneBook[index]);
//                     },
//                   ),
//           ),
//           floatingActionButton: addInGroup.length > 0
//               ? new FloatingActionButton(
//                   backgroundColor: Color(0xffb00bae3),
//                   child: Icon(
//                     Icons.check,
//                     color: Colors.white,
//                     size: 35,
//                   ),
//                   onPressed: () {
//                     // make loading
//                     setState(() {
//                       isLoading = true;
//                     });

//                     // print('goto create group');
//                     print('addingroup:$addInGroup');
//                     List<String> send = new List<String>();
//                     send.addAll(addInGroup);
//                     send.addAll(mem); //widget.members
//                     send.remove(pref.phone.toString());
//                     print('final add members');
//                     rt
//                         .addNewMembersToFirebase(
//                       widget.chatId,
//                       send,
//                       widget.name,
//                     )
//                         .then((onValue) async {
//                       // add sql
//                       await addMemsToSql(addInGroup);
//                       setState(() {
//                         isLoading = false;
//                       });
//                       Fluttertoast.showToast(
//                           msg: 'New members added in ${widget.name}');
//                       Navigator.pop(context);
//                     }, onError: (e) {
//                       Fluttertoast.showToast(
//                           msg:
//                               'Something went wrong! check internet connection.');
//                     });
//                     // Add-----
//                     // Navigator.push(
//                     //     context,
//                     //     MaterialPageRoute(
//                     //       builder: (context) => CreateGroupWithName(
//                     //           addMembers: cl,
//                     //           checkAddMembers: addInGroup),
//                     //     ));
//                     // addNewMember();
//                   },
//                 )
//               : SizedBox(height: 0, width: 0),
//         ),
//         isLoading
//             ? Container(
//                 decoration: BoxDecoration(color: Colors.black54),
//                 child: Center(
//                   child: CircularProgressIndicator(
//                     valueColor:
//                         new AlwaysStoppedAnimation<Color>(Color(0xffb00bae3)),
//                   ),
//                 ))
//             : SizedBox(),
//       ],
//     );
//   }

//   Future addMemsToSql(List<String> addIn) async {
//     Completer _c = new Completer();
//     try {
//       addIn.forEach((m) {
//         print('-add member:$m');
//         // get member details from sql contacts
//         sqlQuery.getContactRow(m).then((onValue) {
//           print('val:$onValue');
//           if (onValue.length == 0) {
//             //this condtion will never come as im adding only may contacts to group
//             print('this number is not in your contact list');
//             Map<String, String> addMember = {
//               'chatId': widget.chatId,
//               'memberPhone': m,
//               'memberName': m,
//               'profileUrl': '',
//               'userType': 'user' 
//             };
//             // add that member in groupMember table sql
//             sqlQuery.addGroupsMember(addMember).then((onValue) {
//               print('$m added in group members sql');
//             }, onError: (e) {
//               print('Error while adding group members in sql:$e');
//             });
//           } else {
//             print('add:${onValue[0]['contactsPhone']}');
//             Map<String, String> addMember = {
//               'chatId': widget.chatId,
//               'memberPhone': onValue[0]['contactsPhone'],
//               'memberName': onValue[0]['contactsName'],
//               'profileUrl': onValue[0]['profileUrl'],
//               'userType': 'user'
//             };
//             sqlQuery.addGroupsMember(addMember).then((onValue) {
//               print('$m added in group members sql');
//             }, onError: (e) {
//               print('Error while adding group members in sql:$e');
//             });
//           }
//         });
//       });
//     } catch (e) {
//       print('Error while adding members in goup SQL:$e');
//       _c.completeError(e);
//     }
//     _c.future;
//   }

//   // GestureDetector
//   Widget _buildListTile(ContactDetails i) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           i.checked = !i.checked;
//         });
//         if (i.checked) {
//           addInGroup.add(i.phone);
//         } else {
//           addInGroup.remove(i.phone);
//         }
//       },
//       child: ListTile(
//         leading: i.profileUrl != ''
//             ? CircleAvatar(
//                 backgroundImage: NetworkImage(i.profileUrl),
//                 backgroundColor: Colors.grey[300],
//                 radius: 25,
//               )
//             : CircleAvatar(
//                 child: Icon(
//                   Icons.person,
//                   color: Colors.white,
//                   size: 35,
//                 ),
//                 backgroundColor: Colors.grey[300],
//                 radius: 25,
//               ),
//         title: Text(i.name),
//         subtitle: Text(i.phone),
//         trailing:
//             i.checked == true
//                 ? FlatButton(
//                     child: Text(
//                       'Remove',
//                       style: TextStyle(color: Colors.black),
//                     ),
//                     color: Colors.red[200],
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30.0)),
//                     onPressed: () {
//                       setState(() {
//                         i.checked = !i.checked;
//                       });
//                       if (i.checked) {
//                         addInGroup.add(i.phone);
//                       } else {
//                         addInGroup.remove(i.phone);
//                       }
//                     },
//                   )
//                 : FlatButton(
//                     child: Text(
//                       'Add',
//                       style: TextStyle(color: Colors.black),
//                     ),
//                     color: Colors.green[300],
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30.0)),
//                     onPressed: () {
//                       // if (i.registered == 1) {
//                       setState(() {
//                         i.checked = !i.checked;
//                       });
//                       if (i.checked) {
//                         addInGroup.add(i.phone);
//                       } else {
//                         addInGroup.remove(i.phone);
//                       }
//                     },
//                   ),
//         selected: i.checked,
//       ),
//     );
//   }


//   getSqlContacts() async {
//     try {
//       var res = await sqlQuery.selectGroupMembers(widget.chatId);
//       print('sqlQuery.selectGroupMembers res : $res');

//       for (var i in res) {
//         mem.add(i['memberPhone']);
//         // if(i['userType'] == 'admin'){
//         // admin = i['memberPhone'];
//         // }
//       }
//       print('now make true');
//       print('mem:$mem');
//       List<ContactDetails> l = List<ContactDetails>();

//       var contacts = await sqlQuery.selectContact();
//       print('sqlQuery.selectContact() : $contacts');

//       if (contacts.length == 0) {
//         print('No record found:Show alert and Go Back ');
//       } else {
//         for (var f in contacts) {
//           if (f['contactRegistered'] == '1' &&
//               !mem.contains(f['contactsPhone'])) {
//             records.add(f);
//           }
//         }

//         records.forEach((f) {
//           print('name:${f['contactsName']}');
//           l.add(
//             ContactDetails(
//                 name: f['contactsName'],
//                 phone: f['contactsPhone'].toString(),
//                 checked: false,
//                 profileUrl: f['profileUrl']),
//           );
//         });

//         l.sort((a, b) => a.name.compareTo(b.name));
//         setState(() {
//           phoneBook = l;
//           isLoading = false;
//         });
//         print('now phonebook : $phoneBook');
//       }
//     } catch (e) {
//       print('Error in getSqlContacts function:$e');
//     }
//   }
// }

// class ContactDetails {
//   String name, profileUrl;
//   String phone;
//   bool checked;
//   ContactDetails({this.name, this.phone, this.checked, this.profileUrl});
// }
