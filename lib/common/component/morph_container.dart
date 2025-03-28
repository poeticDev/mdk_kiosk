import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:mdk_kiosk/common/const/colors.dart';

class MorphContainer extends StatelessWidget {
  final Color color;
  final Widget child;

  const MorphContainer(
      {required this.child, super.key, this.color = COMPONENT_BG_COLOR});

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   decoration: BoxDecoration(
    //     // color: COMPONENT_BG_COLOR,
    //     gradient: LinearGradient(
    //       colors: [
    //         COMPONENT_BG_COLOR,
    //         COMPONENT_BG_COLOR,
    //         COMPONENT_BG_COLOR,
    //         Color(0xFFF8FBFD),
    //       ],
    //       begin: Alignment.topLeft,
    //       end: Alignment.bottomRight
    //     ),
    //     borderRadius: BorderRadius.circular(32.0),
    //     boxShadow: [
    //       BoxShadow(
    //         color: COMPONENT_SHADDOW_COLOR,
    //         offset: Offset(12, 12),
    //         blurRadius: 50.0,
    //         spreadRadius: 12.0,
    //       ),
    //       BoxShadow(
    //         color: Colors.white,
    //         offset: Offset(-20, -20),
    //         blurRadius: 40.0,
    //         spreadRadius: 12.0,
    //       ),
    //     ],
    //   ),
    //   child: child,
    // );

    return Neumorphic(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.circular(32.0),
        ),
        color: color,
        shadowLightColor: Color(0xFFF9F9FF),
        depth: 8,
        intensity: 0.68,
      ),
      child: child,
    );
  }
}
