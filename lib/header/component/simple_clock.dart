import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/style.dart';

class SimpleClock extends StatefulWidget {
  final double fontSize;
  const SimpleClock({super.key, this.fontSize = 36});

  @override
  State<SimpleClock> createState() => _SimpleClockState();
}

class _SimpleClockState extends State<SimpleClock> {
  late Timer _timer;
  late String _currentTime;

  @override
  void initState() {
    super.initState();

    _updateTime(); // 초기값
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final formatted = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _currentTime = formatted;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8.0,
      children: [
        Icon(Icons.access_time_outlined, size: widget.fontSize * 0.9,),
        Text(
          _currentTime,
          style: TITLE_TEXT_STYLE.copyWith(fontSize: widget.fontSize),
        ),
      ],
    );
  }
}
