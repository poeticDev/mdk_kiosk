import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdk_kiosk/common/component/morph_container.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/common/util/data/global_data.dart';
import 'package:mdk_kiosk/header/component/message_container.dart';
import 'package:mdk_kiosk/header/message_controller.dart';
import 'package:mdk_kiosk/header/model/message.dart';

class HeaderLayout extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    List childList = [
      DefaultHeader(),
    ];
    final messageWatcher = ref.watch(messageControllerProvider);

    final List<Message> messageList = ref.read(messageControllerProvider);

    if (messageList.isNotEmpty) {
      for (Message messageData in messageList) {
        Widget child = MessageContainer(
            height: height,
            padding: padding,
            fontSize: fontSize,
            messageData: messageData);

        childList.add(child);
      }
    }

    final child = MessageContainer(
        height: height,
        padding: padding,
        fontSize: fontSize,
        messageData: Message(
            until: DateTime.now().add(Duration(minutes: 10)),
            type: MessageType.check,
            content: '학과 메세지가 있으면 여기에 표시됩니다. 길어지면 애니메이션이 적용됩니다 에헤라디아'));

    return child;
  }

  Widget DefaultHeader() {
    return SizedBox(
      height: height,
      child: MorphContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                globalData.roomName,
                style: TITLE_TEXT_STYLE.copyWith(fontSize: fontSize),
              ),
              Text(
                globalData.titleText,
                style: TITLE_TEXT_STYLE.copyWith(fontSize: fontSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
