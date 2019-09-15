// // 1st time profile
// // dont use this page in PEC as profile data is already filled..
// // now student can modify/change profile info in MyprofilePage.
// import 'dart:async';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:oye_yaaro_pec/Models/sharedPref.dart';
// import 'package:oye_yaaro_pec/Provider/ContactOperations/contact_operations.dart';
// import 'package:oye_yaaro_pec/Provider/Firebase/firebase_storage_operations.dart';
// import 'package:oye_yaaro_pec/Provider/MediaOperation/compressMedia.dart';
// import 'package:oye_yaaro_pec/Provider/SqlCool/database_creator.dart';
// import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
// import 'package:oye_yaaro_pec/View/home.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_native_image/flutter_native_image.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';

// class Profile extends StatefulWidget {
//   @override
//   _ProfileState createState() => _ProfileState();
// }

// class _ProfileState extends State<Profile> {
//   DatabaseReference _profileReference;

//   TextEditingController _textEditingController = new TextEditingController();
//   String photoPath, firebaseUrl = '';
//   bool _isLoading = true, textEdit = false, allowExit = false;

//   @override
//   void initState() {
//     _profileReference =
//         database.reference().child('profiles').child(pref.phone.toString());

//     // call get contacts
//     getAllContacts();
//     super.initState();
//   }

//   getAllContacts() async {
//     co.getContacts().then((onValue) {
//       print('got contacts');
//       setState(() {
//         _isLoading = false;
//       });
//     }, onError: (e) {
//       print('Error from co.getContacts():$e');
//       setState(() {
//         _isLoading = false;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return
//         // WillPopScope(
//         //   child:
//         Stack(
//       children: <Widget>[
//         Scaffold(
//           appBar: AppBar(
//             title: Text(
//               'Profile Info',
//               style: TextStyle(color: Colors.white),
//             ),
//             flexibleSpace: FlexAppbar(),
//           ),
//           body: Container(
//             decoration: BoxDecoration(
//                 image: DecorationImage(
//                     fit: BoxFit.cover, image: AssetImage('assets/login.png'))),
//             child: StreamBuilder(
//               stream: _profileReference.onValue,
//               builder: (context, snap) {
//                 if (snap.hasData &&
//                     !snap.hasError &&
//                     snap.data.snapshot.value != null) {
//                   // has data old user
//                   firebaseUrl =
//                       snap.data.snapshot.value['profileImg'].toString();
//                   if (!textEdit) {
//                     _textEditingController.text =
//                         snap.data.snapshot.value['name'].toString();
//                   }
//                   textEdit = true;

//                   return Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: <Widget>[
//                         new Expanded(
//                             child: ListView(
//                           children: <Widget>[
//                             Padding(
//                                 padding: EdgeInsets.all(15),
//                                 child: Text(
//                                   'Please provide your name and optional profile photo',
//                                   style: TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 16,
//                                   ),
//                                 )),
//                             Padding(
//                               padding: EdgeInsets.all(5),
//                               child: Row(
//                                 children: <Widget>[
//                                   GestureDetector(
//                                       onTap: () {
//                                         openBottomSheet();
//                                       },
//                                       child: photoPath != null
//                                           ? Container(
//                                               height: 150,
//                                               width: 150,
//                                               decoration: BoxDecoration(
//                                                 border: Border.all(
//                                                     color: Color(0xffb00bae3),
//                                                     width: 2.0),
//                                                 color: Colors.grey[300],
//                                                 shape: BoxShape.circle,
//                                                 image: DecorationImage(
//                                                     fit: BoxFit.cover,
//                                                     image: //CachedNetworkImageProvider
//                                                         FileImage(
//                                                             File(photoPath))),
//                                               ),
//                                             )
//                                           : firebaseUrl != ''
//                                               ? 
//                                               Container(
//                                                   height: 150,
//                                                   width: 150,
//                                                   decoration: BoxDecoration(
//                                                     border: Border.all(
//                                                         color:
//                                                             Color(0xffb00bae3),
//                                                         width: 2.0),
//                                                     color: Colors.grey[300],
//                                                     shape: BoxShape.circle,
//                                                   ),
//                                                     child: ClipOval(
//                                                       child:
//                                                        FadeInImage.assetNetwork(
//                                                           placeholder:
//                                                               'assets/loading.gif',
//                                                           image: firebaseUrl,
//                                                           fit: BoxFit.cover,
//                                                         ),
//                                                     ),
//                                                 )
//                                               : Container(
//                                                   height: 150,
//                                                   width: 150,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.grey[300],
//                                                       shape: BoxShape.circle,
//                                                       border: Border.all(
//                                                           color: Color(
//                                                               0xffb00bae3),
//                                                           width: 2.0)),
//                                                   child: Icon(
//                                                     Icons.person,
//                                                     color: Colors.white,
//                                                     size: 90,
//                                                   ),
//                                                 )),
//                                   Expanded(
//                                     child: Container(
//                                       padding: EdgeInsets.all(15),
//                                       child: TextField(
//                                         style: TextStyle(color: Colors.white),
//                                         autofocus: !_isLoading,
//                                         cursorColor: Colors.white,
//                                         maxLength: 25,
//                                         textCapitalization:
//                                             TextCapitalization.sentences,
//                                         controller: _textEditingController,
//                                         decoration: InputDecoration(
//                                           hintText: "Type your name here",
//                                           hintStyle:
//                                               TextStyle(color: Colors.white70),
//                                         ),
//                                         onChanged: (messageText) {
//                                           print(
//                                               'onChanged:${_textEditingController.text}');
//                                         },
//                                         onTap: () {
//                                           print('ontapp.');
//                                         },
//                                         // onSubmitted: _textMessageSubmitted,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(60),
//                               child: SizedBox(
//                                 height: 40.0,
//                                 width: 50,
//                                 child: RaisedButton(
//                                     shape: new RoundedRectangleBorder(
//                                         borderRadius:
//                                             new BorderRadius.circular(30.0)),
//                                     child: Text(
//                                       'Next',
//                                       style: TextStyle(
//                                           color: Color(0xffb00bae3),
//                                           fontSize: 18),
//                                     ),
//                                     color: Colors.white,
//                                     onPressed: () {
//                                       upload(context);
//                                     }),
//                               ),
//                             )
//                           ],
//                         ))
//                       ]);
//                 } else {
//                   // no data new user
//                   return Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: <Widget>[
//                         new Expanded(
//                             child: ListView(
//                           children: <Widget>[
//                             Padding(
//                                 padding: EdgeInsets.all(15),
//                                 child: Text(
//                                   'Please provide your name and optional profile photo',
//                                   style: TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 16,
//                                   ),
//                                 )),
//                             Padding(
//                               padding: EdgeInsets.all(5),
//                               child: Row(
//                                 children: <Widget>[
//                                   GestureDetector(
//                                       onTap: () {
//                                         openBottomSheet();
//                                       },
//                                       child: photoPath != null
//                                           ? Container(
//                                               height: 150,
//                                               width: 150,
//                                               decoration: BoxDecoration(
//                                                 color: Colors.grey[300],
//                                                 shape: BoxShape.circle,
//                                                 image: DecorationImage(
//                                                   fit: BoxFit.cover,
//                                                   image: FileImage(
//                                                       File(photoPath)),
//                                                 ),
//                                               ),
//                                             )
//                                           : Container(
//                                               height: 150,
//                                               width: 150,
//                                               decoration: BoxDecoration(
//                                                   color: Colors.grey[300],
//                                                   shape: BoxShape.circle,
//                                                   border: Border.all(
//                                                       color: Color(0xffb00bae3),
//                                                       width: 2.0)),
//                                               child: Icon(
//                                                 Icons.person,
//                                                 color: Colors.white,
//                                                 size: 90,
//                                               ),
//                                             )),
//                                   Expanded(
//                                     child: Container(
//                                         padding: EdgeInsets.all(15),
//                                         child: TextField(
//                                           style: TextStyle(color: Colors.white),
//                                           autofocus: !_isLoading,
//                                           cursorColor: Colors.white,
//                                           maxLength: 25,
//                                           textCapitalization:
//                                               TextCapitalization.sentences,
//                                           controller: _textEditingController,
//                                           decoration: InputDecoration(
//                                               hintText: "Type your name here",
//                                               hintStyle: TextStyle(
//                                                   color: Colors.white70)),
//                                           onChanged: (messageText) {
//                                             print(
//                                                 'onChanged:${_textEditingController.text}');
//                                           },
//                                           onTap: () {
//                                             print('ontapp.');
//                                           },
//                                           // onSubmitted: _textMessageSubmitted,
//                                         )),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(60),
//                               child: SizedBox(
//                                 height: 40.0,
//                                 width: 50,
//                                 child: RaisedButton(
//                                     color: Colors.white,
//                                     shape: new RoundedRectangleBorder(
//                                         borderRadius:
//                                             new BorderRadius.circular(30.0)),
//                                     child: Text(
//                                       'Next',
//                                       style: TextStyle(
//                                           color: Color(0xffb00bae3),
//                                           fontSize: 18),
//                                     ),
//                                     onPressed: () {
//                                       upload(context);
//                                     }),
//                               ),
//                             )
//                           ],
//                         )),
//                       ]);
//                 }
//               },
//             ),
//           ),
//         ),
//         _isLoading
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
//       // ),
//       //   onWillPop: _onBackPress,
//     );
//   }

// // Future<bool> _onBackPress() {
// //   return Future.value(false);
// // }

//   Future uploadImg(imgPath) async {
//     Completer c = new Completer();
//     try {
//       File imageFile;
//       int fileSize =
//           await File(imgPath).length(); //make compresser common function
//       print('original img file size : $fileSize');

//       if ((fileSize / 1024) > 500) {
//         print('compressing img');
//         imageFile = await FlutterNativeImage.compressImage(imgPath,
//             percentage: 75, quality: 75);
//         int fileSize = await imageFile.length();
//         print('compress img file size : $fileSize');
//       } else {
//         print('no img compression');
//         imageFile = File(imgPath);
//       }

//       // storage
//       storage.uploadImage(pref.phone.toString(), imageFile).then((url) {
//         print('prfile url----------------------------: $url');
//         c.complete(url);
//       }, onError: (e) {
//         print('Error while uploading profile image throw:$e');
//         throw e;
//       });
//     } catch (e) {
//       print('Error while uploading profile image :$e');
//       c.completeError(e);
//     }
//     return c.future;
//   }

//   upload(BuildContext context) async {
//     print('img path:$photoPath');
//     print('name : ${_textEditingController.text}');

//     if (_textEditingController.text.trim() == '') {
//       Fluttertoast.showToast(msg: 'Enter your name ');
//     } else {
//       setState(() {
//         _isLoading = true;
//       });
//       if (photoPath != null) {
//         uploadImg(photoPath).then((url) {
//           var data = {
//             "name": _textEditingController.text,
//             "profileImg": url.toString()
//           };
//           try {
//             _profileReference.set(data).then((onValue) {
//               print('profile info uploaded to fb (photoPath != null)');

//               //instag
//               CollectionReference ref =
//                   Firestore.instance.collection('insta_users');
//               ref.document(pref.phone.toString()).setData({
//                 "userId": pref.phone,
//                 "username": _textEditingController.text,
//                 "photoUrl": url,
//                 "following": {
//                   "Public": true,
//                 },
//               }).then((onValue) {
//                 setState(() {
//                   _isLoading = false;
//                   firebaseUrl = url;
//                   pref.setName(_textEditingController.text);
//                   pref.setProfile(firebaseUrl.toString());
//                 });
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => HomePage(),
//                   ),
//                 );
//               });
//             });
//           } catch (e) {
//             print('err while setting profile info $e : ');
//             Scaffold.of(context).showSnackBar(new SnackBar(
//               content: new Text("Try again."),
//             ));
//             setState(() {
//               _isLoading = false;
//             });
//             throw e; //not throwing
//           }
//         }, onError: (e) {
//           print('Error: $e');
//           setState(() {
//             _isLoading = false;
//           });
//         });
//       } else {
//         var data = {
//           "name": _textEditingController.text,
//           "profileImg": firebaseUrl
//         };
//         try {
//           _profileReference.set(data).then((onValue) {
//             print(
//                 'profile info uploaded to fb ::::$firebaseUrl photoPath != null');
//             //instag
//             CollectionReference ref =
//                 Firestore.instance.collection('insta_users');
//             ref.document(pref.phone.toString()).setData({
//               "userId": pref.phone,
//               "username": _textEditingController.text,
//               "photoUrl": '',
//               "following": {
//                 "Public": true,
//               },
//             }).then((onValue) {
//               print('afetr set');
//               setState(() {
//                 _isLoading = false;
//                 pref.setName(_textEditingController.text);
//                 pref.setProfile(firebaseUrl);
//                 _textEditingController.text = '';
//                 firebaseUrl = '';
//               });
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => HomePage(),
//                 ),
//               );
//             });
//           });
//         } catch (e) {
//           print('err while updatingrpfile info new:$e');
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }

//   //
//   openBottomSheet() {
//     return showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: EdgeInsets.all(15.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: <Widget>[
//               IconButton(
//                 icon: Icon(
//                   Icons.photo_camera,
//                   color: Theme.of(context).accentColor,
//                   size: 40,
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context);
//                   camera();
//                 },
//               ),
//               IconButton(
//                 icon: Icon(
//                   Icons.image,
//                   color: Theme.of(context).accentColor,
//                   size: 40,
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context);
//                   gallery();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   camera() async {
//     File img = await ImagePicker.pickImage(source: ImageSource.camera);
//     print('camera img :$img');
//     if (img != null) getImg(img);
//   }

//   gallery() async {
//     File img = await ImagePicker.pickImage(source: ImageSource.gallery);
//     print('gall img :$img');
//     if (img != null) getImg(img);
//   }

//   getImg(File f) {
//     // compress file
//     cmprsMedia.compressImage(f).then((compressedImageFile) {
//       print('comress:${compressedImageFile.path}');
//       setState(() {
//         photoPath = compressedImageFile.path;
//       });
//     });
//   }
// }
