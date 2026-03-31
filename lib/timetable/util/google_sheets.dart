import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';
import 'package:mdk_kiosk/timetable/data/mappers/gsheets_mapper.dart';
import 'package:mdk_kiosk/timetable/data/timetable_repository.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

/// Google Sheets를 통한 시간표 데이터 저장소 구현
///
/// 구글 스프레드시트에서 시간표 데이터를 읽어와 캐싱하고,
/// 주기적으로 변경사항을 감지하여 동기화합니다.
class GoogleSheets implements TimetableRepository {
  static const String _spreadSheetId =
      '1l71ItWpm7zQ5EYC1ib7wBn5uDJhLagO0GRysxBVsmjs';
  static const String _credentialAssetPath =
      'asset/env/credentials_tu_lld.json';

  final String sheetName;

  GoogleSheets({required this.sheetName});

  static Map<String, dynamic>? _credentials;
  static GSheets? _sheet;
  static Worksheet? _worksheet;
  static Future<void>? _authFuture;

  // 강의 정보 캐시
  List<Lecture> _lectureCache = [];

  // 이전 캐시 (변경 감지용)
  List<Lecture> _previousCache = [];

  // 강의 정보 캐시 getter
  List<Lecture> get lectureCache => _lectureCache;

  @override
  bool get supportsBackgroundRefresh => true;

  @override
  Future<void> initialize() async {
    await _ensureAuthInitialized();
    _worksheet = await _getWorksheet(
      await _sheet!.spreadsheet(_spreadSheetId),
      title: sheetName,
    );
    await _updateLectureCache();
    _previousCache = List.unmodifiable(_lectureCache);
  }

  /// 구글 시트 재초기화 및 강의 캐시 초기화
  Future<void> reInitialize() async {
    await _ensureAuthInitialized();
    _worksheet = await _getWorksheet(
      await _sheet!.spreadsheet(_spreadSheetId),
      title: sheetName,
    );
    await _updateLectureCache();
    _previousCache = List.unmodifiable(_lectureCache);
  }

  /// 현재 시트에서 강의 캐시 업데이트
  Future<void> _updateLectureCache() async {
    final rows = await _worksheet!.values.map.allRows(fromRow: 3);
    if (rows == null) {
      _lectureCache = [];
    } else {
      _lectureCache = rows
          .map((json) => GsheetsMapper.fromGsheets(json))
          .toList();
    }
    print('✅ LectureCache 업데이트 완료 (${_lectureCache.length}개)');
  }

  @override
  Future<bool> refresh() async {
    final rows = await _worksheet!.values.map.allRows(fromRow: 3);
    final List<Lecture> tempLectureCache = rows == null
        ? []
        : rows.map((json) => GsheetsMapper.fromGsheets(json)).toList();

    final bool isDifferent = !_areLectureListsEqual(
      _lectureCache,
      tempLectureCache,
    );

    if (isDifferent) {
      print('🟢 변경사항 감지됨 → lectureCache 갱신');
      _previousCache = List.unmodifiable(_lectureCache);
      _lectureCache = tempLectureCache;
      return true;
    } else {
      print('⚪ 변경사항 없음 → 유지');
      return false;
    }
  }

  /// 강의 리스트 비교 (순서 포함)
  bool _areLectureListsEqual(List<Lecture> list1, List<Lecture> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (!_areLecturesEqual(list1[i], list2[i])) return false;
    }
    return true;
  }

  /// 개별 강의 비교
  bool _areLecturesEqual(Lecture l1, Lecture l2) {
    return l1.id == l2.id &&
        l1.lectureName == l2.lectureName &&
        l1.instructorName == l2.instructorName &&
        l1.weekday == l2.weekday &&
        l1.startAt.hour == l2.startAt.hour &&
        l1.startAt.minute == l2.startAt.minute &&
        l1.endAt.hour == l2.endAt.hour &&
        l1.endAt.minute == l2.endAt.minute &&
        l1.colorIndex == l2.colorIndex;
  }

  /// 구글 시트에서 시트 생성 또는 가져오기
  static Future<Worksheet> _getWorksheet(
    Spreadsheet spreadsheet, {
    required String title,
  }) async {
    try {
      final Worksheet worksheet = await spreadsheet.addWorksheet(title);
      await worksheet.values.insertRow(1, [
        'id',
        'lectureName',
        'instructorName',
        'weekday',
        'startAt',
        'endAt',
        'colorIndex',
      ]);
      return worksheet;
    } catch (e) {
      return spreadsheet.worksheetByTitle(title)!;
    }
  }

  /// 강의 데이터 한 줄 추가
  static Future<void> append() async {
    await _worksheet!.values.appendRow(fromColumn: 1, [
      'test1',
      'test2',
      'test3',
    ]);
  }

  /// 특정 행 데이터 가져오기
  Future<List<String>> getRow(int row) async {
    late final List<String> values;
    if (_worksheet != null) {
      values = await _worksheet!.values.row(row);
    } else {
      values = [];
    }
    return values;
  }

  /// 강의 데이터 삽입
  Future<void> insertLecture(Lecture lecture) async {
    await _worksheet!.values.map.insertRowByKey(
      lecture.id,
      GsheetsMapper.toGsheets(lecture),
    );
  }

  /// 특정 행의 강의 데이터 가져오기
  Future<Lecture> fetchLecture(int row) async {
    final Map<String, String> map = await _worksheet!.values.map.row(row);
    return GsheetsMapper.fromGsheets(map);
  }

  /// 강의 전체 리스트 갱신 후 반환
  Future<List<Lecture>> fetchAllLectures() async {
    await _updateLectureCache();
    return _lectureCache;
  }

  @override
  List<Lecture> getLectures() {
    return List.unmodifiable(_lectureCache);
  }

  @override
  List<Lecture> getLecturesForToday() {
    final DateTime today = DateTime.now();
    final int weekdayIndex = today.weekday; // 1 (월) ~ 7 (일)
    final Weekday todayWeekday = Weekday.values[(weekdayIndex - 1) % 7];

    final List<Lecture> todayLectures = lectureCache
        .where((Lecture lecture) => lecture.weekday == todayWeekday)
        .toList();

    todayLectures.sort((Lecture a, Lecture b) {
      final int aMinutes = a.startAt.hour * 60 + a.startAt.minute;
      final int bMinutes = b.startAt.hour * 60 + b.startAt.minute;
      return aMinutes.compareTo(bMinutes);
    });

    print(
      '📅 오늘 요일: ${weekdays[todayWeekday.index]} → ${todayLectures.length}개 강의',
    );

    return todayLectures;
  }

  Future<void> _ensureAuthInitialized() async {
    _authFuture ??= _initAuth();
    return _authFuture!;
  }

  Future<void> _initAuth() async {
    if (_sheet != null && _credentials != null) return;
    final String jsonString = await rootBundle.loadString(_credentialAssetPath);
    _credentials = jsonDecode(jsonString) as Map<String, dynamic>;
    _sheet = GSheets(_credentials!);
  }
}
