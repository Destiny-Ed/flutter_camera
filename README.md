# Flutter Camera

[![pub package](https://img.shields.io/pub/v/camera.svg)](https://pub.dev/packages/flutter_camera)

A Flutter plugin for iOS and Android allowing access to the device cameras and recording of videos.

*Note*: This plugin is still under development, and some APIs might not be available yet. We are working on a refactor which can be followed here: [issue](https://github.com/flutter/flutter/issues/31225)

This package fully depends on flutter [camera](https://pub.dev/packages/camera) plugin to provide access to camera.

It only supports Android and IOS for now

## Features

* Display live camera preview in a widget.
* Snapshots can be captured and path is returned.
* Device flash light support.
* Record video from camera.
* Add access to the image stream from Dart.
* Live camera flip ( switch between rear & front camera with a click ).
* Only 3 lines of code

## Installation

First, add `flutter_camera` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

### iOS

The camera plugin functionality works on iOS 10.0 or higher. If compiling for any version lower than 10.0,
make sure to programmatically check the version of iOS running on the device before using any camera plugin features.
The [device_info_plus](https://pub.dev/packages/device_info_plus) plugin, for example, can be used to check the iOS version.

Add two rows to the `ios/Runner/Info.plist`:

* one with the key `Privacy - Camera Usage Description` and a usage description.
* and one with the key `Privacy - Microphone Usage Description` and a usage description.

Or in text format add the key:

```xml
<key>NSCameraUsageDescription</key>
<string>Can I use the camera please?</string>
<key>NSMicrophoneUsageDescription</key>
<string>Can I use the mic please?</string>
```

### Android

Change the minimum Android sdk version to 21 (or higher) in your `android/app/build.gradle` file.

```
minSdkVersion 21
```
### Example

Here is a small example flutter app displaying a full screen camera preview with video recording.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_camera/flutter_camera.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  Widget build(BuildContext context) {
    return FlutterCamera(
      color: Colors.amber,
      onImageCaptured: (value) {
        final path = value.path;
        print("::::::::::::::::::::::::::::::::: $path");
      },
      onVideoRecorded: (value) {
        final path = value.path;
        print('::::::::::::::::::::::::;; dkdkkd $path');
      },
    );
    // return Container();
  }
}


```