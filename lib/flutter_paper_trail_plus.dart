import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPaperTrailPlus {
  static const MethodChannel _channel =
      const MethodChannel('flutter_paper_trail_plus');

  static Future<String> initLogger({
    required String hostName,
    required int port,
    required String programName,
    required String machineName,
  }) async {
    return await _channel.invokeMethod('initLogger', {
      "hostName": hostName,
      "machineName": machineName,
      "programName": programName,
      "port": port.toString(),
    });
  }

  static Future<String> setUserId(String userId) async {
    return await _channel.invokeMethod('setUserId', {"userId": userId});
  }

  static Future<String> logError(String message) async {
    return _log(message, "error");
  }

  static Future<String> logWarning(String message) async {
    return _log(message, "warning");
  }

  static Future<String> logInfo(String message) async {
    return _log(message, "info");
  }

  static Future<String> logDebug(String message) async {
    return _log(message, "debug");
  }

  static Future<String> _log(String message, String logLevel) async {
    return await _channel
        .invokeMethod('log', {"message": message, "logLevel": logLevel});
  }
}
