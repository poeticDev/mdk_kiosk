import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

final homeUrl = Uri.parse('https://www.gnu.ac.kr/main/main.do');

class WebViewTest extends StatefulWidget {
  WebViewTest({super.key});

  @override
  State<WebViewTest> createState() => _WebViewTestState();


}

class _WebViewTestState extends State<WebViewTest> {

  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(homeUrl);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Web View Test'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {

              setState(() {
                controller.loadRequest(Uri.parse('https://www.gnu.ac.kr/main/main.do'));
              });

            },
            icon: Icon(Icons.home),
          )
        ],
      ),
      backgroundColor:  BG_COLOR,
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: WebViewWidget(controller: controller)),
    );
  }
}
