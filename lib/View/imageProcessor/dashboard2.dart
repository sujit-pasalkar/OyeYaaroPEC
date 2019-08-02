// remainig:process data operation
// remove .name(copy a file into processData location)
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import 'package:oye_yaaro_pec/Theme/flexAppBar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:oye_yaaro_pec/cameraModule/views/audioList.dart';
import 'package:oye_yaaro_pec/cameraModule/controllers/commonFunctions.dart';
import 'package:oye_yaaro_pec/Models/sharedPref.dart';
import 'package:oye_yaaro_pec/Components/loader.dart';
import 'package:image/image.dart' as Im;
import 'package:flutter/widgets.dart';

class ImageProcessor extends StatefulWidget {
  @override
  _ImageProcessorState createState() => _ImageProcessorState();
}

class _ImageProcessorState extends State<ImageProcessor> {
  List<Asset> images = List<Asset>();
  String _error;
  bool _loading = false;
  SongDetails songDetails;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    CommonFunctions.createdirectories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text("Create Movie"),
              flexibleSpace: FlexAppbar(),
            ),
            backgroundColor: Colors.grey.shade300,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: images.length > 0
                ? FloatingActionButton(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 25.0,
                        ),
                        Text(
                          "DONE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.0,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Color(0xffb4fcce0),
                    onPressed: _processData,
                  )
                : null,
            bottomNavigationBar: images.length > 0
                ? BottomAppBar(
                    shape: CircularNotchedRectangle(),
                    elevation: 2.5,
                    color: Colors.grey[300],
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            onPressed: _getSong,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.music_note,
                                    color: Color(0xffb4fcce0)),
                                SizedBox(
                                  height: 2.5,
                                ),
                                Text(
                                  "Track",
                                  style: TextStyle(
                                    color: Color(0xffb4fcce0),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            onPressed: loadAssets,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.add_a_photo,
                                    color: Color(0xffb4fcce0)),
                                SizedBox(
                                  height: 2.5,
                                ),
                                Text(
                                  "Images",
                                  style: TextStyle(
                                    color: Color(0xffb4fcce0),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
            body: Padding(
              padding: EdgeInsets.all(2.5),
              child: _error != null
                  ? Text("$_error")
                  : images.length > 0
                      ? GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5.0,
                          childAspectRatio: 1,
                          children: List.generate(
                              images.length,
                              (index) => AssetView(UniqueKey(), images[index],
                                  () => delete(index))),
                        )
                      : Center(
                          child: Center(
                            child: FlatButton(
                              padding: EdgeInsets.all(15.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.cloud_upload,
                                    color: Color(0xffb3e4551),
                                    size: 50.0,
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    "Tap here to select images",
                                    style: TextStyle(fontSize: 15.0),
                                    softWrap: true,
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    "Max 100 files are allowed",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12.0),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                              onPressed: loadAssets,
                            ),
                          ),
                        ),
            ),
          ),
          Loader(
            loading: _loading,
          ),
        ],
      ),
      onWillPop: _willPop,
    );
  }

  Future<bool> _willPop() async {
    // Navigator.pop(context);
    return _loading ? false : true;
  }

  // Future<void> deleteAssets() async {
  //   await MultiImagePicker.deleteImages(assets: images);
  //   setState(() {
  //     images = List<Asset>();
  //   });
  // }

  delete(int index) async{
    images.removeAt(index);
    setState(() {});
  //  var res =  await images[index].name();
   print(images[index].name);
  }

  Future<void> loadAssets() async {
    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 100,
          enableCamera: false,
          selectedAssets: images,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
            actionBarColor: "#28aaeb", //Color(0xffb4fcce0),
            actionBarTitle: "Select Images",
            allViewTitle: "All Photos",
            useDetailsView: false,
            selectCircleStrokeColor: "#28aaeb",
          ));

          // print("resultList:$resultList");
    } on PlatformException catch (e) {
      error = e.message;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  void _processData() async {
    setState(() {
      _loading = true;
    });
    if (songDetails == null) {
      setState(() {
        _loading = false;
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Please select song first."),
        duration: Duration(seconds: 3),
      ));

      return;
    }
    try {
      Directory extDir = await getApplicationDocumentsDirectory();

      print("${extDir.path}");
      //Make use of temp directory for procesing
      Directory tempProcessingDir =
          Directory(extDir.path + "/oyeyaaro/processing");

      //Delete temp directory if exists
      if (tempProcessingDir.existsSync()) {
        tempProcessingDir.deleteSync(recursive: true);
      }

      //Create temp directory
      tempProcessingDir.createSync(recursive: true);
      List<Future> futures = List<Future>();
      for (int count = 0; count < images.length; count++) {

        if (images[count].name.endsWith(".jpg") ||
            images[count].name.endsWith(".JPG")) {
          await File(images[count].name)
              .copy(tempProcessingDir.path + "/$count" + ".jpg");
        } else {
          futures.add(processImage(
            originalPath: images[count].name,
            copyPath: tempProcessingDir.path + "/$count" + ".jpg",
          ));
        }
      }

      await Future.wait(futures);
      print('After Future.wait............');

      CommonFunctions cmnfunc = new CommonFunctions();
      await cmnfunc.createMovieusingImages(tempProcessingDir.path,
          this.songDetails.duration, this.songDetails.path, this.images.length);

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Video is created."),
        duration: Duration(seconds: 3),
      ));
      setState(() {
        pref.currentIndex = 1;
      });
      Navigator.pop(context);
      // processData(tempProcessingDir.path, this.songDetails, this.images.length);
    } catch (e) {
      print("...$e");
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> processImage({String originalPath, String copyPath}) async {
    Completer<void> completer = Completer<void>();
    try {
      if (originalPath.endsWith(".jpg") || originalPath.endsWith(".JPG")) {
        await File(originalPath).copy(copyPath);
      } else {
        File originalFile = File(originalPath);
        Im.Image image = Im.decodeImage(originalFile.readAsBytesSync());
        Im.Image smallerImage = Im.copyResize(image);
        File compressedImage = File(copyPath)
          ..writeAsBytesSync(Im.encodeJpg(smallerImage));
        print('compress path:${compressedImage.path}');
      }
      completer.complete();
    } catch (e) {
      print("$e");
      completer.completeError(e);
    }
    return completer.future;
  }

  void _getSong() async {
    final downloadedSongPath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioList(),
        ));

    if (downloadedSongPath != null)
      this.songDetails =
          SongDetails(downloadedSongPath[0], downloadedSongPath[1]);
  }
// }
}

class SongDetails {
  final String path;
  final Duration duration;
  SongDetails(this.path, this.duration);
}

class AssetView extends StatefulWidget {
  final UniqueKey key;
  final Asset _asset;
  final Function delete;

  AssetView(this.key, this._asset, this.delete);

  @override
  State<StatefulWidget> createState() => AssetState(this._asset);
}

class AssetState extends State<AssetView> {
  Asset _asset;
  AssetState(this._asset);

  @override
  void initState() {
    print('name:${_asset.name},id:${_asset.identifier}.....');
    var a = _asset.requestMetadata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0.5),
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            AssetThumb(
              asset: _asset,
              width: 300,
              height: 300,
            ),
            // Image.file(
            //   File(this._asset.name),
            //   fit: BoxFit.cover,
            // ),
            Container(
              child: Positioned(
                right: 0,
                width: 50,
                height: 50,
                child: Container(
                  color: Colors.black.withOpacity(0.75),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                    ),
                    onPressed: this.widget.delete,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
