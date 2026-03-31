import '../model/lecture.dart';

/// 시간표 데이터 저장소 추상 계약
///
/// 모든 시간표 데이터 소스(Google Sheets, 로컬 DB, 로컬 서버 등)는
/// 이 인터페이스를 구현해야 합니다.
///
/// 계약은 순수 Dart 타입만 사용하며 Flutter/Riverpod 타입을 노출하지 않습니다.
abstract class TimetableRepository {
  /// 저장소 초기화
  ///
  /// 데이터베이스 연결, API 클라이언트 설정 등의 초기화 작업을 수행합니다.
  Future<void> initialize();

  /// 모든 강의 목록 조회
  ///
  /// 저장소에서 모든 강의 정보를 가져옵니다.
  List<Lecture> getLectures();

  /// 오늘 요일의 강의 목록 조회
  ///
  /// 현재 요일에 해당하는 강의만 필터링하여 반환합니다.
  List<Lecture> getLecturesForToday();

  /// 시간표 데이터 새로고침
  ///
  /// 외부 소스(Google Sheets, 서버 등)에서 최신 데이터를 가져옵니다.
  /// 데이터가 변경되었으면 true, 변경되지 않았으면 false를 반환합니다.
  ///
  /// 로컬 DB처럼 외부 동기화가 필요 없는 소스는 true를 반환할 수 있습니다.
  Future<bool> refresh();

  /// 백그라운드 자동 새로고침 지원 여부
  ///
  /// true인 경우 주기적인 백그라운드 새로고침(polling)을 활성화합니다.
  /// Google Sheets와 같이 외부 데이터 변경을 감지해야 하는 소스는 true를 반환합니다.
  /// 로컬 DB처럼 낮은 수준에서 변경 감지가 가능한 소스는 false를 반환합니다.
  bool get supportsBackgroundRefresh;
}

/// 편집 가능한 시간표 저장소 추상 계약
///
/// [TimetableRepository]를 확장하여 CRUD(Create, Read, Update, Delete)
/// 작업을 지원하는 인터페이스입니다.
///
/// 로컬 DB처럼 디바이스 내에서 직접 데이터를 수정할 수 있는 소스만
/// 이 인터페이스를 구현해야 합니다.
abstract class EditableTimetableRepository extends TimetableRepository {
  /// 새 강의 생성
  ///
  /// [lecture] 객체를 저장소에 추가합니다.
  /// id는 저장소에서 자동 할당할 수 있습니다.
  Future<void> createLecture(Lecture lecture);

  /// 기존 강의 수정
  ///
  /// [lecture]의 id에 해당하는 강의 정보를 업데이트합니다.
  /// id가 존재하지 않으면 예외를 발생시킬 수 있습니다.
  Future<void> updateLecture(Lecture lecture);

  /// 강의 삭제
  ///
  /// [id]에 해당하는 강의를 저장소에서 제거합니다.
  /// id가 존재하지 않으면 조용히 무시할 수 있습니다.
  Future<void> deleteLecture(int id);
}
