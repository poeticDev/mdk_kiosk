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
  final bool isFading;

  const MessageContainer({
    super.key,
    required this.height,
    required this.padding,
    required this.fontSize,
    required this.messageData,
    required this.isFading,
  });

  @override
  State<MessageContainer> createState() => _MessageContainerState();

  static ColorFilter? _getColorFilter(Color? color, BlendMode colorBlendMode) =>
      color == null ? null : ColorFilter.mode(color, colorBlendMode);
}

class _MessageContainerState extends State<MessageContainer> {
  late final ScrollController _scrollController;
  bool _isScrolling = false;
  bool _scrollWorkQueued = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // 초기 mount 시 한 번 예약
    _scheduleScrollIfNeeded();
  }

  /// Post-frame callback 등록 (중복 등록 방지)
  void _scheduleScrollIfNeeded() {
    if (_scrollWorkQueued) return;
    if (widget.isFading || _isScrolling) return;

    _scrollWorkQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollWorkQueued = false;
      _runScrollIfNeeded();
    });
  }

  /// 실제 스크롤 로직 실행 (post-frame 내부에서만 호출)
  void _runScrollIfNeeded() async {
    if (!mounted) return;
    if (widget.isFading || _isScrolling) return;

    _scrollController.jumpTo(0);
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll > 0) {
        _isScrolling = true;
        await Future.delayed(Duration(seconds: 3));
        if (!mounted) return;
        await _scrollController.animateTo(
          maxScroll,
          duration: Duration(seconds: 5),
          curve: Curves.linear,
        );
        _isScrolling = false;
      }
    }
  }

  @override
  void didUpdateWidget(covariant MessageContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 메시지 내용 또는 isFading 상태가 변경되면 스크롤 reset/재예약
    if (oldWidget.messageData.content != widget.messageData.content ||
        oldWidget.isFading != widget.isFading) {
      _isScrolling = false;
      _scheduleScrollIfNeeded();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ✅ 메모리 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.messageData.color;
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0));

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        // Size 변경 시 스크롤 reset/재예약
        _isScrolling = false;
        _scheduleScrollIfNeeded();
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Stack(
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
                      child: Row(
                        children: [
                          SizedBox(width: widget.height * 0.9),
                          Expanded(
                            child: ScrollConfiguration(
                              behavior: ScrollBehavior(),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _scrollController,
                                child: Text(
                                  widget.messageData.content,
                                  style: TITLE_TEXT_STYLE.copyWith(
                                    fontSize: widget.fontSize,
                                    color: WHITE_TEXT_COLOR,
                                  ),
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
              top: -widget.height * 0.25,
              left: 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    'asset/img/svg/back.svg',
                    height: widget.height,
                    width: widget.height,
                    colorFilter: MessageContainer._getColorFilter(
                      hslDark.toColor(),
                      BlendMode.srcIn,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    child: SvgPicture.asset(
                      widget.messageData.svgPath,
                      height: widget.height * 0.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
