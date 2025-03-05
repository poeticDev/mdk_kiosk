// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift.dart';

// ignore_for_file: type=lint
class $BasicInfoTable extends BasicInfo
    with TableInfo<$BasicInfoTable, BasicInfoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BasicInfoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roomNameMeta =
      const VerificationMeta('roomName');
  @override
  late final GeneratedColumn<String> roomName = GeneratedColumn<String>(
      'room_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('건물번호-강의실번호'));
  static const VerificationMeta _logoImageMeta =
      const VerificationMeta('logoImage');
  @override
  late final GeneratedColumn<Uint8List> logoImage = GeneratedColumn<Uint8List>(
      'logo_image', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _wifiNameMeta =
      const VerificationMeta('wifiName');
  @override
  late final GeneratedColumn<String> wifiName = GeneratedColumn<String>(
      'wifi_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleTextMeta =
      const VerificationMeta('titleText');
  @override
  late final GeneratedColumn<String> titleText = GeneratedColumn<String>(
      'title_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Wall Hub'));
  static const VerificationMeta _myOscPortMeta =
      const VerificationMeta('myOscPort');
  @override
  late final GeneratedColumn<int> myOscPort = GeneratedColumn<int>(
      'my_osc_port', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3000));
  static const VerificationMeta _myPasswordMeta =
      const VerificationMeta('myPassword');
  @override
  late final GeneratedColumn<String> myPassword = GeneratedColumn<String>(
      'my_password', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('12344321!'));
  static const VerificationMeta _serverIpMeta =
      const VerificationMeta('serverIp');
  @override
  late final GeneratedColumn<String> serverIp = GeneratedColumn<String>(
      'server_ip', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('192.168.11.120'));
  static const VerificationMeta _serverOscPortMeta =
      const VerificationMeta('serverOscPort');
  @override
  late final GeneratedColumn<int> serverOscPort = GeneratedColumn<int>(
      'server_osc_port', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(12321));
  static const VerificationMeta _serverMqttPortMeta =
      const VerificationMeta('serverMqttPort');
  @override
  late final GeneratedColumn<int> serverMqttPort = GeneratedColumn<int>(
      'server_mqtt_port', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1883));
  static const VerificationMeta _serverMqttIdMeta =
      const VerificationMeta('serverMqttId');
  @override
  late final GeneratedColumn<String> serverMqttId = GeneratedColumn<String>(
      'server_mqtt_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('mdk'));
  static const VerificationMeta _serverMqttPasswordMeta =
      const VerificationMeta('serverMqttPassword');
  @override
  late final GeneratedColumn<String> serverMqttPassword =
      GeneratedColumn<String>('server_mqtt_password', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('12344321'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  @override
  List<GeneratedColumn> get $columns => [
        id,
        roomId,
        roomName,
        logoImage,
        wifiName,
        titleText,
        myOscPort,
        myPassword,
        serverIp,
        serverOscPort,
        serverMqttPort,
        serverMqttId,
        serverMqttPassword,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'basic_info';
  @override
  VerificationContext validateIntegrity(Insertable<BasicInfoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('room_name')) {
      context.handle(_roomNameMeta,
          roomName.isAcceptableOrUnknown(data['room_name']!, _roomNameMeta));
    }
    if (data.containsKey('logo_image')) {
      context.handle(_logoImageMeta,
          logoImage.isAcceptableOrUnknown(data['logo_image']!, _logoImageMeta));
    } else if (isInserting) {
      context.missing(_logoImageMeta);
    }
    if (data.containsKey('wifi_name')) {
      context.handle(_wifiNameMeta,
          wifiName.isAcceptableOrUnknown(data['wifi_name']!, _wifiNameMeta));
    }
    if (data.containsKey('title_text')) {
      context.handle(_titleTextMeta,
          titleText.isAcceptableOrUnknown(data['title_text']!, _titleTextMeta));
    }
    if (data.containsKey('my_osc_port')) {
      context.handle(
          _myOscPortMeta,
          myOscPort.isAcceptableOrUnknown(
              data['my_osc_port']!, _myOscPortMeta));
    }
    if (data.containsKey('my_password')) {
      context.handle(
          _myPasswordMeta,
          myPassword.isAcceptableOrUnknown(
              data['my_password']!, _myPasswordMeta));
    }
    if (data.containsKey('server_ip')) {
      context.handle(_serverIpMeta,
          serverIp.isAcceptableOrUnknown(data['server_ip']!, _serverIpMeta));
    }
    if (data.containsKey('server_osc_port')) {
      context.handle(
          _serverOscPortMeta,
          serverOscPort.isAcceptableOrUnknown(
              data['server_osc_port']!, _serverOscPortMeta));
    }
    if (data.containsKey('server_mqtt_port')) {
      context.handle(
          _serverMqttPortMeta,
          serverMqttPort.isAcceptableOrUnknown(
              data['server_mqtt_port']!, _serverMqttPortMeta));
    }
    if (data.containsKey('server_mqtt_id')) {
      context.handle(
          _serverMqttIdMeta,
          serverMqttId.isAcceptableOrUnknown(
              data['server_mqtt_id']!, _serverMqttIdMeta));
    }
    if (data.containsKey('server_mqtt_password')) {
      context.handle(
          _serverMqttPasswordMeta,
          serverMqttPassword.isAcceptableOrUnknown(
              data['server_mqtt_password']!, _serverMqttPasswordMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BasicInfoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BasicInfoData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_id'])!,
      roomName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_name'])!,
      logoImage: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}logo_image'])!,
      wifiName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wifi_name']),
      titleText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title_text'])!,
      myOscPort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}my_osc_port'])!,
      myPassword: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}my_password'])!,
      serverIp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_ip'])!,
      serverOscPort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_osc_port'])!,
      serverMqttPort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_mqtt_port'])!,
      serverMqttId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_mqtt_id'])!,
      serverMqttPassword: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}server_mqtt_password'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BasicInfoTable createAlias(String alias) {
    return $BasicInfoTable(attachedDatabase, alias);
  }
}

class BasicInfoData extends DataClass implements Insertable<BasicInfoData> {
  /// 0. 아이디
  final int id;

  /// 1. 강의실 정보
  final String roomId;
  final String roomName;
  final Uint8List logoImage;
  final String? wifiName;
  final String titleText;

  /// 2. 태블릿
  final int myOscPort;
  final String myPassword;

  /// 3. 서버
  final String serverIp;
  final int serverOscPort;
  final int serverMqttPort;
  final String serverMqttId;
  final String serverMqttPassword;

  ///4. 생성일
  final DateTime createdAt;
  const BasicInfoData(
      {required this.id,
      required this.roomId,
      required this.roomName,
      required this.logoImage,
      this.wifiName,
      required this.titleText,
      required this.myOscPort,
      required this.myPassword,
      required this.serverIp,
      required this.serverOscPort,
      required this.serverMqttPort,
      required this.serverMqttId,
      required this.serverMqttPassword,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['room_id'] = Variable<String>(roomId);
    map['room_name'] = Variable<String>(roomName);
    map['logo_image'] = Variable<Uint8List>(logoImage);
    if (!nullToAbsent || wifiName != null) {
      map['wifi_name'] = Variable<String>(wifiName);
    }
    map['title_text'] = Variable<String>(titleText);
    map['my_osc_port'] = Variable<int>(myOscPort);
    map['my_password'] = Variable<String>(myPassword);
    map['server_ip'] = Variable<String>(serverIp);
    map['server_osc_port'] = Variable<int>(serverOscPort);
    map['server_mqtt_port'] = Variable<int>(serverMqttPort);
    map['server_mqtt_id'] = Variable<String>(serverMqttId);
    map['server_mqtt_password'] = Variable<String>(serverMqttPassword);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BasicInfoCompanion toCompanion(bool nullToAbsent) {
    return BasicInfoCompanion(
      id: Value(id),
      roomId: Value(roomId),
      roomName: Value(roomName),
      logoImage: Value(logoImage),
      wifiName: wifiName == null && nullToAbsent
          ? const Value.absent()
          : Value(wifiName),
      titleText: Value(titleText),
      myOscPort: Value(myOscPort),
      myPassword: Value(myPassword),
      serverIp: Value(serverIp),
      serverOscPort: Value(serverOscPort),
      serverMqttPort: Value(serverMqttPort),
      serverMqttId: Value(serverMqttId),
      serverMqttPassword: Value(serverMqttPassword),
      createdAt: Value(createdAt),
    );
  }

  factory BasicInfoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BasicInfoData(
      id: serializer.fromJson<int>(json['id']),
      roomId: serializer.fromJson<String>(json['roomId']),
      roomName: serializer.fromJson<String>(json['roomName']),
      logoImage: serializer.fromJson<Uint8List>(json['logoImage']),
      wifiName: serializer.fromJson<String?>(json['wifiName']),
      titleText: serializer.fromJson<String>(json['titleText']),
      myOscPort: serializer.fromJson<int>(json['myOscPort']),
      myPassword: serializer.fromJson<String>(json['myPassword']),
      serverIp: serializer.fromJson<String>(json['serverIp']),
      serverOscPort: serializer.fromJson<int>(json['serverOscPort']),
      serverMqttPort: serializer.fromJson<int>(json['serverMqttPort']),
      serverMqttId: serializer.fromJson<String>(json['serverMqttId']),
      serverMqttPassword:
          serializer.fromJson<String>(json['serverMqttPassword']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'roomId': serializer.toJson<String>(roomId),
      'roomName': serializer.toJson<String>(roomName),
      'logoImage': serializer.toJson<Uint8List>(logoImage),
      'wifiName': serializer.toJson<String?>(wifiName),
      'titleText': serializer.toJson<String>(titleText),
      'myOscPort': serializer.toJson<int>(myOscPort),
      'myPassword': serializer.toJson<String>(myPassword),
      'serverIp': serializer.toJson<String>(serverIp),
      'serverOscPort': serializer.toJson<int>(serverOscPort),
      'serverMqttPort': serializer.toJson<int>(serverMqttPort),
      'serverMqttId': serializer.toJson<String>(serverMqttId),
      'serverMqttPassword': serializer.toJson<String>(serverMqttPassword),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BasicInfoData copyWith(
          {int? id,
          String? roomId,
          String? roomName,
          Uint8List? logoImage,
          Value<String?> wifiName = const Value.absent(),
          String? titleText,
          int? myOscPort,
          String? myPassword,
          String? serverIp,
          int? serverOscPort,
          int? serverMqttPort,
          String? serverMqttId,
          String? serverMqttPassword,
          DateTime? createdAt}) =>
      BasicInfoData(
        id: id ?? this.id,
        roomId: roomId ?? this.roomId,
        roomName: roomName ?? this.roomName,
        logoImage: logoImage ?? this.logoImage,
        wifiName: wifiName.present ? wifiName.value : this.wifiName,
        titleText: titleText ?? this.titleText,
        myOscPort: myOscPort ?? this.myOscPort,
        myPassword: myPassword ?? this.myPassword,
        serverIp: serverIp ?? this.serverIp,
        serverOscPort: serverOscPort ?? this.serverOscPort,
        serverMqttPort: serverMqttPort ?? this.serverMqttPort,
        serverMqttId: serverMqttId ?? this.serverMqttId,
        serverMqttPassword: serverMqttPassword ?? this.serverMqttPassword,
        createdAt: createdAt ?? this.createdAt,
      );
  BasicInfoData copyWithCompanion(BasicInfoCompanion data) {
    return BasicInfoData(
      id: data.id.present ? data.id.value : this.id,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      roomName: data.roomName.present ? data.roomName.value : this.roomName,
      logoImage: data.logoImage.present ? data.logoImage.value : this.logoImage,
      wifiName: data.wifiName.present ? data.wifiName.value : this.wifiName,
      titleText: data.titleText.present ? data.titleText.value : this.titleText,
      myOscPort: data.myOscPort.present ? data.myOscPort.value : this.myOscPort,
      myPassword:
          data.myPassword.present ? data.myPassword.value : this.myPassword,
      serverIp: data.serverIp.present ? data.serverIp.value : this.serverIp,
      serverOscPort: data.serverOscPort.present
          ? data.serverOscPort.value
          : this.serverOscPort,
      serverMqttPort: data.serverMqttPort.present
          ? data.serverMqttPort.value
          : this.serverMqttPort,
      serverMqttId: data.serverMqttId.present
          ? data.serverMqttId.value
          : this.serverMqttId,
      serverMqttPassword: data.serverMqttPassword.present
          ? data.serverMqttPassword.value
          : this.serverMqttPassword,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BasicInfoData(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('roomName: $roomName, ')
          ..write('logoImage: $logoImage, ')
          ..write('wifiName: $wifiName, ')
          ..write('titleText: $titleText, ')
          ..write('myOscPort: $myOscPort, ')
          ..write('myPassword: $myPassword, ')
          ..write('serverIp: $serverIp, ')
          ..write('serverOscPort: $serverOscPort, ')
          ..write('serverMqttPort: $serverMqttPort, ')
          ..write('serverMqttId: $serverMqttId, ')
          ..write('serverMqttPassword: $serverMqttPassword, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      roomId,
      roomName,
      $driftBlobEquality.hash(logoImage),
      wifiName,
      titleText,
      myOscPort,
      myPassword,
      serverIp,
      serverOscPort,
      serverMqttPort,
      serverMqttId,
      serverMqttPassword,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BasicInfoData &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.roomName == this.roomName &&
          $driftBlobEquality.equals(other.logoImage, this.logoImage) &&
          other.wifiName == this.wifiName &&
          other.titleText == this.titleText &&
          other.myOscPort == this.myOscPort &&
          other.myPassword == this.myPassword &&
          other.serverIp == this.serverIp &&
          other.serverOscPort == this.serverOscPort &&
          other.serverMqttPort == this.serverMqttPort &&
          other.serverMqttId == this.serverMqttId &&
          other.serverMqttPassword == this.serverMqttPassword &&
          other.createdAt == this.createdAt);
}

class BasicInfoCompanion extends UpdateCompanion<BasicInfoData> {
  final Value<int> id;
  final Value<String> roomId;
  final Value<String> roomName;
  final Value<Uint8List> logoImage;
  final Value<String?> wifiName;
  final Value<String> titleText;
  final Value<int> myOscPort;
  final Value<String> myPassword;
  final Value<String> serverIp;
  final Value<int> serverOscPort;
  final Value<int> serverMqttPort;
  final Value<String> serverMqttId;
  final Value<String> serverMqttPassword;
  final Value<DateTime> createdAt;
  const BasicInfoCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.roomName = const Value.absent(),
    this.logoImage = const Value.absent(),
    this.wifiName = const Value.absent(),
    this.titleText = const Value.absent(),
    this.myOscPort = const Value.absent(),
    this.myPassword = const Value.absent(),
    this.serverIp = const Value.absent(),
    this.serverOscPort = const Value.absent(),
    this.serverMqttPort = const Value.absent(),
    this.serverMqttId = const Value.absent(),
    this.serverMqttPassword = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BasicInfoCompanion.insert({
    this.id = const Value.absent(),
    required String roomId,
    this.roomName = const Value.absent(),
    required Uint8List logoImage,
    this.wifiName = const Value.absent(),
    this.titleText = const Value.absent(),
    this.myOscPort = const Value.absent(),
    this.myPassword = const Value.absent(),
    this.serverIp = const Value.absent(),
    this.serverOscPort = const Value.absent(),
    this.serverMqttPort = const Value.absent(),
    this.serverMqttId = const Value.absent(),
    this.serverMqttPassword = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : roomId = Value(roomId),
        logoImage = Value(logoImage);
  static Insertable<BasicInfoData> custom({
    Expression<int>? id,
    Expression<String>? roomId,
    Expression<String>? roomName,
    Expression<Uint8List>? logoImage,
    Expression<String>? wifiName,
    Expression<String>? titleText,
    Expression<int>? myOscPort,
    Expression<String>? myPassword,
    Expression<String>? serverIp,
    Expression<int>? serverOscPort,
    Expression<int>? serverMqttPort,
    Expression<String>? serverMqttId,
    Expression<String>? serverMqttPassword,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (roomName != null) 'room_name': roomName,
      if (logoImage != null) 'logo_image': logoImage,
      if (wifiName != null) 'wifi_name': wifiName,
      if (titleText != null) 'title_text': titleText,
      if (myOscPort != null) 'my_osc_port': myOscPort,
      if (myPassword != null) 'my_password': myPassword,
      if (serverIp != null) 'server_ip': serverIp,
      if (serverOscPort != null) 'server_osc_port': serverOscPort,
      if (serverMqttPort != null) 'server_mqtt_port': serverMqttPort,
      if (serverMqttId != null) 'server_mqtt_id': serverMqttId,
      if (serverMqttPassword != null)
        'server_mqtt_password': serverMqttPassword,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BasicInfoCompanion copyWith(
      {Value<int>? id,
      Value<String>? roomId,
      Value<String>? roomName,
      Value<Uint8List>? logoImage,
      Value<String?>? wifiName,
      Value<String>? titleText,
      Value<int>? myOscPort,
      Value<String>? myPassword,
      Value<String>? serverIp,
      Value<int>? serverOscPort,
      Value<int>? serverMqttPort,
      Value<String>? serverMqttId,
      Value<String>? serverMqttPassword,
      Value<DateTime>? createdAt}) {
    return BasicInfoCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      logoImage: logoImage ?? this.logoImage,
      wifiName: wifiName ?? this.wifiName,
      titleText: titleText ?? this.titleText,
      myOscPort: myOscPort ?? this.myOscPort,
      myPassword: myPassword ?? this.myPassword,
      serverIp: serverIp ?? this.serverIp,
      serverOscPort: serverOscPort ?? this.serverOscPort,
      serverMqttPort: serverMqttPort ?? this.serverMqttPort,
      serverMqttId: serverMqttId ?? this.serverMqttId,
      serverMqttPassword: serverMqttPassword ?? this.serverMqttPassword,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (roomName.present) {
      map['room_name'] = Variable<String>(roomName.value);
    }
    if (logoImage.present) {
      map['logo_image'] = Variable<Uint8List>(logoImage.value);
    }
    if (wifiName.present) {
      map['wifi_name'] = Variable<String>(wifiName.value);
    }
    if (titleText.present) {
      map['title_text'] = Variable<String>(titleText.value);
    }
    if (myOscPort.present) {
      map['my_osc_port'] = Variable<int>(myOscPort.value);
    }
    if (myPassword.present) {
      map['my_password'] = Variable<String>(myPassword.value);
    }
    if (serverIp.present) {
      map['server_ip'] = Variable<String>(serverIp.value);
    }
    if (serverOscPort.present) {
      map['server_osc_port'] = Variable<int>(serverOscPort.value);
    }
    if (serverMqttPort.present) {
      map['server_mqtt_port'] = Variable<int>(serverMqttPort.value);
    }
    if (serverMqttId.present) {
      map['server_mqtt_id'] = Variable<String>(serverMqttId.value);
    }
    if (serverMqttPassword.present) {
      map['server_mqtt_password'] = Variable<String>(serverMqttPassword.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BasicInfoCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('roomName: $roomName, ')
          ..write('logoImage: $logoImage, ')
          ..write('wifiName: $wifiName, ')
          ..write('titleText: $titleText, ')
          ..write('myOscPort: $myOscPort, ')
          ..write('myPassword: $myPassword, ')
          ..write('serverIp: $serverIp, ')
          ..write('serverOscPort: $serverOscPort, ')
          ..write('serverMqttPort: $serverMqttPort, ')
          ..write('serverMqttId: $serverMqttId, ')
          ..write('serverMqttPassword: $serverMqttPassword, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PageTable extends Page with TableInfo<$PageTable, PageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _pageNameMeta =
      const VerificationMeta('pageName');
  @override
  late final GeneratedColumn<String> pageName = GeneratedColumn<String>(
      'page_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pageNumMeta =
      const VerificationMeta('pageNum');
  @override
  late final GeneratedColumn<int> pageNum = GeneratedColumn<int>(
      'page_num', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, pageName, pageNum];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'page';
  @override
  VerificationContext validateIntegrity(Insertable<PageData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('page_name')) {
      context.handle(_pageNameMeta,
          pageName.isAcceptableOrUnknown(data['page_name']!, _pageNameMeta));
    } else if (isInserting) {
      context.missing(_pageNameMeta);
    }
    if (data.containsKey('page_num')) {
      context.handle(_pageNumMeta,
          pageNum.isAcceptableOrUnknown(data['page_num']!, _pageNumMeta));
    } else if (isInserting) {
      context.missing(_pageNumMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PageData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      pageName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}page_name'])!,
      pageNum: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_num'])!,
    );
  }

  @override
  $PageTable createAlias(String alias) {
    return $PageTable(attachedDatabase, alias);
  }
}

class PageData extends DataClass implements Insertable<PageData> {
  /// 1) 식별 아이디
  final int? id;

  /// 2) 페이지 명
  final String pageName;

  /// 3) 페이지 번호
  final int pageNum;
  const PageData({this.id, required this.pageName, required this.pageNum});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['page_name'] = Variable<String>(pageName);
    map['page_num'] = Variable<int>(pageNum);
    return map;
  }

  PageCompanion toCompanion(bool nullToAbsent) {
    return PageCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      pageName: Value(pageName),
      pageNum: Value(pageNum),
    );
  }

  factory PageData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PageData(
      id: serializer.fromJson<int?>(json['id']),
      pageName: serializer.fromJson<String>(json['pageName']),
      pageNum: serializer.fromJson<int>(json['pageNum']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'pageName': serializer.toJson<String>(pageName),
      'pageNum': serializer.toJson<int>(pageNum),
    };
  }

  PageData copyWith(
          {Value<int?> id = const Value.absent(),
          String? pageName,
          int? pageNum}) =>
      PageData(
        id: id.present ? id.value : this.id,
        pageName: pageName ?? this.pageName,
        pageNum: pageNum ?? this.pageNum,
      );
  PageData copyWithCompanion(PageCompanion data) {
    return PageData(
      id: data.id.present ? data.id.value : this.id,
      pageName: data.pageName.present ? data.pageName.value : this.pageName,
      pageNum: data.pageNum.present ? data.pageNum.value : this.pageNum,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PageData(')
          ..write('id: $id, ')
          ..write('pageName: $pageName, ')
          ..write('pageNum: $pageNum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pageName, pageNum);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PageData &&
          other.id == this.id &&
          other.pageName == this.pageName &&
          other.pageNum == this.pageNum);
}

class PageCompanion extends UpdateCompanion<PageData> {
  final Value<int?> id;
  final Value<String> pageName;
  final Value<int> pageNum;
  const PageCompanion({
    this.id = const Value.absent(),
    this.pageName = const Value.absent(),
    this.pageNum = const Value.absent(),
  });
  PageCompanion.insert({
    this.id = const Value.absent(),
    required String pageName,
    required int pageNum,
  })  : pageName = Value(pageName),
        pageNum = Value(pageNum);
  static Insertable<PageData> custom({
    Expression<int>? id,
    Expression<String>? pageName,
    Expression<int>? pageNum,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageName != null) 'page_name': pageName,
      if (pageNum != null) 'page_num': pageNum,
    });
  }

  PageCompanion copyWith(
      {Value<int?>? id, Value<String>? pageName, Value<int>? pageNum}) {
    return PageCompanion(
      id: id ?? this.id,
      pageName: pageName ?? this.pageName,
      pageNum: pageNum ?? this.pageNum,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pageName.present) {
      map['page_name'] = Variable<String>(pageName.value);
    }
    if (pageNum.present) {
      map['page_num'] = Variable<int>(pageNum.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PageCompanion(')
          ..write('id: $id, ')
          ..write('pageName: $pageName, ')
          ..write('pageNum: $pageNum')
          ..write(')'))
        .toString();
  }
}

class $ButtonTable extends Button with TableInfo<$ButtonTable, ButtonData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ButtonTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _buttonNameMeta =
      const VerificationMeta('buttonName');
  @override
  late final GeneratedColumn<String> buttonName = GeneratedColumn<String>(
      'button_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('버튼명을 적어주세요'));
  static const VerificationMeta _isUsingButtonMeta =
      const VerificationMeta('isUsingButton');
  @override
  late final GeneratedColumn<bool> isUsingButton = GeneratedColumn<bool>(
      'is_using_button', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_using_button" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
      'page', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES page (id) ON UPDATE CASCADE'),
      defaultValue: const Constant(0));
  static const VerificationMeta _rowMeta = const VerificationMeta('row');
  @override
  late final GeneratedColumn<int> row = GeneratedColumn<int>(
      'row', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _columnMeta = const VerificationMeta('column');
  @override
  late final GeneratedColumn<int> column = GeneratedColumn<int>(
      'column', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _commandMeta =
      const VerificationMeta('command');
  @override
  late final GeneratedColumnWithTypeConverter<Command, String> command =
      GeneratedColumn<String>('command', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('press'))
          .withConverter<Command>($ButtonTable.$convertercommand);
  static const VerificationMeta _queryStringMeta =
      const VerificationMeta('queryString');
  @override
  late final GeneratedColumn<String> queryString = GeneratedColumn<String>(
      'query_string', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        buttonName,
        isUsingButton,
        page,
        row,
        column,
        command,
        queryString,
        message
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'button';
  @override
  VerificationContext validateIntegrity(Insertable<ButtonData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('button_name')) {
      context.handle(
          _buttonNameMeta,
          buttonName.isAcceptableOrUnknown(
              data['button_name']!, _buttonNameMeta));
    }
    if (data.containsKey('is_using_button')) {
      context.handle(
          _isUsingButtonMeta,
          isUsingButton.isAcceptableOrUnknown(
              data['is_using_button']!, _isUsingButtonMeta));
    }
    if (data.containsKey('page')) {
      context.handle(
          _pageMeta, page.isAcceptableOrUnknown(data['page']!, _pageMeta));
    }
    if (data.containsKey('row')) {
      context.handle(
          _rowMeta, row.isAcceptableOrUnknown(data['row']!, _rowMeta));
    }
    if (data.containsKey('column')) {
      context.handle(_columnMeta,
          column.isAcceptableOrUnknown(data['column']!, _columnMeta));
    }
    context.handle(_commandMeta, const VerificationResult.success());
    if (data.containsKey('query_string')) {
      context.handle(
          _queryStringMeta,
          queryString.isAcceptableOrUnknown(
              data['query_string']!, _queryStringMeta));
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ButtonData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ButtonData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      buttonName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}button_name'])!,
      isUsingButton: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_using_button'])!,
      page: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page'])!,
      row: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}row'])!,
      column: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}column'])!,
      command: $ButtonTable.$convertercommand.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}command'])!),
      queryString: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}query_string']),
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message']),
    );
  }

  @override
  $ButtonTable createAlias(String alias) {
    return $ButtonTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Command, String, String> $convertercommand =
      const EnumNameConverter<Command>(Command.values);
}

class ButtonData extends DataClass implements Insertable<ButtonData> {
  /// 1) 식별 아이디
  final int? id;

  /// 2) 버튼명
  final String buttonName;

  /// 3) osc 전송방식 : 버튼 조작 or 쿼리
  final bool isUsingButton;

  /// 4) 페이지
  final int page;

  /// 5) 행
  final int row;

  /// 6) 열
  final int column;

  /// 7) 명령어
  /// press, down, up...
  final Command command;

  /// 8) 쿼리스트링
  final String? queryString;

  /// 9) 메세지
  final String? message;
  const ButtonData(
      {this.id,
      required this.buttonName,
      required this.isUsingButton,
      required this.page,
      required this.row,
      required this.column,
      required this.command,
      this.queryString,
      this.message});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['button_name'] = Variable<String>(buttonName);
    map['is_using_button'] = Variable<bool>(isUsingButton);
    map['page'] = Variable<int>(page);
    map['row'] = Variable<int>(row);
    map['column'] = Variable<int>(column);
    {
      map['command'] =
          Variable<String>($ButtonTable.$convertercommand.toSql(command));
    }
    if (!nullToAbsent || queryString != null) {
      map['query_string'] = Variable<String>(queryString);
    }
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    return map;
  }

  ButtonCompanion toCompanion(bool nullToAbsent) {
    return ButtonCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      buttonName: Value(buttonName),
      isUsingButton: Value(isUsingButton),
      page: Value(page),
      row: Value(row),
      column: Value(column),
      command: Value(command),
      queryString: queryString == null && nullToAbsent
          ? const Value.absent()
          : Value(queryString),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
    );
  }

  factory ButtonData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ButtonData(
      id: serializer.fromJson<int?>(json['id']),
      buttonName: serializer.fromJson<String>(json['buttonName']),
      isUsingButton: serializer.fromJson<bool>(json['isUsingButton']),
      page: serializer.fromJson<int>(json['page']),
      row: serializer.fromJson<int>(json['row']),
      column: serializer.fromJson<int>(json['column']),
      command: $ButtonTable.$convertercommand
          .fromJson(serializer.fromJson<String>(json['command'])),
      queryString: serializer.fromJson<String?>(json['queryString']),
      message: serializer.fromJson<String?>(json['message']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'buttonName': serializer.toJson<String>(buttonName),
      'isUsingButton': serializer.toJson<bool>(isUsingButton),
      'page': serializer.toJson<int>(page),
      'row': serializer.toJson<int>(row),
      'column': serializer.toJson<int>(column),
      'command': serializer
          .toJson<String>($ButtonTable.$convertercommand.toJson(command)),
      'queryString': serializer.toJson<String?>(queryString),
      'message': serializer.toJson<String?>(message),
    };
  }

  ButtonData copyWith(
          {Value<int?> id = const Value.absent(),
          String? buttonName,
          bool? isUsingButton,
          int? page,
          int? row,
          int? column,
          Command? command,
          Value<String?> queryString = const Value.absent(),
          Value<String?> message = const Value.absent()}) =>
      ButtonData(
        id: id.present ? id.value : this.id,
        buttonName: buttonName ?? this.buttonName,
        isUsingButton: isUsingButton ?? this.isUsingButton,
        page: page ?? this.page,
        row: row ?? this.row,
        column: column ?? this.column,
        command: command ?? this.command,
        queryString: queryString.present ? queryString.value : this.queryString,
        message: message.present ? message.value : this.message,
      );
  ButtonData copyWithCompanion(ButtonCompanion data) {
    return ButtonData(
      id: data.id.present ? data.id.value : this.id,
      buttonName:
          data.buttonName.present ? data.buttonName.value : this.buttonName,
      isUsingButton: data.isUsingButton.present
          ? data.isUsingButton.value
          : this.isUsingButton,
      page: data.page.present ? data.page.value : this.page,
      row: data.row.present ? data.row.value : this.row,
      column: data.column.present ? data.column.value : this.column,
      command: data.command.present ? data.command.value : this.command,
      queryString:
          data.queryString.present ? data.queryString.value : this.queryString,
      message: data.message.present ? data.message.value : this.message,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ButtonData(')
          ..write('id: $id, ')
          ..write('buttonName: $buttonName, ')
          ..write('isUsingButton: $isUsingButton, ')
          ..write('page: $page, ')
          ..write('row: $row, ')
          ..write('column: $column, ')
          ..write('command: $command, ')
          ..write('queryString: $queryString, ')
          ..write('message: $message')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, buttonName, isUsingButton, page, row,
      column, command, queryString, message);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ButtonData &&
          other.id == this.id &&
          other.buttonName == this.buttonName &&
          other.isUsingButton == this.isUsingButton &&
          other.page == this.page &&
          other.row == this.row &&
          other.column == this.column &&
          other.command == this.command &&
          other.queryString == this.queryString &&
          other.message == this.message);
}

class ButtonCompanion extends UpdateCompanion<ButtonData> {
  final Value<int?> id;
  final Value<String> buttonName;
  final Value<bool> isUsingButton;
  final Value<int> page;
  final Value<int> row;
  final Value<int> column;
  final Value<Command> command;
  final Value<String?> queryString;
  final Value<String?> message;
  const ButtonCompanion({
    this.id = const Value.absent(),
    this.buttonName = const Value.absent(),
    this.isUsingButton = const Value.absent(),
    this.page = const Value.absent(),
    this.row = const Value.absent(),
    this.column = const Value.absent(),
    this.command = const Value.absent(),
    this.queryString = const Value.absent(),
    this.message = const Value.absent(),
  });
  ButtonCompanion.insert({
    this.id = const Value.absent(),
    this.buttonName = const Value.absent(),
    this.isUsingButton = const Value.absent(),
    this.page = const Value.absent(),
    this.row = const Value.absent(),
    this.column = const Value.absent(),
    this.command = const Value.absent(),
    this.queryString = const Value.absent(),
    this.message = const Value.absent(),
  });
  static Insertable<ButtonData> custom({
    Expression<int>? id,
    Expression<String>? buttonName,
    Expression<bool>? isUsingButton,
    Expression<int>? page,
    Expression<int>? row,
    Expression<int>? column,
    Expression<String>? command,
    Expression<String>? queryString,
    Expression<String>? message,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (buttonName != null) 'button_name': buttonName,
      if (isUsingButton != null) 'is_using_button': isUsingButton,
      if (page != null) 'page': page,
      if (row != null) 'row': row,
      if (column != null) 'column': column,
      if (command != null) 'command': command,
      if (queryString != null) 'query_string': queryString,
      if (message != null) 'message': message,
    });
  }

  ButtonCompanion copyWith(
      {Value<int?>? id,
      Value<String>? buttonName,
      Value<bool>? isUsingButton,
      Value<int>? page,
      Value<int>? row,
      Value<int>? column,
      Value<Command>? command,
      Value<String?>? queryString,
      Value<String?>? message}) {
    return ButtonCompanion(
      id: id ?? this.id,
      buttonName: buttonName ?? this.buttonName,
      isUsingButton: isUsingButton ?? this.isUsingButton,
      page: page ?? this.page,
      row: row ?? this.row,
      column: column ?? this.column,
      command: command ?? this.command,
      queryString: queryString ?? this.queryString,
      message: message ?? this.message,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (buttonName.present) {
      map['button_name'] = Variable<String>(buttonName.value);
    }
    if (isUsingButton.present) {
      map['is_using_button'] = Variable<bool>(isUsingButton.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (row.present) {
      map['row'] = Variable<int>(row.value);
    }
    if (column.present) {
      map['column'] = Variable<int>(column.value);
    }
    if (command.present) {
      map['command'] =
          Variable<String>($ButtonTable.$convertercommand.toSql(command.value));
    }
    if (queryString.present) {
      map['query_string'] = Variable<String>(queryString.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ButtonCompanion(')
          ..write('id: $id, ')
          ..write('buttonName: $buttonName, ')
          ..write('isUsingButton: $isUsingButton, ')
          ..write('page: $page, ')
          ..write('row: $row, ')
          ..write('column: $column, ')
          ..write('command: $command, ')
          ..write('queryString: $queryString, ')
          ..write('message: $message')
          ..write(')'))
        .toString();
  }
}

class $MediaItemTable extends MediaItem
    with TableInfo<$MediaItemTable, MediaItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaItemTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<MediaType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<MediaType>($MediaItemTable.$convertertype);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fromMeta = const VerificationMeta('from');
  @override
  late final GeneratedColumnWithTypeConverter<MediaFrom, String> from =
      GeneratedColumn<String>('from', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('gDrive'))
          .withConverter<MediaFrom>($MediaItemTable.$converterfrom);
  static const VerificationMeta _fitMeta = const VerificationMeta('fit');
  @override
  late final GeneratedColumnWithTypeConverter<BoxFit?, String> fit =
      GeneratedColumn<String>('fit', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<BoxFit?>($MediaItemTable.$converterfitn);
  static const VerificationMeta _orderNumMeta =
      const VerificationMeta('orderNum');
  @override
  late final GeneratedColumn<int> orderNum = GeneratedColumn<int>(
      'order_num', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, url, fileName, from, fit, orderNum];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_item';
  @override
  VerificationContext validateIntegrity(Insertable<MediaItemData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    }
    context.handle(_fromMeta, const VerificationResult.success());
    context.handle(_fitMeta, const VerificationResult.success());
    if (data.containsKey('order_num')) {
      context.handle(_orderNumMeta,
          orderNum.isAcceptableOrUnknown(data['order_num']!, _orderNumMeta));
    } else if (isInserting) {
      context.missing(_orderNumMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaItemData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: $MediaItemTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name']),
      from: $MediaItemTable.$converterfrom.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from'])!),
      fit: $MediaItemTable.$converterfitn.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fit'])),
      orderNum: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_num'])!,
    );
  }

  @override
  $MediaItemTable createAlias(String alias) {
    return $MediaItemTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MediaType, String, String> $convertertype =
      const EnumNameConverter<MediaType>(MediaType.values);
  static JsonTypeConverter2<MediaFrom, String, String> $converterfrom =
      const EnumNameConverter<MediaFrom>(MediaFrom.values);
  static JsonTypeConverter2<BoxFit, String, String> $converterfit =
      const EnumNameConverter<BoxFit>(BoxFit.values);
  static JsonTypeConverter2<BoxFit?, String?, String?> $converterfitn =
      JsonTypeConverter2.asNullable($converterfit);
}

class MediaItemData extends DataClass implements Insertable<MediaItemData> {
  /// 1) 식별 아이디
  final int id;

  /// 2) 미디어 타입
  final MediaType type;

  /// 3) 주소
  final String url;

  /// 4) 파일명
  /// - 없으면 url 마지막 부분에서 파일명 추출
  final String? fileName;

  /// 5) 저장위치
  final MediaFrom from;

  /// 6) 미디어 표출 방식
  /// - cover(기본): 꽉 채움
  /// - contain: 여백이 있더라도 다 나오게)
  final BoxFit? fit;

  /// 7) 표출 순서 : 기본 생성순
  final int orderNum;
  const MediaItemData(
      {required this.id,
      required this.type,
      required this.url,
      this.fileName,
      required this.from,
      this.fit,
      required this.orderNum});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] =
          Variable<String>($MediaItemTable.$convertertype.toSql(type));
    }
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    {
      map['from'] =
          Variable<String>($MediaItemTable.$converterfrom.toSql(from));
    }
    if (!nullToAbsent || fit != null) {
      map['fit'] = Variable<String>($MediaItemTable.$converterfitn.toSql(fit));
    }
    map['order_num'] = Variable<int>(orderNum);
    return map;
  }

  MediaItemCompanion toCompanion(bool nullToAbsent) {
    return MediaItemCompanion(
      id: Value(id),
      type: Value(type),
      url: Value(url),
      fileName: fileName == null && nullToAbsent
          ? const Value.absent()
          : Value(fileName),
      from: Value(from),
      fit: fit == null && nullToAbsent ? const Value.absent() : Value(fit),
      orderNum: Value(orderNum),
    );
  }

  factory MediaItemData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaItemData(
      id: serializer.fromJson<int>(json['id']),
      type: $MediaItemTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      url: serializer.fromJson<String>(json['url']),
      fileName: serializer.fromJson<String?>(json['fileName']),
      from: $MediaItemTable.$converterfrom
          .fromJson(serializer.fromJson<String>(json['from'])),
      fit: $MediaItemTable.$converterfitn
          .fromJson(serializer.fromJson<String?>(json['fit'])),
      orderNum: serializer.fromJson<int>(json['orderNum']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer
          .toJson<String>($MediaItemTable.$convertertype.toJson(type)),
      'url': serializer.toJson<String>(url),
      'fileName': serializer.toJson<String?>(fileName),
      'from': serializer
          .toJson<String>($MediaItemTable.$converterfrom.toJson(from)),
      'fit': serializer
          .toJson<String?>($MediaItemTable.$converterfitn.toJson(fit)),
      'orderNum': serializer.toJson<int>(orderNum),
    };
  }

  MediaItemData copyWith(
          {int? id,
          MediaType? type,
          String? url,
          Value<String?> fileName = const Value.absent(),
          MediaFrom? from,
          Value<BoxFit?> fit = const Value.absent(),
          int? orderNum}) =>
      MediaItemData(
        id: id ?? this.id,
        type: type ?? this.type,
        url: url ?? this.url,
        fileName: fileName.present ? fileName.value : this.fileName,
        from: from ?? this.from,
        fit: fit.present ? fit.value : this.fit,
        orderNum: orderNum ?? this.orderNum,
      );
  MediaItemData copyWithCompanion(MediaItemCompanion data) {
    return MediaItemData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      url: data.url.present ? data.url.value : this.url,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      from: data.from.present ? data.from.value : this.from,
      fit: data.fit.present ? data.fit.value : this.fit,
      orderNum: data.orderNum.present ? data.orderNum.value : this.orderNum,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('url: $url, ')
          ..write('fileName: $fileName, ')
          ..write('from: $from, ')
          ..write('fit: $fit, ')
          ..write('orderNum: $orderNum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, url, fileName, from, fit, orderNum);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaItemData &&
          other.id == this.id &&
          other.type == this.type &&
          other.url == this.url &&
          other.fileName == this.fileName &&
          other.from == this.from &&
          other.fit == this.fit &&
          other.orderNum == this.orderNum);
}

class MediaItemCompanion extends UpdateCompanion<MediaItemData> {
  final Value<int> id;
  final Value<MediaType> type;
  final Value<String> url;
  final Value<String?> fileName;
  final Value<MediaFrom> from;
  final Value<BoxFit?> fit;
  final Value<int> orderNum;
  const MediaItemCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.url = const Value.absent(),
    this.fileName = const Value.absent(),
    this.from = const Value.absent(),
    this.fit = const Value.absent(),
    this.orderNum = const Value.absent(),
  });
  MediaItemCompanion.insert({
    this.id = const Value.absent(),
    required MediaType type,
    required String url,
    this.fileName = const Value.absent(),
    this.from = const Value.absent(),
    this.fit = const Value.absent(),
    required int orderNum,
  })  : type = Value(type),
        url = Value(url),
        orderNum = Value(orderNum);
  static Insertable<MediaItemData> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? url,
    Expression<String>? fileName,
    Expression<String>? from,
    Expression<String>? fit,
    Expression<int>? orderNum,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (url != null) 'url': url,
      if (fileName != null) 'file_name': fileName,
      if (from != null) 'from': from,
      if (fit != null) 'fit': fit,
      if (orderNum != null) 'order_num': orderNum,
    });
  }

  MediaItemCompanion copyWith(
      {Value<int>? id,
      Value<MediaType>? type,
      Value<String>? url,
      Value<String?>? fileName,
      Value<MediaFrom>? from,
      Value<BoxFit?>? fit,
      Value<int>? orderNum}) {
    return MediaItemCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      from: from ?? this.from,
      fit: fit ?? this.fit,
      orderNum: orderNum ?? this.orderNum,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] =
          Variable<String>($MediaItemTable.$convertertype.toSql(type.value));
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (from.present) {
      map['from'] =
          Variable<String>($MediaItemTable.$converterfrom.toSql(from.value));
    }
    if (fit.present) {
      map['fit'] =
          Variable<String>($MediaItemTable.$converterfitn.toSql(fit.value));
    }
    if (orderNum.present) {
      map['order_num'] = Variable<int>(orderNum.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('url: $url, ')
          ..write('fileName: $fileName, ')
          ..write('from: $from, ')
          ..write('fit: $fit, ')
          ..write('orderNum: $orderNum')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BasicInfoTable basicInfo = $BasicInfoTable(this);
  late final $PageTable page = $PageTable(this);
  late final $ButtonTable button = $ButtonTable(this);
  late final $MediaItemTable mediaItem = $MediaItemTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [basicInfo, page, button, mediaItem];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('page',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('button', kind: UpdateKind.update),
            ],
          ),
        ],
      );
}

typedef $$BasicInfoTableCreateCompanionBuilder = BasicInfoCompanion Function({
  Value<int> id,
  required String roomId,
  Value<String> roomName,
  required Uint8List logoImage,
  Value<String?> wifiName,
  Value<String> titleText,
  Value<int> myOscPort,
  Value<String> myPassword,
  Value<String> serverIp,
  Value<int> serverOscPort,
  Value<int> serverMqttPort,
  Value<String> serverMqttId,
  Value<String> serverMqttPassword,
  Value<DateTime> createdAt,
});
typedef $$BasicInfoTableUpdateCompanionBuilder = BasicInfoCompanion Function({
  Value<int> id,
  Value<String> roomId,
  Value<String> roomName,
  Value<Uint8List> logoImage,
  Value<String?> wifiName,
  Value<String> titleText,
  Value<int> myOscPort,
  Value<String> myPassword,
  Value<String> serverIp,
  Value<int> serverOscPort,
  Value<int> serverMqttPort,
  Value<String> serverMqttId,
  Value<String> serverMqttPassword,
  Value<DateTime> createdAt,
});

class $$BasicInfoTableFilterComposer
    extends Composer<_$AppDatabase, $BasicInfoTable> {
  $$BasicInfoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomName => $composableBuilder(
      column: $table.roomName, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get logoImage => $composableBuilder(
      column: $table.logoImage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wifiName => $composableBuilder(
      column: $table.wifiName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleText => $composableBuilder(
      column: $table.titleText, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get myOscPort => $composableBuilder(
      column: $table.myOscPort, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get myPassword => $composableBuilder(
      column: $table.myPassword, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverIp => $composableBuilder(
      column: $table.serverIp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverOscPort => $composableBuilder(
      column: $table.serverOscPort, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverMqttPort => $composableBuilder(
      column: $table.serverMqttPort,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverMqttId => $composableBuilder(
      column: $table.serverMqttId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverMqttPassword => $composableBuilder(
      column: $table.serverMqttPassword,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BasicInfoTableOrderingComposer
    extends Composer<_$AppDatabase, $BasicInfoTable> {
  $$BasicInfoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomName => $composableBuilder(
      column: $table.roomName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get logoImage => $composableBuilder(
      column: $table.logoImage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wifiName => $composableBuilder(
      column: $table.wifiName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleText => $composableBuilder(
      column: $table.titleText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get myOscPort => $composableBuilder(
      column: $table.myOscPort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get myPassword => $composableBuilder(
      column: $table.myPassword, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverIp => $composableBuilder(
      column: $table.serverIp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverOscPort => $composableBuilder(
      column: $table.serverOscPort,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverMqttPort => $composableBuilder(
      column: $table.serverMqttPort,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverMqttId => $composableBuilder(
      column: $table.serverMqttId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverMqttPassword => $composableBuilder(
      column: $table.serverMqttPassword,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BasicInfoTableAnnotationComposer
    extends Composer<_$AppDatabase, $BasicInfoTable> {
  $$BasicInfoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get roomName =>
      $composableBuilder(column: $table.roomName, builder: (column) => column);

  GeneratedColumn<Uint8List> get logoImage =>
      $composableBuilder(column: $table.logoImage, builder: (column) => column);

  GeneratedColumn<String> get wifiName =>
      $composableBuilder(column: $table.wifiName, builder: (column) => column);

  GeneratedColumn<String> get titleText =>
      $composableBuilder(column: $table.titleText, builder: (column) => column);

  GeneratedColumn<int> get myOscPort =>
      $composableBuilder(column: $table.myOscPort, builder: (column) => column);

  GeneratedColumn<String> get myPassword => $composableBuilder(
      column: $table.myPassword, builder: (column) => column);

  GeneratedColumn<String> get serverIp =>
      $composableBuilder(column: $table.serverIp, builder: (column) => column);

  GeneratedColumn<int> get serverOscPort => $composableBuilder(
      column: $table.serverOscPort, builder: (column) => column);

  GeneratedColumn<int> get serverMqttPort => $composableBuilder(
      column: $table.serverMqttPort, builder: (column) => column);

  GeneratedColumn<String> get serverMqttId => $composableBuilder(
      column: $table.serverMqttId, builder: (column) => column);

  GeneratedColumn<String> get serverMqttPassword => $composableBuilder(
      column: $table.serverMqttPassword, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BasicInfoTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BasicInfoTable,
    BasicInfoData,
    $$BasicInfoTableFilterComposer,
    $$BasicInfoTableOrderingComposer,
    $$BasicInfoTableAnnotationComposer,
    $$BasicInfoTableCreateCompanionBuilder,
    $$BasicInfoTableUpdateCompanionBuilder,
    (
      BasicInfoData,
      BaseReferences<_$AppDatabase, $BasicInfoTable, BasicInfoData>
    ),
    BasicInfoData,
    PrefetchHooks Function()> {
  $$BasicInfoTableTableManager(_$AppDatabase db, $BasicInfoTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BasicInfoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BasicInfoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BasicInfoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> roomId = const Value.absent(),
            Value<String> roomName = const Value.absent(),
            Value<Uint8List> logoImage = const Value.absent(),
            Value<String?> wifiName = const Value.absent(),
            Value<String> titleText = const Value.absent(),
            Value<int> myOscPort = const Value.absent(),
            Value<String> myPassword = const Value.absent(),
            Value<String> serverIp = const Value.absent(),
            Value<int> serverOscPort = const Value.absent(),
            Value<int> serverMqttPort = const Value.absent(),
            Value<String> serverMqttId = const Value.absent(),
            Value<String> serverMqttPassword = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BasicInfoCompanion(
            id: id,
            roomId: roomId,
            roomName: roomName,
            logoImage: logoImage,
            wifiName: wifiName,
            titleText: titleText,
            myOscPort: myOscPort,
            myPassword: myPassword,
            serverIp: serverIp,
            serverOscPort: serverOscPort,
            serverMqttPort: serverMqttPort,
            serverMqttId: serverMqttId,
            serverMqttPassword: serverMqttPassword,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String roomId,
            Value<String> roomName = const Value.absent(),
            required Uint8List logoImage,
            Value<String?> wifiName = const Value.absent(),
            Value<String> titleText = const Value.absent(),
            Value<int> myOscPort = const Value.absent(),
            Value<String> myPassword = const Value.absent(),
            Value<String> serverIp = const Value.absent(),
            Value<int> serverOscPort = const Value.absent(),
            Value<int> serverMqttPort = const Value.absent(),
            Value<String> serverMqttId = const Value.absent(),
            Value<String> serverMqttPassword = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BasicInfoCompanion.insert(
            id: id,
            roomId: roomId,
            roomName: roomName,
            logoImage: logoImage,
            wifiName: wifiName,
            titleText: titleText,
            myOscPort: myOscPort,
            myPassword: myPassword,
            serverIp: serverIp,
            serverOscPort: serverOscPort,
            serverMqttPort: serverMqttPort,
            serverMqttId: serverMqttId,
            serverMqttPassword: serverMqttPassword,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BasicInfoTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BasicInfoTable,
    BasicInfoData,
    $$BasicInfoTableFilterComposer,
    $$BasicInfoTableOrderingComposer,
    $$BasicInfoTableAnnotationComposer,
    $$BasicInfoTableCreateCompanionBuilder,
    $$BasicInfoTableUpdateCompanionBuilder,
    (
      BasicInfoData,
      BaseReferences<_$AppDatabase, $BasicInfoTable, BasicInfoData>
    ),
    BasicInfoData,
    PrefetchHooks Function()>;
typedef $$PageTableCreateCompanionBuilder = PageCompanion Function({
  Value<int?> id,
  required String pageName,
  required int pageNum,
});
typedef $$PageTableUpdateCompanionBuilder = PageCompanion Function({
  Value<int?> id,
  Value<String> pageName,
  Value<int> pageNum,
});

final class $$PageTableReferences
    extends BaseReferences<_$AppDatabase, $PageTable, PageData> {
  $$PageTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ButtonTable, List<ButtonData>> _buttonRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.button,
          aliasName: $_aliasNameGenerator(db.page.id, db.button.page));

  $$ButtonTableProcessedTableManager get buttonRefs {
    final manager = $$ButtonTableTableManager($_db, $_db.button)
        .filter((f) => f.page.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_buttonRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PageTableFilterComposer extends Composer<_$AppDatabase, $PageTable> {
  $$PageTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pageName => $composableBuilder(
      column: $table.pageName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageNum => $composableBuilder(
      column: $table.pageNum, builder: (column) => ColumnFilters(column));

  Expression<bool> buttonRefs(
      Expression<bool> Function($$ButtonTableFilterComposer f) f) {
    final $$ButtonTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.button,
        getReferencedColumn: (t) => t.page,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ButtonTableFilterComposer(
              $db: $db,
              $table: $db.button,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PageTableOrderingComposer extends Composer<_$AppDatabase, $PageTable> {
  $$PageTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pageName => $composableBuilder(
      column: $table.pageName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageNum => $composableBuilder(
      column: $table.pageNum, builder: (column) => ColumnOrderings(column));
}

class $$PageTableAnnotationComposer
    extends Composer<_$AppDatabase, $PageTable> {
  $$PageTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pageName =>
      $composableBuilder(column: $table.pageName, builder: (column) => column);

  GeneratedColumn<int> get pageNum =>
      $composableBuilder(column: $table.pageNum, builder: (column) => column);

  Expression<T> buttonRefs<T extends Object>(
      Expression<T> Function($$ButtonTableAnnotationComposer a) f) {
    final $$ButtonTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.button,
        getReferencedColumn: (t) => t.page,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ButtonTableAnnotationComposer(
              $db: $db,
              $table: $db.button,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PageTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PageTable,
    PageData,
    $$PageTableFilterComposer,
    $$PageTableOrderingComposer,
    $$PageTableAnnotationComposer,
    $$PageTableCreateCompanionBuilder,
    $$PageTableUpdateCompanionBuilder,
    (PageData, $$PageTableReferences),
    PageData,
    PrefetchHooks Function({bool buttonRefs})> {
  $$PageTableTableManager(_$AppDatabase db, $PageTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PageTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PageTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PageTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int?> id = const Value.absent(),
            Value<String> pageName = const Value.absent(),
            Value<int> pageNum = const Value.absent(),
          }) =>
              PageCompanion(
            id: id,
            pageName: pageName,
            pageNum: pageNum,
          ),
          createCompanionCallback: ({
            Value<int?> id = const Value.absent(),
            required String pageName,
            required int pageNum,
          }) =>
              PageCompanion.insert(
            id: id,
            pageName: pageName,
            pageNum: pageNum,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PageTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({buttonRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (buttonRefs) db.button],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (buttonRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$PageTableReferences._buttonRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PageTableReferences(db, table, p0).buttonRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) =>
                                referencedItems.where((e) => e.page == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PageTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PageTable,
    PageData,
    $$PageTableFilterComposer,
    $$PageTableOrderingComposer,
    $$PageTableAnnotationComposer,
    $$PageTableCreateCompanionBuilder,
    $$PageTableUpdateCompanionBuilder,
    (PageData, $$PageTableReferences),
    PageData,
    PrefetchHooks Function({bool buttonRefs})>;
typedef $$ButtonTableCreateCompanionBuilder = ButtonCompanion Function({
  Value<int?> id,
  Value<String> buttonName,
  Value<bool> isUsingButton,
  Value<int> page,
  Value<int> row,
  Value<int> column,
  Value<Command> command,
  Value<String?> queryString,
  Value<String?> message,
});
typedef $$ButtonTableUpdateCompanionBuilder = ButtonCompanion Function({
  Value<int?> id,
  Value<String> buttonName,
  Value<bool> isUsingButton,
  Value<int> page,
  Value<int> row,
  Value<int> column,
  Value<Command> command,
  Value<String?> queryString,
  Value<String?> message,
});

final class $$ButtonTableReferences
    extends BaseReferences<_$AppDatabase, $ButtonTable, ButtonData> {
  $$ButtonTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PageTable _pageTable(_$AppDatabase db) =>
      db.page.createAlias($_aliasNameGenerator(db.button.page, db.page.id));

  $$PageTableProcessedTableManager get page {
    final manager = $$PageTableTableManager($_db, $_db.page)
        .filter((f) => f.id($_item.page));
    final item = $_typedResult.readTableOrNull(_pageTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ButtonTableFilterComposer
    extends Composer<_$AppDatabase, $ButtonTable> {
  $$ButtonTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get buttonName => $composableBuilder(
      column: $table.buttonName, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUsingButton => $composableBuilder(
      column: $table.isUsingButton, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get row => $composableBuilder(
      column: $table.row, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get column => $composableBuilder(
      column: $table.column, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Command, Command, String> get command =>
      $composableBuilder(
          column: $table.command,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get queryString => $composableBuilder(
      column: $table.queryString, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  $$PageTableFilterComposer get page {
    final $$PageTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.page,
        referencedTable: $db.page,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PageTableFilterComposer(
              $db: $db,
              $table: $db.page,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ButtonTableOrderingComposer
    extends Composer<_$AppDatabase, $ButtonTable> {
  $$ButtonTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get buttonName => $composableBuilder(
      column: $table.buttonName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUsingButton => $composableBuilder(
      column: $table.isUsingButton,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get row => $composableBuilder(
      column: $table.row, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get column => $composableBuilder(
      column: $table.column, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get command => $composableBuilder(
      column: $table.command, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get queryString => $composableBuilder(
      column: $table.queryString, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  $$PageTableOrderingComposer get page {
    final $$PageTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.page,
        referencedTable: $db.page,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PageTableOrderingComposer(
              $db: $db,
              $table: $db.page,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ButtonTableAnnotationComposer
    extends Composer<_$AppDatabase, $ButtonTable> {
  $$ButtonTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get buttonName => $composableBuilder(
      column: $table.buttonName, builder: (column) => column);

  GeneratedColumn<bool> get isUsingButton => $composableBuilder(
      column: $table.isUsingButton, builder: (column) => column);

  GeneratedColumn<int> get row =>
      $composableBuilder(column: $table.row, builder: (column) => column);

  GeneratedColumn<int> get column =>
      $composableBuilder(column: $table.column, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Command, String> get command =>
      $composableBuilder(column: $table.command, builder: (column) => column);

  GeneratedColumn<String> get queryString => $composableBuilder(
      column: $table.queryString, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  $$PageTableAnnotationComposer get page {
    final $$PageTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.page,
        referencedTable: $db.page,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PageTableAnnotationComposer(
              $db: $db,
              $table: $db.page,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ButtonTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ButtonTable,
    ButtonData,
    $$ButtonTableFilterComposer,
    $$ButtonTableOrderingComposer,
    $$ButtonTableAnnotationComposer,
    $$ButtonTableCreateCompanionBuilder,
    $$ButtonTableUpdateCompanionBuilder,
    (ButtonData, $$ButtonTableReferences),
    ButtonData,
    PrefetchHooks Function({bool page})> {
  $$ButtonTableTableManager(_$AppDatabase db, $ButtonTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ButtonTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ButtonTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ButtonTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int?> id = const Value.absent(),
            Value<String> buttonName = const Value.absent(),
            Value<bool> isUsingButton = const Value.absent(),
            Value<int> page = const Value.absent(),
            Value<int> row = const Value.absent(),
            Value<int> column = const Value.absent(),
            Value<Command> command = const Value.absent(),
            Value<String?> queryString = const Value.absent(),
            Value<String?> message = const Value.absent(),
          }) =>
              ButtonCompanion(
            id: id,
            buttonName: buttonName,
            isUsingButton: isUsingButton,
            page: page,
            row: row,
            column: column,
            command: command,
            queryString: queryString,
            message: message,
          ),
          createCompanionCallback: ({
            Value<int?> id = const Value.absent(),
            Value<String> buttonName = const Value.absent(),
            Value<bool> isUsingButton = const Value.absent(),
            Value<int> page = const Value.absent(),
            Value<int> row = const Value.absent(),
            Value<int> column = const Value.absent(),
            Value<Command> command = const Value.absent(),
            Value<String?> queryString = const Value.absent(),
            Value<String?> message = const Value.absent(),
          }) =>
              ButtonCompanion.insert(
            id: id,
            buttonName: buttonName,
            isUsingButton: isUsingButton,
            page: page,
            row: row,
            column: column,
            command: command,
            queryString: queryString,
            message: message,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ButtonTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({page = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (page) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.page,
                    referencedTable: $$ButtonTableReferences._pageTable(db),
                    referencedColumn: $$ButtonTableReferences._pageTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ButtonTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ButtonTable,
    ButtonData,
    $$ButtonTableFilterComposer,
    $$ButtonTableOrderingComposer,
    $$ButtonTableAnnotationComposer,
    $$ButtonTableCreateCompanionBuilder,
    $$ButtonTableUpdateCompanionBuilder,
    (ButtonData, $$ButtonTableReferences),
    ButtonData,
    PrefetchHooks Function({bool page})>;
typedef $$MediaItemTableCreateCompanionBuilder = MediaItemCompanion Function({
  Value<int> id,
  required MediaType type,
  required String url,
  Value<String?> fileName,
  Value<MediaFrom> from,
  Value<BoxFit?> fit,
  required int orderNum,
});
typedef $$MediaItemTableUpdateCompanionBuilder = MediaItemCompanion Function({
  Value<int> id,
  Value<MediaType> type,
  Value<String> url,
  Value<String?> fileName,
  Value<MediaFrom> from,
  Value<BoxFit?> fit,
  Value<int> orderNum,
});

class $$MediaItemTableFilterComposer
    extends Composer<_$AppDatabase, $MediaItemTable> {
  $$MediaItemTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MediaType, MediaType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MediaFrom, MediaFrom, String> get from =>
      $composableBuilder(
          column: $table.from,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<BoxFit?, BoxFit, String> get fit =>
      $composableBuilder(
          column: $table.fit,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get orderNum => $composableBuilder(
      column: $table.orderNum, builder: (column) => ColumnFilters(column));
}

class $$MediaItemTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaItemTable> {
  $$MediaItemTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get from => $composableBuilder(
      column: $table.from, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fit => $composableBuilder(
      column: $table.fit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderNum => $composableBuilder(
      column: $table.orderNum, builder: (column) => ColumnOrderings(column));
}

class $$MediaItemTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaItemTable> {
  $$MediaItemTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MediaType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MediaFrom, String> get from =>
      $composableBuilder(column: $table.from, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BoxFit?, String> get fit =>
      $composableBuilder(column: $table.fit, builder: (column) => column);

  GeneratedColumn<int> get orderNum =>
      $composableBuilder(column: $table.orderNum, builder: (column) => column);
}

class $$MediaItemTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MediaItemTable,
    MediaItemData,
    $$MediaItemTableFilterComposer,
    $$MediaItemTableOrderingComposer,
    $$MediaItemTableAnnotationComposer,
    $$MediaItemTableCreateCompanionBuilder,
    $$MediaItemTableUpdateCompanionBuilder,
    (
      MediaItemData,
      BaseReferences<_$AppDatabase, $MediaItemTable, MediaItemData>
    ),
    MediaItemData,
    PrefetchHooks Function()> {
  $$MediaItemTableTableManager(_$AppDatabase db, $MediaItemTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaItemTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaItemTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaItemTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<MediaType> type = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String?> fileName = const Value.absent(),
            Value<MediaFrom> from = const Value.absent(),
            Value<BoxFit?> fit = const Value.absent(),
            Value<int> orderNum = const Value.absent(),
          }) =>
              MediaItemCompanion(
            id: id,
            type: type,
            url: url,
            fileName: fileName,
            from: from,
            fit: fit,
            orderNum: orderNum,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required MediaType type,
            required String url,
            Value<String?> fileName = const Value.absent(),
            Value<MediaFrom> from = const Value.absent(),
            Value<BoxFit?> fit = const Value.absent(),
            required int orderNum,
          }) =>
              MediaItemCompanion.insert(
            id: id,
            type: type,
            url: url,
            fileName: fileName,
            from: from,
            fit: fit,
            orderNum: orderNum,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MediaItemTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MediaItemTable,
    MediaItemData,
    $$MediaItemTableFilterComposer,
    $$MediaItemTableOrderingComposer,
    $$MediaItemTableAnnotationComposer,
    $$MediaItemTableCreateCompanionBuilder,
    $$MediaItemTableUpdateCompanionBuilder,
    (
      MediaItemData,
      BaseReferences<_$AppDatabase, $MediaItemTable, MediaItemData>
    ),
    MediaItemData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BasicInfoTableTableManager get basicInfo =>
      $$BasicInfoTableTableManager(_db, _db.basicInfo);
  $$PageTableTableManager get page => $$PageTableTableManager(_db, _db.page);
  $$ButtonTableTableManager get button =>
      $$ButtonTableTableManager(_db, _db.button);
  $$MediaItemTableTableManager get mediaItem =>
      $$MediaItemTableTableManager(_db, _db.mediaItem);
}
