// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communitydownloader/log/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:communitydownloader/locale/locale.dart';
import 'package:communitydownloader/pages/download/download_page.dart';
import 'package:communitydownloader/pages/settings/settings_page.dart';
import 'package:communitydownloader/settings/settings.dart';

class AfterLoadingPage extends StatefulWidget {
  @override
  _AfterLoadingPageState createState() => new _AfterLoadingPageState();
}

class _AfterLoadingPageState extends State<AfterLoadingPage>
    with WidgetsBindingObserver {
  int _page = 0;
  PageController _c;
  bool isBlurred = false;
  DateTime currentBackPressTime;

  @override
  void initState() {
    _c = new PageController(
      initialPage: _page,
    );
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    setState(() {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive)
        isBlurred = true;
      else
        isBlurred = false;
    });
  }

  @override
  void disposed() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        elevation: 9,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.shifting,
        fixedColor: Settings.majorColor,
        unselectedItemColor:
            Settings.themeWhat ? Colors.white : Colors.black, //Colors.black,
        currentIndex: _page,
        onTap: (index) {
          this._c.animateToPage(index,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut);
        },
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
              icon: new Icon(Icons.file_download),
              title: new Text(Translations.of(context).trans('download'))),
          new BottomNavigationBarItem(
              backgroundColor: Settings.themeWhat
                  ? Colors.grey.shade900.withOpacity(0.90)
                  : Colors.grey.shade50,
              icon: new Icon(Icons.settings),
              title: new Text(Translations.of(context).trans('settings'))),
        ],
      ),
      body: Builder(
        // Create an inner BuildContext so that the onPressed methods
        // can refer to the Scaffold with Scaffold.of().
        // https://stackoverflow.com/questions/53922053/how-to-properly-display-a-snackbar-in-flutter
        builder: (BuildContext context) {
          return WillPopScope(
            child: new PageView(
              controller: _c,
              onPageChanged: (newPage) {
                setState(() {
                  this._page = newPage;
                });
              },
              children: <Widget>[
                DownloadPage(),
                SettingsPage(),
              ],
            ),
            onWillPop: () {
              DateTime now = DateTime.now();
              if (currentBackPressTime == null ||
                  now.difference(currentBackPressTime) > Duration(seconds: 2)) {
                currentBackPressTime = now;
                Scaffold.of(context).showSnackBar(new SnackBar(
                  duration: Duration(seconds: 2),
                  content: new Text(
                    Translations.of(context).trans('closedoubletap'),
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.grey.shade800,
                ));
                return Future.value(false);
              }
              Logger.info('App Main Ends');
              return Future.value(true);
            },
          );
        },
      ),

      // ),
    );
  }
}
