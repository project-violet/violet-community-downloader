// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:io';

import 'package:communitydownloader/database/user/download.dart';
import 'package:communitydownloader/pages/download/inner_drawer.dart';
import 'package:communitydownloader/pages/download/leftside_page.dart';
import 'package:communitydownloader/pages/gallery/animated_opacity_sliver.dart';
import 'package:communitydownloader/pages/gallery/gallery_item.dart';
import 'package:communitydownloader/pages/gallery/gallery_simple_item.dart';
import 'package:communitydownloader/pages/gallery/image_cluster.dart';
import 'package:communitydownloader/pages/gallery/image_cluster_loading_page.dart';
import 'package:communitydownloader/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mdi/mdi.dart';

class GalleryPage extends StatefulWidget {
  final List<GalleryItem> item;
  final DownloadItemModel model;

  GalleryPage({this.item, this.model});

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  //  Current State of InnerDrawerState
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    var windowWidth = MediaQuery.of(context).size.width;
    return
        // InnerDrawer(
        //   key: _innerDrawerKey,
        //   onTapClose: true, // default false
        //   swipe: true, // default true
        //   colorTransitionChild: Colors.cyan, // default Color.black54
        //   colorTransitionScaffold: Colors.black12, // default Color.black54

        //   //When setting the vertical offset, be sure to use only top or bottom
        //   offset: IDOffset.only(
        //       bottom: 0.00, right: (windowWidth - 60) / windowWidth, left: 1.0),

        //   scale: IDOffset.horizontal(1.0), // set the offset in both directions
        //   // leftOff

        //   proportionalChildArea: false, // default true
        //   borderRadius: 0, // default 0
        //   rightAnimationType: InnerDrawerAnimation.linear, // default static
        //   leftAnimationType: InnerDrawerAnimation.linear,
        //   backgroundDecoration: BoxDecoration(
        //       color: Settings.themeWhat
        //           ? Colors.grey.shade900.withOpacity(0.4)
        //           : Colors.grey.shade200.withOpacity(
        //               0.4)), // default  Theme.of(context).backgroundColor

        //   //when a pointer that is in contact with the screen and moves to the right or left
        //   onDragUpdate: (double val, InnerDrawerDirection direction) {
        //     // return values between 1 and 0
        //     // print(val);
        //     // check if the swipe is to the right or to the left
        //     // print(direction == InnerDrawerDirection.start);
        //     // return direction == InnerDrawerDirection.end;
        //   },

        //   // innerDrawerCallback: (a) =>
        //   //     print(a), // return  true (open) or false (close)
        //   // leftChild: Container(
        //   //   width: 10,
        //   // ), // required if rightChild is not set
        //   rightChild: LeftSidePage(),
        //   leftChild: null,

        //   //  A Scaffold is generally used but you are free to use other widgets
        //   // Note: use "automaticallyImplyLeading: false" if you do not personalize "leading" of Bar
        //   scaffold: Scaffold(
        //     body:
        Container(
      color: Settings.themeWhat ? Color(0xFF353535) : Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        // padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Card(
              elevation: 5,
              color:
                  Settings.themeWhat ? Color(0xFF353535) : Colors.grey.shade100,
              child: SizedBox(
                width: width - 16,
                height: height - 16,
                child: Container(
                  child: CustomScrollView(
                    // controller: _scroll,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPersistentHeader(
                        floating: true,
                        delegate: AnimatedOpacitySliver(
                          minExtent: 64 + 12.0,
                          maxExtent: 64.0 + 12,
                          searchBar: Container(
                            decoration: new BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0)),
                              color: Settings.themeWhat
                                  ? Color(0xFF353535)
                                  : Colors.grey.shade100,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _title()),
                                  _clusteringMode ? Container() : _view(),
                                  _clusteringMode ? Container() : _align(),
                                  // _clustering(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.all(4),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                _clusteringMode ? 4 : properties[viewStyle][0],
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            childAspectRatio: 1,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              if (!_clusteringMode) {
                                return GallerySimpleItem(
                                  item: widget.item[index],
                                  size:
                                      width.toInt() ~/ properties[viewStyle][1],
                                );
                              } else {
                                return GallerySimpleItem(
                                  item: _clusteringItems[index],
                                  size: width.toInt() ~/ 2,
                                );
                              }
                            },
                            childCount: _clusteringMode
                                ? _clusteringItems.length
                                : widget.item.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // ),
      // ),
    );
    // return Container(
    //   child: SliverGrid(
    //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //       crossAxisCount: 4,
    //       crossAxisSpacing: 8,
    //       mainAxisSpacing: 8,
    //       childAspectRatio: 1,
    //     ),
    //     delegate: SliverChildBuilderDelegate(
    //       (BuildContext context, int index) {
    //         return GallerySimpleItem(
    //           item: widget.item[index],
    //         );
    //       },
    //       childCount: widget.item.length,
    //     ),
    //   ),
    // );
  }

  Widget _title() {
    return Padding(
      padding: EdgeInsets.only(top: 24, left: 12),
      child: Text(
        widget.model.info(),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  int viewStyle = 0;
  static const List<IconData> icons = [
    Icons.view_comfy,
    Icons.view_module,
    MdiIcons.viewGrid,
    MdiIcons.cubeUnfolded,
    // MdiIcons.atom,
    // MdiIcons.mine,
  ];
  static const List<dynamic> properties = [
    [4, 2],
    [3, 2],
    [2, 1],
    // [5, 3],
    [6, 4],
  ];
  Widget _view() {
    return Align(
      alignment: Alignment.center,
      child: RawMaterialButton(
        constraints: BoxConstraints(),
        child: Center(
          child: Icon(
            icons[viewStyle],
            size: 28,
          ),
        ),
        padding: EdgeInsets.all(12),
        shape: CircleBorder(),
        onPressed: () async {
          setState(() {
            viewStyle = (viewStyle + 1) % icons.length;
          });
        },
      ),
    );
  }

  int alignStyle = 0;
  static const List<IconData> alignIcons = [
    Mdi.sortClockDescending,
    Mdi.sortClockAscending,
    Mdi.folderUpload,
    Mdi.folderDownload,
  ];
  Widget _align() {
    return Align(
      alignment: Alignment.center,
      child: RawMaterialButton(
        constraints: BoxConstraints(),
        child: Center(
          child: Icon(
            alignIcons[alignStyle],
            size: 28,
          ),
        ),
        padding: EdgeInsets.all(12),
        shape: CircleBorder(),
        onPressed: () async {
          alignStyle = (alignStyle + 1) % icons.length;

          switch (alignStyle) {
            case 0:
              widget.item.sort((x, y) => x.path.compareTo(y.path));
              break;
            case 1:
              widget.item.sort((x, y) => y.path.compareTo(x.path));
              break;
            case 2:
              widget.item.sort((x, y) => File(y.path)
                  .lengthSync()
                  .compareTo(File(x.path).lengthSync()));
              break;
            case 3:
              widget.item.sort((x, y) => File(x.path)
                  .lengthSync()
                  .compareTo(File(y.path).lengthSync()));
              break;
          }

          setState(() {});
        },
      ),
    );
  }

  bool _clusteringMode = false;
  List<GalleryItem> _clusteringItems;
  Widget _clustering() {
    return Align(
      alignment: Alignment.center,
      child: RawMaterialButton(
        constraints: BoxConstraints(),
        child: Center(
          child: Icon(
            Mdi.chemicalWeapon,
            size: 28,
          ),
        ),
        padding: EdgeInsets.all(12),
        shape: CircleBorder(),
        onPressed: () async {
          if (_clusteringMode) {
            setState(() {
              _clusteringMode = false;
            });
            return;
          }

          var targets = widget.item
              .map((e) => e.path)
              .where((element) => ['jpg', 'jpeg', 'webp', 'png', 'bmp']
                  .contains(element.split('.').last))
              .toList();

          await Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => ImageClusterLoadingPage(
                paths: targets,
              ),
            ),
          );

          var result = ImageCluster.doClustering(targets);

          var deref = Map<String, int>();
          for (int i = 0; i < widget.item.length; i++)
            deref[widget.item[i].path] = i;
          _clusteringItems = List<GalleryItem>();

          result.sort((x, y) => y.length.compareTo(x.length));
          result.forEach((element) {
            if (element.length == 1) return;
            for (int i = 0; i < element.length; i++) {
              _clusteringItems.add(widget.item[deref[targets[element[i]]]]);
            }
            for (int i = 0; i < ((4 - element.length) % 4); i++) {
              _clusteringItems.add(null);
            }
          });

          setState(() {
            _clusteringMode = true;
          });
        },
      ),
    );
  }
}
