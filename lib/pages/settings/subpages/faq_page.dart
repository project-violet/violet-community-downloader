// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communitydownloader/settings/settings.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text('FAQ'),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            ExpandableNotifier(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: ScrollOnExpand(
                  child: ExpandablePanel(
                    theme: ExpandableThemeData(
                        iconColor:
                            Settings.themeWhat ? Colors.white : Colors.grey,
                        animationDuration: const Duration(milliseconds: 500)),
                    header: Padding(
                      padding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                      child: Text('다운로드 항목이 없다고 표시됩니다.'),
                    ),
                    expanded: Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Column(
                        children: [
                          Text('앱 오류일 가능성이 높습니다. 해당 링크를 메일로 보내주시면 조치하겠습니다.',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 0.5,
              color: Settings.themeWhat
                  ? Colors.grey.shade600
                  : Colors.grey.shade400,
            ),
            ExpandableNotifier(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: ScrollOnExpand(
                  child: ExpandablePanel(
                    theme: ExpandableThemeData(
                        iconColor:
                            Settings.themeWhat ? Colors.white : Colors.grey,
                        animationDuration: const Duration(milliseconds: 500)),
                    header: Padding(
                      padding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                      child: Text('다운로드가 생각보다 너무 느립니다.'),
                    ),
                    expanded: Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Column(
                        children: [
                          Text(
                              'DPI Bypass 툴(Intra, 유니콘 등)이 실행중이라면 종료하고 재시도해보세요. 그래도 느리고, 느린이유가 앱 문제라고 생각한다면 오류 및 버그 항목으로 문의주세요.',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 0.5,
              color: Settings.themeWhat
                  ? Colors.grey.shade600
                  : Colors.grey.shade400,
            ),
            ExpandableNotifier(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: ScrollOnExpand(
                  child: ExpandablePanel(
                    theme: ExpandableThemeData(
                        iconColor:
                            Settings.themeWhat ? Colors.white : Colors.grey,
                        animationDuration: const Duration(milliseconds: 500)),
                    header: Padding(
                      padding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                      child: Text('다운로드된 파일은 어디에 저장되나요?'),
                    ),
                    expanded: Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Column(
                        children: [
                          Text('기본적으로 외부 저장소의 Violet 폴더에 저장됩니다.',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 0.5,
              color: Settings.themeWhat
                  ? Colors.grey.shade600
                  : Colors.grey.shade400,
            ),
            ExpandableNotifier(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: ScrollOnExpand(
                  child: ExpandablePanel(
                    theme: ExpandableThemeData(
                        iconColor:
                            Settings.themeWhat ? Colors.white : Colors.grey,
                        animationDuration: const Duration(milliseconds: 500)),
                    header: Padding(
                      padding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                      child: Text('뭘로 만들었나요?'),
                    ),
                    expanded: Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Column(
                        children: [
                          Text('플러터와 러스트, 파이썬, 코틀린을 사용해서 만들었습니다.',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 0.5,
              color: Settings.themeWhat
                  ? Colors.grey.shade600
                  : Colors.grey.shade400,
            ),
            ExpandableNotifier(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: ScrollOnExpand(
                  child: ExpandablePanel(
                    theme: ExpandableThemeData(
                        iconColor:
                            Settings.themeWhat ? Colors.white : Colors.grey,
                        animationDuration: const Duration(milliseconds: 500)),
                    header: Padding(
                      padding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                      child: Text('앱에 바이러스나 해킹기능, 백도어가 포함되어있나요?'),
                    ),
                    expanded: Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Column(
                        children: [
                          Text('해당 기능은 포함되어있지 않습니다.',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
