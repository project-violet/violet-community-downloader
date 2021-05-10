// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communitydownloader/component/external/youtude-dl.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:communitydownloader/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitPage extends StatefulWidget {
  @override
  _InitPageState createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  String file = '';
  String progress = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(milliseconds: 100)).then((value) async {
      await YoutubeDL.init((file, progress) {
        setState(() {
          this.file = file;
          this.progress = progress.toStringAsFixed(1);
        });
      });

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
                    // child: Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: <Widget>[
                    //     CircularProgressIndicator(),
                    //     Expanded(
                    //       child: Container(child: Text('초기화 중...')),
                    //     )
                    //   ],
                    // ),
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
                              '초기화 중',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 15),
                            child: Text(
                              '잠시만 기다려주세요...',
                            ),
                          ),
                        ),
                        // Align(
                        //   alignment: Alignment.bottomCenter,
                        //   child: Padding(
                        //     padding:
                        //         EdgeInsets.only(bottom: 33, left: 8, right: 8),
                        //     child: Text(
                        //       file,
                        //       overflow: TextOverflow.ellipsis,
                        //       maxLines: 1,
                        //     ),
                        //   ),
                        // ),
                        // Align(
                        //   alignment: Alignment.bottomCenter,
                        //   child: Padding(
                        //     padding: EdgeInsets.only(bottom: 15),
                        //     child: Text(
                        //       progress + ' %',
                        //       overflow: TextOverflow.ellipsis,
                        //       maxLines: 1,
                        //     ),
                        //   ),
                        // ),
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
