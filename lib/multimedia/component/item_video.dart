import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/data/model/media_item.dart';

import 'package:video_player/video_player.dart';

import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/common/view/splash_screen.dart';
import 'package:mdk_kiosk/multimedia/util/download_manager.dart';

String videoUrlFromGDrive =
    'https://drive.google.com/file/d/1zxmvhegyd9coVoUeNSonexwxnhbQ5A_I/view?usp=sharing';

String videoUrlFromWeb =
    'https://www.youtube.com/watch?v=ieMwUbVsTK0&pp=ygUM6r2D67Ct7JeQ7ISc';

class ItemVideo extends StatefulWidget {
  final String downloadUrl;
  final String? fileName;
  final BoxFit? fit;
  final VoidCallback? onPlayStart;
  final VoidCallback? onPlayEnd;

  const ItemVideo({
    super.key,
    required this.downloadUrl,
    this.fileName,
    this.fit = BoxFit.cover,
    this.onPlayStart,
    this.onPlayEnd,
  });

  /// 구글 드라이브 URL 모드
  factory ItemVideo.fromGDrive({
    required String url,
    String? fileName,
    BoxFit? fit = BoxFit.cover,
    VoidCallback? onPlayStart,
    VoidCallback? onPlayEnd,
  }) {
    final convertedUrl = _convertedFromGoogleURL(url);
    return ItemVideo(
      downloadUrl: convertedUrl,
      fileName: fileName,
      fit: fit,
      onPlayStart: onPlayStart,
      onPlayEnd: onPlayEnd,
    );
  }

  /// 앱 db로부터 미디어데이터 불러와 생성하기
  factory ItemVideo.fromMediaData(
    MediaItemData mediaItemData, {
    VoidCallback? onPlayStart,
    VoidCallback? onPlayEnd,
  }) {
    if (mediaItemData.from == MediaFrom.gDrive) {
      return ItemVideo.fromGDrive(
        url: mediaItemData.url,
        fileName:
        mediaItemData.fileName ?? 'videoFromGDrive${mediaItemData.id}',
        fit: mediaItemData.fit,
        onPlayStart: onPlayStart,
        onPlayEnd: onPlayEnd,
      );
    } else {
      return ItemVideo(
        downloadUrl: mediaItemData.url,
        fileName:
        mediaItemData.fileName ?? 'imageFromWeb${mediaItemData.id}',
        fit: mediaItemData.fit,
        onPlayStart: onPlayStart,
        onPlayEnd: onPlayEnd,
      );
    }
  }

  // 구글 드라이브 URL을 다운로드 URL로 변환
  static String _convertedFromGoogleURL(String fullUrl) {
    final DownloadManager downloadManager = DownloadManager();

    return downloadManager.convertToDownloadUrl(fullUrl);
  }

  @override
  State<ItemVideo> createState() => _ItemVideoState();
}

class _ItemVideoState extends State<ItemVideo> {
  late final File file;
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMsg = "URL을 확인해주세요";

  @override
  void initState() {
    super.initState();
    _checkNetworkAndInitialize();
  }

  Future<void> _checkNetworkAndInitialize() async {
    final isNetworkAvailable = await DownloadManager().isNetworkAvailable();
    if (!isNetworkAvailable) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMsg = "네트워크 연결을 확인해주세요";
      });
      return; // 네트워크 안되면 더 이상 진행 안 함
    }

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final DownloadManager downloadManager = DownloadManager();

      widget.onPlayStart?.call();

      file = await downloadManager.downloadVideo(
          widget.downloadUrl, widget.fileName);

      _controller = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {
            _isLoading = false;
            _controller.setLooping(false); // 반복재생 X
          });
        });

      _controller.addListener(_videoListener);

      _controller.play(); // 자동재생
    } catch (e) {
      print('비디오 로드 실패: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _videoListener() {
    // if (_controller.value.isPlaying) {
    //   widget.onPlayStart?.call(); // 재생 시작
    // }

    if (_controller.value.position >= _controller.value.duration) {
      widget.onPlayEnd?.call(); // 재생 끝
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double mWidth = constraints.maxWidth;
      final double mHeight = constraints.maxHeight;

      if (_isLoading) {
        return const Center(child: SplashScreen()); // 로딩 화면
      }

      if (_hasError || !_controller.value.isInitialized) {
        return _buildErrorWidget();
      }

      return Container(
        width: mWidth,
        height: mHeight,
        color: Colors.black,
        child: Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
      );
    });
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          SizedBox(height: 24),
          Text(
            '동영상 재생에 실패했습니다.\n$_errorMsg',
            style: BODY_TEXT_STYLE,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
