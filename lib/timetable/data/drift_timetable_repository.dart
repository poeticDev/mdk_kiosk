import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/timetable/data/timetable_repository.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

/// Drift 로컬 데이터베이스 기반 시간표 저장소 구현
///
/// [EditableTimetableRepository] 인터페이스를 구현하여 CRUD 작업을 지원합니다.
/// 모든 쿼리는 roomId로 필터링되어 강의실별 데이터 격리를 보장합니다.
class DriftTimetableRepository implements EditableTimetableRepository {
  final AppDatabase _db;
  final String _roomId;

  // 강의 정보 캐시
  List<Lecture> _lectureCache = [];

  DriftTimetableRepository({required AppDatabase db, required String roomId})
    : _db = db,
      _roomId = roomId;

  @override
  Future<void> initialize() async {
    // DB는 외부에서 이미 초기화됨
    // 캐시 초기화
    await refresh();
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

    final List<Lecture> todayLectures = _lectureCache
        .where((Lecture lecture) => lecture.weekday == todayWeekday)
        .toList();

    // 시작 시간순 정렬
    todayLectures.sort((Lecture a, Lecture b) {
      final int aMinutes = a.startAt.hour * 60 + a.startAt.minute;
      final int bMinutes = b.startAt.hour * 60 + b.startAt.minute;
      return aMinutes.compareTo(bMinutes);
    });

    return todayLectures;
  }

  @override
  Future<bool> refresh() async {
    final List<Timetable> timetables = await _db.getTimetablesForRoom(_roomId);
    final List<Lecture> newLectures = timetables
        .map(_timetableToLecture)
        .toList();

    final bool hasChanged = !_areLectureListsEqual(_lectureCache, newLectures);

    if (hasChanged) {
      _lectureCache = newLectures;
    }

    return hasChanged;
  }

  @override
  bool get supportsBackgroundRefresh => false;

  @override
  Future<void> createLecture(Lecture lecture) async {
    final companion = _lectureToTimetablesCompanion(lecture);
    await _db.createTimetable(companion);
    await refresh();
  }

  @override
  Future<void> updateLecture(Lecture lecture) async {
    final companion = _lectureToTimetablesCompanion(lecture);
    await _db.updateTimetable(lecture.id, companion);
    await refresh();
  }

  @override
  Future<void> deleteLecture(int id) async {
    await _db.deleteTimetable(id);
    await refresh();
  }

  /// Timetable → Lecture 변환
  Lecture _timetableToLecture(Timetable data) {
    return Lecture(
      id: data.id,
      lectureName: data.lectureName,
      instructorName: data.instructorName,
      weekday: Weekday.values[data.weekdayIndex % 7],
      startAt: TimeOfDay(
        hour: data.startMinutes ~/ 60,
        minute: data.startMinutes % 60,
      ),
      endAt: TimeOfDay(
        hour: data.endMinutes ~/ 60,
        minute: data.endMinutes % 60,
      ),
      colorIndex: data.colorIndex,
    );
  }

  /// Lecture → TimetablesCompanion 변환
  TimetablesCompanion _lectureToTimetablesCompanion(Lecture lecture) {
    return TimetablesCompanion(
      id: lecture.id > 0 ? Value(lecture.id) : Value.absent(),
      roomId: Value(_roomId),
      lectureName: Value(lecture.lectureName),
      instructorName: Value(lecture.instructorName),
      weekdayIndex: Value(lecture.weekday.index),
      startMinutes: Value(lecture.startAt.hour * 60 + lecture.startAt.minute),
      endMinutes: Value(lecture.endAt.hour * 60 + lecture.endAt.minute),
      colorIndex: Value(lecture.colorIndex),
    );
  }

  /// 강의 리스트 비교 (순서 포함)
  bool _areLectureListsEqual(List<Lecture> list1, List<Lecture> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
