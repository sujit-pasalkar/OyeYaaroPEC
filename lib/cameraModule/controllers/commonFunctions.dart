import 'package:flutter/material.dart';
import '../mdels/config.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path/path.dart' as path;
import 'package:thumbnails/thumbnails.dart';

class CommonFunctions {
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  static void showSnackbar(BuildContext _context, String _message) {
    final snackBar = SnackBar(
      content: Text(_message),
    );
    Scaffold.of(_context).showSnackBar(snackBar);
  }

  static void createdirectories() async {
    final Directory extDir = await getExternalStorageDirectory();
    // getApplicationDocumentsDirectory();
    List<String> allDirs = [];
    print("reached here");
    allDirs.add(Config.musicDownloadFolderPath);
    allDirs.add(Config.videoRecordEdit);
    allDirs.add(Config.videoRecordFolderPath);
    allDirs.add(Config.videoRecordFrames);
    allDirs.add(Config.videoRecordTempPath);

    for (int i = 0; i < allDirs.length; i++) {
      final String dirPath = '${extDir.path}${allDirs[i]}';
      if (!Directory(dirPath).existsSync()) {
        Directory(dirPath).createSync(recursive: true);
        print(dirPath);
      }
    }
  }

  Future<String> mergeAudio(String videoFilename, String audioFilename) async {
    String tempPath = (await getTemporaryDirectory()).path;
    File a = new File(videoFilename);
    String basename = path.basename(a.path);
    String dir =
        (await getExternalStorageDirectory() /* getApplicationDocumentsDirectory() */)
            .path;
    String processedfilename = '$dir${Config.videoRecordEdit}/$basename';
    print('$processedfilename--Hi');
    if (audioFilename == null || audioFilename == '') {
      print('copied without mergeing');
      File f = new File(videoFilename);
      f.copySync(processedfilename);
      return processedfilename;
    }
    if (new File('$videoFilename').existsSync()) {
      print("videoFilename is present ");
    }
    await _flutterFFmpeg
        .execute(
            '-y -i $videoFilename -i $audioFilename -c copy -an $tempPath/$basename')
        .then((rc) => print("FFmpeg process exited with rc $rc"));
    if (new File('$tempPath/$basename').existsSync()) {
      print("basename is present ");
    }
    await _flutterFFmpeg
        .execute(
            '-y -i $tempPath/$basename -i $audioFilename -acodec aac -vcodec copy $processedfilename')
        .then((rc) => print("FFmpeg process exited with rc $rc"));

    if (new File('$processedfilename').existsSync()) {
      print("processedfilename is present ");
    }
    File aa = new File('$tempPath/$basename');
    aa.deleteSync();
    a.deleteSync();
    return processedfilename;
  } //-qscale 0 -c copy -shortest

  Future<String> moveProcessedFile(String videoFileName) async {
    File f = new File(videoFileName);
    String dir = (await getExternalStorageDirectory()).path;
    String fname = path.basename(f.path);
    String fnamewoext = path.basenameWithoutExtension(f.path);
    String finaldir = '$dir/OyeYaaro/Videos/';
    String finalfilepath = '$dir/OyeYaaro/Videos/$fname';
    File ss = new File(finalfilepath);
    if (!Directory(finaldir).existsSync()) {
      Directory(finaldir).createSync(recursive: true);
    }
    f.copySync(finalfilepath);
    await createThumbnail(finalfilepath, fnamewoext);
    return finalfilepath;
  }

  Future<String> createThumbnail(String videoFile, String filename) async {
    String dir = (await getExternalStorageDirectory()).path;
    String thumbs = '$dir/OyeYaaro/Thumbnails/';
    String finalfilepath = '$thumbs$filename.png';

    print('reached create Thumbnails $finalfilepath');
    print('videoFile:$videoFile');
    if (!Directory(thumbs).existsSync()) {
      Directory(thumbs).createSync(recursive: true);
    }
    // print('after if');
    /* _flutterFFmpeg
        .execute('-y -i $videoFile -ss 00:00:2 -vframes 1  $finalfilepath')
        .then((rc) => print("FFmpeg process exited with rc $rc")); */

    String thumb = await Thumbnails.getThumbnail(
        thumbnailFolder:
            thumbs, // creates the specified path if it doesnt exist
        videoFile: videoFile,
        imageType: ThumbFormat.PNG,
        quality: 30);
    print('before return:$thumb');

    return finalfilepath;
  }

  Future<String> compressVideo(String videoFilePath) async {
    File f = new File(videoFilePath);
    String dir = (await getExternalStorageDirectory()).path;
    String fname = path.basename(f.path);
    String finaldir = '$dir/OyeYaaro/sent';

    if (!Directory(finaldir).existsSync()) {
      Directory(finaldir).createSync(recursive: true);
    }
    String finalfilepath =
        '$finaldir/VID_${new DateTime.now().millisecondsSinceEpoch}_$fname';
    await _flutterFFmpeg
        .execute(
            '-y -i $videoFilePath -c:v libx264 -crf 34 -preset superfast -c:a copy -b:v 700k $finalfilepath')
        //await _flutterFFmpeg.execute(
        //       '-y -i $videoFilePath $finalfilepath')
        .then((rc) => print("FFmpeg process exited with rc $rc"));
    return finalfilepath;
  }

  Future<bool> createMovieusingImages(
      String imgdir, Duration songDur, String songPath, int len) async {
    print('in createMovieusingImages.............');

    try {
      double imgDur = songDur.inSeconds / len;
      int imgdursec = imgDur.round();
      String time = new DateTime.now().millisecondsSinceEpoch.toString();
      String filename = 'vid_$time.mp4';
      String dirafterAudio = (await getExternalStorageDirectory()).path;
      String finaldirafteraudio = '$dirafterAudio/OyeYaaro/Videos/$filename';
      String dir = (await getTemporaryDirectory()).path;
      String mergedir = '$dir/mergedViddir';
      Directory md = new Directory(mergedir);
      md.createSync(recursive: true);
      String finaldir = '$mergedir/$filename';

      await _flutterFFmpeg
          .execute(
              '-y -framerate 1/$imgdursec -i $imgdir/%01d.jpg -r 30 -c:v libx264 -pix_fmt yuv420p $finaldir')
          .then((rc) => print("FFmpeg process exited with rc $rc"));

      await _flutterFFmpeg
          .execute(
              '-y -i $finaldir -i $songPath -acodec aac -vcodec copy $finaldirafteraudio')
          .then((rc) => print("FFmpeg process exited with rc $rc"));

          print('finaldirafteraudio: $finaldirafteraudio AND filename: $filename');

      String th = await createThumbnail(finaldirafteraudio, filename);
      print('th:$th....................');
      md.deleteSync(recursive: true);
      return true;
    } catch (e) {
      return e;
    }
  }
}
