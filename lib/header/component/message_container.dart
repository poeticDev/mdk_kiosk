import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mdk_kiosk/common/component/morph_container.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/header/model/message.dart';

class MessageContainer extends StatefulWidget {
  final double height;
  final double padding;
  final double fontSize;
  final Message messageData;

  const MessageContainer({
    super.key,
    required this.height,
    required this.padding,
    required this.fontSize,
    required this.messageData,
  });

  @override
  State<MessageContainer> createState() => _MessageContainerState();
}

class _MessageContainerState extends State<MessageContainer> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _startScrolling();
  }

  void _startScrolling() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scrollWidth = _scrollController.position.maxScrollExtent;

      if (scrollWidth > 0) {
        _scrollTimer = Timer.periodic(Duration(seconds: 11), (timer) async {
          // 1. 초기 3초 대기
          await Future.delayed(Duration(seconds: 3));

          // 2. 오른쪽 끝까지 5초간 스크롤
          await _scrollController.animateTo(
            scrollWidth,
            duration: Duration(seconds: 5),
            curve: Curves.linear,
          );

          // 3. 끝에서 3초 머무름
          await Future.delayed(Duration(seconds: 3));

          // 4. 즉시 처음으로 되돌아감 (애니메이션 없이)
          _scrollController.jumpTo(0);
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.messageData.color;

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: widget.height,
          child: MorphContainer(
            color: color,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.padding),
              child: Center(
                child: ClipRect(
                  // overflow 방지
                  child: Row(
                    children: [
                      SizedBox(width: 44),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          child: Text(
                            widget.messageData.content,
                            style: TITLE_TEXT_STYLE.copyWith(
                                fontSize: widget.fontSize,
                                color: WHITE_TEXT_COLOR),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -widget.height * 0.25,
          left: 20,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'asset/img/svg/back.svg',
                height: widget.height,
                width: widget.height,
                colorFilter:
                    _getColorFilter(hslDark.toColor(), BlendMode.srcIn),
              ),
              Positioned(
                top: 12,
                child: SvgPicture.asset(
                  widget.messageData.svgPath,
                  height: widget.height * 0.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static ColorFilter? _getColorFilter(
    Color? color,
    BlendMode colorBlendMode,
  ) =>
      color == null ? null : ColorFilter.mode(color, colorBlendMode);
}
