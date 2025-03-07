import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mdk_kiosk/common/component/morph_container.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/header/model/message.dart';

class MessageContainer extends StatelessWidget {
  final double height;
  final double padding;
  final double fontSize;
  final Message messageData;
  final bool isFading;

  // final ScrollController scrollController; // <- 외부에서 받음

  const MessageContainer({
    super.key,
    required this.height,
    required this.padding,
    required this.fontSize,
    required this.messageData,
    required this.isFading,
    // required this.scrollController,
  });

  void _startScrollingIfNeeded(ScrollController scrollController) {
    if (isFading) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (scrollController.hasClients) {
        final maxScroll = scrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          await Future.delayed(Duration(seconds: 3));
          await scrollController.animateTo(
            maxScroll,
            duration: Duration(seconds: 5),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    _startScrollingIfNeeded(scrollController);

    final color = messageData.color;
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: height,
          child: MorphContainer(
            color: color,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Center(
                child: ClipRect(
                  child: Row(
                    children: [
                      SizedBox(width: 44),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollBehavior(),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: scrollController,
                            child: Text(
                              messageData.content,
                              style: TITLE_TEXT_STYLE.copyWith(
                                  fontSize: fontSize, color: WHITE_TEXT_COLOR),
                            ),
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
          top: -height * 0.25,
          left: 20,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'asset/img/svg/back.svg',
                height: height,
                width: height,
                colorFilter:
                    _getColorFilter(hslDark.toColor(), BlendMode.srcIn),
              ),
              Positioned(
                top: 12,
                child: SvgPicture.asset(
                  messageData.svgPath,
                  height: height * 0.45,
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
