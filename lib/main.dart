// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

// For the development of human civilization and science and technology

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:communitydownloader/database/user/bookmark.dart';
import 'package:communitydownloader/database/user/record.dart';
import 'package:communitydownloader/pages/afterloading/afterloading.dart';
import 'package:communitydownloader/pages/download/download_page.dart';
import 'package:communitydownloader/settings/settings.dart';
import 'package:communitydownloader/variables.dart';
import 'locale/locale.dart';
import 'log/log.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await SystemChrome.setEnabledSystemUIOverlays([]);
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // await di.init(); //initialize the service locator

  await Logger.init();

  Logger.info('App Main Starts');

  // TestWidgetsFlutterBinding.ensureInitialized();

  // Crashlytics.instance.enableInDevMode = true;
  // FlutterError.onError = Crashlytics.instance.recordFlutterError;
  FlutterError.onError = (FlutterErrorDetails detail) async {
    Logger.error('[Global Error] MSG:' +
        detail.exception.toString() +
        '\n' +
        detail.stack.toString());
  };

  var analytics = FirebaseAnalytics();
  var observer = FirebaseAnalyticsObserver(analytics: analytics);
  var id = (await SharedPreferences.getInstance()).getString('fa_userid');
  if (id == null) {
    var ii = sha1.convert(utf8.encode(DateTime.now().toString()));
    id = ii.toString();
    (await SharedPreferences.getInstance()).setString('fa_userid', id);
  }
  await analytics.setUserId(id);

  await Settings.init();
  await User.getInstance();
  await Variables.init();
  // await YoutubeDL.init();
  // await YoutubeDL.test();

  // Init downloader thread
  var tc = (await SharedPreferences.getInstance()).getInt('thread_count');
  if (tc == null) {
    await (await SharedPreferences.getInstance()).setInt('thread_count', 16);
  }

  runApp(
    DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        accentColor: Settings.majorColor,
        // primaryColor: Settings.majorColor,
        // primarySwatch: Settings.majorColor,
        brightness: brightness,
      ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          theme: theme,
          home: AfterLoadingPage(),
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('ko', 'KR'),
            // const Locale('ja', 'JP'),
            // const Locale('zh', 'CH'),
            // const Locale('it', 'IT'),
            // const Locale('eo', 'ES'),
          ],
          localizationsDelegates: [
            const TranslationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          localeResolutionCallback:
              (Locale locale, Iterable<Locale> supportedLocales) {
            if (Settings.language != null) {
              if (Settings.language.contains('_')) {
                var ss = Settings.language.split('_');
                if (ss.length == 2)
                  return Locale.fromSubtags(
                      languageCode: ss[0], scriptCode: ss[1]);
                else
                  return Locale.fromSubtags(
                      languageCode: ss[0],
                      scriptCode: ss[1],
                      countryCode: ss[2]);
              } else
                return Locale(Settings.language);
            }

            if (locale == null) {
              debugPrint("*language locale is null!!!");
              if (Settings.language == null) {
                Settings.setLanguage(supportedLocales.first.languageCode);
              }
              return supportedLocales.first;
            }

            for (Locale supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode ||
                  supportedLocale.countryCode == locale.countryCode) {
                debugPrint("*language ok $supportedLocale");
                if (Settings.language == null) {
                  Settings.setLanguage(supportedLocale.languageCode);
                }
                return supportedLocale;
              }
            }

            debugPrint("*language to fallback ${supportedLocales.first}");
            if (Settings.language == null)
              Settings.setLanguage(supportedLocales.first.languageCode);
            return supportedLocales.first;
          },
        );
      },
    ),
  );
}
