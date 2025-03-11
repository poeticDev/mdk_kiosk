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

  void addMessage(Message message) {
    state = [...state, message];
    _setAutoRemoveTimer(message);
  }

  void removeMessage(Message message) {
    state = state.where((m) => m != message).toList();
    _cancelTimer(message);
  }

  void _setAutoRemoveTimer(Message message) {
    final now = DateTime.now();
    final key = message.key;

    // 타이머 중복 생성 방지
    if (_messageTimers[key] != null) return;

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
    final key = message.key;
    if (_messageTimers.containsKey(key)) {
      _messageTimers[key]?.cancel();
      _messageTimers.remove(key);
    }
  }

  // String _generateMessageKey(Message message) {
  //   // 예시로 until과 content 조합해서 고유키 생성
  //   return '${message.until.toIso8601String()}_${message.content.hashCode}';
  // }

  messageDataHandler({required List<Map<String, dynamic>> messageDataList}) {
    List<Message> messageList = [];

    for (Map<String, dynamic> messageDataMap in messageDataList) {
      final message = Message.fromMap(messageDataMap);

      messageList = [...messageList, message];
    }

    syncMessageList(messageList);
  }
}
