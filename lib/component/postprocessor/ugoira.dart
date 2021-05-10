// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:io';

import 'package:communitydownloader/component/downloadable.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path/path.dart';
import 'package:tuple/tuple.dart';

// Pixiv Ugoira to Webp
class UgoiraPostprocessor extends IPostprocessor {
  final List<dynamic> frames;

  UgoiraPostprocessor({this.frames});

  @override
  Future<String> run(DownloadTask downloadTask) async {
    var path = downloadTask.downloadPath;

    // Extract
    final destinationDir = Directory(path + '.extract');
    if (await destinationDir.exists())
      await destinationDir.delete(recursive: true);

    await ZipFile.extractToDirectory(
      zipFile: File(path),
      destinationDir: destinationDir,
      onExtracting: (zipEntry, progress) {
        return ExtractOperation.extract;
      },
    );

    var delays = frames.map(
      (e) => Tuple2<String, int>(
        e['file'],
        e['delay'],
      ),
    );

    // ffconcat.txt
    var ffconcatBody = '';
    ffconcatBody += 'ffconcat version 1.0\n\n';
    delays.forEach((element) {
      ffconcatBody +=
          'file \'' + destinationDir.path + '/' + element.item1 + '\'\n';
      ffconcatBody +=
          'duration ' + (element.item2 / 1000.0).toString() + '\n\n';
    });
    var ffc = File(path + '.extract/ffconcat.txt');
    await ffc.create();
    await ffc.writeAsString(ffconcatBody);

    var ffmpeg = new FlutterFFmpeg();
    var savepath =
        join(dirname(path), path.split('/').last.split('_').first + '.gif');
    var err = await ffmpeg.executeWithArguments([
      '-y', // Ignore if file already exists
      '-safe', // File name include unicode
      '0',
      '-i',
      ffc.path,
      savepath,
    ]);

    await destinationDir.delete(recursive: true);
    await File(path).delete();

    return savepath;
  }
}
