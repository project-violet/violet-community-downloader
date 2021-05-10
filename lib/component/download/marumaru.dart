// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:convert';

import 'package:communitydownloader/network/wrapper.dart';
import 'package:communitydownloader/other/html/parser.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:communitydownloader/component/downloadable.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:tuple/tuple.dart';

class MarumaruManager extends Downloadable {
  RegExp urlMatcher;

  MarumaruManager() {
    urlMatcher = RegExp(r'^https://marumaru.sale/bbs/cmoic/\d+$');
  }

  @override
  bool acceptURL(String url) {
    return urlMatcher.stringMatch(url) == url;
  }

  @override
  String defaultFormat() {
    return "%(extractor)s/%(title)s/%(episode)s/%(file)s.%(ext)s";
  }

  @override
  String saveOneFormat() {}

  @override
  String fav() {
    return 'https://marumaru.sale/apple-touch-ipad-retina.png';
  }

  @override
  bool loginRequire() {
    return false;
  }

  @override
  bool logined() {
    return false;
  }

  @override
  String name() {
    return 'marumaru';
  }

  @override
  Future<void> setSession(String id, String pwd) async {}

  @override
  Future<bool> tryLogin() async {
    return true;
  }

  @override
  bool supportCommunity() {
    return false;
  }

  @override
  bool acceptCommunity(String url) {
    return false;
  }

  @override
  Future<List<DownloadTask>> createTask(
      String url, GeneralDownloadProgress gdp) async {
    var match = urlMatcher.allMatches(url);

    // var tags = match.first[1];
    // var page = 0;

    // var postThumbnail = false;
    var result = List<DownloadTask>();

    var html = (await HttpWrapper.getr(url)).body;
    var doc = parse(html);

    var title =
        HtmlUnescape().convert(doc.querySelector('div.col-md-12 > h1').text);

    gdp.simpleInfoCallback.call(title);

    gdp.thumbnailCallback.call(
        'https://marumaru.sale' +
            doc.querySelector('div.col-md-12 > img').attributes['href'],
        jsonEncode({'Referer': url}));

    var suburls = List<Tuple2<String, String>>();

    for (var td in doc.querySelectorAll('td.list-subject')) {
      var tt = HtmlUnescape().convert(td.querySelector('a').text.trim());
      var rr = td.querySelector('a').attributes['href'];

      suburls.add(Tuple2<String, String>(tt, 'https://marumaru.sale' + rr));
    }

    int i = 0;

    for (var surl in suburls) {
      var shtml = (await HttpWrapper.getr(surl.item2)).body;
      var sdoc = parse(shtml);

      var imgs = sdoc.querySelector('div.view-img').querySelectorAll('img');

      // print(surl.item1);
      // imgs.forEach((element) {
      //   print('https://marumaru.sale' + element.attributes['src']);
      // });

      //return "%(extractor)s/%(title)s/%(episode)s/%(file)s.%(ext)s";
      int f = 0;
      imgs.forEach((element) {
        result.add(DownloadTask(
            url: 'https://marumaru.sale' + element.attributes['src'],
            filename: element.attributes['src'].split('/').last,
            referer: url,
            format: FileNameFormat(
              // search: HtmlUnescape().convert(tags),
              title: title,
              episode: surl.item1,
              filenameWithoutExtension: intToString(++f, pad: 3),
              extension: path
                  .extension(element.attributes['src'].split('/').last)
                  .replaceAll(".", ""),
              extractor: 'marumaru',
            )));
      });

      gdp.progressCallback(++i, suburls.length);
    }

    //while (true) {
    // var durl =
    //     "https://gelbooru.com/index.php?page=dapi&s=post&q=index&limit=100&tags=" +
    //         tags +
    //         "&pid=" +
    //         page.toString();

    // var xml = await HttpWrapper.getr(durl);
    // var imgs = imgMatcher.allMatches(xml.body);

    // if (imgs == null || imgs.length == 0) break;

    // imgs.forEach((element) {
    //   result.add(DownloadTask(
    //       url: element[1],
    //       filename: element[1].split('/').last,
    //       referer: url,
    //       format: FileNameFormat(
    //         search: HtmlUnescape().convert(tags),
    //         filenameWithoutExtension:
    //             path.basenameWithoutExtension(element[1].split('/').last),
    //         extension: path
    //             .extension(element[1].split('/').last)
    //             .replaceAll(".", ""),
    //         extractor: 'gelbooru',
    //       )));
    // });

    // if (!postThumbnail) {
    //   gdp.thumbnailCallback.call(result[0].url, null);
    //   postThumbnail = true;
    // }

    // page += 1;
    // gdp.progressCallback(result.length, 0);
    // if (page > 10) break;
    //}

    return result;
  }

  @override
  String communityName() {
    return null;
  }

  @override
  TaskMakingDescription communityTaskDesc() {
    return null;
  }

  @override
  Future<List<DownloadTask>> requestCommunityTask(
      TaskRequestDescription task, GeneralDownloadProgress gdp) async {}

  static String intToString(int i, {int pad: 0}) {
    var str = i.toString();
    var paddingToAdd = pad - str.length;
    return (paddingToAdd > 0)
        ? "${new List.filled(paddingToAdd, '0').join('')}$i"
        : str;
  }
}
