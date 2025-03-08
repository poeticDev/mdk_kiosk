import 'package:fluttertoast/fluttertoast.dart';
import 'package:mdk_kiosk/common/const/colors.dart';

void showCustomToast(String toastMsg) {
  Fluttertoast.showToast(
    msg: toastMsg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: TOAST_BG_COLOR,
    textColor: WHITE_TEXT_COLOR,
    fontSize: 16.0,
  );
}
