import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdk_kiosk/header/util/state_manager.dart';

class StateIndicator extends ConsumerWidget {
  final double fontSize;

  const StateIndicator({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateWatcher = ref.watch(studioStateProvider);

    return Container(
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
