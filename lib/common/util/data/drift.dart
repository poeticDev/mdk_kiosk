import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/cupertino.dart' show BoxFit;
import 'package:get_it/get_it.dart';

import 'package:mdk_kiosk/common/util/data/model/basicInfo.dart';
import 'package:mdk_kiosk/common/util/data/model/button.dart';
import 'package:mdk_kiosk/common/util/data/model/button_with_page.dart';
import 'package:mdk_kiosk/common/util/data/model/page.dart';
import 'package:mdk_kiosk/common/util/data/model/media_item.dart';

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
  Future<List<MediaItemData>> getMediaItemDataList() => select(mediaItem).get();

  // MediaItem 생성
  Future<int> createMediaItems(MediaItemCompanion data) =>
      into(mediaItem).insert(data);

  // MediaItem 수정
  Future<int> updateMediaItem(int id, MediaItemCompanion data) {
    return (update(mediaItem)..where((t) => t.id.equals(id))).write(data);
  }

  Future<int> deleteMediaItem(int id) {
    return (delete(mediaItem)..where((t) => t.id.equals(id))).go();
  }

  Future<void> upsertMediaItemByUrl(MediaItemCompanion data) async {
    final existingItem = await (select(mediaItem)
          ..where((t) => t.url.equals(data.url.value)))
        .getSingleOrNull();

    if (existingItem == null) {
      // 해당 url이 없으면 새로 삽입
      await createMediaItems(data);
    } else {
      // 해당 url이 있으면 기존 데이터 업데이트
      await updateMediaItem(existingItem.id, data);
    }
  }

  Future<void> syncMediaItems(List<MediaItemCompanion> newItems) async {
    // 현재 DB에 저장된 모든 URL 가져오기
    final currentItems = await getMediaItemDataList();
    final currentUrls = currentItems.map((e) => e.url).toSet();

    // 새로 받은 데이터의 URL 추출
    final newUrls = newItems.map((e) => e.url.value).toSet();

    // 삭제할 URL 목록 (기존에는 있는데, 새 데이터엔 없는 것들)
    final urlsToDelete = currentUrls.difference(newUrls);

    // 삭제 작업
    await (delete(mediaItem)..where((tbl) => tbl.url.isIn(urlsToDelete))).go();

    // 새 데이터는 upsert로 삽입/수정
    for (final item in newItems) {
      await upsertMediaItemByUrl(item);
    }
  }
}
