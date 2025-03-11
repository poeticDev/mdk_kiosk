import 'package:flutter/material.dart';

import 'colors.dart';

// 타이틀 스타일
// 타이틀 텍스트 스타일

const TITLE_TEXT_STYLE = TextStyle(
  fontSize: 24.0,
  fontWeight: FontWeight.w500,
  color: TEXT_COLOR,
);

/// timetable
const TIME_TITLE_TEXT_STYLE = TextStyle(
  // fontSize: headerHeight * 0.66,
  fontWeight: FontWeight.w600,
  color: TEXT_COLOR,
);

const LECTURE_TITLE_TEXT_STYLE = TextStyle(
  fontWeight: FontWeight.w600,
  color: TEXT_COLOR,
);

const LECTURE_SUBTITLE_TEXT_STYLE = TextStyle(
  fontWeight: FontWeight.w500,
  color: TEXT_COLOR,
);

/// media view
const BODY_TEXT_STYLE = TextStyle(
  fontWeight: FontWeight.w500,
  color: TEXT_COLOR,
);

/// DIALOG Style
final CUSTOM_DIALOG_TITLE_TEXT_STYLE = TextStyle(
  fontSize: 18.0,
  fontWeight: FontWeight.w600,
  color: WHITE_TEXT_COLOR.withOpacity(0.95),
);

final CUSTOM_DIALOG_TITLE_ACTION_TEXT_STYLE = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.w600,
  color: BODY_TEXT_COLOR.withOpacity(0.9),
);

const DIALOG_TITLE_TEXT_STYLE = TextStyle(
  color: TEXT_COLOR,
  fontSize: 24.0,
  fontWeight: FontWeight.w600,
);

const DIALOG_BTN_TEXT_STYLE = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.w500,
  color: Color(0xDD2C2C2C),
);

ButtonStyle DIALOG_BTN_STYLE = ElevatedButton.styleFrom(
  backgroundColor: Colors.white,
  foregroundColor: BODY_TEXT_COLOR,
  fixedSize: Size(120, 40),
  side: BorderSide(
      color: Colors.black.withOpacity(0.3), style: BorderStyle.solid),
  textStyle: TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  ),
  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
);

const SNACKBAR_TEXT_STYLE = TextStyle(
  fontSize: 14.0,
  color: WHITE_TEXT_COLOR,
);