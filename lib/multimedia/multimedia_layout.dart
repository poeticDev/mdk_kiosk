import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/data/model/media_item.dart';
import 'package:mdk_kiosk/common/view/splash_screen.dart';
import 'package:mdk_kiosk/multimedia/component/item_image.dart';
import 'package:mdk_kiosk/multimedia/component/item_video.dart';
import 'package:mdk_kiosk/multimedia/component/item_web_view.dart';

class MultimediaLayout extends StatefulWidget {
  final List<Widget>? items;

  MultimediaLayout({
    super.key,
    this.items,
  });

  @override
  State<MultimediaLayout> createState() => _MultimediaLayoutState();
}

class _MultimediaLayoutState extends State<MultimediaLayout> {
  final CarouselSliderController carouselSliderController =
      CarouselSliderController();

  bool isAutoPlaying = true;
  Color iconColor = ICON_COLOR;

  late List<Widget> mediaItems;
  bool _isLoading = true;

  void _stopAutoPlay() {
    setState(() {
      isAutoPlaying = false;
    });
  }

  void _startAutoPlay() {
    setState(() {
      isAutoPlaying = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeMediaItems();
  }

  void _initializeMediaItems() async {
    final db = GetIt.I<AppDatabase>();

    final List<MediaItemData> mediaItemDatas = await db.getMediaItems();

    mediaItems = _RenderMediaItems(mediaItemDatas);
  }

  List<Widget> _RenderMediaItems(List<MediaItemData> mediaItemDatas) {
    List<Widget> items = [];

    for (MediaItemData mediaItemData in mediaItemDatas) {
      if (mediaItemData.type == MediaType.image) {
        items.add(ItemImage.fromMediaData(mediaItemData,
          onLoadingStart: _stopAutoPlay,
          onLoadingEnd: _startAutoPlay,
        ));
      } else if (mediaItemData.type == MediaType.video) {
        items.add(
          ItemVideo.fromMediaData(
            mediaItemData,
            onPlayStart: _stopAutoPlay,
            onPlayEnd: _startAutoPlay,
          ),
        );
      } else if (mediaItemData.type == MediaType.webView) {
        items.add(
          ItemWebView(url: mediaItemData.url),
        );
      }
    }

    if (items.isEmpty) {
      items.add(
        Center(
          child: Text(
            '미디어 정보가 없습니다',
            style: TextStyle(fontSize: 32),
          ),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });


    return items;
  }

  @override
  Widget build(BuildContext context) {
    // print('nodeRedToFlutterData: $nodeRedToFlutterData');
    // print('nodeRedToFlutterData.runtimeType: ${nodeRedToFlutterData.runtimeType}');
    // print('jsonEncode(nodeRedToFlutterData): ${jsonEncode(nodeRedToFlutterData)}');
    // print('jsonEncode(nodeRedToFlutterData).runtimeType: ${jsonEncode(nodeRedToFlutterData).runtimeType}');
    // print('jsonDecode(jsonEncode(nodeRedToFlutterData)): ${jsonDecode(jsonEncode(nodeRedToFlutterData))}');
    // print('jsonDecode(jsonEncode(nodeRedToFlutterData)).runtimeType: ${jsonDecode(jsonEncode(nodeRedToFlutterData)).runtimeType}');



    return LayoutBuilder(builder: (context, constraints) {
      final mWidth = constraints.maxWidth;
      final mHeight = constraints.maxHeight;
      final iconSize = mHeight * 0.08;

      if (_isLoading) {
        return const Center(child: SplashScreen()); // 로딩 화면
      }

      return Stack(
        children: [
          // 슬라이더
          CarouselSlider(
            carouselController: carouselSliderController,
            options: CarouselOptions(
              aspectRatio: 16 / 9,
              height: mHeight,
              autoPlay: isAutoPlaying,
              autoPlayInterval: Duration(seconds: 5),
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                if (reason == CarouselPageChangedReason.manual) {
                  // 수동 슬라이드 넘김 → autoPlay 재개
                  _startAutoPlay();
                }
              },
            ),
            items: mediaItems,
          ),
          // 컨트롤 버튼
          // _RenderCarouselController(iconSize: iconSize),
        ],
      );
    });
  }

  /// 슬라이더 컨트롤 버튼
  Widget _RenderCarouselController({required double iconSize}) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              carouselSliderController.previousPage();
            },
            icon: Icon(
              CupertinoIcons.arrow_left_circle,
              size: iconSize,
              color: iconColor,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                if (isAutoPlaying) {
                  carouselSliderController.stopAutoPlay();
                } else {
                  carouselSliderController.startAutoPlay();
                  carouselSliderController.nextPage();
                }
                isAutoPlaying = !isAutoPlaying; // ✅ 상태 업데이트
              });
            },
            icon: Icon(
              isAutoPlaying
                  ? CupertinoIcons.pause_circle
                  : CupertinoIcons.play_circle,
              size: iconSize,
              color: iconColor,
            ),
          ),
          IconButton(
            onPressed: () {
              carouselSliderController.nextPage();
            },
            icon: Icon(
              CupertinoIcons.arrow_right_circle,
              size: iconSize,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}
