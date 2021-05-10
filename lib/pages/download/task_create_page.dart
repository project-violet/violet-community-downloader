// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:communitydownloader/component/downloadable.dart';
import 'package:communitydownloader/locale/locale.dart';
import 'package:communitydownloader/network/wrapper.dart';
import 'package:communitydownloader/other/dialogs.dart';
import 'package:communitydownloader/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TaskCreatePage extends StatefulWidget {
  final Downloadable downloadable;
  final String url;
  final TaskRequestDescription request;

  TaskCreatePage({this.downloadable, this.url, this.request});

  @override
  _TaskCreatePageState createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends State<TaskCreatePage> {
  int maxPage = -1;
  String extractor = '';
  String board = '';
  bool supportBestArticles = false;
  String bestArticlesName = '';
  bool supportClass = false;
  bool supportId = true;
  List<String> classes;
  String fav = '';

  String url;
  bool useFilter = false;
  bool endPageValue = false;
  bool usePage = true;
  bool onlyBest = false;
  bool useClass = false;
  bool onlyOneFolder = true;
  bool useCustomPath = false;
  String selectedClass;

  TextEditingController pageStarts = TextEditingController(text: '1');
  TextEditingController pageEnds = TextEditingController(text: '');
  TextEditingController idStarts = TextEditingController(text: '1');
  TextEditingController idEnds = TextEditingController(text: '');
  TextEditingController filtering = TextEditingController(text: '');
  TextEditingController customPath = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100)).then((value) async {
      var desc = widget.downloadable.communityTaskDesc();
      extractor = widget.downloadable.communityName();
      supportBestArticles = desc.supportBestArticles();
      bestArticlesName = desc.bestArticlesName();
      fav = widget.downloadable.fav();
      supportId = desc.supportId();
      setState(() {});

      url = await desc.tidyUrl(widget.url);
      var html = (await HttpWrapper.getr(url, headers: {
        'User-Agent': HttpWrapper.userAgent,
        'Accept': HttpWrapper.accept,
      }))
          .body;

      maxPage = await desc.getMaxPage(html);
      board = await desc.getBoardName(html);
      supportClass = await desc.supportClass(html);
      if (supportClass) {
        classes = await desc.getClasses(html);
        selectedClass = classes[0];
      }
      customPath.text = widget.downloadable.defaultFormat();
      setState(() {});

      if (widget.request != null) {
        this.url = url;
        useFilter = widget.request.useFilter();
        endPageValue = widget.request.endPageValue();
        usePage = widget.request.usePage();
        onlyBest = widget.request.onlyBest();
        useClass = widget.request.useClass();
        onlyOneFolder = widget.request.onlyOneFolder();
        selectedClass = widget.request.selectedClass();
        if (onlyOneFolder == null) onlyOneFolder = true;
        useCustomPath = widget.request.useCustomPath();
        if (useCustomPath == null) useCustomPath = false;

        pageStarts.text = widget.request.startPage().toString();
        if (pageStarts.text == 'null') pageStarts.text = '1';
        pageEnds.text = widget.request.endPage().toString();
        if (pageEnds.text == 'null') pageEnds.text = '';
        idStarts.text = widget.request.startId().toString();
        if (idStarts.text == 'null') idStarts.text = '1';
        idEnds.text = widget.request.endId().toString();
        if (idEnds.text == 'null') idEnds.text = '';
        filtering.text = widget.request.filter();
        if (widget.request.customPath() != null)
          customPath.text = widget.request.customPath();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var windowWidth = MediaQuery.of(context).size.width;
    var windowheight = MediaQuery.of(context).size.height;

    var column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {},
          child: Card(
            color:
                Settings.themeWhat ? Color(0xFF353535) : Colors.grey.shade100,
            elevation: 100,
            child: Column(
              children: [
                SizedBox(
                  width: windowWidth - 80,
                  // height: (56 * 6 + 16).toDouble(),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        _head(),
                        Container(
                          height: 8,
                        ),
                        _pageArea(),
                        supportId ? _idArea() : Container(),
                        supportId ? _selectArea() : Container(),
                        useClass ? _classArea() : Container(),
                        useFilter
                            ? Padding(
                                child: _filterArea(),
                                padding: EdgeInsets.only(
                                  bottom: 8,
                                ),
                              )
                            : Container(),
                        useCustomPath ? _customPathArea() : Container(),
                        supportBestArticles ? _bestArea() : Container(),
                        supportClass ? _classEnableArea() : Container(),
                        _checkFilterArea(),
                        _checkSaveOneFolderArea(),
                        _checkDownloadPathArea(),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: _buttonArea(),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (windowWidth > windowheight) {
      return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          child: SingleChildScrollView(child: column),
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
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        child: column,
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

  _head() {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Settings.enableFavicon
              ? CachedNetworkImage(
                  width: 60,
                  height: 60,
                  imageUrl: fav,
                )
              : Container(),
          Container(
            width: 8,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  extractor + ' 작업도구',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  board,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _pageArea() {
    return Row(
      children: [
        Text(
          '페이지: ',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(
          width: 50,
          height: 30,
          child: TextField(
            controller: pageStarts,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            cursorColor: Settings.majorColor,
            decoration: new InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Settings.majorColor, width: 2.0),
              ),
            ),
            enabled: usePage,
          ),
        ),
        Text(
          ' ~ ',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(
          width: 50,
          height: 30,
          child: TextField(
            controller: pageEnds,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            enabled: !endPageValue && usePage,
            cursorColor: Settings.majorColor,
            decoration: new InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Settings.majorColor, width: 2.0),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: usePage
              ? () {
                  setState(() {
                    endPageValue = !endPageValue;
                  });
                }
              : null,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: endPageValue,
                  onChanged: (value) {
                    if (!usePage) return;
                    setState(() {
                      endPageValue = !endPageValue;
                    });
                  },
                  activeColor: Settings.majorColor,
                ),
                Text('끝까지'),
                Container(
                  width: 10,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  _idArea() {
    return Row(
      children: [
        Text(
          '글번호: ',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(
          width: 80,
          height: 30,
          child: TextField(
            controller: idStarts,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            cursorColor: Settings.majorColor,
            decoration: new InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Settings.majorColor, width: 2.0),
              ),
            ),
            enabled: !usePage,
          ),
        ),
        Text(
          ' ~ ',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(
          width: 80,
          height: 30,
          child: TextField(
            controller: idEnds,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            enabled: !usePage,
            cursorColor: Settings.majorColor,
            decoration: new InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Settings.majorColor, width: 2.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _selectArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              usePage = true;
            });
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Radio(
                  groupValue: true,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: usePage,
                  onChanged: (value) {
                    setState(() {
                      usePage = value;
                    });
                  },
                  activeColor: Settings.majorColor,
                ),
                Text('페이지 사용'),
                Container(
                  width: 10,
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              usePage = false;
            });
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Radio(
                  groupValue: true,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: !usePage,
                  onChanged: (value) {
                    setState(() {
                      usePage = !value;
                    });
                  },
                  activeColor: Settings.majorColor,
                ),
                Text('글번호 사용'),
                Container(
                  width: 10,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  _bestArea() {
    return InkWell(
      onTap: () {
        setState(() {
          onlyBest = !onlyBest;
        });
      },
      child: Container(
        height: 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: onlyBest,
              onChanged: (value) {
                setState(() {
                  onlyBest = value;
                });
              },
              activeColor: Settings.majorColor,
            ),
            Text(bestArticlesName + ' 수집'),
            Container(
              width: 10,
            )
          ],
        ),
      ),
    );
  }

  _classEnableArea() {
    return InkWell(
      onTap: () {
        setState(() {
          useClass = !useClass;
        });
      },
      child: Container(
        height: 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: useClass,
              onChanged: (value) {
                setState(() {
                  useClass = value;
                });
              },
              activeColor: Settings.majorColor,
            ),
            Text('클래스/말머리/카테고리 사용'),
            Container(
              width: 10,
            )
          ],
        ),
      ),
    );
  }

  _classArea() {
    return Row(
      children: [
        Text(
          '클래스: ',
          style: TextStyle(fontSize: 18),
        ),
        DropdownButton(
          value: selectedClass,
          items: classes
              .map(
                (e) => DropdownMenuItem(
                  child: Text(e.split('|').first.trim()),
                  value: e,
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedClass = value;
            });
          },
        )
      ],
    );
  }

  _checkFilterArea() {
    return InkWell(
      onTap: () {
        setState(() {
          useFilter = !useFilter;
        });
      },
      child: Container(
        height: 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: useFilter,
              onChanged: (value) {
                setState(() {
                  useFilter = value;
                });
              },
              activeColor: Settings.majorColor,
            ),
            Text('필터링 사용'),
            Container(
              width: 10,
            )
          ],
        ),
      ),
    );
  }

  _checkSaveOneFolderArea() {
    return InkWell(
      onTap: () {
        setState(() {
          onlyOneFolder = !onlyOneFolder;
          if (onlyOneFolder)
            customPath.text = widget.downloadable.saveOneFormat();
          else
            customPath.text = widget.downloadable.defaultFormat();
        });
      },
      child: Container(
        height: 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: onlyOneFolder,
              onChanged: (value) {
                setState(() {
                  onlyOneFolder = value;
                  if (onlyOneFolder)
                    customPath.text = widget.downloadable.saveOneFormat();
                  else
                    customPath.text = widget.downloadable.defaultFormat();
                });
              },
              activeColor: Settings.majorColor,
            ),
            Text('하나의 폴더에 모두 다운로드'),
            Container(
              width: 10,
            )
          ],
        ),
      ),
    );
  }

  _filterArea() {
    return Row(
      children: [
        Text(
          '필터링: ',
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 0),
            child: SizedBox(
              height: 34,
              child: TextField(
                controller: filtering,
                cursorColor: Settings.majorColor,
                decoration: new InputDecoration(
                  isDense: true,
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Settings.majorColor, width: 2.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 34,
          child: RawMaterialButton(
            constraints: BoxConstraints(),
            child: Center(
              child: Icon(MdiIcons.informationOutline,
                  color: Colors.grey.shade600),
            ),
            padding: EdgeInsets.all(4),
            shape: CircleBorder(),
            onPressed: () async {
              Widget okButton = FlatButton(
                child: Text(Translations.of(context).trans('ok'),
                    style: TextStyle(color: Settings.majorColor)),
                focusColor: Settings.majorColor,
                splashColor: Settings.majorColor.withOpacity(0.3),
                onPressed: () {
                  Navigator.pop(context, "OK");
                },
              );
              AlertDialog alert = AlertDialog(
                title: Text('작업 필터링'),
                content: Text(
                  '단어기반으로 해당 단어가 제목에 포함되어있는지의 여부로 필터링합니다.\n' +
                      '단어들은 띄어쓰기로 구분합니다.\n' +
                      '단어 앞에 -를 붙이면 해당 단어가 포함되지 않음을 의미합니다.',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  okButton,
                ],
              );
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
            },
          ),
        ),
      ],
    );
  }

  _checkDownloadPathArea() {
    return InkWell(
      onTap: () {
        setState(() {
          useCustomPath = !useCustomPath;
        });
      },
      child: Container(
        height: 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: useCustomPath,
              onChanged: (value) {
                setState(() {
                  useCustomPath = value;
                });
              },
              activeColor: Settings.majorColor,
            ),
            Text('다운로드경로 직접 설정'),
            Container(
              width: 10,
            )
          ],
        ),
      ),
    );
  }

  _customPathArea() {
    return Row(
      children: [
        Text(
          '경로: ',
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 0),
            child: SizedBox(
              height: 68,
              child: TextField(
                controller: customPath,
                cursorColor: Settings.majorColor,
                maxLines: 2,
                decoration: new InputDecoration(
                  isDense: true,
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Settings.majorColor, width: 2.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 68,
          child: RawMaterialButton(
            constraints: BoxConstraints(),
            child: Center(
              child: Icon(MdiIcons.informationOutline,
                  color: Colors.grey.shade600),
            ),
            padding: EdgeInsets.all(4),
            shape: CircleBorder(),
            onPressed: () async {
              Widget okButton = FlatButton(
                child: Text(Translations.of(context).trans('ok'),
                    style: TextStyle(color: Settings.majorColor)),
                focusColor: Settings.majorColor,
                splashColor: Settings.majorColor.withOpacity(0.3),
                onPressed: () {
                  Navigator.pop(context, "OK");
                },
              );
              AlertDialog alert = AlertDialog(
                title: Text('다운로드 경로 설정'),
                content: Text(
                  '최상위 경로의 하위 경로의 규칙입니다.\n' +
                      '경로의 각 요소는 토큰으로 구성됩니다.\n여기서 토큰은 %(a)b와 같은 형식을 말합니다.\n' +
                      '제공되는 토큰은 각 추출기마다 다릅니다.\n' +
                      'a위치는 토큰의 이름이며, b는 토큰의 포맷입니다.\n' +
                      '현재 포맷은 (s)tring 포맷 하나만 제공 중입니다.\n' +
                      '또한 "하나의 폴더에 모두 다운로드"를 체크한 경우 %(file)s 토큰의 형식이 달라지니 참고해주세요.\n' +
                      '최상위 경로는 설정=>최상위 경로 설정에서 설정해주세요.\n',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  okButton,
                ],
              );
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
            },
          ),
        ),
      ],
    );
  }

  _buttonArea() {
    return Transform.translate(
      offset: Offset(0, -6),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: FlatButton(
                child: Text('시작', style: TextStyle(color: Settings.majorColor)),
                // color: Settings.majorColor,
                focusColor: Settings.majorColor,
                splashColor: Settings.majorColor.withOpacity(0.3),
                onPressed: () async {
                  var warning = await Dialogs.yesnoDialog(
                      context,
                      '이 작업은 굉장히 오래 걸릴 수 있으며, 해당 웹서버에 무리를 줄 수 있습니다.\n' +
                          '과도한 사용시에 발생할 수 있는 문제(접속차단 등)에 대해선 본 개발자는 책임지지 않습니다.\n' +
                          '계속하시겠습니까?',
                      '경고');

                  if (warning != null && warning) {
                    // Make RequestTask
                    var rt = TaskRequestDescription(
                      baseURL: widget.url,
                      onlyBest: onlyBest,
                      useClass: useClass,
                      selectedClass: selectedClass,
                      url: url,
                      endPageValue: endPageValue,
                      startPage: int.tryParse(pageStarts.text),
                      endPage: int.tryParse(pageEnds.text),
                      startId: int.tryParse(idStarts.text),
                      endId: int.tryParse(idEnds.text),
                      useFilter: useFilter,
                      filter: filtering.text,
                      usePage: usePage,
                      onlyOneFolder: onlyOneFolder,
                      useCustomPath: useCustomPath,
                      customPath: customPath.text,
                    );

                    Navigator.pop(context, rt);
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: FlatButton(
                child: Text('취소', style: TextStyle(color: Settings.majorColor)),
                // color: Settings.majorColor,
                focusColor: Settings.majorColor,
                splashColor: Settings.majorColor.withOpacity(0.3),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
