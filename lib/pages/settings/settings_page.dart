// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:io';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:communitydownloader/downloader/native_downloader.dart';
import 'package:communitydownloader/pages/settings/contact_selector.dart';
import 'package:communitydownloader/pages/settings/subpages/faq_page.dart';
import 'package:communitydownloader/pages/settings/subpages/laboratory_page.dart';
import 'package:communitydownloader/pages/settings/subpages/license_page.dart';
import 'package:communitydownloader/pages/settings/subpages/privacy_page.dart';
import 'package:communitydownloader/pages/settings/subpages/support_page.dart';
import 'package:communitydownloader/pages/settings/subpages/tou_page.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:communitydownloader/component/download/pixiv.dart';
import 'package:communitydownloader/component/hitomi/hitomi.dart';
import 'package:communitydownloader/database/user/bookmark.dart';
import 'package:communitydownloader/other/dialogs.dart';
import 'package:communitydownloader/locale/locale.dart';
import 'package:communitydownloader/pages/settings/version_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:communitydownloader/settings/settings.dart';
import 'package:communitydownloader/version/update_sync.dart';
import 'package:communitydownloader/widgets/toast.dart';
import 'package:communitydownloader/database/database.dart';

class ExCountry extends Country {
  String language;
  String script;
  String region;
  String variant;

  ExCountry(String name, String iso) : super(name: name, isoCode: iso) {}

  static ExCountry create(String iso,
      {String language, String script, String region, String variant}) {
    var c = CountryPickerUtils.getCountryByIsoCode(iso);
    var country = ExCountry(c.name, c.isoCode);
    country.language = language;
    country.script = script;
    country.region = region;
    country.variant = variant;
    return country;
  }

  String toString() {
    final dict = {
      'KR': 'ko',
      'US': 'en',
      // 'JP': 'ja',
      // // 'CN': 'zh',
      // 'RU': 'ru',
      // 'IT': 'it',
      // 'ES': 'eo',
    };

    if (dict.containsKey(isoCode)) return dict[isoCode];

    if (isoCode == 'CN') {
      if (script == 'Hant') return 'zh_Hant';
      if (script == 'Hans') return 'zh_Hans';
    }

    return 'en';
  }

  String getDisplayLanguage() {
    final dict = {
      'KR': '한국어',
      'US': 'English',
      'JP': '日本語',
      // 'CN': '中文(简体)',
      // 'CN': '中文(繁體)',
      'RU': 'Русский',
      'IT': 'Italiano',
      'ES': 'Español',
    };

    if (dict.containsKey(isoCode)) return dict[isoCode];

    if (isoCode == 'CN') {
      if (script == 'Hant') return '中文(繁體)';
      if (script == 'Hans') return '中文(简体)';
    }

    return 'English';
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin<SettingsPage> {
  FlareControls _flareController = FlareControls();
  bool _themeSwitch = false;

  @override
  void initState() {
    super.initState();
    _themeSwitch = Settings.themeWhat;
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      child: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: <Widget>[
                _buildGroup(Translations.of(context).trans('theme')),
                _buildItems([
                  InkWell(
                    customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0))),
                    child: ListTile(
                      leading: ShaderMask(
                        shaderCallback: (bounds) => RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.0,
                          colors: [Colors.black, Colors.white],
                          tileMode: TileMode.clamp,
                        ).createShader(bounds),
                        child:
                            Icon(MdiIcons.themeLightDark, color: Colors.white),
                      ),
                      title: Text(Translations.of(context).trans('darkmode')),
                      trailing: SizedBox(
                        width: 50,
                        height: 50,
                        child: FlareActor(
                          'assets/flare/switch_daytime.flr',
                          animation: _themeSwitch ? "night_idle" : "day_idle",
                          controller: _flareController,
                          snapToEnd: true,
                        ),
                      ),
                    ),
                    onTap: () async {
                      if (!_themeSwitch)
                        _flareController.play('switch_night');
                      else
                        _flareController.play('switch_day');
                      _themeSwitch = !_themeSwitch;
                      Settings.setThemeWhat(_themeSwitch);
                      DynamicTheme.of(context).setBrightness(
                          Theme.of(context).brightness == Brightness.dark
                              ? Brightness.light
                              : Brightness.dark);
                      setState(() {});
                    },
                  ),
                  _buildDivider(),
                  InkWell(
                    customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0))),
                    child: ListTile(
                      leading: ShaderMask(
                        shaderCallback: (bounds) => RadialGradient(
                          center: Alignment.bottomLeft,
                          radius: 1.2,
                          colors: [Colors.orange, Colors.pink],
                          tileMode: TileMode.clamp,
                        ).createShader(bounds),
                        child:
                            Icon(MdiIcons.formatColorFill, color: Colors.white),
                      ),
                      title:
                          Text(Translations.of(context).trans('colorsetting')),
                      trailing: Icon(
                          // Icons.message,
                          Icons.keyboard_arrow_right),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                Translations.of(context).trans('selectcolor')),
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                pickerColor: Settings.majorColor,
                                onColorChanged: (color) async {
                                  await Settings.setMajorColor(color);
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ]),
                _buildGroup(Translations.of(context).trans('system')),
                _buildItems([
                  InkWell(
                    customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0))),
                    child: ListTile(
                      leading: Icon(Icons.language, color: Settings.majorColor),
                      title: Text(Translations.of(context).trans('language')),
                      trailing: Icon(Icons.keyboard_arrow_right),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Theme(
                            data: Theme.of(context)
                                .copyWith(primaryColor: Colors.pink),
                            child: CountryPickerDialog(
                                titlePadding:
                                    EdgeInsets.symmetric(vertical: 16),
                                // searchCursorColor: Colors.pinkAccent,
                                // searchInputDecoration:
                                //     InputDecoration(hintText: 'Search...'),
                                // isSearchable: true,
                                title: Text('Select Language'),
                                onValuePicked: (Country country) async {
                                  var exc = country as ExCountry;
                                  await Translations.of(context)
                                      .load(exc.toString());
                                  await Settings.setLanguage(exc.toString());
                                  setState(() {});
                                },
                                itemFilter: (c) => [].contains(c.isoCode),
                                priorityList: [
                                  ExCountry.create('US'),
                                  ExCountry.create('KR'),
                                  // ExCountry.create('JP'),
                                  // ExCountry.create('CN', script: 'Hant'),
                                  // ExCountry.create('CN', script: 'Hans'),
                                  // ExCountry.create('IT'),
                                  // ExCountry.create('ES'),
                                  // CountryPickerUtils.getCountryByIsoCode('RU'),
                                ],
                                itemBuilder: (Country country) {
                                  return Container(
                                    child: Row(
                                      children: <Widget>[
                                        CountryPickerUtils.getDefaultFlagImage(
                                            country),
                                        SizedBox(
                                          width: 8.0,
                                          height: 30,
                                        ),
                                        Text(
                                            "${(country as ExCountry).getDisplayLanguage()}"),
                                      ],
                                    ),
                                  );
                                })),
                      );
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      MdiIcons.import,
                      color: Settings.majorColor,
                    ),
                    title: Text(
                        Translations.of(context).trans('importdownloaddata')),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () async {
                      if (!await Permission.storage.isGranted) {
                        if (await Permission.storage.request() ==
                            PermissionStatus.denied) {
                          FlutterToast(context).showToast(
                            child: ToastWrapper(
                              isCheck: false,
                              msg: Translations.of(context)
                                  .trans('readpermissionerr'),
                            ),
                            gravity: ToastGravity.BOTTOM,
                            toastDuration: Duration(seconds: 4),
                          );

                          return;
                        }
                      }

                      File file;
                      file = await FilePicker.getFile(
                        type: FileType.any,
                      );

                      if (file == null) {
                        FlutterToast(context).showToast(
                          child: ToastWrapper(
                            isCheck: false,
                            isWarning: true,
                            msg: Translations.of(context)
                                .trans('noselectedfile'),
                          ),
                          gravity: ToastGravity.BOTTOM,
                          toastDuration: Duration(seconds: 4),
                        );

                        return;
                      }

                      var db = await getApplicationDocumentsDirectory();
                      var dbfile = File('${db.path}/user.db');
                      var ext = await getExternalStorageDirectory();
                      var extpath = '${ext.path}/user.db';
                      var extfile = await dbfile.copy(extpath);

                      FlutterToast(context).showToast(
                        child: ToastWrapper(
                          isCheck: true,
                          msg: Translations.of(context).trans('succbring'),
                        ),
                        gravity: ToastGravity.BOTTOM,
                        toastDuration: Duration(seconds: 4),
                      );
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      MdiIcons.export,
                      color: Settings.majorColor,
                    ),
                    title: Text(
                      Translations.of(context).trans('exportdownloaddata'),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () async {
                      if (!await Permission.storage.isGranted) {
                        if (await Permission.storage.request() ==
                            PermissionStatus.denied) {
                          FlutterToast(context).showToast(
                            child: ToastWrapper(
                              isCheck: false,
                              msg: Translations.of(context)
                                  .trans('writepermissionerror'),
                            ),
                            gravity: ToastGravity.BOTTOM,
                            toastDuration: Duration(seconds: 4),
                          );

                          return;
                        }
                      }

                      var db = await getApplicationDocumentsDirectory();
                      var dbfile = File('${db.path}/user.db');
                      var ext = await getExternalStorageDirectory();
                      var extpath = '${ext.path}/user.db';
                      var extfile = await dbfile.copy(extpath);

                      FlutterToast(context).showToast(
                        child: ToastWrapper(
                          isCheck: true,
                          msg: Translations.of(context).trans('succemission'),
                        ),
                        gravity: ToastGravity.BOTTOM,
                        toastDuration: Duration(seconds: 4),
                      );
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      MdiIcons.notebook,
                      color: Settings.majorColor,
                    ),
                    title: Text(
                      Translations.of(context).trans('exportdownloadlog'),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () async {
                      if (!await Permission.storage.isGranted) {
                        if (await Permission.storage.request() ==
                            PermissionStatus.denied) {
                          FlutterToast(context).showToast(
                            child: ToastWrapper(
                              isCheck: false,
                              msg: Translations.of(context)
                                  .trans('writepermissionerror'),
                            ),
                            gravity: ToastGravity.BOTTOM,
                            toastDuration: Duration(seconds: 4),
                          );

                          return;
                        }
                      }

                      var db = await getApplicationDocumentsDirectory();
                      var dbfile = File('${db.path}/log.txt');
                      var ext = await getExternalStorageDirectory();
                      var extpath = '${ext.path}/log.txt';
                      var extfile = await dbfile.copy(extpath);

                      FlutterToast(context).showToast(
                        child: ToastWrapper(
                          isCheck: true,
                          msg: Translations.of(context).trans('succemission'),
                        ),
                        gravity: ToastGravity.BOTTOM,
                        toastDuration: Duration(seconds: 4),
                      );
                    },
                  ),
                  _buildDivider(),
                  InkWell(
                    customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0))),
                    child: ListTile(
                      leading: Icon(Icons.info_outline, color: Colors.orange),
                      title: Text(Translations.of(context).trans('info')),
                      trailing: Icon(Icons.keyboard_arrow_right),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (_, __, ___) {
                            return VersionViewPage();
                          },
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var begin = Offset(0.0, 1.0);
                            var end = Offset.zero;
                            var curve = Curves.ease;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ]),
                _buildGroup(
                  Translations.of(context).trans('save'),
                ),
                _buildItems([
                  InkWell(
                    customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0))),
                    child: ListTile(
                      leading:
                          Icon(MdiIcons.folder, color: Settings.majorColor),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Translations.of(context).trans('topdir'),
                          ),
                          Text(
                            Translations.of(context).trans('cursetdir') +
                                ': ' +
                                Settings.downloadBasePath,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      // trailing: AbsorbPointer(
                      //   child: Switch(
                      //     value: Settings.rightToLeft,
                      //     onChanged: (value) async {},
                      //     activeTrackColor: Settings.majorColor,
                      //     activeColor: Settings.majorAccentColor,
                      //   ),
                      // ),
                    ),
                    onTap: () async {
                      // await Settings.setRightToLeft(!Settings.rightToLeft);
                      // setState(() {});
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
                      TextEditingController text = TextEditingController(
                          text: Settings.downloadBasePath);
                      var dialog = await showDialog(
                        context: context,
                        child: AlertDialog(
                          contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                          title: Text(
                            Translations.of(context).trans('writepath'),
                          ),
                          content: TextField(
                            controller: text,
                            autofocus: true,
                            maxLines: 3,
                          ),
                          actions: [yesButton, noButton],
                        ),
                      );
                      if (dialog == true) {
                        if (!await Directory(text.text).exists()) {
                          FlutterToast(context).showToast(
                            child: ToastWrapper(
                              isCheck: false,
                              isWarning: true,
                              msg: Translations.of(context)
                                  .trans('notvalidpath'),
                            ),
                            gravity: ToastGravity.BOTTOM,
                            toastDuration: Duration(seconds: 4),
                          );
                          return;
                        }

                        Settings.setBaseDirectory(text.text);

                        FlutterToast(context).showToast(
                          child: ToastWrapper(
                            isCheck: true,
                            // isWarning: true,
                            msg: Translations.of(context).trans('changedpath'),
                          ),
                          gravity: ToastGravity.BOTTOM,
                          toastDuration: Duration(seconds: 4),
                        );

                        setState(() {});

                        // await appendTask(text.text);
                      }
                    },
                  ),
                  _buildDivider(),
                  InkWell(
                    customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0))),
                    child: ListTile(
                      leading: Icon(MdiIcons.folderTableOutline,
                          color: Settings.majorColor),
                      title: Text(
                        Translations.of(context).trans('componentdir'),
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right),
                    ),
                    onTap: () {},
                  ),
                ]),
                _buildGroup(
                  Translations.of(context).trans('login'),
                ),
                _buildItems(
                  [
                    //
                    //  SNS
                    //
                    // ListTile(
                    //   leading: ShaderMask(
                    //     shaderCallback: (bounds) => RadialGradient(
                    //       center: Alignment.bottomLeft,
                    //       radius: 1.3,
                    //       colors: [Colors.yellow, Colors.red, Colors.purple],
                    //       tileMode: TileMode.clamp,
                    //     ).createShader(bounds),
                    //     child: Icon(MdiIcons.instagram, color: Colors.white),
                    //   ),
                    //   title: Text(Translations.of(context).trans('instagram')),
                    //   trailing: Icon(Icons.keyboard_arrow_right),
                    //   // onTap: () {},
                    // ),
                    // _buildDivider(),
                    // ListTile(
                    //   leading: Icon(MdiIcons.twitter, color: Colors.blue),
                    //   title: Text(Translations.of(context).trans('twitter')),
                    //   trailing: Icon(Icons.keyboard_arrow_right),
                    //   // onTap: () {},
                    // ),

                    //
                    //  커뮤니티
                    //
                    // _buildDivider(),
                    // ListTile(
                    //   leading: CachedNetworkImage(
                    //     imageUrl: 'https://gall.dcinside.com/favicon.ico',
                    //     width: 25,
                    //     height: 25,
                    //   ),
                    //   title: Text('디시인사이드'),
                    //   trailing: Icon(Icons.keyboard_arrow_right),
                    //   // onTap: () {},
                    // ),
                    // _buildDivider(),
                    // ListTile(
                    //   leading: CachedNetworkImage(
                    //     imageUrl:
                    //         'https://img.ruliweb.com/img/2016/icon/ruliweb_icon_144_144.png',
                    //     width: 25,
                    //     height: 25,
                    //   ),
                    //   title: Text('루리웹'),
                    //   trailing: Icon(Icons.keyboard_arrow_right),
                    //   // onTap: () {},
                    // ),
                    // _buildDivider(),
                    // ListTile(
                    //   leading: CachedNetworkImage(
                    //     imageUrl: 'http://www.inven.co.kr/favicon.ico',
                    //     width: 25,
                    //     height: 25,
                    //   ),
                    //   title: Text('인벤'),
                    //   trailing: Icon(Icons.keyboard_arrow_right),
                    //   // onTap: () {},
                    // ),
                    // _buildDivider(),
                    // ListTile(
                    //   leading: CachedNetworkImage(
                    //     imageUrl:
                    //         'https://image.fmkorea.com/touchicon/logo180.png',
                    //     width: 25,
                    //     height: 25,
                    //   ),
                    //   title: Text('에펨코리아'),
                    //   trailing: Icon(Icons.keyboard_arrow_right),
                    //   // onTap: () {},
                    // ),
                    // _buildDivider(),
                    // ListTile(
                    //   leading: CachedNetworkImage(
                    //     imageUrl: 'http://mlbpark.donga.com/favicon.ico',
                    //     width: 25,
                    //     height: 25,
                    //   ),
                    //   title: Text('MLB파크'),
                    //   trailing: Icon(Icons.keyboard_arrow_right),
                    //   // onTap: () {},
                    // ),
                    // _buildDivider(),
                    // ListTile(
                    //   leading: CachedNetworkImage(
                    //     imageUrl: 'http://web.humoruniv.com/favicon.ico',
                    //     width: 25,
                    //     height: 25,
                    //   ),
                    //   title: Text('웃긴대학'),
                    //   trailing: Icon(Icons.keyboard_arrow_right),
                    //   // onTap: () {},
                    // ),
                    // _buildDivider(),
                    // ListTile(
                    //   leading: CachedNetworkImage(
                    //     imageUrl:
                    //         'https://www.clien.net/service/image/icon180x180.png',
                    //     width: 25,
                    //     height: 25,
                    //   ),
                    //   title: Text('클리앙'),
                    //   trailing: Icon(Icons.keyboard_arrow_right),
                    //   // onTap: () {},
                    // ),
                    // _buildDivider(),
                    // ListTile(
                    //   leading: CachedNetworkImage(
                    //     imageUrl: 'https://arca.live/static/apple-icon.png',
                    //     width: 25,
                    //     height: 25,
                    //   ),
                    //   title: Text('아카라이브'),
                    //   trailing: Icon(Icons.keyboard_arrow_right),
                    //   // onTap: () {},
                    // ),
                    // _buildDivider(),
                    // ListTile(
                    //   leading: CachedNetworkImage(
                    //     imageUrl: 'https://section.cafe.naver.com/favicon.ico',
                    //     width: 25,
                    //     height: 25,
                    //   ),
                    //   title: Text('네이버 카페'),
                    //   trailing: Icon(Icons.keyboard_arrow_right),
                    //   // onTap: () {},
                    // ),

                    //
                    //  동영상
                    //
                    // InkWell(
                    //   customBorder: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.only(
                    //           topLeft: Radius.circular(10.0),
                    //           topRight: Radius.circular(10.0))),
                    //   child: ListTile(
                    //     // TODO: Favicon
                    //     // leading: CachedNetworkImage(
                    //     //   imageUrl:
                    //     //       'https://s.ytimg.com/yts/img/favicon_144-vfliLAfaB.png',
                    //     //   width: 25,
                    //     //   height: 25,
                    //     // ),
                    //     leading: Container(
                    //       // child: Icon(Icons.movie),
                    //       width: 25,
                    //     ),
                    //     title: Text('유튜브'),
                    //     trailing: Icon(Icons.keyboard_arrow_right),
                    //   ),
                    //   onTap: () {},
                    // ),

                    //
                    //  블로그
                    //
                    // _buildDivider(),
                    // ListTile(
                    //   leading: CachedNetworkImage(
                    //     imageUrl: 'https://section.blog.naver.com/favicon.ico',
                    //     width: 25,
                    //     height: 25,
                    //   ),
                    //   title: Text('네이버 블로그'),
                    //   trailing: Icon(Icons.keyboard_arrow_right),
                    //   // onTap: () {},
                    // ),
                    // _buildDivider(),
                    // _buildDivider(),
                    InkWell(
                      customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0))),
                      child: ListTile(
                        leading: Settings.enableFavicon
                            ? Image.network('https://www.pixiv.net/favicon.ico',
                                width: 25)
                            : Container(
                                width: 25,
                              ),
                        title: Text(Translations.of(context).trans('pixiv')),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                      onTap: () async {
                        final storage = new FlutterSecureStorage();
                        var nameController = TextEditingController(
                            text: await storage.read(key: 'pixiv_id'));
                        var descController = TextEditingController(
                            text: await storage.read(key: 'pixiv_pwd'));
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
                        var dialog = await showDialog(
                          context: context,
                          child: AlertDialog(
                            actions: [yesButton, noButton],
                            title: Text(
                              Translations.of(context).trans('pixivlogin'),
                            ),
                            contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Text(Translations.of(context).trans('id') +
                                      ': '),
                                  Expanded(
                                    child: TextField(
                                      controller: nameController,
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Text(Translations.of(context).trans('pw') +
                                      '비밀번호: '),
                                  Expanded(
                                    child: TextField(
                                      obscureText: true,
                                      controller: descController,
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        );
                        if (dialog) {
                          var id = nameController.text.trim();
                          var pwd = descController.text.trim();
                          print(id);
                          print(pwd);
                          await storage.write(key: 'pixiv_id', value: id);
                          await storage.write(key: 'pixiv_pwd', value: pwd);
                          var accessToken =
                              await PixivAPI.getAccessToken(id, pwd);
                          if (accessToken == null || accessToken == '') {
                            FlutterToast(context).showToast(
                              child: ToastWrapper(
                                isCheck: false,
                                msg:
                                    Translations.of(context).trans('loginfail'),
                              ),
                              gravity: ToastGravity.BOTTOM,
                              toastDuration: Duration(seconds: 4),
                            );
                          } else {
                            FlutterToast(context).showToast(
                              child: ToastWrapper(
                                isCheck: true,
                                msg:
                                    Translations.of(context).trans('loginsucc'),
                              ),
                              gravity: ToastGravity.BOTTOM,
                              toastDuration: Duration(seconds: 4),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                _buildGroup(Translations.of(context).trans('network')),
                _buildItems([
                  InkWell(
                    customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0))),
                    child: ListTile(
                      leading: Icon(
                        MdiIcons.lan,
                        color: Settings.majorColor,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Translations.of(context).trans('threadcount'),
                          ),
                          FutureBuilder(
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Text(
                                  Translations.of(context).trans('curthread') +
                                      ': ',
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return Text(
                                Translations.of(context).trans('curthread') +
                                    ': ' +
                                    snapshot.data
                                        .getInt('thread_count')
                                        .toString() +
                                    '개',
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                            future: SharedPreferences.getInstance(),
                          )
                        ],
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right),
                    ),
                    onTap: () async {
                      // 32개 => 50mb/s
                      var tc = (await SharedPreferences.getInstance())
                          .getInt('thread_count');

                      TextEditingController text =
                          TextEditingController(text: tc.toString());
                      Widget yesButton = FlatButton(
                        child: Text('바꾸기',
                            style: TextStyle(color: Settings.majorColor)),
                        focusColor: Settings.majorColor,
                        splashColor: Settings.majorColor.withOpacity(0.3),
                        onPressed: () async {
                          if (int.tryParse(text.text) == null) {
                            await Dialogs.okDialog(context,
                                Translations.of(context).trans('putonlynum'));
                            return;
                          }
                          if (int.parse(text.text) > 128) {
                            await Dialogs.okDialog(context,
                                Translations.of(context).trans('toomuch'));
                            return;
                          }
                          if (int.parse(text.text) == 0) {
                            await Dialogs.okDialog(context,
                                Translations.of(context).trans('threadzero'));
                            return;
                          }

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
                      var dialog = await showDialog(
                        context: context,
                        child: AlertDialog(
                          contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                          title:
                              Text(Translations.of(context).trans('setthread')),
                          content: TextField(
                            controller: text,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                          ),
                          actions: [yesButton, noButton],
                        ),
                      );
                      if (dialog == true) {
                        if (!await (await NativeDownloader.getInstance())
                            .tryChangeThreadCount(int.parse(text.text))) {
                          await Dialogs.okDialog(context,
                              Translations.of(context).trans('remaintask'));
                          return;
                        }

                        await (await SharedPreferences.getInstance())
                            .setInt('thread_count', int.parse(text.text));

                        FlutterToast(context).showToast(
                          child: ToastWrapper(
                            isCheck: true,
                            msg:
                                Translations.of(context).trans('changedthread'),
                          ),
                          gravity: ToastGravity.BOTTOM,
                          toastDuration: Duration(seconds: 4),
                        );

                        setState(() {});
                      }
                    },
                  ),
                  // _buildDivider(),
                  // ListTile(
                  //   leading: Icon(
                  //     MdiIcons.speedometer,
                  //     color: Settings.majorColor,
                  //   ),
                  //   title: Text('최고 다운로드 속도 제한'),
                  //   trailing: Icon(Icons.keyboard_arrow_right),
                  //   onTap: () async {},
                  // ),
                  // _buildDivider(),
                  // InkWell(
                  //   customBorder: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.only(
                  //           bottomLeft: Radius.circular(10.0),
                  //           bottomRight: Radius.circular(10.0))),
                  //   child: ListTile(
                  //     leading: Icon(
                  //       MdiIcons.alarm,
                  //       color: Settings.majorColor,
                  //     ),
                  //     title: Text('딜레이 규칙'),
                  //     trailing: Icon(
                  //         // Icons.email,
                  //         Icons.keyboard_arrow_right),
                  //   ),
                  //   onTap: () {},
                  // ),
                ]),
                _buildGroup(Translations.of(context).trans('etc')),
                _buildItems([
                  InkWell(
                    customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0))),
                    child: ListTile(
                      leading: Icon(
                        MdiIcons.gmail,
                        color: Colors.redAccent,
                      ),
                      title: Text(Translations.of(context).trans('contact')),
                      trailing: Icon(
                          // Icons.email,
                          Icons.keyboard_arrow_right),
                    ),
                    onTap: () async {
                      var v = await showDialog(
                        context: context,
                        child: ContactSelector(),
                      );

                      if (v == null) return;

                      switch (v as int) {
                        case 0:
                          var yn = await Dialogs.yesnoDialog(
                              context,
                              '본 개발자는 오류 및 버그에 대한 정보(다운로드 URL정보, 다운로드 시간 등)을 담은 로그파일을 첨부합니다. ' +
                                  '이 로그에 포함된 내용은 다운로드 로그 내보내기를 통해 내보낸 로그와 동일합니다.' +
                                  '이 정보는 개발자가 오류를 수정하는데 도움이 됩니다. 계속할까요?',
                              'Support');

                          if (yn == null || yn == false) {
                            return;
                          }

                          var db = await getApplicationDocumentsDirectory();
                          var dbfile = File('${db.path}/log.txt');
                          var ext = await getExternalStorageDirectory();
                          var extpath = '${ext.path}/log.txt';
                          var extfile = await dbfile.copy(extpath);

                          final MailOptions mailOptions = MailOptions(
                            body:
                                '* 이 메일에는 사용자 로그정보가 포함됩니다. 여기엔 다운로드 정보(URL 등)이 포함되어있으며, 개인정보는 포함되어있지 않습니다.',
                            subject: '[App Issue] ',
                            recipients: ['violet.dev.master@gmail.com'],
                            // isHTML: true,
                            // bccRecipients: ['other@example.com'],
                            // ccRecipients: ['third@example.com'],
                            attachments: [
                              extpath,
                            ],
                          );
                          await FlutterMailer.send(mailOptions);
                          await extfile.delete();
                          break;

                        case 1:
                          const url =
                              'mailto:violet.dev.master@gmail.com?subject=[Request] &body=';
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                          break;

                        case 2:
                          const url =
                              'mailto:violet.dev.master@gmail.com?subject=[Contact] &body=';
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                          break;
                      }
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      MdiIcons.heart,
                      color: Colors.orange,
                    ),
                    title: Text(Translations.of(context).trans('donate')),
                    trailing: Icon(
                        // Icons.email,
                        Icons.keyboard_arrow_right),
                    onTap: () async {},
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      MdiIcons.frequentlyAskedQuestions,
                      color: Colors.lightBlue.shade500,
                    ),
                    title: Text(Translations.of(context).trans('faq')),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () async {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => FAQPage(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      MdiIcons.flaskOutline,
                      color: Colors.lightGreen,
                    ),
                    title: Text(Translations.of(context).trans('laboratory')),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () async {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => LaboratoryPage(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      MdiIcons.gondola,
                      color: Colors.grey.shade300,
                    ),
                    title: Text(Translations.of(context).trans('supportsweb')),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () async {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => SupportPage(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      MdiIcons.script,
                      color: Colors.brown,
                    ),
                    title: Text(Translations.of(context).trans('termofuse')),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () async {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => TermOfUsePage(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      MdiIcons.serverNetwork,
                      color: Colors.blueGrey,
                    ),
                    title: Text(Translations.of(context).trans('privacy')),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () async {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => PrivacyPage(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  InkWell(
                    customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0))),
                    child: ListTile(
                      leading: Icon(
                        MdiIcons.library,
                        color: Settings.majorColor,
                      ),
                      title: Text(Translations.of(context).trans('license')),
                      trailing: Icon(
                          // Icons.email,
                          Icons.keyboard_arrow_right),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => VioletLicensePage(),
                        ),
                      );
                    },
                  ),
                ]),
                Container(
                  margin: EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 12),
                        ),
                        Text(
                          'Project Violet',
                          style: TextStyle(
                            color: Settings.themeWhat
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 16.0,
                            //fontFamily: "Calibre-Semibold",
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Copyright (C) 2020 by project-violet',
                          style: TextStyle(
                            color: Settings.themeWhat
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 12.0,
                            //fontFamily: "Calibre-Semibold",
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '다운로드한 컨텐츠들은 소장용도로만 사용해주세요',
                          style: TextStyle(
                            color: Settings.themeWhat
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 10.0,
                            //fontFamily: "Calibre-Semibold",
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          '다운로드한 컨텐츠들은 저작권자 동의없이',
                          style: TextStyle(
                            color: Settings.themeWhat
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 10.0,
                            //fontFamily: "Calibre-Semibold",
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          '무단으로 복제와 배포, 상업적으로 이용을 할 수 없습니다.',
                          style: TextStyle(
                            color: Settings.themeWhat
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 10.0,
                            //fontFamily: "Calibre-Semibold",
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Settings.themeWhat ? Colors.grey.shade600 : Colors.grey.shade400,
    );
  }

  Padding _buildGroup(String name) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(name,
              style: TextStyle(
                color: Settings.themeWhat ? Colors.white : Colors.black87,
                fontSize: 24.0,
                // fontFamily: "Calibre-Semibold",
                letterSpacing: 1.0,
              )),
        ],
      ),
    );
  }

  Container _buildItems(List<Widget> items) {
    return Container(
      transform: Matrix4.translationValues(0, -2, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Card(
          elevation: 4.0,
          margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(children: items),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
