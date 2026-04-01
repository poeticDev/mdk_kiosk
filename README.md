# mdk_kiosk

mdk_kiosk


## Getting Started

### **BasicInfo 설정하기**

- 다음은 기본 정보값으로 굵은 글씨 항목은 현장 세팅 시 필수로 변경해주도록 한다.
- **roomId** : 경상대의 경우, 8자리(공백구분자 1자리+건물번호 3자리+강의실번호 4자리)숫자로 한다.
    - 이 아이디가 구글 시트 시간표의 시트 이름이 됩니다
    - ex)0-004-0101 -> 4동 0101호 강의실
- **roomName**: 000동 0000호
- logoImage: asset/img/dau.jpg
- **wifiName**: mdk
- titleText: 자율전공학부
- myOscPort: 3000
- myPassword: 12344321!
- serverIp: 192.168.11.120
- serverOscPort: 12321
- serverMqttPort: 1883
- serverMqttId: mdk
- serverMqttPassword: 12344321

### ** credential.json 발급

# Release

## 2.0.0
- **빌드명** : GHU Studio
- **설치 장소** : Main St.(+1), Self St.(+2)
- **주요 기능** : 구글 드라이브 시간표 연동, MQTT 통신, 온에어, 촬영 스케쥴 표시, 딤 스케쥴러


### 2.1.0
- **빌드명** : ClassRoom TU
- **설치 장소** : 동명대 4동 319호
- **주요 기능** : 구글 드라이브 시간표 연동, MQTT 통신, 강의 스케쥴 표시, 딤 스케쥴러

## 1.0.0
- **빌드명** : GNU Coding PBL
- **설치 장소** : 4-111(+1) ,601-1007(+2)
- **주요 기능** : 구글 드라이브 시간표 연동, MQTT 통신

# 주기능

## MQTT

- MQTT Manager : 0.0.2 https://github.com/poeticDev/mdk_mqtt_manager
- 용처
    1. 미디어 목록 송수신
        - Topic : (송수신 토픽)/data
        - Value
          {
          "roomId": "0-004-0101",
          "timeRecord" : timeInUtc,
          "data": {
          "mediaData": {
          {
          'id': data.id,
          'title': data.title,
          'type': mediaTypeToString(data.type),
          'url': data.url,
          'fileName': data.fileName,
          'from': mediaFromToString(data.from),
          'fit': boxFitToString(data.fit),
          'orderNum': data.orderNum,
          },
          },
          "massage": {
          "target" : "kiosk, controller",
          "until" : TimeInUtc,
          "content" : "",
          }
          }

# 개발 환경 정보(수정 중)

## 서버

- **Companion 버전**: ^3.3.1

## Flutter

- **버전**: Flutter 3.24.4 (Channel stable)
- **운영체제**: Microsoft Windows [Version 10.0.22631.4602], locale en-US
- **프레임워크 리비전**: 603104015d (2024-10-24)
- **엔진 리비전**: db49896cf2
- **Dart 버전**: 3.5.4
- **DevTools 버전**: 2.37.3

## Android Toolchain

- **SDK 버전**: Android SDK 30.0.0
- **플랫폼**: android-30
- **빌드 도구**: build-tools 30.0.0
- **Java 버전**: OpenJDK Runtime Environment (build 21.0.3+-12282718-b509.11)

# rk3399 기기 Impeller 비활성화

## 문제 요약

rk3399 SoC 기기에서 Flutter Impeller 렌더러 활성화 시 UI 버벅임(jank)이 발생한다. `--no-enable-impeller` 플래그로 Impeller를 비활성화하면 증상이 사라진다.

## 적용 범위

- **kiosk flavor**: Impeller 비활성화 적용
- **playstore flavor**: 변경 없음 (Impeller 활성 상태 유지)

## 개발 실행

rk3399 기기에서 개발용 실행 시 Impeller를 비활성화해야 한다:

```bash
flutter run --flavor kiosk -d <rk3399-device-id> --no-enable-impeller
```

## 릴리스 빌드

kiosk flavor 릴리스 빌드는 Android manifest 메타데이터로 Impeller를 비활성화한다. CLI 플래그 없이 빌드한다:

```bash
flutter build apk --flavor kiosk --release
```

## 롤백

향후 Flutter 업그레이드나 rk3399 GPU 드라이버 개선으로 Impeller를 다시 활성화하려면:

1. `android/app/src/kiosk/AndroidManifest.xml` 파일 삭제
2. 또는 해당 파일에서 `<meta-data android:name="io.flutter.embedding.android.EnableImpeller" android:value="false" />` 제거

## Flutter 업그레이드 시 주의사항

Flutter major/minor 업그레이드 후 rk3399 기기에서 Impeller ON/OFF 동작을 다시 검증해야 한다. Impeller 구현이 변경되면 manifest 메타데이터 방식이 유효하지 않을 수 있다.