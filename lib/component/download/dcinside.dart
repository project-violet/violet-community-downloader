// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

// Reference https://github.com/rollrat/downloader/blob/master/Koromo_Copy.Framework/Extractor/PixivExtractor.cs
import 'dart:io';

import 'package:communitydownloader/log/log.dart';
import 'package:communitydownloader/network/wrapper.dart';
import 'package:communitydownloader/other/html/parser.dart';
// import 'package:html/parser.dart';
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

class DCInsideParser {
  static Map<String, dynamic> parseBoardView(String html) {
    var doc = parse(html).querySelector('div.view_content_wrap');

    var id =
        RegExp(r'name="gallery_no" value="(\d+)"').allMatches(html).first[1];
    var name = RegExp(r'<h4 class="block_gallname">\[(.*?) ')
        .allMatches(html)
        .first[1];
    var title = doc.querySelector('span.title_subject').text;
    var imagelink = List<String>();
    var filename = List<String>();

    try {
      imagelink = doc
          .querySelectorAll('ul.appending_file > li')
          .map((e) => e.querySelector('a').attributes['href'])
          .toList();
      filename = doc
          .querySelectorAll('ul.appending_file > li')
          .map((e) => e.querySelector('a').text)
          .toList();
    } catch (e) {}

    return {
      'id': id,
      'name': name,
      'title': title,
      'il': imagelink,
      'fn': filename
    };
  }

  static Map<String, dynamic> parseBoardList(String html) {}
}

class DCInsideManager extends Downloadable {
  RegExp urlMatcher;
  RegExp communityUrlMatcher;

  DCInsideManager() {
    urlMatcher = RegExp(
        r'^https?://(gall|m)\.dcinside\.com/(mgallery/)?board/(view|\w+\/\d+)/?.*?$');
    communityUrlMatcher = RegExp(
        r'^https?://(gall|m)\.dcinside\.com/(mgallery/)?board/(lists|\w+)/?.*?$');
  }

  @override
  bool acceptURL(String url) {
    return urlMatcher.stringMatch(url) == url;
  }

  @override
  String defaultFormat() {
    return "%(extractor)s/%(gallery)s/%(title)s/%(file)s.%(ext)s";
  }

  @override
  String saveOneFormat() {
    return "%(extractor)s/%(gallery)s/%(file)s.%(ext)s";
  }

  @override
  String fav() {
    return 'https://gall.dcinside.com/favicon.ico';
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
    return 'dcinside';
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
    return communityUrlMatcher.stringMatch(url) == url;
  }

  @override
  Future<List<DownloadTask>> createTask(
      String url, GeneralDownloadProgress gdp) async {
    var match = urlMatcher.allMatches(url);

    var ismobile = match.first[1] == 'm';
    if (ismobile) {
      var request = await HttpWrapper.post(url);
      url = request.headers['location'];
      match = urlMatcher.allMatches(url);
    }

    var isminor = match.first[2] != null && match.first[2].contains('mgallery');
    var isview = match.first[3].contains('view'); // not support lists

    var result = List<DownloadTask>();

    if (isview) {
      var g = DCInsideParser.parseBoardView((await HttpWrapper.getr(url)).body);

      gdp.simpleInfoCallback('[${g['name']}] ${g['title']}');

      if (g['il'] != null) {
        gdp.thumbnailCallback(g['il'][0], jsonEncode({'Referer': url}));
      }

      for (int i = 0; i < g['il'].length; i++) {
        var fn = g['fn'][i];
        result.add(
          DownloadTask(
            url: g['il'][i],
            filename: fn,
            referer: url,
            format: FileNameFormat(
              id: g['id'],
              gallery: g['name'],
              title: g['title'],
              filenameWithoutExtension: intToString(i, pad: 3),
              extension: fn.split('.').last,
              extractor: 'dcinside',
            ),
          ),
        );
      }
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
    return '디시인사이드';
  }

  @override
  TaskMakingDescription communityTaskDesc() {
    return _DCInsideTaskMakingDescription();
  }

  @override
  Future<List<DownloadTask>> requestCommunityTask(
      TaskRequestDescription task, GeneralDownloadProgress gdp) async {
    var urls = List<String>();
    var unescape = HtmlUnescape();

    if (task.usePage()) {
      for (int i = task.startPage();
          task.endPageValue() || (i <= task.endPage());
          i++) {
        if (!task.endPageValue()) {
          gdp.statusCallback(
              '${task.endPage() - task.startPage() + 1} 페이지 중 ${i - task.startPage() + 1} 페이지 작업중');
        } else {
          gdp.statusCallback('${i - task.startPage() + 1} 페이지 작업 중');
        }
        var url = task.url() + "&page=$i";
        if (task.useClass()) {
          if (task.selectedClass().split('|').last != 'all') {
            url += '&search_head=' +
                Uri.encodeComponent(task.selectedClass().split('|').last);
          }
        }
        if (task.onlyBest()) {
          url += '&exception_mode=recommend';
        }
        // print(url);
        var html = (await HttpWrapper.getr(url, headers: {
          'User-Agent': HttpWrapper.userAgent,
          'Accept': HttpWrapper.accept,
        }))
            .body;
        var doc = parse(html).querySelector('tbody');
        // print(doc);

        for (var tr in doc.querySelectorAll('tr')) {
          var gall_num = tr.querySelector('td:nth-of-type(1)').text;

          if (int.tryParse(gall_num) == null) continue;

          // Check Exists Class Marker
          var em2 = tr.querySelector('td:nth-of-type(2) > a > em');
          var em3 = tr.querySelector('td:nth-of-type(3) > a > em');
          if (em2 == null) {
            var classs = tr.querySelector('td:nth-of-type(2)').text.trim();

            if (classs == '공지') continue;
          }

          // Check Contains Picture
          if (em2 != null &&
              !(em2.attributes['class'].contains('icon_recomimg') ||
                  em2.attributes['class'].contains('icon_pic'))) continue;
          if (em3 != null &&
              !(em3.attributes['class'].contains('icon_recomimg') ||
                  em3.attributes['class'].contains('icon_pic'))) continue;

          urls.add('https://gall.dcinside.com' +
              tr.querySelector('a').attributes['href']);
        }
      }
    } else {
      for (int i = task.startId(); i <= task.endId(); i++) {
        urls.add(task.url() + '&no=' + i.toString());
      }
    }

    var result = List<DownloadTask>();
    bool infoOnce = false;

    for (int i = 0; i < urls.length; i++) {
      gdp.statusCallback('글 읽는중... [${i + 1}/${urls.length}]');

      var url = urls[i];
      var g =
          DCInsideParser.parseBoardView((await HttpWrapper.getr(url, headers: {
        'User-Agent': HttpWrapper.userAgent,
        'Accept': HttpWrapper.accept,
      }))
              .body);

      if (!infoOnce) {
        gdp.simpleInfoCallback('[${g['name']}] ${g['title']}');

        if (g['il'] != null) {
          gdp.thumbnailCallback(g['il'][0], jsonEncode({'Referer': url}));
          infoOnce = true;
        }
      }

      for (int i = 0; i < g['il'].length; i++) {
        var fn = g['fn'][i];
        result.add(
          DownloadTask(
            url: g['il'][i],
            filename: fn,
            referer: url,
            format: FileNameFormat(
              id: g['id'],
              gallery: g['name'],
              title: g['title'],
              filenameWithoutExtension: task.onlyOneFolder()
                  ? url.split('no=').last.split('&').first +
                      '-' +
                      intToString(i, pad: 3)
                  : intToString(i, pad: 3),
              extension: fn.split('.').last,
              extractor: 'dcinside',
            ),
          ),
        );

        await Future.delayed(Duration(milliseconds: 600));
      }
    }

    return result;
  }
}

class _DCInsideTaskMakingDescription extends TaskMakingDescription {
  @override
  String bestArticlesName() {
    return '개념글';
  }

  @override
  Future<String> getBoardName(String html) async {
    var doc = parse(html);

    return doc
        .querySelector(
            'html > body > div:nth-of-type(2) > div:nth-of-type(2) > main:nth-of-type(1) > section:nth-of-type(1) > header:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(1) > h2:nth-of-type(1) > a:nth-of-type(1)')
        .text
        .trim();
  }

  @override
  bool supportBestArticles() {
    return true;
  }

  @override
  Future<bool> supportClass(String html) async {
    var doc = parse(html);

    return doc.querySelector(
            'html:nth-of-type(1) > body:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(2) > main:nth-of-type(1) > section:nth-of-type(1) > article:nth-of-type(2) > div:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(1) > ul:nth-of-type(1) > li:nth-of-type(1) > a:nth-of-type(1)') !=
        null;
  }

  @override
  bool supportId() {
    return true;
  }

  @override
  Future<int> getMaxPage(String html) async {
    var doc = parse(html);

    return int.tryParse(doc
        .querySelector(
            'html:nth-of-type(1) > body:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(2) > main:nth-of-type(1) > section:nth-of-type(1) > article:nth-of-type(2) > div:nth-of-type(4) > a:nth-of-type(16)')
        .attributes['href']
        .split('=')
        .last
        .trim());
  }

  @override
  Future<List<String>> getClasses(String html) async {
    var doc = parse(html);

    var ll = List<String>();

    for (int i = 1;; i++) {
      var header = doc.querySelector(
          'html:nth-of-type(1) > body:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(2) > main:nth-of-type(1) > section:nth-of-type(1) > article:nth-of-type(2) > div:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(1) > ul:nth-of-type(1) > li:nth-of-type($i) > a:nth-of-type(1)');
      if (header == null) break;
      ll.add(header.text.trim() +
          '|' +
          header.attributes['onclick'].split('(').last.split(')').first.trim());
    }

    return ll;
  }

  // Mobile Page to Desktop Page
  @override
  Future<String> tidyUrl(String url) async {
    var urlMatcher = RegExp(
        r'^https?://(gall|m)\.dcinside\.com/(mgallery/)?board/(lists|\w+)/?.*?$');
    var match = urlMatcher.allMatches(url);

    var ismobile = match.first[1] == 'm';
    if (ismobile) {
      var request = await HttpWrapper.post(url);
      url = request.headers['location'];
    }

    return url.split('&').first;
  }
}
