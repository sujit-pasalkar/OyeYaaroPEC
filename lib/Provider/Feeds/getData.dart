
import 'package:http/http.dart' as http;
// import 'user.dart';
import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:async/async.dart';

final _DataService dataService = _DataService();

class _DataService {
  List<dynamic> allAvailableTags;
  Map<String, String> headers;

   _DataService() {
    allAvailableTags = List<dynamic>();
    headers = Map<String, String>();
  }

    initialize() async {
    headers.addAll({"Content-Type": "application/json"});
    // await currentUser.loadUserDetails();
    getAllTags();
  }

   Future<List<dynamic>> getAllTags() async {
    if (allAvailableTags.length > 0) {
      _getAllTags();
      return allAvailableTags;
    } else {
      try {
        await _getAllTags();
      } catch (e) {
        print(e);
        rethrow;
      }
    }
    return allAvailableTags;
  }

  _getAllTags() async {
    try {
      print('in _getAllTags()');
      http.Response response = await http.get(
        "http://54.200.143.85:4000/getTags",//
        headers: headers,
      );
      if (response.statusCode == 200) {
        print('${response.body}');
        allAvailableTags = jsonDecode(response.body);
      } else {
        throw 'Error getting a tags:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      throw 'Failed invoking the getAllTags function. Exception: $exception';
    }
    return;
  }

}