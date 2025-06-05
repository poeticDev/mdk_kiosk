import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsheets/gsheets.dart';
import 'package:mdk_kiosk/common/util/data/updaters.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

class GoogleSheets {
  static const _spreadSheetId = '1YDH2-1QRNRXxJVO1HW-F2YxXpUAUzQ447Gcl03-lhn4';
  final String sheetName;

  GoogleSheets({required this.sheetName});

  Future<Map<String, dynamic>> loadCredentials() async {
    final jsonString =
    await rootBundle.loadString('asset/env/credentials.json');
    return jsonDecode(jsonString);
  }

  static late final _credentials;
  static final _sheet = GSheets(_credentials);
  static Worksheet? _worksheet;
  static Worksheet? _tempWorksheet;

  // ✅ 강의 목록 캐시
  List<Lecture> _lectureCache = [];

  // ✅ 외부에서 읽기 위한 getter
  List<Lecture> get lectureCache => _lectureCache;

  Future<void> initialize() async {
    _credentials = await loadCredentials();

    _worksheet = await _getWorksheet(
      await _sheet.spreadsheet(_spreadSheetId),
      title: sheetName,
    );

    // 초기 캐시 업데이트
    await updateLectureCache();
  }

  Future<void> reInitialize() async {
    _worksheet = await _getWorksheet(
      await _sheet.spreadsheet(_spreadSheetId),
      title: sheetName,
    );

    // 재초기화 시에도 캐시 업데이트
    await updateLectureCache();
  }

  // ✅ cache 업데이트용 함수
  Future<void> updateLectureCache() async {
    final rows = await _worksheet!.values.map.allRows(fromRow: 3);
    if (rows == null) {
      _lectureCache = [];
    } else {
      _lectureCache = rows.map((json) => Lecture.fromGsheets(json)).toList();
    }

    print('✅ LectureCache 업데이트 완료 (${_lectureCache.length}개)');
  }

  // ✅ 변경 사항 감지 + 캐시 업데이트 + UI 트리거
  Future<void> compareNFetchWorksheet(WidgetRef ref) async {
    _tempWorksheet = await _getWorksheet(
      await _sheet.spreadsheet(_spreadSheetId),
      title: sheetName,
    );

    final oldRows = await _worksheet!.values.map.allRows(fromRow: 3);
    final newRows = await _tempWorksheet!.values.map.allRows(fromRow: 3);

    final oldList = oldRows ?? [];
    final newList = newRows ?? [];

    final isDifferent = !_areRowListsEqual(oldList, newList);

    if (isDifferent) {
      print('🟢 변경사항 감지됨 → _worksheet 갱신 및 cache 업데이트');
      _worksheet = _tempWorksheet;

      await updateLectureCache();

      // 프로바이더 업데이트 → UI 새로고침 트리거
      ref.read(timetableUpdater.notifier).state = DateTime.now();
    } else {
      print('⚪ 변경사항 없음 → 유지');
    }
  }

  // 리스트 비교 함수
  bool _areRowListsEqual(
      List<Map<String, String>> list1, List<Map<String, String>> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (!_areRowsEqual(list1[i], list2[i])) return false;
    }

    return true;
  }

  // 행 비교 함수
  bool _areRowsEqual(Map<String, String> row1, Map<String, String> row2) {
    if (row1.length != row2.length) return false;

    for (var key in row1.keys) {
      print('oldRow: ${row1[key]}');
      print('newRow: ${row2[key]}');
      if (row1[key] != row2[key]) return false;
    }

    return true;
  }

  // 시트 생성 또는 가져오기
  static Future<Worksheet> _getWorksheet(
      Spreadsheet spreadsheet, {
        required String title,
      }) async {
    try {
      final worksheet = await spreadsheet.addWorksheet(title);
      await worksheet.values.insertRow(1, [
        'id',
        'lectureName',
        'instructorName',
        'weekday',
        'startAt',
        'endAt',
        'colorIndex'
      ]);
      return worksheet;
    } catch (e) {
      return spreadsheet.worksheetByTitle(title)!;
    }
  }

  // 기존 append 유지
  static Future<void> append() async {
    await _worksheet!.values
        .appendRow(fromColumn: 1, ['test1', 'test2', 'test3']);
  }

  Future<List<String>> getRow(int row) async {
    late final List<String> values;
    if (_worksheet != null) {
      values = await _worksheet!.values.row(row);
    } else {
      values = [];
    }
    return values;
  }

  Future<void> insertLecture(Lecture lecture) async {
    await _worksheet!.values.map
        .insertRowByKey(lecture.id, lecture.toGsheets());
  }

  Future<Lecture> fetchLecture(int row) async {
    final map = await _worksheet!.values.map.row(row);

    return Lecture.fromGsheets(map);
  }

  // ✅ 기존 fetchAllLectures는 updateLectureCache 사용 (일관성 유지)
  Future<List<Lecture>> fetchAllLectures() async {
    await updateLectureCache();
    return _lectureCache;
  }

  // 현재 요일 LectureList 구하기
  List<Lecture> getLecturesForToday() {
    // 현재 요일 구하기
    final today = DateTime.now();
    final weekdayIndex = today.weekday; // 1 (월) ~ 7 (일)
    final Weekday todayWeekday = Weekday.values[(weekdayIndex - 1) % 7];

    // 오늘 요일에 해당하는 Lecture 필터링
    final todayLectures = lectureCache
        .where((lecture) => lecture.weekday == todayWeekday)
        .toList();

    // startAt 기준으로 정렬
    todayLectures.sort((a, b) {
      final aMinutes = a.startAt.hour * 60 + a.startAt.minute;
      final bMinutes = b.startAt.hour * 60 + b.startAt.minute;
      return aMinutes.compareTo(bMinutes);
    });

    print('📅 오늘 요일: ${weekdays[todayWeekday.index]} → ${todayLectures.length}개 강의');

    return todayLectures;
  }
}
