import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Common {
  //#1.common
  static Future<String> getTime(timestamp) async {
    // to adjust give time according to user's phone
    int getTimestamp = new DateTime.now().toUtc().millisecondsSinceEpoch;

    int now = (DateTime.now().toLocal().millisecondsSinceEpoch / 1000).ceil();

    int differenceInSeconds = now - getTimestamp;
    getTimestamp = int.parse(timestamp) + differenceInSeconds;
    return DateFormat('dd MMM kk:mm')
        .format(DateTime.fromMillisecondsSinceEpoch(getTimestamp * 1000));
  }

  static Future getSongList1() async {
    Completer _c = new Completer();
    try {
      http.post(
        "http://oyeyaaroapi.plmlogix.com/getAudioListForChat",
        headers: {"Content-Type": "application/json"},
      ).then((response) {
        var res = jsonDecode(response.body);
        // print("getSongList1 service  res:$res");
        _c.complete(res);
      });
    } catch (e) {
      _c.completeError(e);
    }
    return _c.future;
  }

  static Future getSongList2() async {
    Completer _c = new Completer();
    try {
      http.post(
        "http://oyeyaaroapi.plmlogix.com/getAudioList",
        headers: {"Content-Type": "application/json"},
      ).then((response) {
        var res = jsonDecode(response.body);
        // print("getSongList1 service  res:$res");
        _c.complete(res);
      });
    } catch (e) {
      _c.completeError(e);
    }
    return _c.future;
  }

  // check and download songs
  static isSongDownloaded(String url, String type) async {
    print('url : $url');
    String s1;
    if (type == '3') {
      s1 = url
          .replaceAll('http://oyeyaaroapi.plmlogix.com/AudioChat/', '');
      print('song 3: $s1 ');
    } else {
      s1 = url
          .replaceAll('http://oyeyaaroapi.plmlogix.com/Audio/', '');
      print('song 4: $s1 ');
    }

    try {
      Directory extDir = await getExternalStorageDirectory();
      // check for .nomedia file
      // File noMediaFile = File(extDir.path + "/OyeYaaro/audio/$type/.nomedia");
      // await noMediaFile.create(recursive: true);
      File downloadedFile = File(extDir.path + "/OyeYaaro/audio/.$type/" + s1);
      print('downloadedFile path : ${downloadedFile.path}');
      bool fileExist = await downloadedFile.exists();
      if (fileExist) {
        // print('song exist');
      } else {
        // print('song not found');
        //  download
        await downloadedFile.create(recursive: true);
        // String dir = downloadedFile.path;
        // print(
        //     'i have created file as its nt exist path : ${downloadedFile.path}');
        downloadFile(url, downloadedFile);
      }
    } catch (e) {
      print('Error in downloadFile() throwed: $e');
    }
  }

  static Future<dynamic> downloadFile(String url, File f) async {
    try {
      print('in download file()');
      File file = f;
      var request = await http.get(
        url,
      );
      var bytes =  request.bodyBytes; //close();
      await file.writeAsBytes(bytes);
      print("downloaded file" + file.path);
    } catch (e) {
      print('Error in downloadFile() : $e');
      throw e;
    }
  }
  
}
