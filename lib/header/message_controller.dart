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

  void upsertMessageList(List<Message> newMessageList) {
    _cancelAllTimers();
    final Map<String, Message> currentMap = {
      for (Message m in state) m.key: m,
    };

    for (final newMsg in newMessageList) {
      currentMap[newMsg.key] = newMsg; // 있으면 덮어쓰기, 없으면 추가
    }

    state = currentMap.values.toList();

    print('currentMessageState: $state');
    // ..sort((a, b) => a.until.compareTo(b.until)); // 정렬은 필요에 따라

    for (Message m in state) _setAutoRemoveTimer(m);

  }

  // void syncMessageList(List<Message> messageList) {
  //   // 기존 타이머 정리
  //   _cancelAllTimers();
  //
  //   final List<String> oldKeys = [];
  //
  //   for (Message message in state) {
  //     oldKeys.add(message.key);
  //   }
  //
  //   for (Message newMessage in messageList) {
  //     for (Message oldMessage in state) {}
  //   }
  //
  //   state = messageList;
  //
  //   print('msg state: $state');
  //
  //   for (final message in messageList) {
  //     _setAutoRemoveTimer(message);
  //   }
  // }

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

    upsertMessageList(messageList);
  }
}