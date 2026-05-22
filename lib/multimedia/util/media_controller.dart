import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:flutter/cupertino.dart' show BoxFit;
import 'package:mdk_kiosk/common/util/data/model/media_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_controller.g.dart';

@Riverpod(keepAlive: true)
class MediaController extends _$MediaController {
  AppDatabase get _db => GetIt.I<AppDatabase>();
  Future<void> _mediaSyncQueue = Future.value();
  List<Map<String, dynamic>>? _pendingMediaDataList;
  int _latestQueuedMediaSyncId = 0;

  @override
  Future<List<MediaItemData>> build() async {
    return _db.getMediaItemDataList();
  }

  String? boxFitToString(BoxFit? fit) {
    if (fit == null) return null;
    return fit.toString().split('.').last;
  }

  String mediaTypeToString(MediaType type) {
    return type.toString().split('.').last;
  }

  String mediaFromToString(MediaFrom from) {
    return from.toString().split('.').last;
  }

  Map<String, dynamic> mediaItemDataToJson(MediaItemData data) {
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

  ///  미디어 아이템 목록을 mdk mqtt 형식의 json 변환
  String mediaItemDataListToJson(List<MediaItemData> mediaItemDataList) {
    final String timeRecord = _nowKST().toString();
    final Map<String, dynamic> formattedData = {
      "timeRecord": timeRecord,
      "mediaData": mediaItemDataList.map((data) => mediaItemDataToJson(data)).toList(),
    };

    return jsonEncode(formattedData);
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
      orElse: () => BoxFit.cover,
    );
  }

  MediaType stringToMediaType(String value) {
    return MediaType.values.firstWhere((e) => e.toString().split('.').last == value);
  }

  MediaFrom stringToMediaFrom(String value) {
    return MediaFrom.values.firstWhere((e) => e.toString().split('.').last == value);
  }

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
        lastUpdated: parsedDate != null ? Value(parsedDate) : const Value.absent(),
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

  Future<void> mediaDataHandler({required List<Map<String, dynamic>> mediaDataList}) async {
    _pendingMediaDataList = mediaDataList.map((item) => Map<String, dynamic>.from(item)).toList(growable: false);
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
      final lastGoodState = state.valueOrNull ?? [];

      try {
        final mediaItemCompanionList = jsonToCompanionList(pendingMediaDataList);
        await _db.syncMediaItems(mediaItemCompanionList);
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
}
