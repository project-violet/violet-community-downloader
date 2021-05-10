// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:communitydownloader/log/log.dart';
import 'package:communitydownloader/pages/download/postprocessor_manager.dart';
import 'package:communitydownloader/pages/download/slot_manager.dart';
import 'package:communitydownloader/pages/download/task_create_page.dart';
import 'package:communitydownloader/component/external/youtude-dl.dart';
import 'package:communitydownloader/pages/gallery/gallery_item.dart';
import 'package:communitydownloader/pages/gallery/gallery_page.dart';
import 'package:convert/convert.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:communitydownloader/component/downloadable.dart';
import 'package:communitydownloader/component/downloadable.dart' as violetd;
import 'package:communitydownloader/locale/locale.dart';
import 'package:communitydownloader/pages/download/download_item_menu.dart';
import 'package:communitydownloader/downloader/native_downloader.dart';
import 'package:communitydownloader/settings/settings.dart';
import 'package:communitydownloader/database/user/download.dart';
import 'package:communitydownloader/widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadItemWidget extends StatefulWidget {
  final double width;
  final DownloadItemModel item;
  bool download;
  bool job;
  final VoidCallback refeshCallback;

  DownloadItemWidget({
    this.width,
    this.item,
    this.job,
    this.download,
    this.refeshCallback,
  });

  @override
  _DownloadItemWidgetState createState() => _DownloadItemWidgetState();
}

class _DownloadItemWidgetState extends State<DownloadItemWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  double scale = 1.0;
  String fav = '';
  String name = '';
  int cur = 0;
  int max = 0;

  double download = 0;
  double downloadSec = 0;
  int downloadTotalFileCount = 0;
  int downloadedFileCount = 0;
  int postprocessTotalFileCount = 0;
  int postprocessFileCount = 0;
  int errorFileCount = 0;
  String downloadSpeed = ' KB/S';
  bool once = false;

  bool youtubeDLMode = false;
  double downloadPercent = 0;

  @override
  void initState() {
    super.initState();

    if (ExtractorManager.instance.existsExtractor(widget.item.url())) {
      var extractor = ExtractorManager.instance.getExtractor(widget.item.url());
      if (extractor != null) {
        name = extractor.name();
        fav = extractor.fav();
      }
    } else if (ExtractorManager.instance
        .existsCommunityExtractor(widget.item.url())) {
      var extractor =
          ExtractorManager.instance.getCommunityExtractor(widget.item.url());
      if (extractor != null) {
        name = extractor.name();
        fav = extractor.fav();
      }
    } else if (Uri.tryParse(widget.item.url()) != null) {
      fav = _getFavicon(Uri.parse(widget.item.url()).host);
    }

    if (!widget.job)
      _downloadProcedure();
    else
      _taskProcedure();
  }

  _downloadProcedure() {
    Future.delayed(Duration(milliseconds: 500)).then((value) async {
      if (once) return;
      once = true;
      // var downloader = await BuiltinDownloader.getInstance();
      var downloader = await NativeDownloader.getInstance();

      var result = Map<String, dynamic>.from(widget.item.result);

      if (widget.item.state() != 1) {
        if (widget.item.state() == 2 ||
            widget.item.state() == 3 ||
            widget.item.state() == 12) {
          result['State'] = 6;
          widget.item.result = result;
          await widget.item.update();
          setState(() {});
          return;
        }
        return;
      }

      if (!widget.download && !widget.job) {
        result['State'] = 6;
        widget.item.result = result;
        await widget.item.update();
        setState(() {});
        return;
      }

      Logger.info(
          '[Download Task] [' + widget.item.id().toString() + '] Appended');

      downloadedFileCount = 0;
      errorFileCount = 0;
      download = 0;
      downloadSec = 0;
      postprocessTotalFileCount = 0;
      postprocessFileCount = 0;

      while (true) {
        while (!SlotManager.getInstance().hasDownloadSlot())
          await Future.delayed(Duration(milliseconds: 500));
        if (await SlotManager.getInstance().ensureDownload()) break;
      }

      Logger.info(
          '[Download Task] [' + widget.item.id().toString() + '] Starts');

      // Check valid url
      if (!ExtractorManager.instance.existsExtractor(widget.item.url())) {
        // Check if community download possible
        if (ExtractorManager.instance
            .existsCommunityExtractor(widget.item.url())) {
          // Software Logic Error!
          // This scope should never be hit!
          result['State'] = 7;
          widget.item.result = result;
          await widget.item.update();
          setState(() {});
          await SlotManager.getInstance().returnDownload();
          Logger.error('[Download Task] [' +
              widget.item.id().toString() +
              '] Community');
          return;
        }

        // Throw task to youtube-dl
        if (widget.item.url().startsWith('http://') ||
            widget.item.url().startsWith('https://')) {
          if (YoutubeDL.checkHost(Uri.parse(widget.item.url()).host)) {
            youtubeDLMode = true;

            try {
              result['State'] = 2;
              widget.item.result = result;
              await widget.item.update();
              setState(() {});

              var thumbnail =
                  await YoutubeDL.requestThumbnail(widget.item.url());

              result['Thumbnail'] = thumbnail;
              widget.item.result = result;
              await widget.item.update();
              setState(() {});

              await YoutubeDL.requestDownload(
                YoutubeDLCallback(
                  pathCallback: (path) async {
                    result['Extractor'] =
                        path.split('/')[path.split('/').length - 2];
                    result['Info'] = basenameWithoutExtension(path);
                    result['Files'] = jsonEncode([path]);
                    widget.item.result = result;
                    await widget.item.update();
                    setState(() {});
                  },
                  progressCallback: (percent) async {
                    if (percent.toStringAsFixed(1) != "0.0" &&
                        result['State'] != 3) {
                      result['State'] = 3;
                      widget.item.result = result;
                      await widget.item.update();
                    }
                    setState(() => downloadPercent = percent);
                  },
                ),
                widget.item.url(),
                Settings.downloadBasePath,
              );

              result['State'] = 0;
              widget.item.result = result;
              await widget.item.update();
              setState(() {});
            } catch (e, stacktrace) {
              void printWrapped(String text) {
                final pattern =
                    new RegExp('.{1,800}'); // 800 is the size of each chunk
                pattern
                    .allMatches(text)
                    .forEach((match) => print(match.group(0)));
              }

              printWrapped(e.toString());
              Logger.error('[Download Task] [' +
                  widget.item.id().toString() +
                  '] YDL Msg:' +
                  e.toString() +
                  '\n' +
                  stacktrace.toString());

              result['State'] = 7;
              widget.item.result = result;
              await widget.item.update();
              setState(() {});
            }

            await SlotManager.getInstance().returnDownload();

            return;
          }
        }

        result['State'] = 8;
        widget.item.result = result;
        await widget.item.update();
        setState(() {});
        await SlotManager.getInstance().returnDownload();
        return;
      }

      // Choose Extractor
      var extractor = ExtractorManager.instance.getExtractor(widget.item.url());
      result['State'] = 2;
      result['Extractor'] = extractor.name();
      widget.item.result = result;
      await widget.item.update();
      setState(() {});

      Logger.info('[Download Task] [' +
          widget.item.id().toString() +
          '] Extractor Selected: ' +
          extractor.name());

      // Login
      if (extractor.loginRequire()) {
        if (!extractor.logined()) {
          if (!await extractor.tryLogin()) {
            result['State'] = 9;
            widget.item.result = result;
            await widget.item.update();
            setState(() {});
            await SlotManager.getInstance().returnDownload();
            Logger.info('[Download Task] [' +
                widget.item.id().toString() +
                '] Login Failed');
            return;
          }
        }
      }

      // Extractor
      List<violetd.DownloadTask> tasks;

      try {
        tasks = await extractor.createTask(
          widget.item.url(),
          GeneralDownloadProgress(
            simpleInfoCallback: (info) async {
              result['Info'] = info;
              widget.item.result = result;
              await widget.item.update();
              setState(() {});
            },
            thumbnailCallback: (url, header) async {
              result['Thumbnail'] = url;
              result['ThumbnailHeader'] = header;
              widget.item.result = result;
              await widget.item.update();
              setState(() {});
            },
            progressCallback: (cur, max) async {
              setState(() {
                this.cur = cur;
                if (this.max < max) this.max = max;
              });
            },
          ),
        );
      } catch (e, stacktrace) {
        result['State'] = 7;
        widget.item.result = result;
        await widget.item.update();
        setState(() {});
        print(e);
        print(stacktrace);
        Logger.error('[Download Task] [' +
            widget.item.id().toString() +
            '] Extracting Error MSG:' +
            e.toString() +
            '\n' +
            stacktrace.toString());
        await SlotManager.getInstance().returnDownload();
        return;
      }

      if (tasks == null || tasks.length == 0) {
        result['State'] = 11;
        widget.item.result = result;
        await widget.item.update();
        setState(() {});
        await SlotManager.getInstance().returnDownload();
        Logger.warning('[Download Task] [' +
            widget.item.id().toString() +
            '] Nothing to download');
        return;
      }

      // Files and Path
      var files = tasks
          .map((e) => join(Settings.downloadBasePath,
              e.format.formatting(extractor.defaultFormat())))
          .toList();
      result['Files'] = jsonEncode(files);
      // Extract Super Path
      var cp = dirname(files[0]).split('/');
      var vp = cp.length;
      for (int i = 1; i < files.length; i++) {
        var tp = dirname(files[i]).split('/');
        for (int i = 0; i < vp; i++) {
          if (cp[i] != tp[i]) {
            vp = i;
            break;
          }
        }
      }
      var pp = cp.take(vp).join('/');
      result['Path'] = pp;
      widget.item.result = result;
      await widget.item.update();

      // Download
      var _timer =
          new Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
        setState(() {
          if (downloadSec / 1024 < 500.0)
            downloadSpeed = (downloadSec / 1024).toStringAsFixed(1) + " KB/S";
          else
            downloadSpeed =
                (downloadSec / 1024 / 1024).toStringAsFixed(1) + " MB/S";
          downloadSec = 0;
        });
      });

      Logger.info('[Download Task] [' +
          widget.item.id().toString() +
          '] Task attached to downloader ' +
          tasks.length.toString());

      // var downloader = FlutterDonwloadDonwloader.getInstance();
      await downloader.addTasks(tasks.map((e) {
        e.downloadPath = join(Settings.downloadBasePath,
            e.format.formatting(extractor.defaultFormat()));

        e.startCallback = () {};
        e.completeCallback = () {
          downloadedFileCount++;
        };

        e.sizeCallback = (byte) {};
        e.downloadCallback = (byte) {
          download += byte;
          downloadSec += byte;
        };

        e.errorCallback = (err) {
          downloadedFileCount++;
          errorFileCount++;
        };

        return e;
      }).toList());
      downloadTotalFileCount = tasks.length;
      result['State'] = 3;
      widget.item.result = result;
      await widget.item.update();
      setState(() {});

      // Wait for download complete
      while (downloadTotalFileCount != downloadedFileCount) {
        await Future.delayed(Duration(milliseconds: 500));
      }
      _timer.cancel();

      await SlotManager.getInstance().returnDownload();

      Logger.info('[Download Task] [' +
          widget.item.id().toString() +
          '] Download complete');

      // Postprocess
      var ppTasks = tasks.where((e) => e.postprocessorTask != null).toList();
      if (ppTasks.length > 0) {
        downloadTotalFileCount = tasks.length;
        result['State'] = 12;
        widget.item.result = result;
        await widget.item.update();
        setState(() {});

        postprocessTotalFileCount = ppTasks.length;

        var fnChange = Map<String, String>();

        await PostprocessorManager.getInstance().appendTasks(ppTasks.map((e) {
          e.postprocessorTask.startPostprocessor = (i) async {};
          e.postprocessorTask.endPostprocessor = (i) async {
            setState(() {
              postprocessFileCount++;
            });
          };
          e.postprocessorTask.filenameCallback = (fn) async {
            fnChange[e.downloadPath] = fn;
          };
          return e.postprocessorTask;
        }).toList());
        while (postprocessTotalFileCount != postprocessFileCount) {
          await Future.delayed(Duration(milliseconds: 500));
        }

        for (int i = 0; i < files.length; i++) {
          if (fnChange.containsKey(files[i])) {
            files[i] = fnChange[files[i]];
          }
        }
        result['Files'] = jsonEncode(files);
        Logger.info('[Download Task] [' +
            widget.item.id().toString() +
            '] Postprocess complete');
      }

      // Complete!
      result['State'] = 0;
      widget.item.result = result;
      await widget.item.update();
      setState(() {});
      Logger.info(
          '[Download Task] [' + widget.item.id().toString() + '] Complete');
    }).catchError((e, stacktrace) {
      Logger.error('[Download Task] [' +
          widget.item.id().toString() +
          '] MSG:' +
          e.toString() +
          '\n' +
          stacktrace.toString());
    });
  }

  String statusMessage = '';

  //
  //  Process user action.
  //
  _taskProcedure() {
    Future.delayed(Duration(milliseconds: 500)).then(
      (value) async {
        if (once) return;
        once = true;
        // var downloader = await BuiltinDownloader.getInstance();
        var downloader = await NativeDownloader.getInstance();

        var result = Map<String, dynamic>.from(widget.item.result);

        downloadedFileCount = 0;
        errorFileCount = 0;
        download = 0;
        downloadSec = 0;
        postprocessTotalFileCount = 0;
        postprocessFileCount = 0;

        Logger.info('[Community Download Task] [' +
            widget.item.id().toString() +
            '] Appended');

        if (widget.item.state() != 1) {
          if (widget.item.state() == 2 || widget.item.state() == 3) {
            result['State'] = 6;
            widget.item.result = result;
            await widget.item.update();
            setState(() {});
            return;
          }
          return;
        }

        if (!widget.download && !widget.job) {
          result['State'] = 6;
          widget.item.result = result;
          await widget.item.update();
          setState(() {});
          return;
        }

        if (!ExtractorManager.instance
            .existsCommunityExtractor(widget.item.url())) {
          result['State'] = 8;
          widget.item.result = result;
          await widget.item.update();
          setState(() {});
          return;
        }

        var extractor =
            ExtractorManager.instance.getCommunityExtractor(widget.item.url());
        result['State'] = 2;
        result['Extractor'] = extractor.name();
        widget.item.result = result;
        await widget.item.update();
        setState(() {});

        Logger.info('[Community Download Task] [' +
            widget.item.id().toString() +
            '] Extractor Selected: ' +
            extractor.name());

        while (true) {
          while (!SlotManager.getInstance().hasDownloadSlot())
            await Future.delayed(Duration(milliseconds: 500));
          if (await SlotManager.getInstance().ensureDownload()) break;
        }

        Logger.info('[Commmunity Download Task] [' +
            widget.item.id().toString() +
            '] Starts');

        // Login
        if (extractor.loginRequire()) {
          if (!extractor.logined()) {
            if (!await extractor.tryLogin()) {
              result['State'] = 9;
              widget.item.result = result;
              await widget.item.update();
              setState(() {});
              return;
            }
          }
        }

        // Extractor
        List<violetd.DownloadTask> tasks;
        var desc =
            TaskRequestDescription(map: jsonDecode(widget.item.option()));

        try {
          tasks = await extractor.requestCommunityTask(
            desc,
            GeneralDownloadProgress(
              simpleInfoCallback: (info) async {
                result['Info'] = info;
                widget.item.result = result;
                await widget.item.update();
                setState(() {});
              },
              thumbnailCallback: (url, header) async {
                result['Thumbnail'] = url;
                result['ThumbnailHeader'] = header;
                widget.item.result = result;
                await widget.item.update();
                setState(() {});
              },
              statusCallback: (status) async {
                setState(() {
                  statusMessage = status;
                });
              },
            ),
          );
        } catch (e, stacktrace) {
          result['State'] = 7;
          widget.item.result = result;
          await widget.item.update();
          setState(() {});
          print(e);
          print(stacktrace);
          Logger.error('[Community Download Task] [' +
              widget.item.id().toString() +
              '] Extracting Error MSG:' +
              e.toString() +
              '\n' +
              stacktrace.toString());
          return;
        }

        if (tasks == null || tasks.length == 0) {
          result['State'] = 11;
          widget.item.result = result;
          await widget.item.update();
          setState(() {});
          return;
        }

        Logger.info('[Community Download Task] [' +
            widget.item.id().toString() +
            '] Task attached to downloader ' +
            tasks.length.toString());

        // Files and Path
        var files = tasks
            .map((e) => join(
                Settings.downloadBasePath,
                e.format.formatting(desc.useCustomPath()
                    ? desc.customPath()
                    : desc.onlyOneFolder()
                        ? extractor.saveOneFormat()
                        : extractor.defaultFormat())))
            .toList();
        result['Files'] = jsonEncode(files);
        // Extract Super Path
        var cp = dirname(files[0]).split('/');
        var vp = cp.length;
        for (int i = 1; i < files.length; i++) {
          var tp = dirname(files[i]).split('/');
          for (int i = 0; i < vp; i++) {
            if (cp[i] != tp[i]) {
              vp = i;
              break;
            }
          }
        }
        var pp = cp.take(vp).join('/');
        result['Path'] = pp;
        widget.item.result = result;
        await widget.item.update();

        // Download
        var _timer =
            new Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
          setState(() {
            if (downloadSec / 1024 < 500.0)
              downloadSpeed = (downloadSec / 1024).toStringAsFixed(1) + " KB/S";
            else
              downloadSpeed =
                  (downloadSec / 1024 / 1024).toStringAsFixed(1) + " MB/S";
            downloadSec = 0;
          });
        });

        await downloader.addTasks(tasks.map((e) {
          e.downloadPath = join(
              Settings.downloadBasePath,
              e.format.formatting(desc.useCustomPath()
                  ? desc.customPath()
                  : desc.onlyOneFolder()
                      ? extractor.saveOneFormat()
                      : extractor.defaultFormat()));

          e.startCallback = () {};
          e.completeCallback = () {
            downloadedFileCount++;
          };

          e.sizeCallback = (byte) {};
          e.downloadCallback = (byte) {
            download += byte;
            downloadSec += byte;
          };

          e.errorCallback = (err) {
            downloadedFileCount++;
            errorFileCount++;
          };

          return e;
        }).toList());
        downloadTotalFileCount = tasks.length;
        result['State'] = 3;
        widget.item.result = result;
        await widget.item.update();
        setState(() {});

        // Wait for download complete
        while (downloadTotalFileCount != downloadedFileCount) {
          await Future.delayed(Duration(milliseconds: 500));
        }
        _timer.cancel();

        await SlotManager.getInstance().returnDownload();

        Logger.info('[Community Download Task] [' +
            widget.item.id().toString() +
            '] Download complete');

        // Postprocess
        // Postprocess
        var ppTasks = tasks.where((e) => e.postprocessorTask != null).toList();
        if (ppTasks.length > 0) {
          downloadTotalFileCount = tasks.length;
          result['State'] = 12;
          widget.item.result = result;
          await widget.item.update();
          setState(() {});

          postprocessTotalFileCount = ppTasks.length;

          var fnChange = Map<String, String>();

          await PostprocessorManager.getInstance().appendTasks(ppTasks.map((e) {
            e.postprocessorTask.startPostprocessor = (i) async {};
            e.postprocessorTask.endPostprocessor = (i) async {
              setState(() {
                postprocessFileCount++;
              });
            };
            e.postprocessorTask.filenameCallback = (fn) async {
              fnChange[e.downloadPath] = fn;
            };
            return e.postprocessorTask;
          }).toList());
          while (postprocessTotalFileCount != postprocessFileCount) {
            await Future.delayed(Duration(milliseconds: 500));
          }

          for (int i = 0; i < files.length; i++) {
            if (fnChange.containsKey(files[i])) {
              files[i] = fnChange[files[i]];
            }
          }
          result['Files'] = jsonEncode(files);
        }

        // Complete!
        result['State'] = 0;
        widget.item.result = result;
        await widget.item.update();
        setState(() {});
        Logger.info('[Community Download Task] [' +
            widget.item.id().toString() +
            '] Complete');
      },
    ).catchError((e, stacktrace) {
      Logger.error('[Community Download Task] [' +
          widget.item.id().toString() +
          '] MSG:' +
          e.toString() +
          '\n' +
          stacktrace.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    double ww = widget.width - 16;
    double hh = 130.0;

    return GestureDetector(
      child: SizedBox(
        width: ww,
        height: hh,
        child: AnimatedContainer(
          // alignment: FractionalOffset.center,
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 300),
          // padding: EdgeInsets.all(pad),
          transform: Matrix4.identity()
            ..translate(ww / 2, hh / 2)
            ..scale(scale)
            ..translate(-ww / 2, -hh / 2),
          child: buildBody(),
        ),
      ),
      onLongPress: () async {
        setState(() {
          scale = 1.0;
        });

        var v = await showDialog(
          context: context,
          child: DownloadItemMenu(),
        );

        if (v == -1) {
          await widget.item.delete();
          widget.refeshCallback();
        } else if (v == 3) {
          if (await canLaunch(widget.item.url())) {
            await launch(widget.item.url());
          }
        } else if (v == 2) {
          Clipboard.setData(new ClipboardData(text: widget.item.url()));
          FlutterToast(context).showToast(
            child: ToastWrapper(
              isCheck: true,
              isWarning: false,
              msg: 'URL이 복사되었습니다!',
            ),
            gravity: ToastGravity.BOTTOM,
            toastDuration: Duration(seconds: 4),
          );
        } else if (v == 1) {
          if (widget.item.option() == null) {
            var copy = Map<String, dynamic>.from(widget.item.result);
            copy['State'] = 1;
            widget.item.result = copy;
            await widget.item.update();
            once = false;
            widget.download = true;
            _downloadProcedure();
          } else {
            var result = await Navigator.push(
              this.context,
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, __, ___) => TaskCreatePage(
                  url: widget.item.url(),
                  downloadable: ExtractorManager.instance.getCommunityExtractor(
                    widget.item.url(),
                  ),
                  request: TaskRequestDescription(
                    map: jsonDecode(
                      widget.item.option(),
                    ),
                  ),
                ),
              ),
            );

            if (result == null) return;
            var copy = Map<String, dynamic>.from(widget.item.result);
            copy['State'] = 1;
            widget.item.result = copy;
            await widget.item.update();
            once = false;

            copy['Option'] = jsonEncode(result.result);
            widget.item.result = copy;
            await widget.item.update();

            widget.job = true;
            _taskProcedure();
          }
          setState(() {});
        }
      },
      onTap: () {
        if (widget.item.state() == 0 && widget.item.files() != null) {
          var gi = GalleryItem.fromDonwloadItem(widget.item);

          if (gi.length != 0) {
            Navigator.of(context).push(PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 500),
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
              pageBuilder: (_, __, ___) =>
                  GalleryPage(item: gi, model: widget.item),
            ));
          }
        }
      },
      onTapDown: (details) {
        setState(() {
          scale = 0.95;
        });
      },
      onTapUp: (details) {
        setState(() {
          scale = 1.0;
        });
      },
      onTapCancel: () {
        setState(() {
          scale = 1.0;
        });
      },
    );
  }

  Widget buildBody() {
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Settings.themeWhat ? Colors.grey.shade800 : Colors.white70,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        boxShadow: [
          BoxShadow(
            color: Settings.themeWhat
                ? Colors.grey.withOpacity(0.08)
                : Colors.grey.withOpacity(0.4),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          buildThumbnail(),
          Expanded(
            child: buildDetail(),
          ),
        ],
      ),
    );
  }

  Widget buildThumbnail() {
    return Visibility(
      visible: widget.item.thumbnail() != null,
      child: _ThumbnailWidget(
        thumbnail: widget.item.thumbnail(),
        thumbnailTag:
            (widget.item.thumbnail() == null ? '' : widget.item.thumbnail()) +
                widget.item.dateTime().toString(),
        thumbnailHeader: widget.item.thumbnailHeader(),
      ),
    );
  }

  Widget buildDetail() {
    var title = widget.item.url();

    if (widget.item.info() != null) {
      title = widget.item.info();
    }

    var state = 'None';
    var pp =
        '${Translations.instance.trans('date')}: ' + widget.item.dateTime();

    var statecolor = !Settings.themeWhat ? Colors.black : Colors.white;
    var statebold = FontWeight.normal;

    switch (widget.item.state()) {
      case 0:
        state = Translations.instance.trans('complete');
        break;
      case 1:
        state = Translations.instance.trans('waitqueue');
        pp = Translations.instance.trans('progress') +
            ': ' +
            Translations.instance.trans('waitdownload');
        break;
      case 2:
        if (widget.item.option() == null) {
          if (max == 0) {
            state = Translations.instance.trans('extracting');
            pp = Translations.instance.trans('progress') +
                ': ' +
                Translations.instance
                    .trans('count')
                    .replaceAll('%s', cur.toString());
          } else {
            state = Translations.instance.trans('extracting') + '[$cur/$max]';
            pp = Translations.instance.trans('progress') + ': ';
          }
        } else {
          state = statusMessage;
          pp = '';
        }
        break;

      case 3:
        // state =
        //     '[$downloadedFileCount/$downloadTotalFileCount] ($downloadSpeed ${(download / 1024.0 / 1024.0).toStringAsFixed(1)} MB)';
        if (!youtubeDLMode)
          state = '[$downloadedFileCount/$downloadTotalFileCount]';
        else
          state = downloadPercent.toString() + "%";
        pp = Translations.instance.trans('progress') + ': ';
        break;

      case 6:
        state = Translations.instance.trans('stop');
        pp = '';
        statecolor = Colors.orange;
        // statebold = FontWeight.bold;
        break;
      case 7:
        state = Translations.instance.trans('unknownerr');
        pp = '';
        statecolor = Colors.red;
        // statebold = FontWeight.bold;
        break;
      case 8:
        state = Translations.instance.trans('urlnotsupport');
        pp = '';
        statecolor = Colors.redAccent;
        // statebold = FontWeight.bold;
        break;
      case 9:
        state = Translations.instance.trans('tryagainlogin');
        pp = '';
        statecolor = Colors.redAccent;
        // statebold = FontWeight.bold;
        break;
      case 11:
        state = Translations.instance.trans('nothingtodownload');
        pp = '';
        statecolor = Colors.orangeAccent;
        // statebold = FontWeight.bold;
        break;

      case 12:
        state = '후처리 작업중...[$postprocessFileCount/$postprocessTotalFileCount]';
        pp = Translations.instance.trans('progress') + ': ';
        break;
    }

    return AnimatedContainer(
      margin: EdgeInsets.fromLTRB(8, 4, 4, 4),
      duration: Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          //
          //  Title
          //
          Text(Translations.instance.trans('dinfo') + ': ' + title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          Container(
            height: 2,
          ),
          //
          //  State
          //
          Text(Translations.instance.trans('state') + ': ' + state,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 15, color: statecolor, fontWeight: statebold)),
          Container(
            height: 2,
          ),
          //
          //  Progress
          //
          (widget.item.state() != 3 && widget.item.state() != 12)
              //
              //  Extracting
              //
              ? Text(pp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15))
              //
              //  Download
              //
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(pp,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15)),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: LinearProgressIndicator(
                          value: widget.item.state() == 12
                              ? postprocessFileCount / postprocessTotalFileCount
                              : youtubeDLMode
                                  ? downloadPercent / 100.0
                                  : downloadedFileCount /
                                      downloadTotalFileCount,
                          minHeight: 18,
                        ),
                      ),
                    ),
                  ],
                ),
          //
          //  Favicon, File Count, Size
          //
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 4),
                      child: Settings.enableFavicon
                          ? fav != '' && fav != null
                              ? CachedNetworkImage(
                                  imageUrl: fav,
                                  width: 25,
                                  height: 25,
                                  fadeInDuration: Duration(microseconds: 500),
                                  fadeInCurve: Curves.easeIn)
                              : Container()
                          : Text(name + ' 추출기'),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFavicon(String host) {
    switch (host) {
      case 'youtube.com':
        return 'https://s.ytimg.com/yts/img/favicon_144-vfliLAfaB.png';
    }

    return 'https://' + host + '/favicon.ico';
  }
}

class _ThumbnailWidget extends StatelessWidget {
  final String thumbnail;
  final String thumbnailHeader;
  final String thumbnailTag;

  _ThumbnailWidget({
    this.thumbnail,
    this.thumbnailHeader,
    this.thumbnailTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: thumbnail != null
          ? ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(5.0)),
              child: _thumbnailImage(),
            )
          : FlareActor(
              "assets/flare/Loading2.flr",
              alignment: Alignment.center,
              fit: BoxFit.fitHeight,
              animation: "Alarm",
            ),
    );
  }

  Widget _thumbnailImage() {
    Map<String, String> headers = {};
    if (thumbnailHeader != null) {
      var hh = jsonDecode(thumbnailHeader) as Map<String, dynamic>;
      hh.entries.forEach((element) {
        headers[element.key] = element.value as String;
      });
    }
    return Hero(
      tag: thumbnailTag,
      child: CachedNetworkImage(
        imageUrl: thumbnail,
        fit: BoxFit.cover,
        httpHeaders: headers,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
          child: Container(),
        ),
        placeholder: (b, c) {
          return FlareActor(
            "assets/flare/Loading2.flr",
            alignment: Alignment.center,
            fit: BoxFit.fitHeight,
            animation: "Alarm",
          );
        },
      ),
    );
  }
}
