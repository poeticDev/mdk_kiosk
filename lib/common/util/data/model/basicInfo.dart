import 'package:drift/drift.dart';

class BasicInfo extends Table {
  /// 0. 아이디
  IntColumn get id => integer().autoIncrement()();

  /// 1. 강의실 정보
  TextColumn get roomId => text()();
  TextColumn get roomName => text().withDefault(const Constant('000동 0000호'))();
  BlobColumn get logoImage => blob()();
  TextColumn get titleText => text().withDefault(const Constant('Wall Hub'))();
  TextColumn get wifiName => text().withDefault(const Constant('와이파이 이름'))();

  /// 2. 태블릿
  // TextColumn get myIp => text().withDefault(const Constant('192.168.11.111'))();
  IntColumn get myOscPort => integer().withDefault(const Constant(3000))();
  TextColumn get myPassword => text().withDefault(const Constant('12344321!'))();

  /// 3. 서버
  TextColumn get serverIp => text().withDefault(const Constant('192.168.11.120'))();
  IntColumn get serverOscPort => integer().withDefault(const Constant(12321))();
  IntColumn get serverMqttPort => integer().withDefault(const Constant(1883))();
  TextColumn get serverMqttId => text().withDefault(const Constant('mdk'))();
  TextColumn get serverMqttPassword => text().withDefault(const Constant('12344321'))();

  // IntColumn get ndiPort => integer().withDefault(const Constant(12322))();
  // TextColumn get serverMac => text().nullable()();
  // BoolColumn get isServerUnder331 => boolean().withDefault(const Constant(false))();


  ///4. 생성일
  DateTimeColumn get createdAt => dateTime().clientDefault(
        () => DateTime.now(),
  )();
}