import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/data/model/media_item.dart';
import 'package:mdk_kiosk/common/view/splash_screen.dart';
import 'package:mdk_kiosk/multimedia/component/item_image.dart';
import 'package:mdk_kiosk/multimedia/component/item_video.dart';
import 'package:mdk_kiosk/multimedia/component/item_web_view.dart';
import 'package:mdk_kiosk/multimedia/util/media_controller.dart';

class MultimediaLayout extends ConsumerStatefulWidget {
  final List<Widget>? items;

  const MultimediaLayout({
    super.key,
    this.items,
  });

  @override
  ConsumerState<MultimediaLayout> createState() => _MultimediaLayoutState();
}

class _MultimediaLayoutState extends ConsumerState<MultimediaLayout> {
  final CarouselSliderController carouselSliderController =
      CarouselSliderController();

  bool isAutoPlaying = true;

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

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final asyncMediaItems = ref.watch(mediaControllerProvider);

    return LayoutBuilder(builder: (context, constraints) {
      final mHeight = constraints.maxHeight;

      return asyncMediaItems.when(
        loading: () => Center(child: SplashScreen()),
        error: (error, stack) => Center(
          child: Text(
            '미디어 정보가 없습니다',
            style: TextStyle(fontSize: 32),
          ),
        ),
        data: (mediaItemDataList) {
          if (mediaItemDataList.isEmpty) {
            return Center(
              child: Text(
                '미디어 정보가 없습니다',
                style: TextStyle(fontSize: 32),
              ),
            );
          }

          final mediaItems = widget.items ?? _RenderMediaItems(mediaItemDataList);

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
        },
      );
    });
  }
}