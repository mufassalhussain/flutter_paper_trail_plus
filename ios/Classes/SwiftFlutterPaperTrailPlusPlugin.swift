import Flutter
import UIKit
import PaperTrailLumberjack

extension DDLogLevel {
    static func fromString(logLevelString:String) -> DDLogLevel {
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
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_paper_trail_plus", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterPaperTrailPlusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "initLogger" {
            self.setupLoggerAndParseArguments(call, result: result)
        }else if call.method == "setUserId" {
            self.configureUserAndParseArguments(call, result: result)
        }else if call.method == "log"{
            logMessageAndParseArguments(call, result: result)
        }else{
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func configureUserAndParseArguments(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        guard let params = call.arguments as? Dictionary<String,String> else {
            result(FlutterError(code: "Missing arguments", message: nil, details: nil))
            return
        }
        
        guard let userId = params["userId"] else {
            result(FlutterError(code: "Missing arguments", message: "Missing userId", details: nil))
            return
        }
        guard let _ = RMPaperTrailLogger.sharedInstance()?.programName else{
            result(FlutterError(code: "Cannot call configure user before init logger", message: nil, details: nil))
            return
        }
        let paperTrailLogger = RMPaperTrailLogger.sharedInstance()!
        paperTrailLogger.programName = userId + "--on--" + SwiftFlutterPaperTrailPlusPlugin.programName!
        result("Logger updated")
    }
    
    
    private func logMessageAndParseArguments(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        guard let params = call.arguments as? Dictionary<String,String> else {
            result(FlutterError(code: "Missing arguments", message: "Missing userId", details: nil))
            return
        }
        
        guard let message = params["message"] else {
            result(FlutterError(code: "Missing arguments", message: "Missing message", details: nil))
            return
        }
        guard let logLevelString = params["logLevel"] else {
            result(FlutterError(code: "Missing arguments", message: "Missing logLevel", details: nil))
            return
        }
        let logLevel = DDLogLevel.fromString(logLevelString: logLevelString)
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
        
        result("logged")
    }
    
    
    private func setupLoggerAndParseArguments(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        guard let params = call.arguments as? Dictionary<String,String> else {
            result(FlutterError(code: "Missing arguments", message: nil, details: nil))
            return
        }
        
        guard let hostName = params["hostName"] else {
            result(FlutterError(code: "Missing arguments", message: "Missing hostName", details: nil))
            return
        }
        guard let programNameParam = params["programName"] else {
            result(FlutterError(code: "Missing arguments", message: "Missing programName", details: nil))
            return
        }
        guard let machineName = params["machineName"] else {
            result(FlutterError(code: "Missing arguments", message: "Missing machineName", details: nil))
            return
        }
        
        guard let portString = params["port"] else {
            result(FlutterError(code: "Missing arguments", message: "Missing port", details: nil))
            return
        }
        guard let port = UInt(portString) else{
            result(FlutterError(code: "Missing arguments", message: "port is not int", details: nil))
            return
        }
        
        let paperTrailLogger = RMPaperTrailLogger.sharedInstance()!
        paperTrailLogger.host = hostName
        paperTrailLogger.port = port
        
        SwiftFlutterPaperTrailPlusPlugin.programName = programNameParam
        paperTrailLogger.programName = SwiftFlutterPaperTrailPlusPlugin.programName
        paperTrailLogger.machineName = machineName
        DDLog.add(paperTrailLogger)
        
        result("Logger initialized")
    }
}
