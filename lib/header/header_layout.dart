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
  // 오토슬라이드 타이머
  Timer? _timer;

  // 현재 표출 중인 헤더
  int _currentIndex = 0;
  late AnimationController _fadeController;

  // 현재 애니메이션 상태 -> 메세지 컨테이너가 계속 리빌드되면서 불필요한 스크롤 컨트롤러가 계속 생성되는 걸 막아줌
  bool isFading = true;

  // 헤더 수에 따라 오토슬라이드 관리
  int? childrenCount;

  @override
  void initState() {
    super.initState();
    // vsync 때문에 여기서 정의
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  // 오토슬라이드 시작
  void _startAutoSlide() {
    _fadeController.forward();

    _timer = Timer.periodic(Duration(seconds: 12), (timer) {
      _fadeController.reverse().then((value) {
        _fadeController.forward();
      });
    });
  }

  // 오토슬라이드 중지
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

  // 헤더 생성
  List<Widget> _childList(List<Message> messageList) {
    List<Widget> childList = [
      DefaultHeader(),
      // Test용
      MessageContainer(
        height: widget.height,
        padding: widget.padding,
        fontSize: widget.fontSize,
        messageData: Message(
            until: DateTime.now().add(
              Duration(minutes: 10),
            ),
            type: MessageType.check,
            content: '테스트 1. 체크 타입입니다. 학과 메세지가 있으면 여기에 표시됩니다.'),
        isFading: isFading,
      ),
      MessageContainer(
        height: widget.height,
        padding: widget.padding,
        fontSize: widget.fontSize,
        messageData: Message(
            until: DateTime.now().add(
              Duration(minutes: 10),
            ),
            type: MessageType.announce,
            content: '테스트2. 공지사항 타입입니다. 메세지가 한번에 표시되는 길이보다 더 길어지면 3초 뒤에 흐르기 시작합니다.'),
        isFading: isFading,
      ),
      MessageContainer(
        height: widget.height,
        padding: widget.padding,
        fontSize: widget.fontSize,
        messageData: Message(
            until: DateTime.now().add(
              Duration(minutes: 10),
            ),
            type: MessageType.warning,
            content: '테스트3. 경고 타입입니다. 메세지는 약 12초간 노출됩니다.'),
        isFading: isFading,
      ),
      MessageContainer(
        height: widget.height,
        padding: widget.padding,
        fontSize: widget.fontSize,
        messageData: Message(
            until: DateTime.now().add(
              Duration(minutes: 10),
            ),
            type: MessageType.normal,
            content: '테스트4. 일반 타입입니다.'),
        isFading: isFading,
      ),
    ];

    // 학과 메세지가 있을 경우, 헤더 생성
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

  // 페이드 상태에 따라 헤더를 재생성(메모리 누수 방지)
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

    // 헤더 수에 따라 오토슬라이드 설정
    if (childrenCount == null || childrenCount != children.length) {
      childrenCount = children.length;
      _stopAutoSlide();
      if (childrenCount! <= 1) {
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
