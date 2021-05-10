// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:aes_crypt/aes_crypt.dart';
import 'package:communitydownloader/component/download/arcalive.dart';
import 'package:communitydownloader/component/download/dcinside.dart';
import 'package:communitydownloader/component/download/twitter.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:math';
import 'package:communitydownloader/main.dart';
import 'package:http/http.dart' as http;

void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(MyApp());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);

  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();

  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });

  // test("dc", () async {
  //   var html = await HttpWrapper.getr(
  //       'https://gall.dcinside.com/board/view/?id=comic_new2&no=4787389&_rk=zx3&page=1');
  //   print(DCInsideParser.parseBoardView(html.body).toString());
  // });

  test("aes", () async {
    // AesCrypt crypt = AesCrypt();
    // crypt.setOverwriteMode(AesCryptOwMode.on);
    // crypt.setPassword('56142c695763677caa03bf19d0ac96b900a0a5be');
    // String encFilepath;
    // try {
    //   encFilepath = crypt.encryptFileSync('youtube-dl-release.zip');
    //   print('The encryption has been completed successfully.');
    //   print('Encrypted file: $encFilepath');
    // } catch (e) {
    //   if (e.type == AesCryptExceptionType.destFileExists) {
    //     print('The encryption has been completed unsuccessfully.');
    //     print(e.message);
    //   } else {
    //     return 'ERROR';
    //   }
    // }

    var file =
        File('F:\\Dev\\communitydownloader\\test\\youtube-dl-release-arm.zip');
    var oo = await file.open(mode: FileMode.append);
    var rand = Random(697469746974);
    await oo.setPosition(0);
    var ll = await oo.length();

    // for (int i = 0; i < x.length; i++) {
    //   await oo.setPosition(i);
    //   await oo.writeByte(x[i]);
    // }

    await oo.setPosition(100);
    var rr = await oo.read(1024 * 1024);
    var xx = rr.map((e) => e ^ rand.nextInt(0x100)).toList();
    await oo.setPosition(100);
    await oo.writeFrom(xx);

    await oo.setPosition(ll - 1024 * 1024 * 3);
    rr = await oo.read(1024 * 1024 * 3 - 10);
    xx = rr.map((e) => e ^ rand.nextInt(0x100)).toList();
    await oo.setPosition(ll - 1024 * 1024 * 3);
    await oo.writeFrom(xx);

    // for (int i = 0; i < 100; i++) {
    //   await oo.setPosition(i);
    //   var rr = await oo.readByte() ^ rand.nextInt(0x100);
    //   await oo.setPosition(i);
    //   await oo.writeByte(rr);
    // }

    // for (int i = 0; i < 100000; i++) {
    //   await oo.setPosition(ll - i - 1);
    //   var rr = await oo.readByte() ^ rand.nextInt(0x100);
    //   await oo.setPosition(ll - i - 1);
    //   await oo.writeByte(rr);
    // }

    // return encFilepath;
  });

  test("twitter", () async {
    // await TwitterAPI.init();
    // var name = await TwitterAPI.userByScreenName('siiteiebahiro');
    // var ss = TwitterAPI.pagination('2/timeline/media/${name['rest_id']}.json');
    // const retweets = false;
    // const replies = false;
    // const quoted = false;
    // await ss.forEach((element) {
    //   if (!retweets && element.containsKey('retweeted_status_id_str')) return;
    //   if (!replies && element.containsKey('in_reply_to_user_id_str')) return;
    //   if (!quoted && element.containsKey('quoted')) return;

    //   // extract twitpic
    //   // https://github.com/mikf/gallery-dl/blob/2b88c90f6f128fe421e9e2bb25d85e1f798b73ca/gallery_dl/extractor/twitter.py#L62
    //   for (var media in element['extended_entities']['media']) {
    //     if (media.containsKey('video_info')) {
    //       var info = media['video_info']['variants'];
    //       var ll = (info as List<dynamic>)
    //           .where((element) => element.containsKey('bitrate'))
    //           .toList();
    //       ll.sort((x, y) => y['bitrate'].compareTo(x['bitrate']));
    //       print(ll[0]['url']);
    //     } else if (media.containsKey('media_url_https')) {
    //       var url = media['media_url_https'] + ':orig';
    //       print(url);
    //     } else {
    //       var url = media['media_url'] + ':orig';
    //       print(url);
    //     }
    //   }

    //   if (!element.containsKey('extended_entities')) return;
    // });
  });

  // test("asdf", () async {
  //   // JsonEncoder encoder = new JsonEncoder.withIndent('  ');
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=1')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=2')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=3')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=4')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=5')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=6')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=7')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=8')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=9')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=10')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=11')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=12')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=13')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=14')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=15')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=16')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=17')).body)).length);
  //   // print((await ArcaLiveParser.parseBoard((await HttpWrapper.getr('https://arca.live/b/nymphet?p=18')).body)).length);
  //   var html = (await http
  //           .get('https://gall.dcinside.com/mgallery/board/lists?id=aoegame'))
  //       .body;

  //   print(await DCInsideManager().communityTaskDesc().supportClass(html));
  // });
}
