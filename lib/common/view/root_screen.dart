import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/layout/default_layout.dart';
import 'package:mdk_kiosk/timetable/component/timetable.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      midChild: Timetable(),
    );
  }
}