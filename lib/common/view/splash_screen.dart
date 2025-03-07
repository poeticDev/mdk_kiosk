import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/common/util/initializer.dart';

class SplashScreen extends ConsumerStatefulWidget {
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
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // bool isLoading = false; // ✅ 중복 실행 방지
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _onSplashing();
  }

  Future<void> _onSplashing() async {
    if (!isLoading) return;

    if (widget.onSplashing != null) {
      await Future.sync(() => widget.onSplashing!());
    } else {
      // await Future.delayed(Duration(seconds: 2)); // 기본 대기 시간
    }

    isLoading = false;
  }

  void _navigateToNextPageAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.nextPagePath != null) {
        context.go(widget.nextPagePath!);
      } else if (widget.nextPageName != null) {
        context.goNamed(widget.nextPageName!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      setState(() async {
        await Future.delayed(Duration(seconds: 1));
      });
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? BG_COLOR,
      body: StreamBuilder<String>(
          stream: AppInitializer.initialize(),
          builder: (context, snapshot) {
            if (snapshot.data == ' ' && !isLoading) {
              _navigateToNextPageAfterBuild();
            }

            return LayoutBuilder(builder: (context, constraints) {
              final mWidth = constraints.maxWidth;
              final mHeight = constraints.maxHeight;
              final circleSize = (mWidth < mHeight ? mWidth : mHeight) / 2;

              return SafeArea(
                child: Center(
                  child: SizedBox(
                    width: circleSize,
                    height: circleSize,
                    child: Stack(
                      children: [
                        if (widget.isLogoOn)
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              'asset/img/gnu_logo.png',
                              width: circleSize * 0.7,
                              height: circleSize * 0.7,
                              fit: BoxFit.contain,
                            ),
                          ),
                        SizedBox(
                          width: circleSize,
                          height: circleSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                            color: Colors.indigo,
                          ),
                        ),
                        if (snapshot.data != null)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              snapshot.data!,
                              style: BODY_TEXT_STYLE,
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              );
            });
          }),
    );
  }
}
