import 'package:flutter/material.dart';
import 'package:flutter_paper_trail_plus/flutter_paper_trail_plus.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future initPlatformState() async {
    return FlutterPaperTrailPlus.initLogger(
        hostName: "logs.papertrailapp.com",
        programName: "flutter-test-app",
        port: 21358,
        machineName: "Pixel 4");
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        floatingActionButton: new FloatingActionButton(
          onPressed: () async {
            await FlutterPaperTrailPlus.logError(
                "I love logging infos on paper trail");
            await FlutterPaperTrailPlus.logInfo(
                "I love logging infos on paper trail");
            await FlutterPaperTrailPlus.logWarning(
                "I love logging warnings on paper trail");
            await FlutterPaperTrailPlus.logDebug(
                "I love logging debugs on paper trail");
          },
          tooltip: 'Log to papertrail',
          child: const Icon(Icons.add),
        ),
        appBar: new AppBar(
          title: const Text('Papertrail logging example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Press the + button to test logging to Papertrail'),
              TextButton(
                child: Text('Identify User'),
                onPressed: () {
                  FlutterPaperTrailPlus.setUserId("JohnDeer391");
                },
              ),
              Text('Press the + button again after identifying the user'),
            ],
          ),
        ),
      ),
    );
  }
}
