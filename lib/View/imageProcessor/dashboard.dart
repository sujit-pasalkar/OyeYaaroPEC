// import 'dart:async';
// import 'dart:io';

// import 'package:oye_yaaro_pec/Components/loader.dart';
// import 'package:oye_yaaro_pec/Models/sharedPref.dart';
// import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
// import 'package:oye_yaaro_pec/cameraModule/controllers/commonFunctions.dart';
// import 'package:oye_yaaro_pec/cameraModule/views/audioList.dart';
// import 'package:flutter/material.dart';
// import 'package:custom_multi_image_picker/asset.dart';
// import 'package:custom_multi_image_picker/custom_multi_image_picker.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:image/image.dart' as Im;

// class ImageProcessor extends StatefulWidget {
//   @override
//   _ImagePocessor createState() => _ImagePocessor();
// }

// class _ImagePocessor extends State<ImageProcessor> {
//   bool _loading = false;

//   List<Asset> images = List<Asset>();
//   String _error;
//   SongDetails songDetails;

//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     super.initState();
//     CommonFunctions.createdirectories();
//   }

//   void loadAssets() async {
//     List resultList;
//     String error;

//     try {
//       resultList = await MultiImagePicker.pickImages(
//         maxImages: 100,
//       );
//     } on PlatformException catch (e) {
//       error = e.message;
//       print("PlatformException:${e.message}");
//     }

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     resultList.forEach((f) {
//       images.add(f);
//     });
//     setState(() {
//       _error = error;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       child: Stack(
//         children: <Widget>[
//           Scaffold(
//             key: _scaffoldKey,
//             appBar: AppBar(
//               title: Text("Create Movie"),
//               flexibleSpace: FlexAppbar(),
//             ),
//             backgroundColor: Colors.grey.shade300,
//             floatingActionButtonLocation:
//                 FloatingActionButtonLocation.centerDocked,
//             floatingActionButton: images.length > 0
//                 ? AnimatedContainer(
//                     duration: Duration(milliseconds: 200),
//                     height: images.length > 0 ? 60.0 : 0.0,
//                     child: FloatingActionButton(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.max,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: <Widget>[
//                           Icon(
//                             Icons.check,
//                             color: Colors.white,
//                             size: 25.0,
//                           ),
//                           Text(
//                             "DONE",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 8.0,
//                             ),
//                           ),
//                         ],
//                       ),
//                       backgroundColor: Theme.of(context).primaryColor,
//                       onPressed: _processData,
//                     ),
//                   )
//                 : null,
//             bottomNavigationBar: images.length > 0
//                 ? AnimatedContainer(
//                     duration: Duration(milliseconds: 150),
//                     height: images.length > 0 ? 60.0 : 0.0,
//                     child: BottomAppBar(
//                       shape: CircularNotchedRectangle(),
//                       elevation: 2.5,
//                       // color: Colors.indigoAccent,
//                       color: Theme.of(context).primaryColor,
//                       child: Row(
//                         mainAxisSize: MainAxisSize.max,
//                         children: <Widget>[
//                           Expanded(
//                             child: FlatButton(
//                               onPressed: _getSong,
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: <Widget>[
//                                   Icon(Icons.music_note, color: Colors.white),
//                                   SizedBox(
//                                     height: 2.5,
//                                   ),
//                                   Text(
//                                     "Track",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: FlatButton(
//                               onPressed: loadAssets,
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: <Widget>[
//                                   Icon(Icons.add_a_photo, color: Colors.white),
//                                   SizedBox(
//                                     height: 2.5,
//                                   ),
//                                   Text(
//                                     "Images",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 : null,
//             body: Padding(
//               padding: EdgeInsets.all(2.5),
//               child: _error != null
//                   ? Text("$_error")
//                   : images.length > 0
//                       ? GridView.count(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 5.0,
//                           mainAxisSpacing: 5.0,
//                           childAspectRatio: 1,
//                           children: List.generate(
//                               images.length,
//                               (index) => AssetView(UniqueKey(), images[index],
//                                   () => delete(index))),
//                         )
//                       : Center(
//                           child: Center(
//                             child: FlatButton(
//                               padding: EdgeInsets.all(15.0),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: <Widget>[
//                                   Icon(
//                                     Icons.cloud_upload,
//                                     color: Color(0xffb3e4551),
//                                     size: 50.0,
//                                   ),
//                                   SizedBox(
//                                     height: 5.0,
//                                   ),
//                                   Text(
//                                     "Tap here to select images",
//                                     style: TextStyle(fontSize: 15.0),
//                                     softWrap: true,
//                                   ),
//                                   SizedBox(
//                                     height: 5.0,
//                                   ),
//                                   Text(
//                                     "Max 100 files are allowed",
//                                     style: TextStyle(
//                                         color: Colors.grey, fontSize: 12.0),
//                                     softWrap: true,
//                                   ),
//                                 ],
//                               ),
//                               onPressed: loadAssets,
//                             ),
//                           ),
//                         ),
//             ),
//           ),
//           Loader(
//             loading: _loading,
//           ),
//         ],
//       ),
//       onWillPop: _willPop,
//     );
//   }

//   delete(int index) {
//     images.removeAt(index);
//     setState(() {});
//   }

//   Future<bool> _willPop() async {
//     // Navigator.pop(context);
//     return _loading ? false : true;
//   }

//   void _processData() async {
//     setState(() {
//       _loading = true;
//     });
//     if (songDetails == null) {
//       setState(() {
//         _loading = false;
//       });
//       _scaffoldKey.currentState.showSnackBar(SnackBar(
//         content: Text("Please select song first."),
//         duration: Duration(seconds: 3),
//       ));

//       return;
//     }
//     try {
//       Directory extDir = await getApplicationDocumentsDirectory();

//       print("${extDir.path}");

//       //Make use of temp directory for procesing
//       Directory tempProcessingDir =
//           Directory(extDir.path + "/oyeyaaro/processing");

//       //Delete temp directory if exists
//       if (tempProcessingDir.existsSync()) {
//         tempProcessingDir.deleteSync(recursive: true);
//       }

//       //Create temp directory
//       tempProcessingDir.createSync(recursive: true);
//       List<Future> futures = List<Future>();
//       for (int count = 0; count < images.length; count++) {
//         //await File(images[count].filePath)
//         //.copy(tempProcessingDir.path + "/$count" + ".png");
//         /* futures.add(processImage(
//           originalPath: images[count].filePath,
//           copyPath: tempProcessingDir.path + "/$count" + ".jpg",
//         )); */

//         if (images[count].filePath.endsWith(".jpg") ||
//             images[count].filePath.endsWith(".JPG")) {
//           await File(images[count].filePath)
//               .copy(tempProcessingDir.path + "/$count" + ".jpg");
//         } else {
//           futures.add(processImage(
//             originalPath: images[count].filePath,
//             copyPath: tempProcessingDir.path + "/$count" + ".jpg",
//           ));
//         }
//       }

//       await Future.wait(futures);
//       print('After Future.wait............');

//       CommonFunctions cmnfunc = new CommonFunctions();
//       await cmnfunc.createMovieusingImages(tempProcessingDir.path,
//           this.songDetails.duration, this.songDetails.path, this.images.length);

//        _scaffoldKey.currentState.showSnackBar(SnackBar(
//         content: Text("Video is created."),
//         duration: Duration(seconds: 3),
//       ));
//       setState(() {
//         pref.currentIndex = 1;
//       });
//       Navigator.pop(context);
//       // processData(tempProcessingDir.path, this.songDetails, this.images.length);
//     } catch (e) {
//       print("...$e");
//     }
//     setState(() {
//       _loading = false;
//     });
//   }

//   Future<void> processImage({String originalPath, String copyPath}) async {
//     Completer<void> completer = Completer<void>();
//     try {
//       if (originalPath.endsWith(".jpg") || originalPath.endsWith(".JPG")) {
//         await File(originalPath).copy(copyPath);
//       } else {
//         File originalFile = File(originalPath);
//         Im.Image image = Im.decodeImage(originalFile.readAsBytesSync());
//         Im.Image smallerImage = Im.copyResize(image);
//         File compressedImage = File(copyPath)
//           ..writeAsBytesSync(Im.encodeJpg(smallerImage));
//         print('compress path:${compressedImage.path}');
//       }
//       completer.complete();
//     } catch (e) {
//       print("$e");
//       completer.completeError(e);
//     }
//     return completer.future;
//   }

//   void _getSong() async {
//     final downloadedSongPath = await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => AudioList(),
//         ));

//     if (downloadedSongPath != null)
//       this.songDetails =
//           SongDetails(downloadedSongPath[0], downloadedSongPath[1]);
//   }
// }

// class AssetView extends StatefulWidget {
//   final UniqueKey key;
//   final Asset _asset;
//   final Function delete;

//   AssetView(this.key, this._asset, this.delete);

//   @override
//   State<StatefulWidget> createState() => AssetState(this._asset);
// }

// class AssetState extends State<AssetView> {
//   Asset _asset;
//   AssetState(this._asset);

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(0.5),
//       color: Colors.black,
//       child: AspectRatio(
//         aspectRatio: 1,
//         child: Stack(
//           fit: StackFit.expand,
//           children: <Widget>[
//             Image.file(
//               File(this._asset.filePath),
//               fit: BoxFit.cover,
//             ),
//             Container(
//               child: Positioned(
//                 right: 0,
//                 width: 50,
//                 height: 50,
//                 child: Container(
//                   color: Colors.black.withOpacity(0.75),
//                   child: IconButton(
//                     padding: EdgeInsets.zero,
//                     icon: Icon(
//                       Icons.delete_forever,
//                       color: Colors.white,
//                     ),
//                     onPressed: this.widget.delete,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SongDetails {
//   final String path;
//   final Duration duration;
//   SongDetails(this.path, this.duration);
// }
