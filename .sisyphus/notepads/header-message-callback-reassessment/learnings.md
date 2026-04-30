# Header Message Callback Reassessment - Learnings

## Test Pattern Learned

### Setting up globalData for tests
```dart
void _initGlobalData() {
  globalData.roomId = 'test-room';
  globalData.roomName = 'Test Room';
  globalData.logoImage = Uint8List(0);
  // ... other fields
}
```

### Mocking MqttManager
```dart
class MockMqttManager extends MqttManager {
  MockMqttManager() : super(broker: 'localhost', clientId: 'test', ...);
  
  @override
  void publish(String topic, String message) {
    // Absorb - no-op in tests
  }
}
```

### Overriding Riverpod providers in tests
```dart
ProviderScope(
  overrides: [
    mqttManagerProvider.overrideWithValue(mockMqttManager),
    messageControllerProvider.overrideWith(() => TestController([...])),
  ],
  child: ...
)
```

### Test-specific MessageController
```dart
class TestMessageController extends MessageController {
  final List<Message> _initialMessages;
  TestMessageController(this._initialMessages);
  @override
  List<Message> build() => _initialMessages;
}
```

## HeaderLayout Behavior Notes

### Child List Structure
- Always includes `DefaultHeader()` at index 0
- Messages are appended after DefaultHeader
- With 1 message: children = [DefaultHeader, Message] = 2 items → auto-slide enabled
- With 0 messages: children = [DefaultHeader] = 1 item → no auto-slide

### Auto-slide Logic
- Timer fires every 12 seconds
- `_currentIndex = (_currentIndex + 1) % childrenCount`
- FadeTransition used for smooth switching
- postFrameCallback used to avoid setState during build

## Testing Gotchas

### First build before postFrameCallback
- First build happens with childrenCount = null
- postFrameCallback updates childrenCount on next frame
- Need to pump frames to trigger callback

### get_it singleton pattern
- Need to reset in setUp and tearDown
- Register mocks before widget pump

## Timestamp
2026-04-01

---

## MessageContainer Auto-Scroll Test Learnings

### Test Structure for MessageContainer

1. **Widget Testing with ScrollController**
   - `SingleChildScrollView`의 `controller` 속성을 통해 `ScrollController`에 접근 가능
   - `tester.widget<SingleChildScrollView>(finder).controller`로 컨트롤러 획득
   - `scrollController.offset`으로 현재 스크롤 위치 확인
   - `scrollController.position.maxScrollExtent`로 최대 스크롤 범위 확인

2. **Testing Async Scroll Behavior**
   - `WidgetsBinding.instance.addPostFrameCallback`은 `pump()` 후에 실행됨
   - `Future.delayed`는 `pump(Duration)`으로 시간을 진행시켜야 함
   - `animateTo` 애니메이션도 `pump()`로 시간을 진행시켜야 실제로 스크롤됨

3. **MessageContainer Internal Structure**
   - `SizedBox(width: height * 0.9)` - 아이콘 공간
   - `Expanded` - 텍스트 공간
   - `padding: 16.0` (수평)
   - 테스트에서 위젯 너비 설정 시 내부 구조 고려 필요
   - 너무 작은 너비는 `RenderFlex overflow` 에러 유발

4. **Testing Widget Dispose Safety**
   - `scrollController.hasClients`로 위젯이 dispose되었는지 확인 가능
   - `mounted` 체크가 `addPostFrameCallback`과 `Future.delayed` 후에 필요
   - `pumpWidget`으로 완전히 다른 위젯을 렌더링하면 이전 위젯 dispose됨

5. **Test Width Considerations**
   - 짧은 메시지 테스트: 너비 400.0으로 충분한 공간 확보
   - 긴 메시지 테스트: 너비 200.0으로 텍스트 영역 제한 (아이콘 72 + 패딩 32 = 104 차감)
   - `height * 0.9`가 아이콘 공간으로 차지됨을 고려

### Key Test Patterns

```dart
// ScrollController 접근 패턴
final scrollableView = find.byType(SingleChildScrollView);
final scrollController = tester.widget<SingleChildScrollView>(scrollableView).controller;

// 비동기 스크롤 타이밍 테스트
await tester.pump(); // post-frame callback 실행
await tester.pump(const Duration(seconds: 3)); // 3초 대기
await tester.pump(const Duration(seconds: 2)); // 스크롤 애니메이션 진행

// Dispose 안전성 테스트
await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
expect(scrollController.hasClients, isFalse);
```

---

## Post-Layout Scheduling Pattern (2026-04-01)

### Problem: Build-Triggered Scheduling

`build()`에서 직접 `addPostFrameCallback`을 호출하면:
- 매 빌드마다 callback이 누적됨
- `addPostFrameCallback`은 one-shot이지만, `build()`는 여러 번 호출됨
- 불필요한 스크롤 예약 중복 발생

### Solution: Lifecycle-Based One-Shot Scheduling

```dart
class _MessageContainerState extends State<MessageContainer> {
  late final ScrollController _scrollController;
  bool _isScrolling = false;
  bool _scrollWorkQueued = false;  // 중복 등록 방지

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scheduleScrollIfNeeded();  // 초기 mount 시 한 번 예약
  }

  /// Post-frame callback 등록 (중복 등록 방지)
  void _scheduleScrollIfNeeded() {
    if (_scrollWorkQueued) return;
    if (widget.isFading || _isScrolling) return;

    _scrollWorkQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollWorkQueued = false;
      _runScrollIfNeeded();
    });
  }

  /// 실제 스크롤 로직 실행 (post-frame 내부에서만 호출)
  void _runScrollIfNeeded() async {
    if (!mounted) return;
    if (widget.isFading || _isScrolling) return;

    _scrollController.jumpTo(0);
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll > 0) {
        _isScrolling = true;
        await Future.delayed(Duration(seconds: 3));
        if (!mounted) return;
        await _scrollController.animateTo(
          maxScroll,
          duration: Duration(seconds: 5),
          curve: Curves.linear,
        );
        _isScrolling = false;
      }
    }
  }

  @override
  void didUpdateWidget(covariant MessageContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 메시지 내용 또는 isFading 상태가 변경되면 스크롤 reset/재예약
    if (oldWidget.messageData.content != widget.messageData.content ||
        oldWidget.isFading != widget.isFading) {
      _isScrolling = false;
      _scheduleScrollIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    // build()에서 직접 호출하지 않음!
    // 대신 SizeChangedLayoutNotifier로 constraint 변경 대응
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        _isScrolling = false;
        _scheduleScrollIfNeeded();
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: /* ... */,
      ),
    );
  }
}
```

### Key Points

1. **`_scrollWorkQueued` 플래그**: 중복 post-frame callback 등록 방지
2. **`initState()`에서 초기 예약**: 위젯 mount 시 한 번만 호출
3. **`didUpdateWidget`에서 재예약**: content/isFading 변화 시에만
4. **`SizeChangedLayoutNotifier`**: constraint 변경(레이아웃 크기 변화) 대응
5. **`build()`에서 직접 호출 금지**: lifecycle 메서드에서만 스케줄링

### SizeChangedLayoutNotifier Usage

```dart
NotificationListener<SizeChangedLayoutNotification>(
  onNotification: (notification) {
    // Size 변경 시 스크롤 reset/재예약
    _isScrolling = false;
    _scheduleScrollIfNeeded();
    return true;
  },
  child: SizeChangedLayoutNotifier(
    child: /* widget tree */,
  ),
)
```

### Why This Works

- `initState()`: 위젯이 처음 생성될 때 한 번만 호출
- `didUpdateWidget()`: 부모가 새 위젯을 제공할 때만 호출
- `SizeChangedLayoutNotification`: 레이아웃 constraint가 변경될 때만 발생
- `_scrollWorkQueued`: post-frame callback이 이미 등록되어 있으면 중복 등록 방지

### Test Compatibility

기존 테스트는 모두 통과:
- (a) 짧은 메시지는 스크롤되지 않음
- (b) 긴 메시지는 0.0에서 시작하고 3초 후 스크롤 시작
- (c) 메시지 전환 시 스크롤이 0.0으로 리셋되고 재시작
- (d) 위젯 dispose 후 예외 없음

---

## Task 4 Verification Learnings (2026-04-01)

### Scope Verification

**Target file:** `lib/header/component/message_container.dart` - Modified as intended
**HeaderLayout:** Contains unused import warnings from OTHER work in HEAD commit
**MqttManager:** Contains unused import warnings from OTHER work in HEAD commit

### Verification Commands

```bash
# Run focused tests
flutter test test/header/component/message_container_test.dart test/header/header_layout_test.dart

# Run analyzer
flutter analyze --fatal-infos

# Check diff scope
git diff --name-only HEAD~1..HEAD
```

### Evidence Files Created

1. `.sisyphus/evidence/task-4-focused-verification.log` - Test and analyzer results
2. `.sisyphus/evidence/task-4-scope-guard.log` - Scope guard analysis

### Key Findings

- Header-focused tests: 6/6 PASS
- Analyzer: 71 issues (warnings/infos only, no errors) - PASS with --fatal-infos
- MessageContainer modification isolated to target file only
- Other changed files in HEAD are from parallel work, not scope creep
