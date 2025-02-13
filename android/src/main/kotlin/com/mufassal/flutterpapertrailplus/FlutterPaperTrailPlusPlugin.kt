package com.mufassal.flutterpapertrailplus

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import timber.log.Timber
import me.jagdeep.papertrail.timber.PapertrailTree

class FlutterPaperTrailPlusPlugin : MethodCallHandler, FlutterPlugin {

    private lateinit var channel: MethodChannel
    private var treeBuilder: PapertrailTree.Builder? = null
    private var tree: PapertrailTree? = null
    private var programName: String? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = binding.binaryMessenger
        channel = MethodChannel(messenger, "flutter_paper_trail_plus")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initLogger" -> initLoggerAndParseArguments(call, result)
            "setUserId" -> configureUserAndParseArguments(call, result)
            "log" -> logAndParseArguments(call, result)
            else -> result.notImplemented()
        }
    }

    private fun configureUserAndParseArguments(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<*, *> ?: run {
            result.error("missing arguments", "", null)
            return
        }

        val userId = arguments["userId"] as? String ?: run {
            result.error("missing argument userId", "", null)
            return
        }

        if (tree == null || programName == null || treeBuilder == null) {
            result.error("Cannot call configure user before init logger", "", null)
            return
        }
        treeBuilder?.program("$userId--on--$programName")

        Timber.uproot(tree!!)
        tree = treeBuilder!!.build()
        Timber.plant(tree!!)
        result.success("Logger updated")
    }

    private fun logAndParseArguments(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<*, *> ?: run {
            result.error("missing arguments", "", null)
            return
        }

        val message = arguments["message"] as? String ?: run {
            result.error("missing argument message", "", null)
            return
        }

        val logLevel = arguments["logLevel"] as? String ?: run {
            result.error("missing argument logLevel", "", null)
            return
        }

        when (logLevel) {
            "error" -> Timber.e(message)
            "warning" -> Timber.w(message)
            "info" -> Timber.i(message)
            "debug" -> Timber.d(message)
            else -> Timber.i(message)
        }

        result.success("logged")
    }

    private fun initLoggerAndParseArguments(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<*, *> ?: run {
            result.error("missing arguments", "", null)
            return
        }

        val hostName = arguments["hostName"] as? String ?: run {
            result.error("missing arguments", "", null)
            return
        }

        val machineName = arguments["machineName"] as? String ?: run {
            result.error("missing argument machineName", "", null)
            return
        }

        val portString = arguments["port"] as? String ?: run {
            result.error("missing argument port", "", null)
            return
        }

        val port = portString.toIntOrNull() ?: run {
            result.error("port is not a number", "", null)
            return
        }

        programName = arguments["programName"] as? String ?: run {
            result.error("missing argument programName", "", null)
            return
        }

        val safeMachineName = cleanString(machineName)

        if (tree != null) {
            Timber.uproot(tree!!)
        }

        treeBuilder = PapertrailTree.Builder()
            .system(safeMachineName)
            .program(programName!!)
            .logger(programName!!)
            .host(hostName)
            .port(port)

        tree = treeBuilder!!.build()
        Timber.plant(tree!!)
        result.success("Logger initialized")
    }

    private fun cleanString(stringToClean: String): String {
        val re = Regex("[^A-Za-z0-9 ]")
        return re.replace(stringToClean, "")
    }
}
