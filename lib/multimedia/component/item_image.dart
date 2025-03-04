import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/common/view/splash_screen.dart';

String imageUrlFromGDrive =
    'https://drive.google.com/file/d/1YKPA7ezjTsN1jIc79Zs0NM7Me-akXWVA/view?usp=sharing';

String imageUrlFromWeb =
    'https://www.gnu.ac.kr/upload/main/na/bbs_5171/ntt_2264748/img_44ab9c58-a741-4b93-bd7b-ddeee17c0ac11736728581323.png';

class ItemImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const ItemImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  /// 이미지가 구글 드라이브에 있을 때
  factory ItemImage.fromGDrive({
    required String url,
    BoxFit fit = BoxFit.cover,
  }) {
    final convertedUrl = _convertedFromGoogleURL(url);

    return ItemImage(
      url: convertedUrl,
      fit: fit,
    );
  }

  // 구글 드라이브 url에서 파일 url만 추출
  static String _convertedFromGoogleURL(String fullUrl) {
    final uri = Uri.parse(fullUrl);
    final segments = uri.pathSegments;

    if (segments.contains('file')) {
      final fileIndex = segments.indexOf('file');
      if (fileIndex + 2 < segments.length) {
        return 'https://drive.google.com/uc?export=view&id=${segments[fileIndex + 2]}'; // 'd' 다음이 파일ID
      }
    }

    throw fullUrl;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double mWidth = constraints.maxWidth;
      final double mHeight = constraints.maxHeight;

      return Image.network(
        url,
        width: mWidth,
        height: mHeight,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          // 로딩 완료
          if (loadingProgress == null) {
            return child;
          } else {
            return Center(
              child: SplashScreen(),
            );
          }
        },
        errorBuilder: (context, error, stackTrace) {
          print('이미지 로딩 에러');
          print(error);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 24),
                Text(
                  '이미지 주소를 확인해주세요',
                  style: BODY_TEXT_STYLE,
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
