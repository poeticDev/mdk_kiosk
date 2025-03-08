import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';

class CustomDialog extends StatelessWidget {
  double borderRadius;
  String? title;
  List<Widget>? titleActions;
  double widthRatio;
  double heightRatio;
  Widget content;

  CustomDialog({
    this.title,
    this.titleActions,
    this.widthRatio = 0.9,
    this.heightRatio = 0.9,
    required this.content,
    this.borderRadius = 16,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * widthRatio;
    final height = MediaQuery.of(context).size.height * heightRatio;

    return Dialog(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: TOAST_BG_COLOR,
          width: 4.0,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      backgroundColor: BG_COLOR,
      child: SizedBox(
        width: width,
        height: height,
        // padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (title != null) renderTitle(),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  Widget renderTitle() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: TOAST_BG_COLOR,
          width: 4.0,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        color: DIALOG_TITLE_BG_COLOR,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                size: 26,
                color: WHITE_TEXT_COLOR.withOpacity(0.95),
              ),
              SizedBox(width: 12.0),
              Text(
                title!,
                style: CUSTOM_DIALOG_TITLE_TEXT_STYLE,
              ),
            ],
          ),
          if (titleActions != null)
            Row(
              children: titleActions!,
            )
        ],
      ),
    );
  }
}
