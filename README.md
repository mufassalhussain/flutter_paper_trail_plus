# flutter_paper_trail_plus

Elevate your app development experience with Flutter Paper Trail Plus. Seamlessly integrate advanced logging and real-time monitoring into your Flutter project. Swiftly identify and prioritize issues with enhanced logging, customizable outputs, and error notifications. Utilize the power of data insights and security while simplifying the debugging process. Choose Flutter PaperTrail Plus for efficient, streamlined, and proactive app maintenance.

# Usage


Setup:

```dart
import 'package:flutter_paper_trail_plus/flutter_paper_trail_plus.dart';

FlutterPaperTrailPlus.initLogger(
        hostName: "secret.papertrailapp.com",
        programName: "flutter-test-app",
        port: 9999,
        machineName: "Iphone SE (3rd Gen)");
    //for machine name use Flutter DeviceInfoPlugin

```

Calling:

```dart
FlutterPaperTrailPlus.logError("My message");
```

Extra setup (when a user is logged in):

```dart
FlutterPaperTrailPlus.setUserId("mufassal786");
```


## MIT License
```
Copyright (c) 2023 Mufassal Hussain

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```
