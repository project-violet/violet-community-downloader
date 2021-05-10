// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:convert';
import 'dart:io';

import 'package:communitydownloader/network/wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';
import 'package:communitydownloader/variables.dart';

class HitomiManager {
  // [Image List], [Big Thumbnail List (Perhaps only two are valid.)], [Small Thubmnail List]
  static Future<Tuple3<List<String>, List<String>, List<String>>> getImageList(
      String id) async {
    var gg = await HttpWrapper.getr('https://ltn.hitomi.la/galleries/$id.js');
    var urls = gg.body;
    var files = jsonDecode(urls.substring(urls.indexOf('=') + 1))
        .cast<String, dynamic>()['files'];
    const number_of_frontends = 3;
    final subdomain = String.fromCharCode(
        97 + (id[id.length - 1].codeUnitAt(0) % number_of_frontends));

    var btresult = List<String>();
    var stresult = List<String>();
    var result = List<String>();
    for (var row in files) {
      var rr = row.cast<String, dynamic>();
      var hash = rr['hash'] as String;
      var postfix = hash.substring(hash.length - 3);

      var subdomainx = subdomain;

      var x = int.tryParse('${postfix[0]}${postfix[1]}', radix: 16);

      if (x != null && !x.isNaN) {
        var nf = 3;
        if (x < 0x30) nf = 2;
        if (x < 0x09) x = 1;
        subdomainx = String.fromCharCode(97 + (x % nf));
      }

      if (rr['haswebp'] == 0 || rr['haswebp'] == null) {
        result.add(
            'https://${subdomainx}a.hitomi.la/images/${postfix[2]}/${postfix[0]}${postfix[1]}/$hash.${(rr['name'] as String).split('.').last}');
      } else if (hash == "")
        result.add(
            'https://${subdomainx}a.hitomi.la/webp/${rr['name'] as String}.webp');
      else if (hash.length < 3)
        result.add('https://${subdomainx}a.hitomi.la/webp/$hash.webp');
      else {
        result.add(
            'https://${subdomainx}a.hitomi.la/webp/${postfix[2]}/${postfix[0]}${postfix[1]}/$hash.webp');
      }
      btresult.add(
          'https://tn.hitomi.la/bigtn/${postfix[2]}/${postfix[0]}${postfix[1]}/$hash.jpg');
      stresult.add(
          'https://${subdomainx}tn.hitomi.la/smalltn/${postfix[2]}/${postfix[0]}${postfix[1]}/$hash.jpg');
    }
    return Tuple3<List<String>, List<String>, List<String>>(
        result, btresult, stresult);
  }
}
