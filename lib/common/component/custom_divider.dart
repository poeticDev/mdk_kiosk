import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:mdk_kiosk/common/const/colors.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Neumorphic(
        child: Container(
          height: 6.0,
          decoration: BoxDecoration(
            color: DIVIDER_COLOR,
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }
}
