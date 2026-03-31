// 시간표 데이터 소스 유형을 정의합니다.
// 개발자 상수로만 제어하며 DB에 저장하지 않습니다.

// 소스 유형 열거형
/// - googleSheets: Google Sheets에서 시간표 데이터 조회
/// - localDb: 로컬 drift DB에서 시간표 데이터 관리
/// - localServer: 향후 확장용 (현재 미구현)
enum TimetableSourceType {
  /// Google Sheets에서 시간표 조회
  googleSheets,

  /// 로컬 drift DB에서 시간표 관리 (오프라인 우선)
  localDb,

  /// 로컬 서버에서 시간표 조회 (향후 확장용, 미구현)
  localServer,
}

/// 현재 활성화된 시간표 소스 (개발자가 빌드 시 설정)
/// 기본값: localDb (오프라인 우선)
const TimetableSourceType activeTimetableSource = TimetableSourceType.localDb;

/// TimetableSourceType 확장 메서드
extension TimetableSourceTypeExtension on TimetableSourceType {
  /// 해당 소스가 편집 가능한지 반환합니다.
  /// 현재는 localDb만 편집 가능합니다.
  bool get isEditable => this == TimetableSourceType.localDb;
}
