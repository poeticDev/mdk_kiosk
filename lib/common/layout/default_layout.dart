import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:mdk_kiosk/common/component/morph_container.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/common/util/data/global_data.dart';

class DefaultLayout extends StatelessWidget {
  final Color? backgroundColor;
  final Widget? cover;
  final Widget? midChild;
  final List<Widget>? mediaList;

  DefaultLayout({
    this.backgroundColor,
    this.cover,
    this.midChild,
    this.mediaList,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;
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
                  child: _Header(height: 72.0),
                ),
                // CustomDivider(),
                SizedBox(
                  height: padding,
                ),
                // 2. 시간표
                Expanded(
                  child: MorphContainer(
                    child: _MidChild(),
                  ),
                ),
                // CustomDivider(),
                SizedBox(
                  height: padding,
                ),
                // 3. 멀티미디어
                MorphContainer(
                  child: _MultiMedia(
                      width: maxWidth - padding * 3.5,
                      height: (maxWidth - padding * 3.5) * 9 / 16),
                ),
                SizedBox(
                  height: padding,
                ),
                // 4. 로고
                Container(
                  color: Colors.transparent,
                  height: 90,
                  width: 160,
                  child: Image.asset('asset/img/gnu_logo.png'),
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
              globalData.roomName,
              style: TITLE_TEXT_STYLE,
            ),
            Text(
              globalData.titleText,
              style: TITLE_TEXT_STYLE,
            ),
          ],
        ),
      ),
    );
  }

  Widget _MidChild() {
    return Center(
      child: midChild,
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
