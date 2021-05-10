// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communitydownloader/settings/settings.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text('PRIVACY POLICY'),
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
                      child: Text('서문'),
                    ),
                    expanded: Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('1. ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  "Violet Community Downloader (이하 'Violet')은(는) 개인정보보호법에 따라 이용자의 개인정보 보호 및 권익을 보호하고 개인정보와 관련한 이용자의 고충을 원활하게 처리할 수 있도록 다음과 같은 처리방침을 두고 있습니다.",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('2. ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  "개인정보의 처리 목적: 'Violet'은(는) 개인정보를 다음의 목적을 위해 처리합니다. 처리한 개인정보는 다음의 목적이외의 용도로는 사용되지 않으며 이용 목적이 변경될 시에는 사전동의를 구할 예정입니다.",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
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
                      child: Text('제 3자에게 제공하는 정보'),
                    ),
                    expanded: Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('1. ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  '개인정보를 제공받는 자: 이 앱은 구글 애널리틱스(GA. Google Analytics)에게 사용자 정보를 일부 제공하고 있습니다.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('2. ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  '제공받는 자의 개인정보 이용 목적: 통계 작성 및 앱 오류에 대한 정보 수집',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('3. ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  '제공하는 개인정보 항목: 지역, 기기 모델명, 앱 접속 기록, 오류 정보, 앱 설치 시각을 기반으로 생성된 비식별 사용자 정보',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('4. ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  '제공받는 자의 보유·이용기간: 18개월',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
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
                      child: Text('다운로드 및 로그 기록 처리 방침'),
                    ),
                    expanded: Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('1. ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  '다운로드 및 로그 기록은 외부 사용자나 외부 앱이 접근할 수 없는 내부 저장소에 보관됩니다.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('2. ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  '본 개발자는 사용자의 다운로드 및 로그 기록과 이에 관한 어떠한 정보도 수집하지 않습니다.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
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
                      child: Text('로그인 정보 처리 방침'),
                    ),
                    expanded: Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('1. ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  '로그인 정보(다운로드에 필요한 웹 사이트의 아이디 및 비밀번호)는 각 디바이스가 별도로 제공하는 Key Store(iOS의 경우엔 Key Chain)에 안전하게 보관됩니다.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('2. ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  '본 개발자는 사용자의 로그인 정보와 이에 관한 어떠한 정보도 수집하지 않습니다.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
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
