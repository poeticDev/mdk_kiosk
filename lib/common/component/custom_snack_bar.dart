import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';

class CustomSnackBar extends SnackBar {
  final String text;
  final Widget? actionButton;
  final Duration showTime;

  CustomSnackBar(
      {super.key,
      required this.text,
      this.actionButton,
      this.showTime = const Duration(seconds: 3)})
      : super(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: SNACKBAR_TEXT_STYLE,
                ),
              ),
              if (actionButton != null) actionButton,
            ],
          ),
          backgroundColor:
              actionButton != null ? TOGGLE_QUERY_COLOR : NORMAL_BLUE,
          behavior: SnackBarBehavior.floating,
          width: 400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          duration: actionButton != null
              ? const Duration(minutes: 30) // 버튼이 있으면 30분 간 표출
              : showTime, // 버튼이 없으면 기본 지속 시간
        );
}
