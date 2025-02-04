import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';

class DefaultLayout extends StatelessWidget {
  final Color? backgroundColor;
  final Widget? child;

  const DefaultLayout({
    this.backgroundColor,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? BG_COLOR,
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: child ?? const Text('페이지 정보가 없습니다.')),
    );
  }
}
