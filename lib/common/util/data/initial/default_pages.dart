import 'package:drift/drift.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';

/// 페이지 아이디로 식별합니다.
/// 아이디는 순서대로 자동 부여되니, 협의 없이 임의로 순서를 바꾸면 안 됩니다.
/// 표출 순서는 pageNum에 따라 오름차순입니다.
const List<PageCompanion> DEFAULT_PAGES = [
  PageCompanion(
    pageName: Value('POWER'),
    pageNum: Value(99),
  ),
  PageCompanion(
    pageName: Value('NDI'),
    pageNum: Value(85),
  ),
  PageCompanion(
    pageName: Value('MTX'),
    pageNum: Value(80),
  ),
  PageCompanion(
    pageName: Value('PPT'),
    pageNum: Value(2),
  ),
  PageCompanion(
    pageName: Value('ZOOM'),
    pageNum: Value(2),
  ),
  PageCompanion(
    pageName: Value('DMX'),
    pageNum: Value(7),
  ),
  PageCompanion(
    pageName: Value('AUDIO'),
    pageNum: Value(4),
  ),
  PageCompanion(
    pageName: Value('Camera'),
    pageNum: Value(3),
  ),
];