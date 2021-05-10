// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communitydownloader/settings/settings.dart';
import 'package:flutter/material.dart';

class LeftSidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    var windowWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Settings.themeWhat
          ? Colors.grey.shade900.withOpacity(0.4)
          : Colors.grey.shade200.withOpacity(0.4),
      child: Padding(
        padding: EdgeInsets.only(left: windowWidth - 60, top: statusBarHeight),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              // Text('asdf'),
              // _IconButton(
              //     img: 'https://gall.dcinside.com/favicon.ico', scale: 0.8),
              // _IconButton(
              //     img: 'http://web.humoruniv.com/favicon.ico', scale: 0.8),
              // _IconButton(img: 'http://www.inven.co.kr/favicon.ico', scale: 0.5),
              // _IconButton(
              //     img:
              //         'https://img.ruliweb.com/img/2016/icon/ruliweb_icon_144_144.png',
              //     scale: 1.8),
              // _IconButton(
              //     img: 'https://image.fmkorea.com/touchicon/logo180.png',
              //     scale: 1.8),
              // _IconButton(
              //     img: 'http://mlbpark.donga.com/favicon.ico', scale: 1.0),
              // _IconButton(
              //     img: 'https://static.instiz.net/favicon.ico?1907071',
              //     scale: 1.0),
              // _IconButton(
              //     img: 'http://www.todayhumor.co.kr/favicon.ico', scale: 1.0),
              // _IconButton(
              //     img: 'https://www.clien.net/service/image/icon180x180.png',
              //     scale: 1.8),
              // _IconButton(
              //     img: 'https://arca.live/static/apple-icon.png', scale: 1.8),
              // _IconButton(
              //     img: 'http://www.etoland.co.kr/img/etoland.png', scale: 1.8),
              // _IconButton(img: 'https://hygall.com/favicon.ico', scale: 1.8),
              // _IconButton(
              //     img:
              //         'https://image.bobaedream.co.kr/renew2017/assets/images/favicon.ico',
              //     scale: 1.0),
              // _IconButton(img: 'https://www.82cook.com/favicon.ico', scale: 1.0),
              // _IconButton(
              //     img: 'https://pann.nate.com/favicon.ico?m=3.0.11', scale: 1.0),

              _IconButton('https://gall.dcinside.com/favicon.ico'),

              _IconButton('http://web.humoruniv.com/favicon.ico'),
              _IconButton('http://www.inven.co.kr/favicon.ico'),
              _IconButton(
                  'https://img.ruliweb.com/img/2016/icon/ruliweb_icon_144_144.png'),
              _IconButton('https://image.fmkorea.com/touchicon/logo180.png'),
              _IconButton('http://mlbpark.donga.com/favicon.ico'),
              _IconButton('https://static.instiz.net/favicon.ico?1907071'),
              _IconButton('http://www.todayhumor.co.kr/favicon.ico'),
              _IconButton(
                  'https://www.clien.net/service/image/icon180x180.png'),
              _IconButton('https://arca.live/static/apple-icon.png'),
              _IconButton('http://www.etoland.co.kr/img/etoland.png'),
              _IconButton('https://hygall.com/favicon.ico'),
              _IconButton(
                  'https://image.bobaedream.co.kr/renew2017/assets/images/favicon.ico'),
              _IconButton('https://www.82cook.com/favicon.ico'),
              _IconButton('https://pann.nate.com/favicon.ico?m=3.0.11'),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatefulWidget {
  final String img;

  _IconButton(this.img);

  @override
  __IconButtonState createState() => __IconButtonState();
}

class __IconButtonState extends State<_IconButton>
    with TickerProviderStateMixin {
  AnimationController scaleAnimationController;
  double scale = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    scaleAnimationController = AnimationController(
      vsync: this,
      lowerBound: 1.0,
      upperBound: 1.08,
      duration: Duration(milliseconds: 180),
    );
    scaleAnimationController.addListener(() {
      setState(() {
        scale = scaleAnimationController.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: GestureDetector(
        child: SizedBox(
          // width: 50,
          // height: 50,
          child: AnimatedContainer(
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: 150),
            transform: Matrix4.identity()
              ..translate(50 / 2, 50 / 2)
              ..scale(scale)
              ..translate(-50 / 2, -50 / 2),
            child: Image.network(
              widget.img,
              width: 35,
              height: 35,
              fit: BoxFit.fill,
              // scale: widget.scale,
            ),
          ),
        ),
        onTapDown: (details) => setState(() {
          scale = 0.90;
        }),
        onTapUp: (details) => setState(() {
          scale = 1.0;
        }),
        onTapCancel: () => setState(() {
          scale = 1.0;
        }),
      ),
    );
  }
}
