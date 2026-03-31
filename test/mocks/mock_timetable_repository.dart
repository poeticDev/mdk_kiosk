import 'package:mdk_kiosk/timetable/data/timetable_repository.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

/// 테스트용 Mock EditableTimetableRepository
///
/// 메모리 기반으로 동작하며 CRUD 작업을 지원합니다.
class MockEditableTimetableRepository implements EditableTimetableRepository {
  final List<Lecture> _lectures = [];
  int _nextId = 1;

  @override
  List<Lecture> getLectures() => List.unmodifiable(_lectures);

  @override
  List<Lecture> getLecturesForToday() {
    final today = DateTime.now();
    final weekdayIndex = today.weekday;
    final todayWeekday = Weekday.values[(weekdayIndex - 1) % 7];

    return _lectures
        .where((lecture) => lecture.weekday == todayWeekday)
        .toList();
  }

  @override
  Future<bool> refresh() async {
    // 메모리 기반이므로 항상 false (변경 없음)
    return false;
  }

  @override
  Future<void> initialize() async {
    // 초기화 불필요
  }

  @override
  bool get supportsBackgroundRefresh => false;

  @override
  Future<void> createLecture(Lecture lecture) async {
    final newLecture = Lecture(
      id: _nextId++,
      lectureName: lecture.lectureName,
      instructorName: lecture.instructorName,
      weekday: lecture.weekday,
      startAt: lecture.startAt,
      endAt: lecture.endAt,
      colorIndex: lecture.colorIndex,
    );
    _lectures.add(newLecture);
  }

  @override
  Future<void> updateLecture(Lecture lecture) async {
    final index = _lectures.indexWhere((l) => l.id == lecture.id);
    if (index >= 0) {
      _lectures[index] = lecture;
    }
  }

  @override
  Future<void> deleteLecture(int id) async {
    _lectures.removeWhere((l) => l.id == id);
  }

  /// 테스트 헬퍼: 모든 강의 삭제
  void clear() {
    _lectures.clear();
    _nextId = 1;
  }
}
