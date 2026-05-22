import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';
import 'package:mdk_kiosk/timetable/timetable_layout.dart';
import 'package:mdk_kiosk/timetable/util/google_sheets.dart';

class Timetable extends StatefulWidget {
  const Timetable({super.key});

  @override
  State<Timetable> createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  // Future<List<Lecture>> lectures;
  final GoogleSheets gSheet = GetIt.I<GoogleSheets>();
  late final Future<List<Lecture>> _lecturesFuture;

  @override
  void initState() {
    super.initState();
    print('[Timetable] initState() - creating lecture fetch future');
    _lecturesFuture = _loadLectures();
  }

  Future<List<Lecture>> _loadLectures() async {
    final stopwatch = Stopwatch()..start();
    print('[Timetable] fetch start');

    try {
      final lectures = await gSheet.fetchAllLectures();
      stopwatch.stop();
      print(
          '[Timetable] fetch success. lectureCount=${lectures.length}, elapsedMs=${stopwatch.elapsedMilliseconds}');
      return lectures;
    } catch (e, stackTrace) {
      stopwatch.stop();
      print('[Timetable] fetch failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _lecturesFuture,
        builder: (context, snapshot) {
          print(
              '[Timetable] FutureBuilder state=${snapshot.connectionState}, hasData=${snapshot.hasData}, hasError=${snapshot.hasError}');

          // 에러체크
          if (snapshot.hasError) {
            print('[Timetable] FutureBuilder error: ${snapshot.error}');
            return Center(
                child: Text(
                    '에러가 발생했습니다. 관리자에게 문의하세요.\nError: ${snapshot.error.toString()}'));
          }

          // 데이터 로딩 중
          if (snapshot.data == null ||
              snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }

          print('[Timetable] Rendering TimetableLayout with ${snapshot.data!.length} lectures');

          return TimetableLayout(
            lectures: snapshot.data!,
          );
        });
  }
}
