# AppInitializer MQTT 이슈 체크리스트

## 원인 분석

- [x] `AppInitializer.initialize` 3.2단계에서 `await openMqttManager(ref).timeout(...)` 결과를 try/catch 없이
  기다려, MQTT 서버 미접속 시 timeout 예외가 스트림을 중단시킨다.
- [x] MQTT 연결이 지연되면 해당 Future가 완료되지 않아 이후 단계(시간표 초기화 등)로 진행하지 못하고 UI도 `'MQTT 매니저 초기화 중...'` 상태에 멈춘다.

## 대안 제시

- [x] 초기화 단계를 필수(권한, DB, 시간표)와 선택(MQTT)으로 분리해 네트워크 장애에도 핵심 기능을 계속 진행한다.
- [x] `MqttInitResult`(예: `bool isSuccess`, `String message`, `bool canRetry`,
  `DateTime nextRetryAt`)를 정의하고 `mqttInitStateProvider`(StateNotifier)로 노출해 UI·로그가 실패 원인을 안내하며 재시도
  타이밍을 공유한다.
- [x] 앱 초기화 이후에도 백그라운드 재시도(초기 5초, 이후 30초 간격 지수 백오프)와 설정 화면의 수동 재시도 버튼을 제공해 운영자가 즉시 복구를 시도할 수 있도록 한다.

## 해결 절차 설계

- [x] `openMqttManager` 호출을 try/catch/finally로 감싸 timeout, SocketException을 처리하고 실패 시에도 다음 초기화 단계를
  계속 진행한다. *(예:
  `try { await openMqttManager... } on TimeoutException catch (_) { result = MqttInitResult.failure(...) } finally { yield nextStep; }`)*
- [x] 실패 시 상태 스트림에 `'MQTT 연결 실패, 재시도 예정'` 메시지를 추가로 전송하고 `_isInitialized`는 나머지 단계 완료 후 true로 마킹한다. *(
  yield fail message → continue timetable init → `_isInitialized = true` regardless)*
- [x] Global/Riverpod 상태에 `mqttConnectionState`를 추가해 재시도 스케줄러(Timer 또는 Riverpod `ref.listen`)가 실패
  상태에서만 주기적으로 `openMqttManager`를 재호출하도록 한다. *(StateNotifier keeps `MqttConnectionState`, schedules
  Timer using `Future.delayed` with backoff)*
- [x] 재연결 성공 시 구독 로직(`subscribeTopics`)을 실행하고, 필요한 경우 UI에 성공 메시지를 브로드캐스트한다. *(on success transition
  success state → call `subscribeTopics` → update banner toast)*

## 구현 체크리스트

- [x] `lib/common/util/network/mqtt_connection_status.dart`에 `MqttInitResult`, 연결 단계 enum, 상태 노티파이어, `mqttConnectionStateProvider`를 구현한다.
- [x] `lib/common/util/network/mqtt_manager.dart`에 상태 업데이트, 5초→30초 재시도, 구독 재설정, 연결 타임아웃 처리를 반영한다.
- [x] `lib/common/util/initializer.dart`에서 MQTT 단계를 새 상태와 연동하고, 실패 시에도 스트림이 계속 진행되도록 메시지를 보강한다.
