import 'dart:async';

class AppEditorMode {
  static final AppEditorMode _instance = AppEditorMode._internal();

  factory AppEditorMode() => _instance;

  AppEditorMode._internal();

  int count = 0;
  Timer? _timer;
  bool isEditorModeOn = false;

  void countUp() {
    if (isEditorModeOn) return;

    _timer?.cancel();

    _timer = Timer(const Duration(minutes: 1), () {
      count = 0;
      _timer?.cancel();
    });

    count++;

    if (count >= 5) turnEditorModeOn();
  }

  void turnEditorModeOn() {
    isEditorModeOn = true;
    count = 0;

    _timer = Timer(const Duration(minutes: 30), () {
      turnEditorModeOff();
      _timer?.cancel();
    });
  }

  void turnEditorModeOff() {
    isEditorModeOn = false;
    count = 0;
  }
}

final appEditorManager = AppEditorMode();
