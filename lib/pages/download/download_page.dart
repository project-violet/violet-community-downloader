// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:async';
import 'dart:convert';

import 'package:communitydownloader/log/log.dart';
import 'package:communitydownloader/pages/download/inner_drawer.dart';
import 'package:communitydownloader/pages/download/leftside_page.dart';
import 'package:communitydownloader/pages/download/task_create_page.dart';
import 'package:communitydownloader/pages/init/init_page.dart';
import 'package:communitydownloader/widgets/floating_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:communitydownloader/component/downloadable.dart';
import 'package:communitydownloader/other/dialogs.dart';
import 'package:communitydownloader/locale/locale.dart';
import 'package:communitydownloader/pages/download/download_item_widget.dart';
import 'package:communitydownloader/settings/settings.dart';
import 'package:communitydownloader/widgets/search_bar.dart';
import 'package:communitydownloader/database/user/download.dart';

typedef StringCallback = Future Function(String);

class DownloadPageManager {
  static bool downloadPageLoaded = false;
  static StringCallback appendTask;
}

// This page must remain alive until the app is closed.
class DownloadPage extends StatefulWidget {
  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage>
    with AutomaticKeepAliveClientMixin<DownloadPage> {
  StreamSubscription _intentDataStreamSubscription;
  Uri _sharedUri;
  bool _isBottomBarVisible = true;
  bool _checkModePre = true;

  @override
  bool get wantKeepAlive => true;

  ScrollController _scroll = ScrollController();
  List<DownloadItemModel> items = List<DownloadItemModel>();

  @override
  void initState() {
    super.initState();
    refresh();
    DownloadPageManager.appendTask = appendTask;

    _initIntent();

    Future.delayed(Duration(milliseconds: 100)).then((value) async {
      var x =
          (await SharedPreferences.getInstance()).getBool('youtube-dl-init-q');
      if (x != null && x) return;

      Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => InitPage(),
        ),
      );
    });

    _scroll.addListener(() {
      if (_scroll.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isBottomBarVisible == true && _checkModePre == true) {
          setState(() {
            _checkModePre = false;
          });
          Future.delayed(Duration(milliseconds: 300)).then((value) {
            setState(() {
              _isBottomBarVisible = false;
            });
          });
        }
      } else {
        if (_scroll.position.userScrollDirection == ScrollDirection.forward) {
          if (_isBottomBarVisible == false) {
            setState(() {
              _isBottomBarVisible = true;
            });
            Future.delayed(Duration(milliseconds: 100)).then((value) {
              setState(() {
                _checkModePre = true;
              });
            });
          }
        }
      }
    });
  }

  _initIntent() {
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStreamAsUri().listen((Uri value) {
      print(value);
      setState(() {
        intentOnce = false;
        _sharedUri = value;
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    ReceiveSharingIntent.getInitialTextAsUri().then((Uri value) {
      print(value);
      setState(() {
        intentOnce = false;
        _sharedUri = value;
      });
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  void refresh() {
    Future.delayed(Duration(milliseconds: 500), () async {
      items = await (await Download.getInstance()).getDownloadItems();
      setState(() {});
      // _showOverlayWindow();
    });
  }

  bool intentOnce = false;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    var windowWidth = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    DownloadPageManager.downloadPageLoaded = true;

    if (intentOnce == false) {
      intentOnce = true;
      if (_sharedUri != null) {
        var c = _sharedUri;
        _sharedUri = null;
        Future.delayed(Duration(milliseconds: 800)).then((value) async {
          if (await Permission.storage.isPermanentlyDenied ||
              await Permission.storage.isUndetermined ||
              await Permission.storage.isDenied) {
            if (await Permission.storage.request() == PermissionStatus.denied) {
              // await Dialogs.okDialog(context,
              //     "You cannot use downloader, if you not allow external storage permission.");
              await Dialogs.okDialog(
                  context, "저장공간 권한을 허용하지 않으면 다운로더를 이용할 수 없어요 ㅠㅠ");
              return;
            }
          }
          appendTask(c.toString());
        });
      }
    }

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: GestureDetector(
          child: CustomScrollView(
            // key: key,
            // cacheExtent: height * 100,
            controller: _scroll,
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverPersistentHeader(
                floating: true,
                delegate: SearchBarSliver(
                  minExtent: 64 + 12.0,
                  maxExtent: 64.0 + 12,
                  searchBar: Stack(
                    children: <Widget>[
                      _urlBar(),
                      _taskBar(),
                      // _align(),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  items.reversed.map((e) {
                    // print(e.url());
                    return Align(
                      key: Key('dp' + e.id().toString() + e.url()),
                      alignment: Alignment.center,
                      child: DownloadItemWidget(
                        width: windowWidth - 4.0,
                        job: e.job,
                        item: e,
                        download: e.download,
                        refeshCallback: refresh,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: _isBottomBarVisible,
        child: AnimatedOpacity(
          opacity: _checkModePre ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: _floatingButton(),
        ),
      ),
    );
  }

  // void _toggle() {
  //   _innerDrawerKey.currentState.toggle(
  //       // direction is optional
  //       // if not set, the last direction will be used
  //       //InnerDrawerDirection.start OR InnerDrawerDirection.end
  //       direction: InnerDrawerDirection.end);
  // }

  Widget _taskBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(210, 8, 8, 0),
      child: SizedBox(
        height: 64,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          elevation: 100,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Material(
                    color: Settings.themeWhat
                        ? Colors.grey.shade900.withOpacity(0.4)
                        : Colors.grey.shade200.withOpacity(0.4),
                    child: ListTile(
                      title: TextFormField(
                        cursorColor: Colors.black,
                        decoration: new InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: -10, bottom: 11, top: 11, right: 0),
                            hintText: '작업 추가'),
                      ),
                      leading: SizedBox(
                        width: 25,
                        height: 25,
                        child: Icon(MdiIcons.plus),
                      ),
                    ),
                  )
                ],
              ),
              Positioned(
                left: 0.0,
                top: 0.0,
                bottom: 0.0,
                right: 0.0,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () async {
                      // if (await Permission.storage.isPermanentlyDenied ||
                      //     await Permission.storage.isUndetermined ||
                      //     await Permission.storage.isDenied) {
                      //   if (await Permission.storage.request() ==
                      //       PermissionStatus.denied) {
                      //     // await Dialogs.okDialog(context,
                      //     //     "You cannot use downloader, if you not allow external storage permission.");
                      //     await Dialogs.okDialog(
                      //         context, "저장공간 권한을 허용하지 않으면 다운로더를 이용할 수 없어요 ㅠㅠ");
                      //     return;
                      //   }
                      // }
                      // _toggle();

                      await Dialogs.okDialog(
                          context,
                          '현재 작업 추가기능을 별도로 제공하고있지 않습니다.\n' +
                              '글이 아닌 게시판의 주소를 공유하거나 URL 추가를 통해 작업을 생성해주세요.',
                          '작업 추가');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _urlBar() {
    double width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, width - 210, 0),
      child: SizedBox(
        height: 64,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          elevation: 100,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Material(
                    color: Settings.themeWhat
                        ? Colors.grey.shade900.withOpacity(0.4)
                        : Colors.grey.shade200.withOpacity(0.4),
                    child: ListTile(
                      title: TextFormField(
                        cursorColor: Colors.black,
                        decoration: new InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: -10, bottom: 11, top: 11, right: 0),
                            hintText: Translations.of(context).trans('addurl')),
                      ),
                      leading: SizedBox(
                        width: 25,
                        height: 25,
                        child: Icon(MdiIcons.linkVariant),
                      ),
                    ),
                  )
                ],
              ),
              Positioned(
                left: 0.0,
                top: 0.0,
                bottom: 0.0,
                right: 0.0,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onLongPress: () async {
                      if (await Permission.storage.isPermanentlyDenied ||
                          await Permission.storage.isUndetermined ||
                          await Permission.storage.isDenied) {
                        if (await Permission.storage.request() ==
                            PermissionStatus.denied) {
                          // await Dialogs.okDialog(context,
                          //     "You cannot use downloader, if you not allow external storage permission.");
                          await Dialogs.okDialog(
                              context, "저장공간 권한을 허용하지 않으면 다운로더를 이용할 수 없어요 ㅠㅠ");
                          return;
                        }
                      }
                      // Clipboard.setData(new ClipboardData(text: widget.item.url()));
                      var copy = await Clipboard.getData(Clipboard.kTextPlain);
                      if (copy != null) await appendTask(copy.text);
                    },
                    onTap: () async {
                      if (await Permission.storage.isPermanentlyDenied ||
                          await Permission.storage.isUndetermined ||
                          await Permission.storage.isDenied) {
                        if (await Permission.storage.request() ==
                            PermissionStatus.denied) {
                          // await Dialogs.okDialog(context,
                          //     "You cannot use downloader, if you not allow external storage permission.");
                          await Dialogs.okDialog(
                              context, "저장공간 권한을 허용하지 않으면 다운로더를 이용할 수 없어요 ㅠㅠ");
                          return;
                        }
                      }
                      Widget yesButton = FlatButton(
                        child: Text(Translations.of(context).trans('ok'),
                            style: TextStyle(color: Settings.majorColor)),
                        focusColor: Settings.majorColor,
                        splashColor: Settings.majorColor.withOpacity(0.3),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      );
                      Widget noButton = FlatButton(
                        child: Text(Translations.of(context).trans('cancel'),
                            style: TextStyle(color: Settings.majorColor)),
                        focusColor: Settings.majorColor,
                        splashColor: Settings.majorColor.withOpacity(0.3),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      );
                      TextEditingController text = TextEditingController();
                      var dialog = await showDialog(
                        context: context,
                        child: AlertDialog(
                          contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                          title:
                              Text(Translations.of(context).trans('writeurl')),
                          content: TextField(
                            controller: text,
                            autofocus: true,
                          ),
                          actions: [yesButton, noButton],
                        ),
                      );
                      if (dialog == true) {
                        await appendTask(text.text);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> appendTask(String url) async {
    Logger.info('[Task Appended] ' + url);
    if (url.toLowerCase().contains('youtube.com/') ||
        url.toLowerCase().contains('youtu.be/')) {
      await Dialogs.okDialog(context, '정책상 금지된 작업입니다!');
      return;
    }
    if (!ExtractorManager.instance.existsExtractor(url) &&
        ExtractorManager.instance.existsCommunityExtractor(url)) {
      var result = await Navigator.push(
        this.context,
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => TaskCreatePage(
            url: url,
            downloadable: ExtractorManager.instance.getCommunityExtractor(
              url,
            ),
          ),
        ),
      );
      if (result == null) return;

      var item = await (await Download.getInstance()).createNew(url);
      var rr = Map<String, dynamic>.from(item.result);
      rr['Option'] = jsonEncode(result.result);
      item.result = rr;
      await item.update();
      item.job = true;
      setState(() {
        items.add(item);
      });
    } else {
      var item = await (await Download.getInstance()).createNew(url);
      item.download = true;
      setState(() {
        items.add(item);
      });
    }
  }

  Widget _floatingButton() {
    return AnimatedFloatingActionButton(
      fabButtons: <Widget>[
        Container(
          child: FloatingActionButton(
            onPressed: () {},
            elevation: 4,
            heroTag: 'a',
            child: Icon(MdiIcons.checkAll),
          ),
        ),
        Container(
          child: FloatingActionButton(
            onPressed: () async {},
            elevation: 4,
            heroTag: 'b',
            child: Icon(MdiIcons.delete),
          ),
        ),
        Container(
          child: FloatingActionButton(
            onPressed: () async {},
            elevation: 4,
            heroTag: 'c',
            child: Icon(MdiIcons.folderMove),
          ),
        ),
      ],
      animatedIconData: AnimatedIcons.menu_close,
      exitCallback: () {
        setState(() {
          // _checkModePre = false;
        });
        Future.delayed(Duration(milliseconds: 500)).then((value) {
          setState(() {
            // checkMode = false;
          });
        });
      },
    );
  }
}
