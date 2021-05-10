// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communitydownloader/other/dialogs.dart';
import 'package:communitydownloader/settings/settings.dart';
import 'package:communitydownloader/widgets/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LaboratoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('LABORATORY'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Use Own FFmpeg Binary'),
            subtitle: Text('arm64-v8a is only supported.'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () async {
              // const url = 'https://docs.python.org/3/license.html';
              // if (await canLaunch(url)) {
              //   await launch(url);
              // }
              await Dialogs.okDialog(context,
                  'This binary is not supported. Contact developers for details.');
            },
            onLongPress: () async {
              await Dialogs.okDialog(
                  context,
                  'The FFmpeg included in this app has been removed from the under GPL license'
                  ' non-free, and not needed code in this app.');
            },
          ),
          Container(
            width: double.infinity,
            height: 0.5,
            color: Settings.themeWhat
                ? Colors.grey.shade600
                : Colors.grey.shade400,
          ),
          ListTile(
            title: Text('Use youtube-dl with command line'),
            // subtitle: Text(''),
            trailing: Icon(MdiIcons.console),
            onTap: () async {
              // const url = 'https://docs.python.org/3/license.html';
              // if (await canLaunch(url)) {
              //   await launch(url);
              // }
            },
          ),
          Container(
            width: double.infinity,
            height: 0.5,
            color: Settings.themeWhat
                ? Colors.grey.shade600
                : Colors.grey.shade400,
          ),
          ListTile(
            title: Text('Enable favicon'),
            subtitle: Text('Favicon is disabled, cuz trademark violation'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () async {
              await Settings.setEnableFavicon(true);
              FlutterToast(context).showToast(
                child: ToastWrapper(
                  isCheck: true,
                  msg: 'Favicon Enabled!',
                ),
                gravity: ToastGravity.BOTTOM,
                toastDuration: Duration(seconds: 4),
              );
            },
          ),
          Container(
            width: double.infinity,
            height: 0.5,
            color: Settings.themeWhat
                ? Colors.grey.shade600
                : Colors.grey.shade400,
          ),
          ListTile(
            title: Text('Set Concurrent Download Task Size'),
            subtitle: Text('Default: 3'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () async {
              // const url = 'https://docs.python.org/3/license.html';
              // if (await canLaunch(url)) {
              //   await launch(url);
              // }
            },
          ),
          Container(
            width: double.infinity,
            height: 0.5,
            color: Settings.themeWhat
                ? Colors.grey.shade600
                : Colors.grey.shade400,
          ),
          ListTile(
            title: Text('Import Downloader (only python)'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () async {
              // const url = 'https://docs.python.org/3/license.html';
              // if (await canLaunch(url)) {
              //   await launch(url);
              // }
              await Dialogs.okDialog(
                  context, 'We are preparing to provide this features.');
            },
          ),
          Container(
            width: double.infinity,
            height: 0.5,
            color: Settings.themeWhat
                ? Colors.grey.shade600
                : Colors.grey.shade400,
          ),
          ListTile(
            title: Text('Use Custom Font'),
            subtitle: Text('Default font is android roboto'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () async {
              // const url = 'https://docs.python.org/3/license.html';
              // if (await canLaunch(url)) {
              //   await launch(url);
              // }
            },
          ),
          Container(
            width: double.infinity,
            height: 0.5,
            color: Settings.themeWhat
                ? Colors.grey.shade600
                : Colors.grey.shade400,
          ),
          ListTile(
            title: Text('Indeterminate Components'),
            // subtitle: Text('Default font is android roboto'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () async {
              // const url = 'https://docs.python.org/3/license.html';
              // if (await canLaunch(url)) {
              //   await launch(url);
              // }
            },
          ),
          Container(
            height: 50,
          ),
          Text(
            'These features can be removed at any time.',
            style: TextStyle(
              color: Settings.themeWhat ? Colors.white : Colors.black87,
              fontSize: 12.0,
              // fontFamily: "Calibre-Semibold",
              letterSpacing: 1.0,
            ),
          ),
          // Container(
          //   width: double.infinity,
          //   height: 0.5,
          //   color: Settings.themeWhat
          //       ? Colors.grey.shade600
          //       : Colors.grey.shade400,
          // ),
          // ListTile(
          //   title: Text('libViolet License'),
          //   trailing: Icon(Icons.open_in_new),
          //   onTap: () async {
          //     const url =
          //         'https://github.com/ytdl-org/youtube-dl/blob/master/LICENSE';
          //     if (await canLaunch(url)) {
          //       await launch(url);
          //     }
          //   },
          // ),
        ],
      ),
    );
  }
}
