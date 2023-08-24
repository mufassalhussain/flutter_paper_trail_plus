import 'dart:async';

import 'package:flutter/services.dart';

/// A Flutter plugin for integrating with PaperTrail log service.
class FlutterPaperTrailPlus {
  static const MethodChannel _channel =
      const MethodChannel('flutter_paper_trail_plus');

  /// Initializes the logger for sending logs to PaperTrail.
  ///
  /// This method must be called before using any logging functions.
  ///
  /// - [hostName]: The hostname of the PaperTrail server.
  /// - [port]: The port number to connect to on the PaperTrail server.
  /// - [programName]: The name of the program or application.
  /// - [machineName]: The name of the machine or device.
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

  /// Sets the user ID for the logs.
  ///
  /// - [userId]: The user ID to associate with the logs.
  static Future<String> setUserId(String userId) async {
    return await _channel.invokeMethod('setUserId', {"userId": userId});
  }

  /// Logs an error message to PaperTrail.
  ///
  /// - [message]: The error message to log.
  static Future<String> logError(String message) async {
    return _log(message, "error");
  }

  /// Logs a warning message to PaperTrail.
  ///
  /// - [message]: The warning message to log.
  static Future<String> logWarning(String message) async {
    return _log(message, "warning");
  }

  /// Logs an informational message to PaperTrail.
  ///
  /// - [message]: The information message to log.
  static Future<String> logInfo(String message) async {
    return _log(message, "info");
  }

  /// Logs a debug message to PaperTrail.
  ///
  /// - [message]: The debug message to log.
  static Future<String> logDebug(String message) async {
    return _log(message, "debug");
  }

  /// Internal method to log a message with a specific log level.
  ///
  /// - [message]: The message to log.
  /// - [logLevel]: The log level associated with the message.
  static Future<String> _log(String message, String logLevel) async {
    return await _channel
        .invokeMethod('log', {"message": message, "logLevel": logLevel});
  }
}
