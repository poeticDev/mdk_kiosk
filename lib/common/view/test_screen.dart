import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/data/initial/mqtt_json_sample.dart';
import 'package:mdk_kiosk/common/util/network/mqtt_manager.dart';
import 'package:mdk_kiosk/multimedia/util/media_controller.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BG_COLOR,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          decoration: BoxDecoration(border: Border.all()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.go('/home');
                },
                child: Text(
                  'go back',
                  style: BODY_TEXT_STYLE,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final db = GetIt.I<AppDatabase>();
                  final List<MediaItemData> mediaItemList = await db.getMediaItemDataList();

                  final message = MediaController().mediaItemDataListToJson(mediaItemList);;

                  mqttManager.publish(
                      'node-mdk/$KIOSK_NAME/$KIOSK_NAME', message);
                },
                child: Text(
                  'mqtt publish',
                  style: BODY_TEXT_STYLE,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
