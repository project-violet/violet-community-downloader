// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

// Reference https://github.com/rollrat/downloader/blob/master/Koromo_Copy.Framework/Extractor/PixivExtractor.cs
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

class ArcaLiveParser {
  static Map<String, dynamic> parseArticle(String html) {
    var doc = parse(html);

    var channel = doc
        .querySelector(
            'html > body > div:nth-of-type(1) > div:nth-of-type(3) > article:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(1) > a:nth-of-type(1)')
        .text
        .trim();
    var title = doc
        .querySelector(
            'html > body > div:nth-of-type(1) > div:nth-of-type(3) > article:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(2) > div:nth-of-type(1) > div:nth-of-type(1)')
        .text
        .trim();
    var body = doc.querySelector(
        'html > body > div:nth-of-type(1) > div:nth-of-type(3) > article:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(3) > div:nth-of-type(2)');

    var links = List<String>();

    var imgs = body.querySelectorAll('img');
    var videos = body.querySelectorAll('video');

    try {
      if (imgs != null) {
        links.addAll(
            imgs.map((e) => 'https:' + e.attributes['src'] + '?type=orig'));
      }
      if (videos != null) {
        links.addAll(videos.map((e) {
          if (e.attributes['data-orig'] == 'gif')
            return 'https:' + e.attributes['src'] + '.gif?type=orig';
          return 'https:' + e.attributes['src'] + '?type=orig';
        }));
      }
    } catch (e) {
      // print(e);
    }

    return {
      'channel': channel,
      'title': title,
      'links': links,
    };
  }

/*
Pattern: /html[1]/body[1]/div[1]/div[3]/article[1]/div[1]/div[4]/div[2]/a[{8+i*1}]
public class Pattern
{
    public string no;
    public string class;
    public string title;
    public string comment;
    public string author;
    public string datetime;
    public string views;
    public string recom;
}

public List<Pattern> Extract(string html)
{
    HtmlDocument document = new HtmlDocument();
    document.LoadHtml(html);
    var result = new List<Pattern>();
    var root_node = document.DocumentNode;
    for (int i = 1; ; i++)
    {
        var node = root_node.SelectSingleNode($"/html[1]/body[1]/div[1]/div[3]/article[1]/div[1]/div[4]/div[2]/a[{8+i*1}]");
        if (node == null) break;
        var pattern = new Pattern();
        pattern.no = node.SelectSingleNode("./div[1]/span[1]").InnerText;
        pattern.class = node.SelectSingleNode("./div[1]/span[2]/span[1]").InnerText;
        pattern.title = node.SelectSingleNode("./div[1]/span[2]/span[2]").InnerText;
        pattern.comment = node.SelectSingleNode("./div[1]/span[2]/span[3]").InnerText;
        pattern.author = node.SelectSingleNode("./div[2]/span[1]/span[1]").InnerText;
        pattern.datetime = node.SelectSingleNode("./div[2]/span[2]").InnerText;
        pattern.views = node.SelectSingleNode("./div[2]/span[3]").InnerText;
        pattern.recom = node.SelectSingleNode("./div[2]/span[4]").InnerText;
        result.Add(pattern);
    }
    return result;
}
*/

  static Future<List<Map<String, dynamic>>> parseBoard(String html) async {
    var doc = parse(html);
    var result = List<Map<String, dynamic>>();

    for (int i = 0;; i++) {
      var node = doc.querySelector(
          'html > body > div:nth-of-type(1) > div:nth-of-type(3) > article:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(4) > div:nth-of-type(2) > a:nth-of-type(${1 + i})');
      if (node == null) break;

      if (node
              .querySelector('div:nth-of-type(1) > span:nth-of-type(1)')
              .text
              .trim() ==
          '공지') continue;

      result.add({
        'no': node
            .querySelector('div:nth-of-type(1) > span:nth-of-type(1)')
            .text
            .trim(),
        'class': node
            .querySelector(
                'div:nth-of-type(1) > span:nth-of-type(2) > span:nth-of-type(1)')
            .text
            .trim(),
        'title': node
            .querySelector(
                'div:nth-of-type(1) > span:nth-of-type(2) > span:nth-of-type(2)')
            .text
            .trim(),
        'comment': node
            .querySelector(
                'div:nth-of-type(1) > span:nth-of-type(2) > span:nth-of-type(3)')
            .text
            .trim(),
        'author': node
            .querySelector(
                'div:nth-of-type(2) > span:nth-of-type(1) > span:nth-of-type(1)')
            .text
            .trim(),
        'datetime': node
            .querySelector('div:nth-of-type(2) > span:nth-of-type(2)')
            .text
            .trim(),
        'views': node
            .querySelector('div:nth-of-type(2) > span:nth-of-type(3)')
            .text
            .trim(),
        'recom': node
            .querySelector('div:nth-of-type(2) > span:nth-of-type(4)')
            .text
            .trim(),
        'url': node.attributes['href'],
      });
    }

    return result;
  }
}

class ArcaLiveManager extends Downloadable {
  RegExp urlMatcher;
  RegExp communityUrlMatcher;

  ArcaLiveManager() {
    urlMatcher =
        RegExp(r'^https?://.*?arca.live/b/(?<id>.*?)/(?<no>\d+)(\?.*?)?$');
    communityUrlMatcher = RegExp(r'^https?://.*?arca.live/b/[^/]+$');
  }

  @override
  bool acceptURL(String url) {
    return urlMatcher.stringMatch(url) == url;
  }

  @override
  String defaultFormat() {
    return "%(extractor)s/%(channel)s/%(title)s/%(file)s.%(ext)s";
  }

  @override
  String saveOneFormat() {
    return "%(extractor)s/%(channel)s/%(file)s.%(ext)s";
  }

  @override
  String fav() {
    return 'https://arca.live/static/apple-icon.png';
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
    return 'arcalive';
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

    var result = List<DownloadTask>();

    var g = ArcaLiveParser.parseArticle((await HttpWrapper.getr(url)).body);

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
            channel: g['channel'],
            title: g['title'],
            filenameWithoutExtension: intToString(i, pad: 3),
            extension: g['links'][i].split('?')[0].split('.').last,
            extractor: 'arcalive',
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
    return '아카라이브';
  }

  @override
  TaskMakingDescription communityTaskDesc() {
    return _ArcaLiveTaskMakingDescription();
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
        var url = task.url() + "?p=$i";
        if (task.useClass()) {
          url += '&category=' + Uri.encodeComponent(task.selectedClass());
        }
        if (task.onlyBest()) {
          url += '&mode=best';
        }
        var html = (await HttpWrapper.getr(url)).body;

        try {
          var items = await ArcaLiveParser.parseBoard(html);
          if (items.length == 0) break;
          items.forEach((element) {
            if (task.useFilter()) {
              var tt = unescape.convert(element['title']);
              if (task.filter().split(' ').toList().every((element) {
                    if (element.startsWith('-'))
                      return !tt.contains(element.substring(1));
                    return tt.contains(element);
                  }) ==
                  false) return;
            }
            urls.add('https://arca.live' + element['url']);
          });
        } catch (e) {}

        await Future.delayed(Duration(milliseconds: 100));
      }
    } else {
      for (int i = task.startId(); i <= task.endId(); i++)
        urls.add(task.url() + '/' + i.toString());
    }

    bool infoOnce = false;

    var result = List<DownloadTask>();
    for (int i = 0; i < urls.length; i++) {
      gdp.statusCallback('글 읽는중... [${i + 1}/${urls.length}]');

      var html = (await HttpWrapper.getr(urls[i])).body;
      var g = ArcaLiveParser.parseArticle(html);

      if (!infoOnce) {
        gdp.simpleInfoCallback('[${g['channel']} 작업]');

        if (g['links'] != null && g['links'].length != 0) {
          gdp.thumbnailCallback(
              g['links'][0], jsonEncode({'Referer': task.url()}));
          infoOnce = true;
        }
      }

      for (int j = 0; j < g['links'].length; j++) {
        result.add(
          DownloadTask(
            url: g['links'][j],
            referer: urls[i],
            format: FileNameFormat(
              channel: g['channel'],
              title: g['title'],
              filenameWithoutExtension: task.onlyOneFolder()
                  ? urls[i].split('/').last.split('?').first +
                      '-${intToString(j, pad: 3)}'
                  : intToString(j, pad: 3),
              extension: g['links'][j].split('?')[0].split('.').last,
              extractor: 'arcalive',
            ),
          ),
        );
      }

      await Future.delayed(Duration(milliseconds: 100));
    }
    return result;
  }
}

class _ArcaLiveTaskMakingDescription extends TaskMakingDescription {
  @override
  String bestArticlesName() {
    return '헤드라인';
  }

  @override
  Future<String> getBoardName(String html) async {
    var doc = parse(html);

    return doc
        .querySelector(
            'html > body > div:nth-of-type(1) > div:nth-of-type(3) > article:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(1) > a:nth-of-type(1)')
        .text;
  }

  @override
  bool supportBestArticles() {
    return true;
  }

  @override
  Future<bool> supportClass(String html) async {
    var doc = parse(html);
    var categories = doc.querySelector(
        'html > body > div:nth-of-type(1) > div:nth-of-type(3) > article:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(4) > div:nth-of-type(1) > div:nth-of-type(1) > ul:nth-of-type(1) > li:nth-of-type(1) > a:nth-of-type(1)');
    return categories != null;
  }

  @override
  bool supportId() {
    return false;
  }

  @override
  Future<String> tidyUrl(String url) async {
    if (url.contains('?')) return url.split('?')[0];
    return url;
  }

  @override
  Future<int> getMaxPage(String html) async {
    // Cannot
    return -1;
  }

  @override
  Future<List<String>> getClasses(String html) async {
    var doc = parse(html);
    var categories = doc.querySelector(
        'html > body > div:nth-of-type(1) > div:nth-of-type(3) > article:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(4) > div:nth-of-type(1) > div:nth-of-type(1) > ul:nth-of-type(1)');
    return categories.querySelectorAll('li').map((e) => e.text.trim()).toList();
  }
}
