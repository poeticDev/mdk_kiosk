import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

late final Logger logger;

// logger.t("Trace log");
//
// logger.d("Debug log");
//
// logger.i("Info log");
//
// logger.w("Warning log");
//
// logger.e("Error log", error: 'Test Error');
//
// logger.f("What a fatal log", error: error, stackTrace: stackTrace);

class CustomLogger {
  static late Logger _logger;
  static File? _logFile;

  static get logger => _logger;

  static Future<Logger> initLogging() async {
    final dir = await getApplicationDocumentsDirectory();
    _logFile = File('${dir.path}/wall_hub_logs.txt');

    _logger = Logger(
      filter: ProductionFilter(),
      level: Level.trace,
      printer: PrettyPrinter(
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ), // 예쁘게 포맷된 콘솔 출력
      output: MultiOutput([
        ConsoleOutput(),
        FileOutput(file: _logFile!), // 파일로 로그 저장
      ]),
    );

    return _logger;
  }
}

/// 파일 출력 커스텀 Output
// class FileOutput extends LogOutput {
//   final File file;
//
//   FileOutput(this.file);
//
//   @override
//   void output(OutputEvent event) {
//     final logMessage = event.lines.join('\n') + '\n';
//     file.writeAsStringSync(logMessage, mode: FileMode.append);
//   }
// }
