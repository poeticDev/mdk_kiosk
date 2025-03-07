import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mdk_kiosk/header/model/message.dart';

part 'message_controller.g.dart';

@riverpod
class MessageController extends _$MessageController {
  final Map<String, Timer> _messageTimers = {}; // 메시지 식별자 -> 타이머 매핑

  List<Message> get _initialState => [];

  @override
  List<Message> build() {
    return _initialState;
  }

  void syncMessageList(List<Message> messageList) {
    // 기존 타이머 정리
    _cancelAllTimers();

    state = messageList;

    for (final message in messageList) {
      _setAutoRemoveTimer(message);
    }
  }

  void addMessage(Message messageData) {
    state = [...state, messageData];
    _setAutoRemoveTimer(messageData);
  }

  void removeMessage(Message messageData) {
    state = state.where((m) => m != messageData).toList();
    _cancelTimer(messageData);
  }

  void _setAutoRemoveTimer(Message message) {
    final now = DateTime.now();
    final key = _generateMessageKey(message);

    if (message.until.isAfter(now)) {
      final duration = message.until.difference(now);
      final timer = Timer(duration, () {
        removeMessage(message);
      });

      _messageTimers[key] = timer;
    } else {
      // 이미 만료된 메시지는 즉시 삭제
      removeMessage(message);
    }
  }

  void _cancelAllTimers() {
    for (final timer in _messageTimers.values) {
      timer.cancel();
    }
    _messageTimers.clear();
  }

  void _cancelTimer(Message message) {
    final key = _generateMessageKey(message);
    if (_messageTimers.containsKey(key)) {
      _messageTimers[key]?.cancel();
      _messageTimers.remove(key);
    }
  }

  String _generateMessageKey(Message message) {
    // 예시로 until과 content 조합해서 고유키 생성
    return '${message.until.toIso8601String()}_${message.content.hashCode}';
  }
}
