import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/common/util/data/initial/mqtt_json_sample.dart';
import 'package:mdk_kiosk/common/util/network/mqtt_manager.dart';

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
                onPressed: () {
                  mqttManager.publish(
                      'node-mdk/$KIOSK_NAME/$KIOSK_NAME', (jsonEncode(jsonSample)));
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
