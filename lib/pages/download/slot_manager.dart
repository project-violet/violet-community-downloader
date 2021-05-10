// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:synchronized/synchronized.dart' as sync;

// Blocking is prevented from websites by limiting simultaneous extracting operations.
class SlotManager {
  static const int maxDownloadCount = 3;
  int _curDownloadCount = 0;
  sync.Lock lock = sync.Lock();

  static SlotManager _instance;

  static SlotManager getInstance() {
    if (_instance == null) {
      _instance = SlotManager();
    }
    return _instance;
  }

  bool hasDownloadSlot() {
    return _curDownloadCount < maxDownloadCount;
  }

  Future<bool> ensureDownload() async {
    var succ = false;
    await lock.synchronized(() {
      if (hasDownloadSlot()) {
        _curDownloadCount++;
        succ = true;
      }
    });
    return succ;
  }

  Future<void> returnDownload() async {
    await lock.synchronized(() {
      _curDownloadCount--;
    });
  }
}
