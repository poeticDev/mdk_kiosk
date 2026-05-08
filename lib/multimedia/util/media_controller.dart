import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/cupertino.dart' show BoxFit;
import 'package:mdk_kiosk/common/util/data/model/media_item.dart';

part 'media_controller.g.dart';

@Riverpod(keepAlive: true)
class MediaController extends _$MediaController {
  AppDatabase get _db => GetIt.I<AppDatabase>();
  Future<void> _mediaSyncQueue = Future.value();
  List<Map<String, dynamic>>? _pendingMediaDataList;
  int _latestQueuedMediaSyncId = 0;

  /// Async DB hydration - proper async provider pattern
  @override
  Future<List<MediaItemData>> build() async {
    return _db.getMediaItemDataList();
  }

  /// BoxFit을 문자열로 변환하는 헬퍼 메서드
  String? boxFitToString(BoxFit? fit) {
    if (fit == null) return null;
    return fit.toString().split('.').last;
  }

  /// MediaType을 문자열로 변환하는 헬퍼 메서드
  String mediaTypeToString(MediaType type) {
    return type.toString().split('.').last;
  }

  /// MediaFrom을 문자열로 변환하는 헬퍼 메서드
  String mediaFromToString(MediaFrom from) {
    return from.toString().split('.').last;
  }

  /// 미디어 아이템 목록을 mdk mqtt 형식의 json 변환
  String mediaItemDataListToJson(List<MediaItemData> mediaItemDataList) {
    final String timeRecord = _nowKST().toString();
    final Map<String, dynamic> formattedData = {
      "timeRecord": timeRecord,
      "mediaData": mediaItemDataList.map((data) => _mediaItemDataToJson(data)).toList(),
    };
    return _jsonEncode(formattedData);
  }

  Map<String, dynamic> _mediaItemDataToJson(MediaItemData data) {
    return {
      'key': data.key,
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
        .map((mediaItem) => _mediaItemDataToJson(mediaItem))
        .toList();
    final jsonString = _jsonEncode(jsonList);
    print(jsonString);
  }

  /// App <- [MQTT] <- Server
  BoxFit? stringToBoxFit(String? value) {
    if (value == null) return null;
    return BoxFit.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => BoxFit.cover);
  }

  MediaType stringToMediaType(String value) {
    return MediaType.values.firstWhere((e) => e.toString().split('.').last == value);
  }

  MediaFrom stringToMediaFrom(String value) {
    return MediaFrom.values.firstWhere((e) => e.toString().split('.').last == value);
  }

  /// MediaItemCompanion 변환
  List<MediaItemCompanion> jsonToCompanionList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) {
      final parsedDate = json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : null;

      final key = _requireNonEmptyString(json, 'key');
      final title = _requireNonEmptyString(json, 'title');
      final type = stringToMediaType(_requireNonEmptyString(json, 'type'));
      final url = _requireNonEmptyString(json, 'url');
      final from = stringToMediaFrom(_requireNonEmptyString(json, 'from'));

      return MediaItemCompanion(
        key: Value(key),
        title: Value(title),
        type: Value(type),
        url: Value(url),
        fileName: Value(json['fileName'] as String?),
        from: Value(from),
        fit: json['fit'] != null
            ? Value(stringToBoxFit(json['fit'] as String))
            : const Value.absent(),
        orderNum: Value(_requireInt(json, 'orderNum')),
        lastUpdated: parsedDate != null
            ? Value(parsedDate)
            : const Value.absent(),
      );
    }).toList();
  }

  String _requireNonEmptyString(Map<String, dynamic> json, String fieldName) {
    final value = json[fieldName]?.toString().trim();
    if (value == null || value.isEmpty) {
      throw FormatException('Missing required media field: $fieldName');
    }
    return value;
  }

  int _requireInt(Map<String, dynamic> json, String fieldName) {
    final value = json[fieldName];
    final parsed = value == null ? null : int.tryParse(value.toString());
    if (parsed == null) {
      throw FormatException('Invalid required media field: $fieldName');
    }
    return parsed;
  }

  /// MediaItemData 핸들러 - 유일한 미디어 데이터 수신 진입점
  /// - JSON → Companion 변환
  /// - Drift snapshot sync
  /// - Provider state refresh from DB
  /// - 실패 시 마지막 정상 상태 보존
  Future<void> mediaDataHandler({required List<Map<String, dynamic>> mediaDataList}) async {
    _pendingMediaDataList = mediaDataList
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
    _latestQueuedMediaSyncId++;

    _mediaSyncQueue = _mediaSyncQueue.then((_) => _drainPendingMediaSyncs());
    await _mediaSyncQueue;
  }

  Future<void> _drainPendingMediaSyncs() async {
    while (true) {
      final pendingMediaDataList = _pendingMediaDataList;
      if (pendingMediaDataList == null) {
        return;
      }

      _pendingMediaDataList = null;
      final syncId = _latestQueuedMediaSyncId;

      // 마지막 정상 상태 저장
      final lastGoodState = state.valueOrNull ?? [];

      try {
        // 1. JSON → MediaItemCompanion 변환
        final mediaItemCompanionList = jsonToCompanionList(pendingMediaDataList);

        // 2. Drift snapshot sync (atomic transaction)
        await _db.syncMediaItems(mediaItemCompanionList);

        // 3. Provider state refresh from DB
        final freshState = await _db.getMediaItemDataList();

        if (_hasNewerQueuedMediaSync(syncId)) {
          print('MediaController: newer media snapshot queued, skipping stale state publish for sync $syncId');
          continue;
        }

        state = AsyncValue.data(freshState);
        print('MediaController: synced ${mediaItemCompanionList.length} items, state now has ${freshState.length} items');
      } catch (e) {
        if (_hasNewerQueuedMediaSync(syncId)) {
          print('MediaController: stale sync failed - $e, newer snapshot already queued');
          continue;
        }

        // 실패 시 마지막 정상 상태 보존 - destructive empty state 방지
        print('MediaController: sync failed - $e, preserving last good state (${lastGoodState.length} items)');
        state = AsyncValue.data(lastGoodState);
      }
    }
  }

  bool _hasNewerQueuedMediaSync(int syncId) {
    return _pendingMediaDataList != null && syncId != _latestQueuedMediaSyncId;
  }

  static DateTime _nowKST() {
    return DateTime.now().toUtc().add(const Duration(hours: 9));
  }

  String _jsonEncode(dynamic object) => jsonEncode(object);
}
