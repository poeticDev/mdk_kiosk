import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/header/util/state_manager.dart';

class SimpleMeters extends ConsumerWidget {
  final double fontSize;

  const SimpleMeters({super.key, this.fontSize = 36});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double num = 20;

    return Row(
      spacing: 32,
      children: [
        _StateMeter(
          provider: temperatureProvider,
          icon: Icon(
            Icons.thermostat_outlined,
            size: fontSize * 0.9,
            color: Colors.red,
          ),
          unitString: '℃',
        ),
        _StateMeter(
          provider: humidityProvider,
          icon: Icon(
            Icons.water_drop,
            size: fontSize * 0.9,
            color: Colors.blue,
          ),
          unitString: '%',
        ),
      ],
    );
  }

  Widget _StateMeter(
      {required StateProvider provider,
      required Icon icon,
      String? unitString}) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(provider);
        return Row(
          spacing: 8,
          children: [
            icon,
            Text(
              '${state.round().toString()}$unitString',
              style: TITLE_TEXT_STYLE.copyWith(fontSize: fontSize),
            ),
          ],
        );
      },
    );
  }
}
