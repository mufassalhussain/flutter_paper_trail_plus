package com.mufassal.flutterpapertrailplus

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import me.jagdeep.papertrail.timber.PapertrailTree
import timber.log.Timber


class FlutterPaperTrailPlusPlugin : MethodCallHandler, FlutterPlugin {

    private var channel: MethodChannel? = null
    private var treeBuilder: PapertrailTree.Builder? = null
    private var tree: PapertrailTree? = null
    private var programName: String? = null

    companion object {
        @JvmStatic
        @SuppressWarnings("deprecation")
        fun registerWith(registrar: Registrar) {
            val plugin = FlutterPaperTrailPlusPlugin()
            plugin.onAttachedToEngine(registrar.messenger())
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.onAttachedToEngine(binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    private fun onAttachedToEngine(messenger: BinaryMessenger) {
        channel = MethodChannel(
            messenger,
            "flutter_paper_trail_plus")
            .apply {
                setMethodCallHandler(this@FlutterPaperTrailPlusPlugin)
            }
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
        if (call.arguments !is Map<*, *>) {
            result.error("missing arguments", "", null)
            return
        }

        val arguments = call.arguments as Map<*, *>?

        if (arguments == null) {
            result.error("missing arguments", "", null)
            return
        }

        val userId = arguments["userId"] as String?
        if (userId == null) {
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
        if (call.arguments !is Map<*, *>) {
            result.error("missing arguments", "", null)
            return
        }

        val arguments = call.arguments as Map<*, *>?

        if (arguments == null) {
            result.error("missing arguments", "", null)
            return
        }

        val message = arguments["message"] as String?
        if (message == null) {
            result.error("missing argument message", "", null)
            return
        }

        val logLevel = arguments["logLevel"] as String?
        if (logLevel == null) {
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
        if (call.arguments !is Map<*, *>) {
            result.error("missing arguments", "", null)
            return
        }

        val arguments = call.arguments as Map<*, *>?

        if (arguments == null) {
            result.error("missing arguments", "", null)
            return
        }

        val hostName = arguments["hostName"] as String?
        if (hostName == null) {
            result.error("missing arguments", "", null)
            return
        }

        val machineName = arguments["machineName"] as String?
        if (machineName == null) {
            result.error("missing argument machineName", "", null)
            return
        }

        val portString = arguments["port"] as String?
        if (portString == null) {
            result.error("missing argument port", "", null)
            return
        }

        val port =
            try {
                portString.toInt()
            } catch (e: Exception) {
                result.error("port is not a number", "", null)
                return
            }

        programName = arguments["programName"] as String?
        if (programName == null) {
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

