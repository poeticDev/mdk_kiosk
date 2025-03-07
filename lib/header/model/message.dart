import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';

enum MessageType {
  normal,
  warning,
  check,
  announce,
}

class Message {
  final DateTime until;
  final MessageType type;
  final String content;
  late final Color color;
  late final String svgPath;

  Message({
    required this.until,
    required this.type,
    required this.content,
  }) {
    switch (type) {
      case MessageType.normal:
        color = normalBlue;
        svgPath = 'asset/img/svg/hello.svg';
        break;

      case MessageType.warning:
        color = warningRed;
        svgPath = 'asset/img/svg/warning.svg';
        break;
      case MessageType.check:
        color = checkGreen;
        svgPath = 'asset/img/svg/check.svg';
        break;
      case MessageType.announce:
        color = announceYellow;
        svgPath = 'asset/img/svg/announce.svg';
        break;
    }
  }
}
