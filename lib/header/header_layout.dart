import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdk_kiosk/common/component/morph_container.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/common/util/data/global_data.dart';
import 'package:mdk_kiosk/header/component/message_container.dart';
import 'package:mdk_kiosk/header/message_controller.dart';
import 'package:mdk_kiosk/header/model/message.dart';

class HeaderLayout extends ConsumerStatefulWidget {
  final double height;
  final double padding;
  late final double fontSize;

  HeaderLayout({
    super.key,
    this.height = 80.0,
    this.padding = 32.0,
  }) {
    fontSize = height * 0.36;
  }

  @override
  ConsumerState<HeaderLayout> createState() => _HeaderLayoutState();
}

class _HeaderLayoutState extends ConsumerState<HeaderLayout>
    with SingleTickerProviderStateMixin {
  // message 자동 넘기기
  Timer? _timer;
  int _currentIndex = 0;
  late AnimationController _fadeController;
  bool isFading = true;
  int? childrenCount;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _startAutoSlide() {
    _fadeController.forward();

    _timer = Timer.periodic(Duration(seconds: 12), (timer) {
      _fadeController.reverse().then((value) {
        _fadeController.forward();
      });
    });
  }

  void _stopAutoSlide() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopAutoSlide();
    _fadeController.dispose();
    super.dispose();
  }

  List<Widget> _childList(List<Message> messageList) {
    List<Widget> childList = [
      DefaultHeader(),
      MessageContainer(
        height: widget.height,
        padding: widget.padding,
        fontSize: widget.fontSize,
        messageData: Message(
            until: DateTime.now().add(
              Duration(minutes: 10),
            ),
            type: MessageType.check,
            content: '학과 메세지가 있으면 여기에 표시됩니다. 길어지면 애니메이션이 적용됩니다 에헤라디아'),
        isFading: isFading,
      ),
    ];

    if (messageList.isNotEmpty) {
      for (Message messageData in messageList) {
        childList.add(
          MessageContainer(
            height: widget.height,
            padding: widget.padding,
            fontSize: widget.fontSize,
            messageData: messageData,
            isFading: isFading,
          ),
        );
      }
    }
    return childList;
  }

  void _onStatusChanged(status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        isFading = false;
      });
    } else if (status == AnimationStatus.forward) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % childrenCount!;
        isFading = true;
      });
    } else if (status == AnimationStatus.reverse) {
      setState(() {
        isFading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageWatcher = ref.watch(messageControllerProvider);
    final children = _childList(messageWatcher);

    if (childrenCount == null || childrenCount != children.length) {
      childrenCount = children.length;
      _stopAutoSlide();
      if (children.length <= 1) {
        setState(() {
          _fadeController.removeStatusListener(_onStatusChanged);
          // 1개 이하면 슬라이드 불필요
          isFading = false;
        });
      } else {
        _startAutoSlide();
        _fadeController.addStatusListener(_onStatusChanged);
      }
    }

    if (childrenCount == 1) {
      return SizedBox(
        height: widget.height,
        child: children[0],
      );
    }

    return SizedBox(
      height: widget.height,
      child: FadeTransition(
        opacity: _fadeController,
        child: children[_currentIndex],
      ),
    );
  }

  Widget DefaultHeader() {
    return SizedBox(
      height: widget.height,
      child: MorphContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                globalData.roomName,
                style: TITLE_TEXT_STYLE.copyWith(fontSize: widget.fontSize),
              ),
              Text(
                globalData.titleText,
                style: TITLE_TEXT_STYLE.copyWith(fontSize: widget.fontSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
