import 'package:drift/drift.dart';
import 'package:mdk_kiosk/common/util/data/model/page.dart';

// command 종류
enum Command {
  // down and up
  press,

  // down : 누름. up이 없으면 hold
  down,

  // up : 안 누름. down이 선행되지 않으면 무효
  up,
}

class Button extends Table {
  /// 1) 식별 아이디
  IntColumn get id => integer().autoIncrement().nullable()();

  /// 2) 버튼명
  TextColumn get buttonName =>
      text().withDefault(const Constant('버튼명을 적어주세요'))();

  /// 3) osc 전송방식 : 버튼 조작 or 쿼리
  BoolColumn get isUsingButton => boolean().withDefault(const Constant(true))();

  /// 4) 페이지
  IntColumn get page => integer()
      .references(Page, #id, onUpdate: KeyAction.cascade)
      .withDefault(const Constant(0))();

  /// 5) 행
  IntColumn get row => integer().withDefault(const Constant(0))();

  /// 6) 열
  IntColumn get column => integer().withDefault(const Constant(0))();

  /// 7) 명령어
  /// press, down, up...
  TextColumn get command =>
      textEnum<Command>().withDefault(const Constant('press'))();

  /// 8) 쿼리스트링
  TextColumn get queryString => text().nullable()();

  /// 9) 메세지
  TextColumn get message => text().nullable()();
}
