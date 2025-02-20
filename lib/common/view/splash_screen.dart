import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  final String? nextPagePath;
  final String? nextPageName;
  final Color? backgroundColor;

  final Future<void> Function()? onSplashing;
  final Widget? child;
  final bool isLogoOn;

  const SplashScreen({
    this.nextPagePath,
    this.nextPageName,
    this.backgroundColor,
    this.onSplashing,
    this.child,
    this.isLogoOn = true,
    super.key,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoading = false; // ✅ 중복 실행 방지

  @override
  void initState() {
    super.initState();
    _onSplashing();
  }

  Future<void> _onSplashing() async {
    if (isLoading) return; // ✅ 중복 실행 방지
    isLoading = true;

    if (widget.onSplashing != null) {
      await Future.sync(() => widget.onSplashing!());
    } else {
      await Future.delayed(Duration(seconds: 2)); // 기본 대기 시간
    }

    _navigateToNextPage();
  }

  void _navigateToNextPage() {
    if (widget.nextPagePath != null) {
      context.go(widget.nextPagePath!);
    } else if (widget.nextPageName != null) {
      context.goNamed(widget.nextPageName!);
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? BG_COLOR,
      body: LayoutBuilder(builder: (context, constraints) {
        final mWidth = constraints.maxWidth;
        final mHeight = constraints.maxHeight;
        final circleSize = (mWidth < mHeight ? mWidth : mHeight) / 2;

        return SafeArea(
          child: Center(
            child: SizedBox(
              width: circleSize,
              height: circleSize,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.isLogoOn)
                    Image.asset(
                      'asset/img/gnu_logo.png',
                      width: circleSize - 32,
                      height: circleSize - 32,
                    ),
                  CircularProgressIndicator(
                    strokeWidth: 6,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
