// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:convert';

import 'package:communitydownloader/network/wrapper.dart';
import 'package:communitydownloader/other/html/parser.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:communitydownloader/component/downloadable.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class SankakuManager extends Downloadable {
  RegExp urlMatcher;

  SankakuManager() {
    // currently chan only support
    urlMatcher =
        RegExp(r'^https?://chan.sankakucomplex.com/\?tags\=(?<tag>.*?)$');
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
    return 'https://chan.sankakucomplex.com/favicon.png';
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
    return 'sankakucomplex';
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
    var match = urlMatcher.firstMatch(url);
    var tag = HtmlUnescape().convert(match.namedGroup('tag'));

    gdp.simpleInfoCallback.call(tag);

    var html = (await HttpWrapper.getr(url)).body;
    var result = List<DownloadTask>();

    var rr = RegExp(r'/post/show/\d+');
    var rx = RegExp(r'next\-page\-url\="(.*?)"');
    String next;
    try {
      next = HtmlUnescape().convert(rx.firstMatch(html).group(1));
    } catch (e) {}

    var subLinks = rr.allMatches(html).map((e) => e.group(0)).toList();

    print(next);

    while (next != null) {
      try {
        var shtml =
            (await HttpWrapper.getr('https://chan.sankakucomplex.com' + next))
                .body;

        try {
          next = HtmlUnescape().convert(rx.firstMatch(shtml).group(1));
        } catch (e) {
          next = null;
        }

        subLinks.addAll(rr.allMatches(shtml).map((e) => e.group(0)).toList());

        gdp.progressCallback.call(subLinks.length, 0);
        if (subLinks.length > 100) break;
      } catch (e) {
        await Future.delayed(Duration(seconds: 4));
      }
    }

    var postThumbnail = false;
    for (int i = 0; i < subLinks.length; i++) {
      try {
        var surl = 'https://chan.sankakucomplex.com' + subLinks[i];
        var shtml = (await HttpWrapper.getr(surl)).body;

        var doc = parse(shtml).querySelector('div[id=post-content]');

        // break;
        if (doc.querySelector('video') != null) {
          var content = 'https:' +
              HtmlUnescape()
                  .convert(doc.querySelector('video').attributes['src']);

          result.add(DownloadTask(
              url: content,
              filename: '',
              referer: surl,
              format: FileNameFormat(
                search: tag,
                filenameWithoutExtension:
                    intToString(result.length + 1, pad: 3),
                extension: 'mp4',
                extractor: 'sankaku',
              )));
        } else if (doc.querySelector('a') != null &&
            doc.querySelector('a').attributes['class'] == 'sample') {
          var content = 'https:' +
              HtmlUnescape().convert(doc.querySelector('a').attributes['href']);

          if (postThumbnail) {
            gdp.thumbnailCallback.call(content, jsonEncode({'Referer': surl}));
            postThumbnail = true;
          }

          result.add(DownloadTask(
              url: content,
              filename: '',
              accept: 'image/webp,*/*',
              referer: surl,
              format: FileNameFormat(
                search: tag,
                filenameWithoutExtension:
                    intToString(result.length + 1, pad: 3),
                extension: path
                    .extension(content.split('/').last.split('?').first)
                    .replaceAll(".", ""),
                extractor: 'sankaku',
              )));
        } else if (doc.querySelector('img') != null) {
          var content = 'https:' +
              HtmlUnescape()
                  .convert(doc.querySelector('img').attributes['src']);

          if (postThumbnail) {
            gdp.thumbnailCallback.call(content, jsonEncode({'Referer': surl}));
            postThumbnail = true;
          }

          result.add(DownloadTask(
              url: content,
              accept: 'image/webp,*/*',
              filename: '',
              referer: surl,
              format: FileNameFormat(
                search: tag,
                filenameWithoutExtension:
                    intToString(result.length + 1, pad: 3),
                extension: path
                    .extension(content.split('/').last.split('?').first)
                    .replaceAll(".", ""),
                extractor: 'sankaku',
              )));
        }
        gdp.progressCallback.call(subLinks.length, i + 1);
      } catch (e) {
        await Future.delayed(Duration(seconds: 4));
        i--;

        print(e);
      }
    }

    //; html:nth-of-type(1) > body:nth-of-type(1) > div:nth-of-type(5) > div:nth-of-type(1) > div:nth-of-type(3) > div:nth-of-type(1)

    // var match = urlMatcher.allMatches(url);

    // var tags = match.first[1];
    // var page = 0;

    // var postThumbnail = false;
    // var result = List<DownloadTask>();

    // gdp.simpleInfoCallback.call(HtmlUnescape().convert(tags));

    // while (true) {
    //   var durl =
    //       "https://gelbooru.com/index.php?page=dapi&s=post&q=index&limit=100&tags=" +
    //           tags +
    //           "&pid=" +
    //           page.toString();

    //   var xml = await HttpWrapper.getr(durl);
    //   var imgs = imgMatcher.allMatches(xml.body);

    //   if (imgs == null || imgs.length == 0) break;

    //   imgs.forEach((element) {
    //     result.add(DownloadTask(
    //         url: element[1],
    //         filename: element[1].split('/').last,
    //         referer: url,
    //         format: FileNameFormat(
    //           search: HtmlUnescape().convert(tags),
    //           filenameWithoutExtension:
    //               path.basenameWithoutExtension(element[1].split('/').last),
    //           extension: path
    //               .extension(element[1].split('/').last)
    //               .replaceAll(".", ""),
    //           extractor: 'gelbooru',
    //         )));
    //   });

    //   if (!postThumbnail) {
    //     gdp.thumbnailCallback.call(result[0].url, null);
    //     postThumbnail = true;
    //   }

    //   page += 1;
    //   gdp.progressCallback(result.length, 0);
    //   if (page > 10) break;
    // }

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

  // https://stackoverflow.com/questions/15193983/is-there-a-built-in-method-to-pad-a-string
  static String intToString(int i, {int pad: 0}) {
    var str = i.toString();
    var paddingToAdd = pad - str.length;
    return (paddingToAdd > 0)
        ? "${new List.filled(paddingToAdd, '0').join('')}$i"
        : str;
  }
}
