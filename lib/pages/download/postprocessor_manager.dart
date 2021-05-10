// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:collection';

import 'package:communitydownloader/component/downloadable.dart';
import 'package:communitydownloader/thread/semaphore.dart';
import 'package:flutter/cupertino.dart';
import 'package:synchronized/synchronized.dart' as sync;

class PostprocessorManager {
  static const int maxProcessCount = 1;
  sync.Lock lock = sync.Lock();

  Semaphore sem;

  PostprocessorManager() {
    sem = Semaphore(maxCount: maxProcessCount);
  }

  static PostprocessorManager _instance;
  static PostprocessorManager getInstance() {
    if (_instance == null) _instance = PostprocessorManager();
    return _instance;
  }

  int id = 0;

  Future<void> appendTask(PostprocessorTask task) async {
    await lock.synchronized(() async {
      sem.acquire(id++).then((value) async {
        await task.startPostprocessor(value);
        var fn = await task.postprocessor.run(task.downloadTask);
        if (fn != null) task.filenameCallback(fn);
        await task.endPostprocessor(value);
        sem.release();
      });
    });
  }

  Future<void> appendTasks(List<PostprocessorTask> task) async {
    for (int i = 0; i < task.length; i++) {
      await appendTask(task[i]);
    }
  }
}
