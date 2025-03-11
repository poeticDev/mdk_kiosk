import 'dart:io';

import 'package:video_player/video_player.dart';

/// 필요시 사용
/// 현재 협의사항 -> 동영상 재생 시, 해당 영상이 재생 완료된 후 다음 슬라이드로 넘어감
//
// class VideoControllerManager {
//   static final VideoControllerManager _instance = VideoControllerManager
//       ._internal();
//
//   factory VideoControllerManager() => _instance;
//
//   VideoControllerManager._internal();
//
//   final Map<String, VideoPlayerController> _controllers = {};
//
//   Future<VideoPlayerController> getController(File file) async {
//     final key = file.path;
//
//     if (_controllers.containsKey(key)) {
//       return _controllers[key]!;
//     }
//
//     final controller = VideoPlayerController.file(file);
//     await controller.initialize();
//     _controllers[key] = controller;
//     return controller;
//   }
//
//   void disposeController(String filePath) {
//     _controllers[filePath]?.dispose();
//     _controllers.remove(filePath);
//   }
//
//   void disposeAll() {
//     _controllers.forEach((key, controller) {
//       controller.dispose();
//     });
//     _controllers.clear();
//   }
//
//
// }