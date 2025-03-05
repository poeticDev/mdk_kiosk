// import 'package:riverpod_annotation/riverpod_annotation.dart';
//
// part 'media_controller.g.dart';
//
// @Riverpod(keepAlive: true)
// class MediaController extends _$MediaController {
//   Map<String, String> get _initialState {
//     return {};
//   }
// }
//

import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:mdk_kiosk/common/util/data/model/media_item.dart';

class MediaController {
  /// 싱글턴 패턴
  static final MediaController _instance = MediaController._internal();

  factory MediaController() => _instance;

  MediaController._internal();

  final AppDatabase db = GetIt.I<AppDatabase>();

  void sendAllMediaList() {


  }

  /// App -> [MQTT] -> Server
  // BoxFit을 문자열로 변환하는 헬퍼 메서드
  String? boxFitToString(BoxFit? fit) {
    if (fit == null) return null;
    return fit.toString().split('.').last; // BoxFit.cover -> cover
  }

// MediaType을 문자열로 변환하는 헬퍼 메서드
  String mediaTypeToString(MediaType type) {
    return type.toString().split('.').last; // MediaType.image -> image
  }

// MediaFrom을 문자열로 변환하는 헬퍼 메서드
  String mediaFromToString(MediaFrom from) {
    return from.toString().split('.').last; // MediaFrom.gDrive -> gDrive
  }

  Map<String, dynamic> mediaItemDataToJson(MediaItemData data) {
    return {
      'id': data.id,
      'title': data.title,
      'type': mediaTypeToString(data.type),
      'url': data.url,
      'fileName': data.fileName,
      'from': mediaFromToString(data.from),
      'fit': boxFitToString(data.fit),
      'orderNum': data.orderNum,
    };
  }

  void dataListToJson(List<MediaItemData> mediaItemDataList) {
    final List<Map<String, dynamic>> jsonList = mediaItemDataList
        .map((mediaItem) => mediaItemDataToJson(mediaItem))
        .toList();

    final jsonString = jsonEncode(jsonList);

    print(jsonString); // 필요에 따라 저장이나 전송 로직 추가 가능
  }

  /// App <- [MQTT] <- Server
  BoxFit? stringToBoxFit(String? value) {
    if (value == null) return null;
    return BoxFit.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => BoxFit.cover); // 기본값 cover
  }

  MediaType stringToMediaType(String value) {
    return MediaType.values
        .firstWhere((e) => e.toString().split('.').last == value);
  }

  MediaFrom stringToMediaFrom(String value) {
    return MediaFrom.values
        .firstWhere((e) => e.toString().split('.').last == value);
  }

// 실제 Companion 변환 메서드
  MediaItemCompanion jsonToCompanion(Map<String, dynamic> json) {
    return MediaItemCompanion(
      id: Value(json['id'] as int),
      // id도 명시적으로 넣고 싶으면
      title: Value(json['title'] as String),
      type: Value(stringToMediaType(json['type'] as String)),
      url: Value(json['url'] as String),
      fileName: Value(json['fileName'] as String?),
      from: Value(stringToMediaFrom(json['from'] as String)),
      fit: Value(stringToBoxFit(json['fit'] as String?)),
      orderNum: Value(json['orderNum'] as int),
    );
  }

}
