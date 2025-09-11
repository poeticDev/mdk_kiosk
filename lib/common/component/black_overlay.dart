import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class BlackoutOverlay extends StatefulWidget {
  const BlackoutOverlay({super.key});

  @override
  State<BlackoutOverlay> createState() => _BlackoutOverlayState();
}

class _BlackoutOverlayState extends State<BlackoutOverlay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  String _timeText = '';
  Timer? _clockTimer;

  // 텍스트 박스 크기(충돌계산용) — 필요하면 폰트·문구 바뀌면 값만 조정
  static const double boxW = 160;
  static const double boxH = 48;

  // 현재 위치
  double _x = 40;
  double _y = 80;

  // 픽셀/초 단위 속도 (방향 포함)
  double _vx = 90; // +→ 오른쪽, -→ 왼쪽
  double _vy = 70; // +→ 아래,   -→ 위

  // 화면 크기 캐시
  Size? _screenSize;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();

    _updateTime();
    _clockTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _screenSize = Size(constraints.maxWidth, constraints.maxHeight);

      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned(
              left: _x,
              top: _y,
              child: SizedBox(
                width: boxW,
                height: boxH,
                child: Center(
                  child: Text(
                    // _timeText,
                    '',
                    style: const TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _timeText = '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          // '${now.second.toString().padLeft(2, '0')}'
      ;
    });
  }

  Duration _lastTs = Duration.zero;

  void _onTick(Duration ts) {
    if (_screenSize == null) return;
    if (_lastTs == Duration.zero) {
      _lastTs = ts;
      return;
    }

    final dt = (ts - _lastTs).inMicroseconds / 1e6; // 초 단위
    _lastTs = ts;

    // 다음 위치 예측
    double nx = _x + _vx * dt;
    double ny = _y + _vy * dt;

    // 경계(0 ~ max)
    final maxX = _screenSize!.width - boxW;
    final maxY = _screenSize!.height - boxH;

    // X축 반사
    if (nx <= 0) {
      nx = 0;
      _vx = _vx.abs();
    } else if (nx >= maxX) {
      nx = maxX;
      _vx = -_vx.abs();
    }

    // Y축 반사
    if (ny <= 0) {
      ny = 0;
      _vy = _vy.abs();
    } else if (ny >= maxY) {
      ny = maxY;
      _vy = -_vy.abs();
    }

    setState(() {
      _x = nx;
      _y = ny;
    });
  }
}
