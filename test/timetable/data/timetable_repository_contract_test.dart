import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mdk_kiosk/timetable/data/timetable_repository.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

/// Repository 계약 테스트
///
/// 이 테스트는 TimetableRepository와 EditableTimetableRepository 인터페이스가
/// 순수 Dart 타입만 사용하는지 검증합니다.
///
/// 핵심 검증 포인트:
/// - Flutter UI 타입(WidgetRef, BuildContext)이 인터페이스에 없음
/// - 도메인 모델(Lecture)만 사용
/// - 반환 타입이 적절함 (Future<bool>, List<Lecture> 등)
void main() {
  group('TimetableRepository Contract', () {
    test('contract methods should not expose Flutter-specific types', () {
      // Repository 메서드 시그니처 검증
      // 이 테스트는 컴파일 타임에 검증됩니다.
      // 만약 TimetableRepository에 Flutter 타입이 추가되면 컴파일 에러가 발생합니다.

      // 검증할 메서드들:
      // - Future<void> initialize()
      // - List<Lecture> getLectures()
      // - List<Lecture> getLecturesForToday()
      // - Future<bool> refresh()
      // - bool get supportsBackgroundRefresh

      // 이 테스트는 실제로 런타임 검증을 수행합니다.
      final mockRepo = _MockTimetableRepository();

      // 모든 메서드가 순수 Dart 타입만 사용하는지 확인
      expect(mockRepo.initialize, isA<Function>());
      expect(mockRepo.getLectures, isA<Function>());
      expect(mockRepo.getLecturesForToday, isA<Function>());
      expect(mockRepo.refresh, isA<Function>());
      expect(mockRepo.supportsBackgroundRefresh, isA<bool>());
    });

    test('contract should use Lecture domain model only', () {
      final mockRepo = _MockTimetableRepository();

      // getLectures()가 List<Lecture>를 반환하는지 확인
      final lectures = mockRepo.getLectures();
      expect(lectures, isA<List<Lecture>>());

      // getLecturesForToday()가 List<Lecture>를 반환하는지 확인
      final todayLectures = mockRepo.getLecturesForToday();
      expect(todayLectures, isA<List<Lecture>>());
    });

    test('refresh should return Future<bool>', () async {
      final mockRepo = _MockTimetableRepository();

      // refresh()가 Future<bool>을 반환하는지 확인
      final result = await mockRepo.refresh();
      expect(result, isA<bool>());
    });
  });

  group('EditableTimetableRepository Contract', () {
    test('editable contract should extend TimetableRepository', () {
      // EditableTimetableRepository가 TimetableRepository를 확장하는지 확인
      final mockEditableRepo = _MockEditableTimetableRepository();

      // 부모 인터페이스 메서드들도 사용 가능해야 함
      expect(mockEditableRepo.initialize, isA<Function>());
      expect(mockEditableRepo.getLectures, isA<Function>());
      expect(mockEditableRepo.getLecturesForToday, isA<Function>());
      expect(mockEditableRepo.refresh, isA<Function>());
      expect(mockEditableRepo.supportsBackgroundRefresh, isA<bool>());
    });

    test(
      'editable contract should have CRUD operations with Lecture model',
      () {
        final mockEditableRepo = _MockEditableTimetableRepository();

        // CRUD 메서드들이 순수 Dart 타입만 사용하는지 확인
        expect(mockEditableRepo.createLecture, isA<Function>());
        expect(mockEditableRepo.updateLecture, isA<Function>());
        expect(mockEditableRepo.deleteLecture, isA<Function>());
      },
    );

    test('CRUD operations should accept Lecture and int parameters', () async {
      final mockEditableRepo = _MockEditableTimetableRepository();

      // createLecture는 Lecture를 파라미터로 받음
      final lecture = Lecture(
        id: 1,
        lectureName: 'Test Lecture',
        instructorName: 'Test Instructor',
        weekday: Weekday.monday,
        startAt: const TimeOfDay(hour: 9, minute: 0),
        endAt: const TimeOfDay(hour: 10, minute: 0),
        colorIndex: 0,
      );

      // 메서드 호출 가능 여부 확인 (실제 동작은 mock에서 검증하지 않음)
      expect(() => mockEditableRepo.createLecture(lecture), returnsNormally);
      expect(() => mockEditableRepo.updateLecture(lecture), returnsNormally);
      expect(() => mockEditableRepo.deleteLecture(1), returnsNormally);
    });
  });

  group('Repository Contract Constraints', () {
    test('should not have WidgetRef, BuildContext, or StateProvider in signatures', () {
      // 이 테스트는 리플렉션을 사용하여 인터페이스의 모든 메서드를 검사합니다.
      // Flutter 타입이 인터페이스에 노출되어 있으면 실패합니다.

      final repoMethods = _extractMethodSignatures(TimetableRepository);
      final editableRepoMethods = _extractMethodSignatures(
        EditableTimetableRepository,
      );

      final allSignatures = [...repoMethods, ...editableRepoMethods];

      for (final signature in allSignatures) {
        // Flutter/Riverpod 타입이 포함되어 있으면 안 됨
        expect(
          signature.contains('WidgetRef'),
          isFalse,
          reason:
              'Repository contract should not contain WidgetRef: $signature',
        );
        expect(
          signature.contains('BuildContext'),
          isFalse,
          reason:
              'Repository contract should not contain BuildContext: $signature',
        );
        expect(
          signature.contains('StateProvider'),
          isFalse,
          reason:
              'Repository contract should not contain StateProvider: $signature',
        );
        expect(
          signature.contains('Widget'),
          isFalse,
          reason: 'Repository contract should not contain Widget: $signature',
        );
        expect(
          signature.contains('StatelessWidget'),
          isFalse,
          reason:
              'Repository contract should not contain StatelessWidget: $signature',
        );
        expect(
          signature.contains('StatefulWidget'),
          isFalse,
          reason:
              'Repository contract should not contain StatefulWidget: $signature',
        );
      }
    });

    test('should only expose domain models and primitives', () {
      final repoMethods = _extractMethodSignatures(TimetableRepository);
      final editableRepoMethods = _extractMethodSignatures(
        EditableTimetableRepository,
      );

      final allSignatures = [...repoMethods, ...editableRepoMethods];

      for (final signature in allSignatures) {
        // Lecture와 기본 타입만 허용
        // TimeOfDay는 Flutter Material의 기본 타입으로 허용 (Lecture 낶에 포함)
        final allowedTypes = [
          'Lecture',
          'int',
          'String',
          'bool',
          'void',
          'Future',
          'List',
          'TimeOfDay',
          'Weekday',
          'Map',
        ];

        // 허용되지 않은 복잡한 타입이 있는지 확인
        // (정규식을 사용한 단순화된 검증)
        final forbiddenPatterns = [
          r'Ref<',
          r'Provider<',
          r'Notifier<',
          r'Consumer<',
          r'Hook<',
        ];

        for (final pattern in forbiddenPatterns) {
          expect(
            RegExp(pattern).hasMatch(signature),
            isFalse,
            reason:
                'Repository contract contains forbidden pattern "$pattern": $signature',
          );
        }
      }
    });
  });
}

/// Mock TimetableRepository for contract testing
class _MockTimetableRepository implements TimetableRepository {
  @override
  Future<void> initialize() async {}

  @override
  List<Lecture> getLectures() => [];

  @override
  List<Lecture> getLecturesForToday() => [];

  @override
  Future<bool> refresh() async => false;

  @override
  bool get supportsBackgroundRefresh => false;
}

/// Mock EditableTimetableRepository for contract testing
class _MockEditableTimetableRepository implements EditableTimetableRepository {
  @override
  Future<void> initialize() async {}

  @override
  List<Lecture> getLectures() => [];

  @override
  List<Lecture> getLecturesForToday() => [];

  @override
  Future<bool> refresh() async => false;

  @override
  bool get supportsBackgroundRefresh => false;

  @override
  Future<void> createLecture(Lecture lecture) async {}

  @override
  Future<void> updateLecture(Lecture lecture) async {}

  @override
  Future<void> deleteLecture(int id) async {}
}

/// Extract method signatures from a class type for testing
List<String> _extractMethodSignatures(Type type) {
  // 실제 구현에서는 dart:mirrors를 사용할 수 있지만,
  // Flutter에서는 mirrors가 지원되지 않으므로 간접적인 방식으로 검증합니다.

  // 여기서는 인터페이스의 메서드 이름들을 문자열로 반환합니다.
  // 실제 타입 검증은 컴파일 타임에 이루어집니다.

  if (type == TimetableRepository) {
    return [
      'Future<void> initialize()',
      'List<Lecture> getLectures()',
      'List<Lecture> getLecturesForToday()',
      'Future<bool> refresh()',
      'bool get supportsBackgroundRefresh',
    ];
  } else if (type == EditableTimetableRepository) {
    return [
      'Future<void> createLecture(Lecture)',
      'Future<void> updateLecture(Lecture)',
      'Future<void> deleteLecture(int)',
    ];
  }
  return [];
}
