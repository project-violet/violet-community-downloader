// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communitydownloader/network/wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EHSession {
  static EHSession tryLogin(String id, String pass) {
    return null;
  }

  static Future<String> requestString(String url) async {
    var cookie =
        (await SharedPreferences.getInstance()).getString('eh_cookies');
    return (await HttpWrapper.getr(url, headers: {"Cookie": cookie})).body;
  }
}
