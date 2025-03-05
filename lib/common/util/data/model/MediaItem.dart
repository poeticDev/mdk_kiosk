import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart' show BoxFit;

enum MediaType { image, video, webView }

enum MediaFrom { gDrive, etc, webView }

class MediaItem extends Table {
  /// 1) 식별 아이디
  IntColumn get id => integer().autoIncrement()();

  /// 2) 미디어 타입
  TextColumn get type => textEnum<MediaType>()();

  /// 3) 주소
  TextColumn get url => text()();

  /// 4) 파일명
  /// - 없으면 url 마지막 부분에서 파일명 추출
  TextColumn get fileName => text().nullable()();

  /// 5) 저장위치
  TextColumn get from =>
      textEnum<MediaFrom>().withDefault(const Constant('gDrive'))();

  /// 6) 미디어 표출 방식
  /// - cover(기본): 꽉 채움
  /// - contain: 여백이 있더라도 다 나오게)
  TextColumn get fit => textEnum<BoxFit>().nullable()();

  /// 7) 표출 순서 : 기본 생성순
  IntColumn get orderNum => integer()();
}

// class ItemModel {
//   final int id;
//   final MediaType type;
//   final String url;
//   final String? fileName;
//   final BoxFit? fit;
//   final int? orderNum;
//
//   ItemModel({
//     required this.id,
//     required this.type,
//     required this.url,
//     this.fileName,
//     this.fit,
//     this.orderNum
//   });
//
//   factory ItemModel.fromJson({required Map<String, dynamic> json}) {
//     return ItemModel(
//       id: json['id'],
//       type: json['type'],
//       url: json['url'],
//       fileName: json['fileName'],
//       fit: json['fit'],
//       orderNum: json['orderNum'],
//     );
//   }
// }
