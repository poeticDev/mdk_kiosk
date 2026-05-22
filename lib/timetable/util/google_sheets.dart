import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

class GoogleSheets {
  static const _spreadSheetId = '1cDSkWV4GQohzon0JH_Wf58OM9mWjSxsUnu2yIm9y2rY';
  final String sheetName;

  GoogleSheets({required this.sheetName});

  Future<Map<String, dynamic>> loadCredentials() async {
    print('[Timetable][GoogleSheets] Loading credentials asset for sheet: $sheetName');
    final jsonString = await rootBundle.loadString('asset/env/credentials.json');
    final credentials = jsonDecode(jsonString) as Map<String, dynamic>;
    print(
        '[Timetable][GoogleSheets] Credentials loaded. project_id=${credentials['project_id']}, client_email=${credentials['client_email']}');
    return credentials;
  }

  static late final _credentials;

  // r'''
  //   {
  // "type": "service_account",
  // "project_id": "test-flutter-spreadsheet-sync",
  // "private_key_id": "1c73c25a8ea09912325dd5a7df59c092902cce5a",
  // "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDXx0HWi8nMYxxY\nP4y4uYfd+5nYtP4f3ddpYCcC+TRzJFCWd/odooDNA6VNc96At88az6I7LO0KNIWn\nEQ4OMqsPgUFfT1e/eYuOhtlKPUepwFfGcrnP7KlOBrpnAtFK60chiBFjNKfv2Hi3\nP8mXfaeevccFS8veqELqFAYh2o3vMkGMvZPheqDjEfUWvMljLORyBbWuJpjueVw2\nEQdrAVbxzkaUMmKYpqzV+IrvWXnvLswPWrF7PmdQJ/30BrScPPXaMXK2UfPuILW4\neMWmGV7E4NTHxezktPzsegPg7HsqD2FoLss8r2zU/MI9YsMi+EkXAB6XW1NnZ21b\n2B1mqIbTAgMBAAECggEAHZRbGiYfi70qbY6Io+oLDgsnk+V70LKAjRl5P5cZ8Y7Q\n3U+lIdrc/T26s1tm7Q5Ffc9o1ePausNobvaPjrKzcHSvmXku9jibQPaLYvnzkPml\nDrc7cZ1nuCKD+wsP1c1a+uXEPG1DeEWchsJfyDyZddFeLwOs9uDqC1yjWpCzVE62\n0nN6p/nAo3gWo4F5/0KV7gyukvqhoIjsaQlkjJReS9jaFXWRZHaxef502OzGC17M\nGmqfXHkST7dWgwJ59b2y+yOd860pp0N/Hfm6+4fwVgCYn7c0gceYcuFKKOSnm/7V\nekg2L9BNednaahNjfWjRzYT4Bu9iQacDl77hJNAZAQKBgQD44CrfxxPmK0/9h33k\nyNaQESv3Iglk/kcxUcAo705fo800kiNnHwQHJWFDDlYOshn9Nm4DV4kDGuXzGQ9V\nO8yWsvs5DqSLvUNCjPJiyPBhvkKSios1XGELnofRUG8R78CkzA1isZrQEJ2Q9idt\niyoqWKRC/4nj9ISUvkMox1EFQwKBgQDd9IsJCLkBdv8AHqE3GoxvtyxcwwSuCPiU\nnB1rMVuTOUi1gQrpaIksn37sB0O7tGUQsYYMFcpmAmAvCMIdt8H2ChKh2myDpePh\nAVP6w4uV0XoNV+fYyWhlRBgflNrcVFbmwDbSxbWhQ9Iw8Dad1XWxmQIcc1x1HkbF\ngI91iwSXMQKBgQCkkVbIcpOt96YFN7r/te5rhW9VE6Syq5HYAv7WEqf4hhADWz8d\nyVyYfRc7iBdP0GVvErbcbt2it/6mKUQCUHCQlfmZWR1ladk4AIum1shdWbobvJEg\nz908GbAlsNJBQhBY6LVRNa/xNYt7d8nKneNb7RFxXBiKK/4ffVBbfrEMkQKBgDVj\nYR4nLvkfOm847uZmSGmG0fDuJ+4E0mZMtvbVxIVBPjAKfilur7BAHTOA+9Xmqni9\netTlWO34nFIz9R1Y2hroiVrNQ1TXTl0NCLpE1wqOfKFBB8+pgqb5HiRaldpxnwWa\nLpW8YNgNjD2hSkHk2o6Bk3Rse0zgn31aUyee7NfBAoGABtGrQGxMsVsbbkpTHhb7\n/ohL63Yg6Txo0gIyV+0pHRmjZ+FZMXTKQRTdg6P9MUlh3FGZezlL4xyIy8R/cPTw\n4VsMVwGJPLI06eCQkf7qxB9cCsADHGg9rgKVsHXJPFAKxZqUAREIx6188WmWPOvA\nR1bxuciq9/4m4TyG0hrQ2KM=\n-----END PRIVATE KEY-----\n",
  // "client_email": "test-flutter-sheets-sync@test-flutter-spreadsheet-sync.iam.gserviceaccount.com",
  // "client_id": "113459007087480478007",
  // "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  // "token_uri": "https://oauth2.googleapis.com/token",
  // "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  // "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/test-flutter-sheets-sync%40test-flutter-spreadsheet-sync.iam.gserviceaccount.com",
  // "universe_domain": "googleapis.com"
  //   }
  // '''

  static final _sheet = GSheets(_credentials); // 스프레드시트
  static Worksheet? _worksheet; // 스프레드시트 중 작업 대상 시트

  Future<void> initialize() async {
    print('[Timetable][GoogleSheets] initialize() start. sheetName=$sheetName');
    try {
      _credentials = await loadCredentials();

      _worksheet = await _getWorksheet(
        await _sheet.spreadsheet(_spreadSheetId),
        title: sheetName.toString(),
      );
      print(
          '[Timetable][GoogleSheets] initialize() done. worksheetTitle=${_worksheet?.title}, sheetName=$sheetName');
    } catch (e, stackTrace) {
      print('[Timetable][GoogleSheets] initialize() failed for sheetName=$sheetName: $e');
      print(stackTrace);
      rethrow;
    }
  }

  Future<void> reInitialize() async {
    print('[Timetable][GoogleSheets] reInitialize() start. sheetName=$sheetName');
    try {
      _worksheet = await _getWorksheet(
        await _sheet.spreadsheet(_spreadSheetId),
        title: sheetName.toString(),
      );
      print(
          '[Timetable][GoogleSheets] reInitialize() done. worksheetTitle=${_worksheet?.title}, sheetName=$sheetName');
    } catch (e, stackTrace) {
      print('[Timetable][GoogleSheets] reInitialize() failed for sheetName=$sheetName: $e');
      print(stackTrace);
      rethrow;
    }
  }

  /// 먼저 시트를 생성하고, 이미 있을 경우는 해당 시트를 가져온다.
  static Future<Worksheet> _getWorksheet(
    Spreadsheet spreadsheet, {
    required String title,
  }) async {
    try {
      print('[Timetable][GoogleSheets] Creating worksheet if needed: $title');
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
      print('[Timetable][GoogleSheets] Worksheet created: ${worksheet.title}');
      return worksheet;
    } catch (e) {
      print(
          '[Timetable][GoogleSheets] Worksheet create skipped/failed for $title. Falling back to existing worksheet. error=$e');
      final existingWorksheet = spreadsheet.worksheetByTitle(title);
      if (existingWorksheet == null) {
        throw Exception(
            '[Timetable][GoogleSheets] Worksheet not found after fallback. title=$title, error=$e');
      }
      print('[Timetable][GoogleSheets] Existing worksheet found: ${existingWorksheet.title}');
      return existingWorksheet;
    }
  }

  /// appendRow는 insert처럼 덮어씌우기가 아니라, 아래 로우에 차곡차곡 insert 된다.
  static Future<void> append() async {
    await _worksheet!.values
        .appendRow(fromColumn: 1, ['test1', 'test2', 'test3']);
  }

  Future<List<String>> getRow(int row) async {
    late final List<String> values;
    if (_worksheet != null) values = await _worksheet!.values.row(row);

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

  Future<List<Lecture>> fetchAllLectures() async {
    print('[Timetable][GoogleSheets] fetchAllLectures() start. sheetName=$sheetName');
    final worksheet = _worksheet;
    if (worksheet == null) {
      throw StateError(
          '[Timetable][GoogleSheets] fetchAllLectures() called before worksheet initialization. sheetName=$sheetName');
    }

    try {
      final rows = await worksheet.values.map.allRows(fromRow: 3);
      final rowCount = rows?.length ?? 0;
      print(
          '[Timetable][GoogleSheets] fetchAllLectures() rows fetched: $rowCount from worksheet=${worksheet.title}');

      if (rows == null || rows.isEmpty) {
        print(
            '[Timetable][GoogleSheets] No lecture rows found from row 3. worksheet=${worksheet.title}');
        return [];
      }

      final lectures = <Lecture>[];
      for (final row in rows) {
        try {
          lectures.add(Lecture.fromGsheets(row));
        } catch (e, stackTrace) {
          print('[Timetable][GoogleSheets] Failed to parse lecture row: $row');
          print(e);
          print(stackTrace);
          rethrow;
        }
      }

      print(
          '[Timetable][GoogleSheets] fetchAllLectures() success. parsedLectures=${lectures.length}');
      return lectures;
    } catch (e, stackTrace) {
      print('[Timetable][GoogleSheets] fetchAllLectures() failed. sheetName=$sheetName');
      print(e);
      print(stackTrace);
      rethrow;
    }
  }
}
