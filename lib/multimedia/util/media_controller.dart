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
  DateTime lastModified = _nowKST();

  factory MediaController() => _instance;

  MediaController._internal();

  final AppDatabase db = GetIt.I<AppDatabase>();

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

  List<MediaItemCompanion> jsonToCompanionList(
      List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) {
      return MediaItemCompanion(
        title: Value(json['title'] ?? '미디어 이름'),
        type: Value(MediaType.values.byName(json['type'])),
        url: Value(json['url']),
        fileName: Value(json['fileName']),
        from: Value(MediaFrom.values.byName(json['from'] ?? 'gDrive')),
        fit: json['fit'] != null
            ? Value(BoxFit.values.byName(json['fit']))
            : const Value.absent(),
        orderNum: Value(json['orderNum'] ?? 0),
      );
    }).toList();
  }

  /// MediaItemData 핸들링
  void mediaDataHandler(
      {required List<Map<String, dynamic>> mediaDataList,
      required DateTime timeRecord}) {
    // 최신 데이터가 아니면 무시
    if (lastModified.isAfter(timeRecord)) {
      return;
    } else {
      lastModified = timeRecord;
    }

    // MediaItemCompanion 변환
    final List<MediaItemCompanion> mediaItemCompanionList =
        jsonToCompanionList(mediaDataList);

    // MediaItem 동기화
    db.syncMediaItems(mediaItemCompanionList);

    // 화면 rebuild하는 방법 투입(데이터베이스에서 불러오기부터 필요)
  }

  static DateTime _nowKST() {
    return DateTime.now().toUtc().add(Duration(hours: 9));
  }
}
