import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

FirebaseStorageOperations storage = new FirebaseStorageOperations();

class FirebaseStorageOperations {
  
  Future uploadImage(String timestamp, File imgFile, [bool feedsImage]) async {
    Completer _c = new Completer();
    StorageReference firebaseStorageRef;
    try {
      if (feedsImage == true) {
        firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child('posts')
            .child('$timestamp.jpg');
      } else {
        firebaseStorageRef =
            FirebaseStorage.instance.ref().child('$timestamp.jpg');
      }
      print('uploading img');

      final StorageUploadTask uploadTask = firebaseStorageRef.putFile(imgFile);
      String firebaseUrl =
          await (await uploadTask.onComplete).ref.getDownloadURL();
      _c.complete(firebaseUrl);
    } catch (e) {
      _c.completeError(e);
    }
    return _c.future;
  }

//later make one function for upload
  Future uploadVideo(String timestamp, File vidFile, [bool feedsImage]) async {
    Completer _c = new Completer();
    StorageReference firebaseStorageRef;
    try {
      print('in uploadVideo() ');
      print('feedsImage:$feedsImage');

      if (feedsImage == true) {
        firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child('posts')
            .child('$timestamp.mp4');
      } else {
      print('this is not feed img');
        firebaseStorageRef =
            FirebaseStorage.instance.ref().child('$timestamp.mp4');
      print('got firebaseStorageRef');
      }

      final StorageUploadTask uploadTask = firebaseStorageRef.putFile(vidFile);
      print('got uploadTask');

      var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();

      _c.complete(dowurl.toString());
    } catch (e) {
      _c.completeError(e);
    }
    return _c.future;
  }

  Future downloadImage(String url, String timestamp,{bool feedsImage,String chatId,}) async {
    Completer _c = new Completer();
    try {
      print('in downloadImage()');
      File downloadFile;
      StorageReference ref;
      Directory extDir = await getExternalStorageDirectory();
      if (feedsImage == true) {
        print('feedsImage true');
        downloadFile =
            File(extDir.path + "/OyeYaaro/.posts/$timestamp" + ".jpg");
      } else {
        downloadFile =
            File(extDir.path + "/OyeYaaro/Media/Img/.$chatId/$timestamp" + ".jpg");
      }

      bool fileExist = await downloadFile.exists();

      if (fileExist) {
        print('file name already exist^.^');
        _c.complete(false);
      } else {
        print('file name not exist.:$downloadFile');
        await downloadFile.create(recursive: true);
        if (feedsImage == true) {
          ref = FirebaseStorage.instance
              .ref()
              .child('posts')
              .child("$timestamp" + ".jpg");
        } else {
          ref = FirebaseStorage.instance.ref().child("$timestamp" + ".jpg");
        }

        final StorageFileDownloadTask downloadTask =
            ref.writeToFile(downloadFile);

        downloadTask.future.then((onData) {
          print(onData.totalByteCount);
        });

        downloadTask.future.whenComplete(() {
          _c.complete(true);
        });
      }
    } catch (e) {
      print('got exception in: downloadImage() :$e ');
      _c.completeError(e);
    }
    return _c.future;
  }

  // download video for Post video's
  Future dowonloadPostsVideo(
    String videoUrl,
    String timestamp,
  ) async {
    Completer _c = new Completer();
    try {
      print('in  dowonloadPostsVideo()');

      Directory extDir = await getExternalStorageDirectory();
      File downloadfile = File(extDir.path + "/OyeYaaro/.posts/$timestamp" + ".mp4");
      bool isExist = await downloadfile.exists();

      if (isExist) {
        print('Video file name already exist^.^');
        _c.complete(downloadfile);
      } else {
        print('Video file name not exist.');
        await downloadfile.create(recursive: true);

        final StorageReference sRef =
            FirebaseStorage.instance.ref().child('posts').child("$timestamp" + ".mp4");
        final StorageFileDownloadTask downloadTask =
            sRef.writeToFile(downloadfile);

        downloadTask.future.then((onData) {
          print('Counting for video: ${onData.totalByteCount}');
        });

        downloadTask.future.whenComplete(() {
          _c.complete(downloadfile);
        });
      }
      
    } catch (e) {
      _c.completeError(e);
    }
    return _c.future;
  }

//change to downvideo,
  Future downloadChatVideo(
    //can pass only snap[]
    String videoUrl, 
    String videoThumbUrl,
    String timestamp,
    String chatId
  ) async {
    Completer _c = new Completer();
    try {
      print('in  downloadChatVideo()');
      Directory extDir = await getExternalStorageDirectory();
      File downloadVFile =
          File(extDir.path + "/OyeYaaro/Media/Vid/.$chatId/$timestamp.mp4");

      bool vfileExist = await downloadVFile.exists();
      if (vfileExist) {
        print('video file name already exist^.^');
        _c.complete(false);
      } else {
        print('video file name not exist.');
        await downloadVFile.create(recursive: true);

        final StorageReference refV =
            FirebaseStorage.instance.ref().child("$timestamp" + ".mp4");
        final StorageFileDownloadTask downloadTaskV =
            refV.writeToFile(downloadVFile);

        downloadTaskV.future.then((onData) {
          print('Counting for video: ${onData.totalByteCount}');
        });

        downloadTaskV.future.whenComplete(() {
          _c.complete(true);
        });
      }
    } catch (e) {
      print('got exception in: downloadImage() :$e ');
      _c.completeError(e);
    }
    return _c.future;
  }

  Future downloadThumb(
    //every time calls for showing blurr image
    String url,
    String timestamp,
    String chatId
  ) async {
    // make or keep lower quality img
    Completer _c = new Completer();
    try {
      print('in downloadThumb function');
      Directory extDir = await getExternalStorageDirectory();
      File downloadFile =
          File(extDir.path + "/OyeYaaro/Media/Thumbs/.$chatId/$timestamp.jpg");
      bool fileExist = await downloadFile.exists();

      if (fileExist) {
        print('file name already exist^.^');
        _c.complete(false);
      } else {
        print('file name not exist.:$downloadFile');
        await downloadFile.create(recursive: true);

        final StorageReference ref =
            FirebaseStorage.instance.ref().child("$timestamp" + ".jpg");
        final StorageFileDownloadTask downloadTask =
            ref.writeToFile(downloadFile);

        downloadTask.future.then((onData) {
          print(onData.totalByteCount);
        });

        downloadTask.future.whenComplete(() {
          _c.complete(true);
        });
      }
    } catch (e) {
      print('got exception in: downloadImage() :$e ');
      _c.completeError(e);
    }
    return _c.future;
  }

  // Future downloadVideo(
  //   //video thumb
  //   String videoUrl,
  //   String videoThumbUrl,
  //   String timestamp,
  // ) async {
  //   Completer _c = new Completer();
  //   try {
  //     print('in  downloadVideo()');
  //     Directory extDir = await getExternalStorageDirectory();
  //     File downloadVThumb =
  //         File(extDir.path + "/OyeYaaro/Video/$timestamp" + ".jpg");

  //     bool thumbfileExist = await downloadVThumb.exists();

  //     //download thumb
  //     if (thumbfileExist) {
  //       print('file name already exist^.^');
  //       _c.complete(false);
  //     } else {
  //       print('file name not exist.');
  //       await downloadVThumb.create(recursive: true);

  //       final StorageReference refT =
  //           FirebaseStorage.instance.ref().child("$timestamp" + ".jpg");

  //       final StorageFileDownloadTask downloadTaskT =
  //           refT.writeToFile(downloadVThumb);

  //       downloadTaskT.future.then((onData) {
  //         print('Counting for thumb: ${onData.totalByteCount}');
  //       });

  //       downloadTaskT.future.whenComplete(() {
  //         _c.complete(true);
  //       });
  //     }
  //   } catch (e) {
  //     print('got exception in: downloadImage() :$e ');
  //     _c.completeError(e);
  //   }
  //   return _c.future;
  // }

  // // call every time and download vid thum automatilly for blurr
  // // no need to call for download img and vid thumbs in chat both
  // Future downloadVidThumb(
  //   //video thumb
  //   String videoUrl,
  //   String timestamp,
  //   {String chatId}
  // ) async {
  //   Completer _c = new Completer();
  //   try {
  //     print('in  downloadVideo ()');
  //     Directory extDir = await getExternalStorageDirectory();
  //     File downloadVThumb =
  //         File(extDir.path + "/OyeYaaro/Media/Thumbs/$chatId/$timestamp.jpg");

  //     bool thumbfileExist = await downloadVThumb.exists();

  //     //download thumb
  //     if (thumbfileExist) {
  //       print('file name already exist^.^ vid tumb blurr');
  //       _c.complete(false);
  //     } else {
  //       print('vid thumbfile name not exist.');
  //       await downloadVThumb.create(recursive: true);

  //       final StorageReference refT =
  //           FirebaseStorage.instance.ref().child("$timestamp" + ".jpg");

  //       final StorageFileDownloadTask downloadTaskT =
  //           refT.writeToFile(downloadVThumb);

  //       downloadTaskT.future.then((onData) {
  //         print('Counting for thumb: ${onData.totalByteCount}');
  //       });

  //       downloadTaskT.future.whenComplete(() {
  //         _c.complete(true);
  //       });
  //     }
  //   } catch (e) {
  //     print('got exception in: downloadvide thumb blurr Image() :$e ');
  //     _c.completeError(e);
  //   }
  //   return _c.future;
  // }
}
