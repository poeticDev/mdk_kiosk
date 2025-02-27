import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/util/data/global_data.dart';
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

  @override
  Widget build(BuildContext context) {
    Future<List<Lecture>> lectures = gSheet.fetchAllLectures();

    return FutureBuilder(
        future: lectures,
        builder: (context, snapshot) {
          // 에러체크
          if (snapshot.hasError) {
            return Center(
                child: Text(
                    '에러가 발생했습니다. 관리자에게 문의하세요.\nError: ${snapshot.error.toString()}'));
          }

          // 데이터 로딩 중
          if (snapshot.data == null ||
              snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }

          return TimetableLayout(
            lectures: snapshot.data!,
          );
        });
  }
}
