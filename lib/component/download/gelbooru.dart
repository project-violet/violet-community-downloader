// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communitydownloader/network/wrapper.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:communitydownloader/component/downloadable.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class GelbooruManager extends Downloadable {
  RegExp urlMatcher;
  RegExp imgMatcher;

  GelbooruManager() {
    urlMatcher = RegExp(
        r'^https?://gelbooru\.com/index\.php\?.*?tags\=(.*?)(\&.*?)?/?$');
    imgMatcher = RegExp(r'file_url="(.*?)"');
  }

  @override
  bool acceptURL(String url) {
    return urlMatcher.stringMatch(url) == url;
  }

  @override
  String defaultFormat() {
    return "%(extractor)s/%(search)s/%(file)s.%(ext)s";
  }

  @override
  String saveOneFormat() {}

  @override
  String fav() {
    return 'https://gelbooru.com/favicon.png';
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
    return 'gelbooru';
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

    var tags = match.first[1];
    var page = 0;

    var postThumbnail = false;
    var result = List<DownloadTask>();

    gdp.simpleInfoCallback.call(HtmlUnescape().convert(tags));

    while (true) {
      var durl =
          "https://gelbooru.com/index.php?page=dapi&s=post&q=index&limit=100&tags=" +
              tags +
              "&pid=" +
              page.toString();

      var xml = await HttpWrapper.getr(durl);
      var imgs = imgMatcher.allMatches(xml.body);

      if (imgs == null || imgs.length == 0) break;

      imgs.forEach((element) {
        result.add(DownloadTask(
            url: element[1],
            filename: element[1].split('/').last,
            referer: url,
            format: FileNameFormat(
              search: HtmlUnescape().convert(tags),
              filenameWithoutExtension:
                  path.basenameWithoutExtension(element[1].split('/').last),
              extension: path
                  .extension(element[1].split('/').last)
                  .replaceAll(".", ""),
              extractor: 'gelbooru',
            )));
      });

      if (!postThumbnail) {
        gdp.thumbnailCallback.call(result[0].url, null);
        postThumbnail = true;
      }

      page += 1;
      gdp.progressCallback(result.length, 0);
      if (page > 10) break;
    }

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
}
