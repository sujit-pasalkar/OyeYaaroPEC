import 'dart:async';
import 'dart:io';

import 'package:flutter_native_image/flutter_native_image.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

final CompressMedia cmprsMedia = new CompressMedia();

class CompressMedia {
  
  Future compressImage(File f) async {
    print('in compressImage()');
    Completer _c = new Completer();
    try {
      File compressedImageFile;
      int fileSize = await f.length();
      print('fileSize : $fileSize');
      print('path : ${f.path}');

      if ((fileSize / 1024) > 400) {
        compressedImageFile = await FlutterNativeImage.compressImage(f.path,
            percentage: 75, quality: 75);
        print('compressedImageFile path1 :${compressedImageFile.toString()}');
        // final String path = compressedImageFile.path;
        _c.complete(compressedImageFile);
      } else {
        compressedImageFile = f;
        print('compressedImageFile path2 :${compressedImageFile.toString()}');
        // final String path = compressedImageFile.path;
        _c.complete(compressedImageFile);
      }
    } catch (e) {
      print('Error while compressing image:$e');
      _c.completeError(e);
    }
    return _c.future;
  }

  Future compressVideo(File vid, String finalDirPath,String timestamp) async {
    // compressing and coping to desired path
    print('in compressVideo()');
    Completer _c = new Completer();
    try {
      final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

       if (!Directory(finalDirPath).existsSync()) {
      Directory(finalDirPath).createSync(recursive: true);
    }

    String finalFilePath = finalDirPath+"/"+timestamp+".mp4";

      // bool isExist = await File(finalFilePath).exists();
      // if (!isExist) {
      //   print('compressedVideo file not exist..');
      //   File(finalPath).createSync(recursive: true);
      // }

      await _flutterFFmpeg
          .execute(
              '-y -i ${vid.path} -c:v libx264 -crf 34 -preset superfast -c:a copy -b:v 700k $finalFilePath')
          .then((rc) {
        print("FFmpeg process exited with rc $rc");
        _c.complete(File(finalFilePath));
      }, onError: (e) {
        print("Error in compressing _flutterFFmpeg.execute() Video $e");
        throw e;
      });
    } catch (e) {
      print('Error while compressing Video:$e');
      _c.completeError(e);
    }
    return _c.future;
  }

  // File f = new File(videoFilePath);
  // String dir = (await getExternalStorageDirectory()).path;
  // String fname = path.basename(f.path);
  // String finaldir = '$dir/OyeYaaro/Media/Vid/';

  // if (!Directory(finaldir).existsSync()) {
  //   Directory(finaldir).createSync(recursive: true);
  // }
  // String finalfilepath = finalPath;
  // '$finaldir/VID_${new DateTime.now().millisecondsSinceEpoch}_$fname';
}
