import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';

class GlobalData {
  /// Basic Info
  /// 0. 아이디
  late int id;

  /// 1. 강의실 정보
  late String roomId;
  late String roomName;
  late Uint8List logoImage;
  late String? wifiName;
  late String titleText;

  /// 2. 태블릿
  late int myOscPort;
  late String myPassword;

  /// 3. 서버
  late String serverIp;
  late int serverOscPort;
  late int serverMqttPort;
  late String serverMqttId;
  late String serverMqttPassword;

  void updateFromBasicInfoData({required BasicInfoData basicInfoData}) {
    id = basicInfoData.id;
    roomId = basicInfoData.roomId;
    roomName = basicInfoData.roomName;
    logoImage = basicInfoData.logoImage;
    wifiName = basicInfoData.wifiName;
    titleText = basicInfoData.titleText;
    myOscPort = basicInfoData.myOscPort;
    myPassword = basicInfoData.myPassword;
    serverIp = basicInfoData.serverIp;
    serverOscPort = basicInfoData.serverOscPort;
    serverMqttPort = basicInfoData.serverMqttPort;
    serverMqttId = basicInfoData.serverMqttId;
    serverMqttPassword = basicInfoData.serverMqttPassword;
  }
}

final GlobalData globalData = GlobalData();
