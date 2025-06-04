import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';

class StudioState {
  final String text;
  final Color bgColor;
  final Color fontColor;
  final TextStyle fontStyle;


  StudioState({
    required this.text,
    required this.bgColor,
    required this.fontColor,
    this.fontStyle = TITLE_TEXT_STYLE,
  });
}



final StudioState STATE_ON_AIR = StudioState(
  text: '촬영 중',
  bgColor: Colors.red,
  fontColor: WHITE_TEXT_COLOR,
);

final StudioState STATE_READY = StudioState(
  text: '대기 중',
  bgColor: Colors.green,
  fontColor: WHITE_TEXT_COLOR,
);

final StudioState STATE_CHECK = StudioState(
  text: '자동\n점검 중',
  bgColor: NORMAL_BLUE,
  fontColor: WHITE_TEXT_COLOR,
);

final StudioState STATE_CHECK_END = StudioState(
  text: '점검\n종료',
  bgColor: Colors.yellow,
  fontColor: BODY_TEXT_COLOR,
);


final StudioState STATE_OFF = StudioState(
  text: 'OFF',
  bgColor: Colors.grey,
  fontColor: BODY_TEXT_COLOR,
);

final List<StudioState> STATE_LIST = [STATE_READY, STATE_ON_AIR, STATE_CHECK, STATE_CHECK_END, STATE_OFF];
