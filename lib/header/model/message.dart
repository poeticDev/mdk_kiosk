import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';

enum MessageType {
  normal,
  warning,
  check,
  announce,
}

class Message {
  final String key;
  final DateTime until;
  final MessageType type;
  final String content;
  late final Color color;
  late final String svgPath;

  Message({
    required this.key,
    required this.until,
    required this.type,
    required this.content,
  }) {
    switch (type) {
      case MessageType.normal:
        color = NORMAL_BLUE;
        svgPath = 'asset/img/svg/hello.svg';
        break;

      case MessageType.warning:
        color = WARNING_RED;
        svgPath = 'asset/img/svg/warning.svg';
        break;
      case MessageType.check:
        color = CHECK_GREEN;
        svgPath = 'asset/img/svg/check.svg';
        break;
      case MessageType.announce:
        color = ANNOUNCE_YELLOW;
        svgPath = 'asset/img/svg/announce.svg';
        break;
    }
  }

  factory Message.fromMap(Map<String, dynamic> messageDataMap) {
    return Message(
      key: messageDataMap['key'],
      until: DateTime.parse(messageDataMap['until']),
      type: MessageType.values.byName(messageDataMap['type']),
      content: messageDataMap['content'],
    );
  }
}
