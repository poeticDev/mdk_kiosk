import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mdk_kiosk/common/const/colors.dart';

class MultimediaLayout extends StatelessWidget {
  const MultimediaLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final mWidth = constraints.maxWidth;
      final mHeight = constraints.maxHeight;

      return CarouselSlider(
        options: CarouselOptions(
          height: mHeight,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 5),
        ),
        items: [1, 2, 3, 4, 5].map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                  width: mWidth,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(color: LECTURE_BG_COLORS[i]),
                  child: Text(
                    'text $i',
                    style: TextStyle(fontSize: 16.0),
                  ));
            },
          );
        }).toList(),
      );
    });
  }
}
