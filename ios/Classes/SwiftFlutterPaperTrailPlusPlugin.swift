import Flutter
import UIKit
import PaperTrailLumberjack

extension DDLogLevel {
    static func fromString(logLevelString: String) -> DDLogLevel {
        switch logLevelString {
        case "error":
            return DDLogLevel.error
        case "warning":
            return DDLogLevel.warning
        case "info":
            return DDLogLevel.info
        case "debug":
            return DDLogLevel.debug
        default:
            return DDLogLevel.info
        }
    }
}

public class SwiftFlutterPaperTrailPlusPlugin: NSObject, FlutterPlugin {
    private static var programName: String?
    private static let maxRetryAttempts = 3
    private static let retryInterval: TimeInterval = 5 // Retry interval in seconds
    private var isConnectionActive = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_paper_trail_plus", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterPaperTrailPlusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "initLogger" {
            self.setupLoggerAndParseArguments(call, result: result)
        } else if call.method == "setUserId" {
            self.configureUserAndParseArguments(call, result: result)
        } else if call.method == "log" {
            logMessageAndParseArguments(call, result: result)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func configureUserAndParseArguments(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let params = call.arguments as? [String: String],
              let userId = params["userId"],
              let _ = RMPaperTrailLogger.sharedInstance()?.programName else {
            result(FlutterError(code: "InvalidArguments", message: "Missing or invalid arguments", details: nil))
            return
        }

        let paperTrailLogger = RMPaperTrailLogger.sharedInstance()!
        paperTrailLogger.programName = "\(userId)--on--\(SwiftFlutterPaperTrailPlusPlugin.programName ?? "")"
        result("Logger updated")
    }

    private func logMessageAndParseArguments(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let params = call.arguments as? [String: String],
              let message = params["message"],
              let logLevelString = params["logLevel"] else {
            result(FlutterError(code: "InvalidArguments", message: "Missing or invalid arguments", details: nil))
            return
        }

        let logLevel = DDLogLevel.fromString(logLevelString: logLevelString)

        DispatchQueue.global(qos: .background).async {
            var attempts = 0
            var success = false

            while attempts < SwiftFlutterPaperTrailPlusPlugin.maxRetryAttempts && !success {
                do {
                    if !self.isConnectionActive {
                        self.reconnectLogger()
                    }

                    switch logLevel {
                    case .debug:
                        DDLogDebug(message)
                    case .info:
                        DDLogInfo(message)
                    case .error:
                        DDLogError(message)
                    default:
                        DDLogError(message)
                    }
                    success = true
                } catch {
                    attempts += 1
                    if attempts == SwiftFlutterPaperTrailPlusPlugin.maxRetryAttempts {
                        DispatchQueue.main.async {
                            result(FlutterError(code: "LogDeliveryFailed", message: "Failed to deliver log after \(SwiftFlutterPaperTrailPlusPlugin.maxRetryAttempts) attempts", details: nil))
                        }
                        return
                    }
                }
            }
            DispatchQueue.main.async {
                result("Log delivered")
            }
        }
    }

    private func setupLoggerAndParseArguments(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let params = call.arguments as? [String: String],
              let hostName = params["hostName"],
              let programNameParam = params["programName"],
              let machineName = params["machineName"],
              let portString = params["port"],
              let port = UInt(portString) else {
            result(FlutterError(code: "InvalidArguments", message: "Missing or invalid arguments", details: nil))
            return
        }
        let paperTrailLogger = RMPaperTrailLogger.sharedInstance()!
        paperTrailLogger.host = hostName
        paperTrailLogger.port = port
        SwiftFlutterPaperTrailPlusPlugin.programName = programNameParam
        paperTrailLogger.programName = SwiftFlutterPaperTrailPlusPlugin.programName
        paperTrailLogger.machineName = machineName
        DDLog.add(paperTrailLogger)
        self.isConnectionActive = true
        result("Logger initialized")
    }

    private func reconnectLogger() {
        guard let paperTrailLogger = RMPaperTrailLogger.sharedInstance() else { return }

        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + SwiftFlutterPaperTrailPlusPlugin.retryInterval) {
            paperTrailLogger.host = paperTrailLogger.host
            paperTrailLogger.port = paperTrailLogger.port 
            paperTrailLogger.programName = SwiftFlutterPaperTrailPlusPlugin.programName
            paperTrailLogger.machineName = paperTrailLogger.machineName
            DDLog.add(paperTrailLogger)
            self.isConnectionActive = true
        }
    }
}
