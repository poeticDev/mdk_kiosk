import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:mdk_kiosk/common/component/morph_container.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/header/header_layout.dart';
import 'package:mdk_kiosk/multimedia/multimedia_layout.dart';

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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.withAlpha(100),
                Colors.indigo.withAlpha(60),
                Colors.transparent,
                Colors.transparent,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. 헤더
                HeaderLayout(height: maxHeight * 0.035),
                // ElevatedButton(
                //   onPressed: () {
                //     context.go('/test');
                //   },
                //   child: Text(
                //     'TEST_PAGE',
                //     style: BODY_TEXT_STYLE,
                //   ),
                // ),
                SizedBox(
                  height: padding,
                ),
                // 2. 시간표
                if (midChild != null)
                  Expanded(
                    child: MorphContainer(
                      child: midChild!,
                    ),
                  ),
                // CustomDivider(),
                SizedBox(
                  height: padding,
                ),
                // 3. 멀티미디어
                MorphContainer(
                  child:
                      _MultiMedia(width: maxWidth, height: (maxWidth) * 9 / 16),
                ),
                SizedBox(
                  height: padding * 0.7,
                ),
                // 4. 로고
                Container(
                  color: Colors.transparent,
                  height: 72,
                  width: 138,
                  child: Image.asset('asset/img/gnu_logo.png'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _MultiMedia({required double height, double? width}) {
    return SizedBox(
      height: height,
      width: width,
      child: MultimediaLayout(),
    );
  }
}
