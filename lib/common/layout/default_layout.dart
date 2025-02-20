import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:mdk_kiosk/common/component/morph_container.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:uuid/uuid.dart';

class DefaultLayout extends StatelessWidget {
  final Color? backgroundColor;
  final Widget? child;

  late WebSocket? ws;

  DefaultLayout({
    this.backgroundColor,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery
        .of(context)
        .size
        .width;
    final maxHeight = MediaQuery
        .of(context)
        .size
        .height;
    const double padding = 60.0;

    return Scaffold(
      backgroundColor: backgroundColor ?? BG_COLOR,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. 헤더
                MorphContainer(
                  child: _Header(height: 80.0),
                ),
                // CustomDivider(),
                SizedBox(height: padding,),
                // 2. 시간표
                Expanded(
                  child: MorphContainer(
                    child: _TimeTable(),
                  ),
                ),
                // CustomDivider(),
                SizedBox(height: padding,),
                // 3. 멀티미디어
                MorphContainer(
                  child: _MultiMedia(
                      width: maxWidth - padding * 4,
                      height: (maxWidth - padding * 2) * 9 / 16),
                ),
                SizedBox(height: padding,),
                // 4. 로고
                Container(
                  color: Colors.white60,
                  height: 90,
                  width: 160,
                  child: Center(
                    child: Text(
                      'GNU LOGO',
                      style: TITLE_TEXT_STYLE,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _Header({double? height}) {
    return SizedBox(
      height: height ?? 80.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '00동-000호 강의시간표',
              style: TITLE_TEXT_STYLE,
            ),
            Text(
              '높이 80 픽셀',
              style: TITLE_TEXT_STYLE,
            ),
            Text(
              '자율전공학부',
              style: TITLE_TEXT_STYLE,
            ),
          ],
        ),
      ),
    );
  }

  Widget _TimeTable() {
    return Center(
      child: Text(
        '시간표 : 나머지 공간 최대 차지',
        style: TITLE_TEXT_STYLE,
      ),
    );
  }

  Widget _MultiMedia({required double height, double? width}) {
    return Container(
      height: height,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(),
          Text(Uuid().v4()),
          Text(
            '멀티미디어 뷰\n16 : 9 가로폭에 맞춰 높이 자동 지정',
            textAlign: TextAlign.center,
            style: TITLE_TEXT_STYLE,
          ),
          SizedBox(
            width: 160,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration:
                  BoxDecoration(shape: BoxShape.circle, color: DOT_COLOR),
                  width: 16.0,
                  height: 16.0,
                ),
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: DIVIDER_COLOR),
                  width: 16.0,
                  height: 16.0,
                ),
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: DIVIDER_COLOR),
                  width: 16.0,
                  height: 16.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
