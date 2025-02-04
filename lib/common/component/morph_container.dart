import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:mdk_kiosk/common/const/colors.dart';

class MorphContainer extends StatelessWidget {
  final Widget child;

  const MorphContainer({
    required this.child
    , super.key});

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.circular(40.0),
        ),
        color: COMPONENT_BG_COLOR,
      ),
      child: child,
    );
  }
}
