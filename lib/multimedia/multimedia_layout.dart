import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/multimedia/component/item_image.dart';

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final mWidth = constraints.maxWidth;
      final mHeight = constraints.maxHeight;
      final iconSize = mHeight * 0.08;

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
                viewportFraction: 1),
            items: [1, 2, 3].map((i) {
              return Builder(
                builder: (BuildContext context) {
                  if (i == 2) {
                    return ItemImage(url: imageUrlFromWeb);
                  }

                  if (i == 3) {
                    return ItemImage.fromGDrive(
                        url: imageUrlFromGDrive, fit: BoxFit.contain);
                  }
                  return Container(
                      width: mWidth,
                      // margin: EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(color: LECTURE_BG_COLORS[i]),
                      child: Center(
                        child: Text(
                          '테스트 슬라이드 $i',
                          style: TextStyle(fontSize: mHeight * 0.05),
                        ),
                      ));
                },
              );
            }).toList(),
          ),
          Positioned(
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
          )
        ],
      );
    });
  }
}
