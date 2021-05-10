// This source code is a part of Project Violet.
// Copyright (C) 2020. violet-team. Licensed under the MIT License.

import 'dart:ffi';
import 'dart:io';

import 'package:communitydownloader/component/external/youtude-dl.dart';
import 'package:communitydownloader/downloader/native_downloader.dart';
import 'package:communitydownloader/log/log.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:kdtree/kdtree.dart';
import "package:collection/collection.dart";

import 'package:opencv/opencv.dart';

// typedef attach_hash = Void Function(Pointer<Utf8>);
// typedef AttachHash = void Function(Pointer<Utf8> img);
// typedef compare_hash = Int64 Function(Pointer<Utf8> a, Pointer<Utf8> b);
// typedef CompareHash = int Function(Pointer<Utf8> a, Pointer<Utf8> b);

class Idata {
  String title;
  int index;

  Idata({this.title, this.index});

  int compareTo(Idata id) {
    return title.compareTo(id.title);
  }

  bool operator <(Idata id) {
    return title.compareTo(id.title) < 0;
  }

  String toString() {
    return title;
  }
}

class DisjointSet {
  // Disjoint Set Array
  List<int> array;

  DisjointSet(int N) {
    array = List<int>(N);

    for (int i = 0; i < N; i++) array[i] = i;
  }

  int find(int x) {
    if (array[x] == x) return x;
    return array[x] = find(array[x]);
  }

  void union(int a, int b) {
    int aa = find(a);
    int bb = find(b);

    if (aa == bb) return;

    if (aa > bb) {
      int tt = aa;
      aa = bb;
      bb = tt;
    }

    array[bb] = aa;
  }
}

class ImageCluster {
  // AttachHash attachHash;
  // CompareHash compareHash;

  // Future<void> init() async {
  //   var libviolet = (await NativeDownloader.getInstance()).libviolet;

  //   attachHash = libviolet
  //       .lookup<NativeFunction<attach_hash>>("attach_hash")
  //       .asFunction();
  //   compareHash = libviolet
  //       .lookup<NativeFunction<compare_hash>>("compare_hash")
  //       .asFunction();

  //   Logger.info('[IC] Initialized');
  // }

  // static ImageCluster _instance;
  // static Future<ImageCluster> getInstance() async {
  //   if (_instance == null) {
  //     _instance = ImageCluster();
  //     await _instance.init();
  //   }

  //   return _instance;
  // }

  static Map<String, List<int>> hashMap = Map<String, List<int>>();

  static Future<dynamic> append(String path) async {
    // attachHash(Utf8.toUtf8(path));
    if (hashMap.containsKey(path)) return hashMap[path];
    return hashMap[path] =
        await ImgProc.getHash(await File(path).readAsBytes());
    // var r = await compute(ImgProc.getHash, path);
    // return hashMap[path] = await ImgProc.getHash(path);
    // await YoutubeDL.platform.invokeMethod('calHash', {'filename': path});
    // return null;
    // return null;
  }

  static int bitCount32(int n) {
    n = n - ((n >> 1) & 0x55555555);
    n = (n & 0x33333333) + ((n >> 2) & 0x33333333);
    n = (n + (n >> 4)) & 0x0f0f0f0f;
    n = n + (n >> 8);
    n = n + (n >> 16);
    return n & 0x3f;
  }

  static int compare(String path1, String path2) {
    var aa = hashMap[path1];
    var bb = hashMap[path2];

    var result = 0;
    for (int i = 0; i < aa.length; i++) {
      result += bitCount32(aa[i] ^ bb[i]);
    }
    return result;
  }

  static int _distance(dynamic a, dynamic b) {
    return compare(a['t'].title, b['t'].title);
  }

  static List<List<int>> doClustering(List<String> titles) {
    var ctitles = List<Map<String, Idata>>();

    for (int i = 0; i < titles.length; i++) {
      var mm = Map<String, Idata>();
      mm['t'] = Idata(title: titles[i], index: i);
      ctitles.add(mm);
    }

    var tree = KDTree(ctitles, _distance, ['t']);
    var maxnode = titles.length;

    if (maxnode > 100) maxnode = 100;

    var groups = List<List<int>>();
    ctitles.forEach((element) {
      var near = tree.nearest(element, maxnode, 50);

      var rr = List<int>();
      near.forEach((element) {
        rr.add(element[0]['t'].index);
      });

      rr.sort();
      groups.add(rr);
    });

    // Group By Same Lists
    var gg = groupBy(groups, (x) => x.join(','));
    var ds = DisjointSet(titles.length);

    // Join groups
    gg.forEach((key, value) {
      value[0].forEach((element) {
        if (value[0][0] == element) return;
        ds.union(value[0][0], element);
      });
    });

    var join = Map<int, List<int>>();
    for (int i = 0; i < titles.length; i++) {
      var v = ds.find(i);
      if (!join.containsKey(v)) join[v] = List<int>();
      join[v].add(i);
    }

    var result = join.values.toList();

    result.forEach((element) {
      if (element.length == 1) return;
      print('------------');
      element.forEach((element) {
        print(titles[element]);
      });
    });

    return result;
  }

  // int compare(String path1, String path2) {
  //   return compareHash(Utf8.toUtf8(path1), Utf8.toUtf8(path2));
  // }
}
