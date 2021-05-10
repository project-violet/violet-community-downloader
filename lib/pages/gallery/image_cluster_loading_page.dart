// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communitydownloader/pages/gallery/image_cluster.dart';
import 'package:flutter/material.dart';
import 'package:communitydownloader/settings/settings.dart';

class ImageClusterLoadingPage extends StatefulWidget {
  final List<String> paths;

  ImageClusterLoadingPage({this.paths});

  @override
  _ImageClusterLoadingPageState createState() =>
      _ImageClusterLoadingPageState();
}

class _ImageClusterLoadingPageState extends State<ImageClusterLoadingPage> {
  int succ = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(milliseconds: 100)).then((value) async {
      for (int i = 0; i < widget.paths.length; i++) {
        await ImageCluster.append(widget.paths[i]);
        setState(() => succ += 1);
      }

      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Card(
              color:
                  Settings.themeWhat ? Color(0xFF353535) : Colors.grey.shade100,
              elevation: 100,
              child: SizedBox(
                child: SizedBox(
                  width: 280,
                  height: (56 * 4 + 16).toDouble(),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Stack(
                      children: [
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 33),
                            child: Text(
                              '해싱중',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 15),
                            child: Text(
                              '[$succ/${widget.paths.length}]',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(1)),
          boxShadow: [
            BoxShadow(
              color: Settings.themeWhat
                  ? Colors.black.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
      ),
    );
  }
}
