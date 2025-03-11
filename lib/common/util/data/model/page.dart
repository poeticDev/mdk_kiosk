import 'package:drift/drift.dart';

class Page extends Table {
  /// 1) 식별 아이디
  IntColumn get id => integer().autoIncrement().nullable()();

  /// 2) 페이지 명
  TextColumn get pageName => text()();

  /// 3) 페이지 번호
  IntColumn get pageNum => integer()();
}