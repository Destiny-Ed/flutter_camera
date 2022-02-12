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
