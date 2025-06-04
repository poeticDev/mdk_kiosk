import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdk_kiosk/header/util/state_manager.dart';

class StateIndicatorForMediaBox extends ConsumerWidget {
  final double fontSize;
  final double width;
  final double height;

  const StateIndicatorForMediaBox(
      {super.key,
      required this.fontSize,
      required this.width,
      required this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateWatcher = ref.watch(studioStateProvider);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: stateWatcher.bgColor,
          borderRadius: BorderRadius.circular(32.0)),
      child: Center(
        child: Text(
          stateWatcher.text,
          style: stateWatcher.fontStyle
              .copyWith(color: stateWatcher.fontColor, fontSize: fontSize),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
