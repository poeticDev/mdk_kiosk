import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/cupertino.dart' show BoxFit;
import 'package:get_it/get_it.dart';

import 'package:mdk_kiosk/common/util/data/model/basicInfo.dart';
import 'package:mdk_kiosk/common/util/data/model/button.dart';
import 'package:mdk_kiosk/common/util/data/model/button_with_page.dart';
import 'package:mdk_kiosk/common/util/data/model/page.dart';
import 'package:mdk_kiosk/common/util/data/model/MediaItem.dart';

part 'drift.g.dart';

@DriftDatabase(tables: [BasicInfo, Page, Button, MediaItem])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  static AppDatabase? _instance;

  static AppDatabase get instance {
    _instance ??= AppDatabase();
    return _instance!;
  }

  /// Database Open
  static void openDB() {
    if (!GetIt.I.isRegistered<AppDatabase>()) {
      final db = instance;
      GetIt.I.registerSingleton<AppDatabase>(db);
    }
  }

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    // driftDatabase from package:drift_flutter stores the database in
    // getApplicationDocumentsDirectory().
    return driftDatabase(name: 'tablet_database');
  }

  /// 1. BasicInfo
  Future<BasicInfoData?> getLatestBasicInfo() async {
    final query = select(basicInfo)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
      ])
      ..limit(1); // limit을 직접 사용

    final result = await query.get(); // 쿼리 실행

    // 결과가 있을 경우 첫 번째 데이터를 반환
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<BasicInfoData>> getBasicInfos() => select(basicInfo).get();

  // basicinfo를 생성
  Future<int> createBasicInfo(BasicInfoCompanion data) =>
      into(basicInfo).insert(data);

  /// 2. Pages
  Future<List<PageData>> getPages() => select(page).get();

  // page를 생성
  Future<int> createPage(PageCompanion data) => into(page).insert(data);

  // page를 수정
  Future<int> updatePage(int id, PageCompanion data) =>
      (update(page)..where((t) => t.id.equals(id))).write(data);

  /// 3. Button
  Future<List<ButtonData>> getButtons() => select(button).get();

  Future<ButtonData?> getButtonById(int buttonId) async {
    final result = await (select(button)
          ..where((tbl) => tbl.id.equals(buttonId)))
        .getSingleOrNull();
    return result;
  }

  Future<bool> doesButtonExist(int buttonId) async {
    final result = await (select(button)
          ..where((tbl) => tbl.id.equals(buttonId)))
        .getSingleOrNull();
    return result != null; // ✅ 존재하면 true, 없으면 false 반환
  }

  // button 생성
  Future<int> createButton(ButtonCompanion data) => into(button).insert(data);

  // button 수정
  Future<int> updateButton(int id, ButtonCompanion data) {
    return (update(button)..where((t) => t.id.equals(id))).write(data);
  }

  /// 2+3.Button with Page
  Future<List<ButtonWithPage>> getButtonWithPage() {
    final query = (select(button)
          ..orderBy([
            (t) => OrderingTerm(expression: t.page, mode: OrderingMode.asc)
          ]))
        .join([
      innerJoin(page, page.id.equalsExp(button.page)),
    ]);

    return query.map((row) {
      final buttonInfo = row.readTable(button);
      final pageInfo = row.readTable(page);

      return ButtonWithPage(button: buttonInfo, page: pageInfo);
    }).get();
  }


  /// 4. MediaItem
  Future<List<MediaItemData>> getMediaItems() => select(mediaItem).get();

  // button 생성
  Future<int> createMediaItems(MediaItemCompanion data) => into(mediaItem).insert(data);

  // button 수정
  Future<int> updateMediaItem(int id, MediaItemCompanion data) {
    return (update(mediaItem)..where((t) => t.id.equals(id))).write(data);
  }

  Future<int> deleteMediaItem(int id) {
    return (delete(mediaItem)..where((t) => t.id.equals(id))).go();
  }


}
