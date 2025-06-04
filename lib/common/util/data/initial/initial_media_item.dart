import 'package:drift/drift.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/data/model/media_item.dart';

const List<MediaItemCompanion> DEFAULT_MEDIA_ITEM = [

  MediaItemCompanion(
    key: Value('initialData'),
    type: Value(MediaType.image),
    title: Value('chatGPT광주보건대'),
    url: Value(
        'https://www.ghu.ac.kr/storage/board/74/content/20250403090137FSxSpXIdmfUD0627Y7ZM.png'),
    from: Value(MediaFrom.etc),
    orderNum: Value(1),
  ),
  // 2025-1학기 수강정정 기간 안내
  // MediaItemCompanion(
  //   type: Value(MediaType.image),
  //   title: Value('수강정정 안내'),
  //   url: Value(
  //       'https://drive.google.com/file/d/1NohQvH-3Bqg1ev-Wju50Yfsp3TRFKZf2/view?usp=sharing'),
  //   from: Value(MediaFrom.gDrive),
  //   orderNum: Value(2),
  // ),
  // 경상대 홍보 영상
  // MediaItemCompanion(
  //   type: Value(MediaType.video),
  //   title: Value('대학홍보영상'),
  //   url: Value(
  //       'https://drive.google.com/file/d/1NkN1gbTceG_4rnAjhcu5SHZHsx4cMoSo/view?usp=sharing'),
  //   from: Value(MediaFrom.gDrive),
  //   orderNum: Value(3),
  // ),
  // 경상대 웹뷰
  // MediaItemCompanion(
  //   type: Value(MediaType.webView),
  //   title: Value('대학 홈페이지'),
  //   url: Value(
  //       'https://www.gnu.ac.kr/main/main.do'),
  //   from: Value(MediaFrom.webView),
  //   orderNum: Value(4),
  // ),
];
