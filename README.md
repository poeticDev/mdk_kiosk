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

# Release

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