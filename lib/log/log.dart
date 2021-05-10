// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart' as sync;

class Logger {
  static sync.Lock lock = sync.Lock();
  static File logFile;

  static Future<void> init() async {
    print('asdf');
    var dir = await getApplicationDocumentsDirectory();
    logFile = File(join(dir.path, 'log.txt'));
    if (!await logFile.exists()) {
      await logFile.create();
    }
  }

  static Future<void> log(String msg) async {
    await lock.synchronized(() async {
      await logFile.writeAsString('[${DateTime.now().toUtc()}] ' + msg + '\n',
          mode: FileMode.append);
    });
  }

  static Future<void> info(String msg) async {
    await log('[Info] ' + msg);
  }

  static Future<void> error(String msg) async {
    await log('[Error] ' + msg);
  }

  static Future<void> warning(String msg) async {
    await log('[Warning] ' + msg);
  }
}
