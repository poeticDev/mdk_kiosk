import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

void main() {
  group('Lecture.getTimeFromGsheets', () {
    test('HH:mm 문자열을 TimeOfDay로 변환한다', () {
      final TimeOfDay result = Lecture.getTimeFromGsheets('09:30');

      expect(result.hour, 9);
      expect(result.minute, 30);
    });

    test('구글시트 시간 시리얼 문자열을 TimeOfDay로 변환한다', () {
      final TimeOfDay result = Lecture.getTimeFromGsheets('0.375');

      expect(result.hour, 9);
      expect(result.minute, 0);
    });

    test('날짜를 포함한 시리얼 문자열에서는 시간 소수부만 사용한다', () {
      final TimeOfDay result = Lecture.getTimeFromGsheets('45291.75');

      expect(result.hour, 18);
      expect(result.minute, 0);
    });
  });
}
