import 'package:drift/drift.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/data/model/media_item.dart';

const List<MediaItemCompanion> DEFAULT_MEDIA_ITEM = [
  // 2025 경상대 새해복
  MediaItemCompanion(
    type: Value(MediaType.image),
    title: Value('2025새해복'),
    url: Value(
        'https://www.gnu.ac.kr/upload/main/na/bbs_5171/ntt_2264748/img_44ab9c58-a741-4b93-bd7b-ddeee17c0ac11736728581323.png'),
    from: Value(MediaFrom.etc),
    orderNum: Value(1),
  ),
  // 2025-1학기 수강정정 기간 안내
  MediaItemCompanion(
    type: Value(MediaType.image),
    title: Value('수강정정 안내'),
    url: Value(
        'https://drive.google.com/file/d/1NohQvH-3Bqg1ev-Wju50Yfsp3TRFKZf2/view?usp=sharing'),
    from: Value(MediaFrom.gDrive),
    orderNum: Value(2),
  ),
  // 경상대 홍보 영상
  MediaItemCompanion(
    type: Value(MediaType.video),
    title: Value('대학홍보영상'),
    url: Value(
        'https://drive.google.com/file/d/1NkN1gbTceG_4rnAjhcu5SHZHsx4cMoSo/view?usp=sharing'),
    from: Value(MediaFrom.gDrive),
    orderNum: Value(3),
  ),
  // 경상대 웹뷰
  MediaItemCompanion(
    type: Value(MediaType.webView),
    title: Value('대학 홈페이지'),
    url: Value(
        'https://www.gnu.ac.kr/main/main.do'),
    from: Value(MediaFrom.webView),
    orderNum: Value(4),
  ),
];
