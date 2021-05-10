// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:io';

import 'package:communitydownloader/network/wrapper.dart';
import 'package:communitydownloader/other/html/parser.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:communitydownloader/component/downloadable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'package:communitydownloader/component/hitomi/hitomi.dart';
import 'package:communitydownloader/database/database.dart';
import 'package:communitydownloader/database/query.dart';

class RuliwebParser {
  static Map<String, dynamic> parseArticle(String html) {
    var doc = parse(html);

    var title = doc
        .querySelector(
            'html > body > div:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(3) > div:nth-of-type(3) > div:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(1) > h4:nth-of-type(1) > span:nth-of-type(1)')
        .text
        .trim();
    var board = doc
        .querySelector(
            'html > body > div:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(3) > div:nth-of-type(3) > div:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(1) > h3:nth-of-type(1) > a:nth-of-type(1)')
        .text
        .trim();
    var body = doc.querySelector(
        'html > body > div:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(3) > div:nth-of-type(3) > div:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(2)');

    var links = List<String>();

    var imgs = body.querySelectorAll('img');
    var videos = body.querySelectorAll('video');

    try {
      if (imgs != null) {
        links.addAll(imgs.map((e) => 'https:' + e.attributes['src']));
      }
      if (videos != null) {
        links.addAll(videos.map((e) {
          return 'https:' + e.attributes['src'];
        }));
      }
    } catch (e) {
      // print(e);
    }

    return {
      'board': board,
      'title': title,
      'links': links,
    };
  }
}

class RuliwebManager extends Downloadable {
  RegExp urlMatcher;
  RegExp communityUrlMatcher;

  RuliwebManager() {
    urlMatcher = RegExp(
        r'^https://(bbs|m).ruliweb.com/community/board/\d+/read/\d+.*?$');
  }

  @override
  bool acceptURL(String url) {
    return urlMatcher.stringMatch(url) == url;
  }

  @override
  String defaultFormat() {
    return "%(extractor)s/%(board)s/%(title)s/%(file)s.%(ext)s";
  }

  @override
  String saveOneFormat() {}

  @override
  String fav() {
    return 'https://img.ruliweb.com/img/2016/icon/ruliweb_icon_144_144.png';
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
    return 'ruliweb';
  }

  @override
  Future<void> setSession(String id, String pwd) async {}

  @override
  Future<bool> tryLogin() async {
    return true;
  }

  @override
  bool supportCommunity() {
    return true;
  }

  @override
  bool acceptCommunity(String url) {
    return false;
  }

  @override
  Future<List<DownloadTask>> createTask(
      String url, GeneralDownloadProgress gdp) async {
    var match = urlMatcher.allMatches(url);

    if (match.first[1] == 'm') url = url.replaceFirst('bbs.', 'm.');

    var result = List<DownloadTask>();

    var g = RuliwebParser.parseArticle((await HttpWrapper.getr(url, headers: {
      'Referer': url,
      'User-Agent': HttpWrapper.userAgent,
      'Accept': HttpWrapper.accept,
    }))
        .body);

    gdp.simpleInfoCallback('[${g['channel']}] ${g['title']}');

    if (g['links'] != null && g['links'].length != 0) {
      gdp.thumbnailCallback(g['links'][0], jsonEncode({'Referer': url}));
    }

    for (int i = 0; i < g['links'].length; i++) {
      result.add(
        DownloadTask(
          url: g['links'][i],
          // filename: fn,
          referer: url,
          format: FileNameFormat(
            board: g['board'],
            title: g['title'],
            filenameWithoutExtension: intToString(i, pad: 3),
            extension: g['links'][i].split('?')[0].split('.').last,
            extractor: 'ruliweb',
          ),
        ),
      );
    }

    return result;
  }

  // https://stackoverflow.com/questions/15193983/is-there-a-built-in-method-to-pad-a-string
  static String intToString(int i, {int pad: 0}) {
    var str = i.toString();
    var paddingToAdd = pad - str.length;
    return (paddingToAdd > 0)
        ? "${new List.filled(paddingToAdd, '0').join('')}$i"
        : str;
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
