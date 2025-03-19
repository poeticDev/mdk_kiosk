import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mdk_kiosk/common/component/custom_snack_bar.dart';
import 'package:mdk_kiosk/common/component/editor_dialog.dart';
import 'package:mdk_kiosk/common/component/morph_container.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/common/util/app_editor_mode.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/initializer.dart';
import 'package:mdk_kiosk/common/util/route/router.dart';
import 'package:mdk_kiosk/header/header_layout.dart';
import 'package:mdk_kiosk/multimedia/multimedia_layout.dart';

class DefaultLayout extends StatefulWidget {
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
  State<DefaultLayout> createState() => _DefaultLayoutState();
}

class _DefaultLayoutState extends State<DefaultLayout> {
  String contactName = '교육혁신처';
  String contactNumber = '055-772-4864';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> assignContact() async {
    final db = GetIt.I<AppDatabase>();
    ButtonData? contactData = await db.getButtonByName('contact');
    contactName = contactData?.queryString ?? '교육혁신처';
    contactNumber = contactData?.message ?? '055-772-4864';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;
    const double layoutPadding = 60.0;
    const double betweenPadding = 40.0;

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? BG_COLOR,
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
            padding: EdgeInsets.all(layoutPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. 헤더
                EditorWrapper.basicInfo(
                  child: HeaderLayout(height: maxHeight * 0.045),
                ),
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
                  height: betweenPadding,
                ),
                // 2. 시간표
                if (widget.midChild != null)
                  Expanded(
                    child: MorphContainer(
                      child: widget.midChild!,
                    ),
                  ),
                // CustomDivider(),
                SizedBox(
                  height: betweenPadding,
                ),
                // 3. 멀티미디어
                MorphContainer(
                  child:
                      _MultiMedia(width: maxWidth, height: (maxWidth) * 9 / 16),
                ),
                SizedBox(
                  height: betweenPadding * 0.7,
                ),
                // 4. 푸터 : 연락처 & 로고
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onLongPress: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return ButtonEditorDialog(
                                    buttonName: 'contact');
                              });
                        },
                        child: Text(
                          '$contactName $contactNumber',
                          style: BODY_TEXT_STYLE.copyWith(
                            fontWeight: FontWeight.w300,
                            fontSize: 26,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          appEditorManager.countUp();

                          if (appEditorManager.isEditorModeOn) {
                            setState(() {});
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              CustomSnackBar(
                                text: '관리자 모드가 실행 중입니다!',
                                actionButton: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    appEditorManager.turnEditorModeOff();

                                    context.go('/reinit');
                                  },
                                  child: Text('종료',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          color: Colors.transparent,
                          height: 72,
                          width: 138,
                          child: Image.asset('asset/img/gnu_logo.png'),
                        ),
                      ),
                    ],
                  ),
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
