import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/data/model/media_item.dart';
import 'package:mdk_kiosk/common/view/splash_screen.dart';
import 'package:mdk_kiosk/multimedia/util/download_manager.dart';

String imageUrlFromGDrive =
    'https://drive.google.com/file/d/1YKPA7ezjTsN1jIc79Zs0NM7Me-akXWVA/view?usp=sharing';

String imageUrlFromWeb =
    'https://www.gnu.ac.kr/upload/main/na/bbs_5171/ntt_2264748/img_44ab9c58-a741-4b93-bd7b-ddeee17c0ac11736728581323.png';

class ItemImage extends StatefulWidget {
  final String downloadUrl;
  final String? fileName;
  final BoxFit? fit;
  final VoidCallback? onLoadingStart;
  final VoidCallback? onLoadingEnd;

  const ItemImage({
    super.key,
    required this.downloadUrl,
    this.fit = BoxFit.cover,
    this.fileName,
    this.onLoadingStart,
    this.onLoadingEnd,
  });

  /// 이미지가 구글 드라이브에 있을 때
  factory ItemImage.fromGDrive({
    required String url,
    String? fileName,
    BoxFit? fit = BoxFit.cover,
    VoidCallback? onLoadingStart,
    VoidCallback? onLoadingEnd,
  }) {
    final convertedUrl = DownloadManager().convertToDownloadUrl(url);

    return ItemImage(
      downloadUrl: convertedUrl,
      fileName: fileName,
      fit: fit,
      onLoadingStart: onLoadingStart,
      onLoadingEnd: onLoadingEnd,
    );
  }

  /// 앱 db로부터 미디어데이터 불러와 생성하기
  factory ItemImage.fromMediaData(
    MediaItemData mediaItemData, {
    VoidCallback? onLoadingStart,
    VoidCallback? onLoadingEnd,
  }) {
    if (mediaItemData.from == MediaFrom.gDrive) {
      return ItemImage.fromGDrive(
        url: mediaItemData.url,
        fileName:
            mediaItemData.fileName ?? 'imageFromGDrive${mediaItemData.id}',
        fit: mediaItemData.fit,
        onLoadingStart: onLoadingStart,
        onLoadingEnd: onLoadingEnd,
      );
    } else {
      return ItemImage(
        downloadUrl: mediaItemData.url,
        fileName: mediaItemData.fileName ?? 'imageFromWeb${mediaItemData.id}',
        fit: mediaItemData.fit,
        onLoadingStart: onLoadingStart,
        onLoadingEnd: onLoadingEnd,
      );
    }
  }

  @override
  State<ItemImage> createState() => _ItemImageState();
}

class _ItemImageState extends State<ItemImage> {
  late final File file;
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

    _initializeImage();
  }

  Future<void> _initializeImage() async {
    try {
      if (widget.onLoadingStart != null) {
        widget.onLoadingStart!();
      }

      final DownloadManager downloadManager = DownloadManager();

      file = await downloadManager.downloadImage(
          widget.downloadUrl, widget.fileName);

      if (widget.onLoadingEnd != null) {
        widget.onLoadingEnd!();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('이미지 로드 실패: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double mWidth = constraints.maxWidth;
      final double mHeight = constraints.maxHeight;

      if (_isLoading) {
        return Center(child: SplashScreen()); // 로딩 화면
      }

      if (_hasError) {
        return _buildErrorWidget();
      }

      return Image.file(
        file,
        width: mWidth,
        height: mHeight,
        fit: widget.fit,
      );
    });
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 24),
          Text(
            '사진 불러오기에 실패했습니다.\n$_errorMsg',
            style: BODY_TEXT_STYLE,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
