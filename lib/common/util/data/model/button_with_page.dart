import 'package:mdk_kiosk/common/util/data/drift.dart';

class ButtonWithPage {
  final ButtonData button;
  final PageData page;

  ButtonWithPage({
    required this.button,
    required this.page,
  });
}

// final emptyBwP = ButtonWithPage(
//     button: globalData.buttons.first.copyWith(
//       // id: 99999,
//       buttonName: '버튼정보없음',
//     ),
//     page: globalData.pages.first);
