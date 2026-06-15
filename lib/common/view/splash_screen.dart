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

  Stream<String>? stream;
  final bool needInitializing;

  final Future<void> Function()? onSplashing;

  final bool isLogoOn;

  SplashScreen({
    this.nextPagePath,
    this.nextPageName,
    this.backgroundColor,
    this.stream,
    this.needInitializing = false,
    this.onSplashing,
    this.isLogoOn = true,
    super.key,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool isLoading = true;
  late final Stream<String> _stream;
  bool _hasNavigated = false;

  @override
  void initState() {
    if (widget.needInitializing) {
      if (!AppInitializer.getInitializedStatus()) {
        _stream = AppInitializer.initialize(ref);
      } else {
        _stream = AppInitializer.reinitAfterEditorMode(ref);
      }
    } else if (widget.stream != null) {
      _stream = widget.stream!;
    } else {
      _stream = Stream.value(' ');
    }

    super.initState();
    _onSplashing();
  }

  Future<void> _onSplashing() async {
    if (widget.onSplashing != null) {
      await Future.sync(() => widget.onSplashing!());
    } else {
      await Future.delayed(const Duration(seconds: 1));
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToNextPageAfterBuild() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final currentLocation = GoRouterState.of(context).uri.toString();
      if (widget.nextPagePath != null &&
          currentLocation != widget.nextPagePath) {
        context.go(widget.nextPagePath!);
      } else if (widget.nextPageName != null) {
        context.goNamed(widget.nextPageName!);
      }
    });
  }

  @override
  void dispose() {
    isLoading = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? BG_COLOR,
      body: StreamBuilder<String>(
          stream: _stream,
          initialData: '',
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
