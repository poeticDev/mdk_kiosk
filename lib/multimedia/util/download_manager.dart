import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadManager {
  /// 싱글턴 패턴
  static final DownloadManager _instance = DownloadManager._internal();

  factory DownloadManager() => _instance;

  DownloadManager._internal();

  final Dio _dio = Dio();

  /// ✅ 네트워크 연결 여부 확인
  Future<bool> isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      print('❌ 네트워크 연결 실패: $e');
      return false;
    }
  }

  /// ✅ 구글 드라이브 URL → 다운로드 URL 변환
  String convertToDownloadUrl(String gDriveUrl) {
    final uri = Uri.parse(gDriveUrl);
    final segments = uri.pathSegments;

    if (segments.contains('file')) {
      final fileIndex = segments.indexOf('file');
      if (fileIndex + 2 < segments.length) {
        final fileId = segments[fileIndex + 2];
        return 'https://drive.google.com/uc?export=download&id=$fileId';
      }
    }
    throw Exception('잘못된 다운로드 URL입니다: $gDriveUrl');
  }

  /// ✅ 이미지 파일 다운로드 (중복 처리 포함)
  Future<File> downloadImage(String imgUrl, String? fileName,
      {bool overwrite = false}) async {
    return await _downloadFile(imgUrl, fileName, overwrite: overwrite);
  }

  /// ✅ 동영상 파일 다운로드 (중복 처리 포함)
  Future<File> downloadVideo(String videoUrl, String? fileName,
      {bool overwrite = false}) async {
    return await _downloadFile(videoUrl, fileName, overwrite: overwrite);
  }

  /// ✅ 파일 다운로드 (기존 파일 체크 & 덮어쓰기 옵션 추가)
  Future<File> _downloadFile(String url, String? fileName,
      {bool overwrite = false}) async {
    final directory = await getApplicationDocumentsDirectory();
    fileName ??= url.split('/').last;

    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    if (await file.exists() && !overwrite) {
      print('📂 기존 파일 재사용: $filePath');
      return file;
    }

    try {
      final response = await _dio.download(url, filePath);
      if (response.statusCode == 200) {
        print('✅ 파일 다운로드 성공: $filePath');
        return file;
      } else {
        throw Exception('파일 다운로드 실패: 상태코드 ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 파일 다운로드 오류: $e');
      rethrow;
    }
  }

  /// ✅ 오래된 파일 정리 (기본 7일 지난 파일 삭제)
  Future<void> clearOldFiles({int days = 7}) async {
    final directory = await getApplicationDocumentsDirectory();
    final now = DateTime.now();

    final files = directory.listSync();
    for (var file in files) {
      if (file is File) {
        final lastModified = await file.lastModified();
        if (now.difference(lastModified).inDays >= days) {
          print('🗑️ 오래된 파일 삭제: ${file.path}');
          await file.delete();
        }
      }
    }
  }
}
