import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';

String webViewUrl = 'https://www.gnu.ac.kr/main/na/ntt/selectNttInfo.do?mi=1289&bbsId=1039&nttSn=2269297';

class ItemWebView extends StatefulWidget {
  final String url;

  const ItemWebView({super.key, required this.url});

  @override
  State<ItemWebView> createState() => _ItemWebViewState();

  // factory ItemWebView.fromMediaData(MediaItemData mediaItemData){
  //   return ItemWebView(url: mediaItemData.url);
  //
  // }
}

class _ItemWebViewState extends State<ItemWebView> {
  InAppWebViewSettings options = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true, // URL 로딩 제어
    mediaPlaybackRequiresUserGesture: true, // 미디어 자동 재생
    javaScriptEnabled: true, // 자바스크립트 실행 여부
    javaScriptCanOpenWindowsAutomatically: false, // 팝업 여부
    useHybridComposition: true, // 하이브리드 사용을 위한 안드로이드 웹뷰 최적화
    supportMultipleWindows: true, // 멀티 윈도우 허용
    allowsInlineMediaPlayback: true, // 웹뷰 내 미디어 재생 허용
  );

  // late final WebViewController _controller;
  //
  // @override
  // void initState() {
  //   super.initState();
  //
  //   const PlatformWebViewControllerCreationParams params =
  //       PlatformWebViewControllerCreationParams();
  //
  //   final WebViewController controller =
  //       WebViewController.fromPlatformCreationParams(params);
  //
  //   controller
  //     ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //     ..setBackgroundColor(const Color(0x00000000))
  //     ..setNavigationDelegate(
  //       NavigationDelegate(
  //         onProgress: (int progress) {
  //           debugPrint('WebView is loading (progress : $progress%)');
  //         },
  //         onPageStarted: (String url) {
  //           debugPrint('Page started loading: $url');
  //         },
  //         onPageFinished: (String url) {
  //           debugPrint('Page finished loading: $url');
  //         },
  //         onWebResourceError: (WebResourceError error) {
  //           debugPrint('''
  //
  //
  //
  //                       Page resource error:
  //
  //
  //
  //                         code: ${error.errorCode}
  //
  //
  //
  //                         description: ${error.description}
  //
  //
  //
  //                         errorType: ${error.errorType}
  //
  //
  //
  //                         isForMainFrame: ${error.isForMainFrame}
  //
  //
  //
  //                   ''');
  //         },
  //         onNavigationRequest: (NavigationRequest request) {
  //           debugPrint('allowing navigation to ${request.url}');
  //
  //           return NavigationDecision.navigate;
  //         },
  //       ),
  //     )
  //     ..addJavaScriptChannel(
  //       'Toaster',
  //       onMessageReceived: (JavaScriptMessage message) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text(message.message)),
  //         );
  //       },
  //     )
  //     ..loadRequest(Uri.parse('https://flutter.dev/'));
  //
  //   if (controller.platform is AndroidWebViewController) {
  //     AndroidWebViewController.enableDebugging(true);
  //
  //     (controller.platform as AndroidWebViewController)
  //         .setMediaPlaybackRequiresUserGesture(false);
  //   }
  //
  //   _controller = controller;
  // }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double mWidth = constraints.maxWidth;
      final double mHeight = constraints.maxHeight;

      return SizedBox(
        width: mWidth,
        height: mHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.url),
            ),
            initialSettings: options,
          ),
        ),
      );
    });
  }
}
