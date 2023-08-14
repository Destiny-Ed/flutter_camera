// ignore_for_file: must_be_immutable

library flutter_camera;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterCamera extends StatefulWidget {
  final Color? color;
  final Color? iconColor;
  Function(XFile)? onImageCaptured;
  Function(XFile)? onVideoRecorded;
  final Duration? animationDuration;
  FlutterCamera(
      {Key? key,
      this.onImageCaptured,
      this.animationDuration = const Duration(seconds: 1),
      this.onVideoRecorded,
      this.iconColor = Colors.white,
      required this.color})
      : super(key: key);
  @override
  _FlutterCameraState createState() => _FlutterCameraState();
}

class _FlutterCameraState extends State<FlutterCamera> {
  List<CameraDescription>? cameras;

  CameraController? controller;

  bool volumeControl(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
        captureImage();
      }
      if (event.logicalKey == LogicalKeyboardKey.audioVolumeDown) {
        captureImage();
      }
    }
    return true;
  }

  @override
  void initState() {
    HardwareKeyboard.instance.addHandler(volumeControl);
    super.initState();
    initCamera().then((_) {
      ///initialize camera and choose the back camera as the initial camera in use.
      setCamera(0);
    });
  }

  /// calls [availableCameras()] which returns a list<CameraDescription>.
  Future initCamera() async {
    cameras = await availableCameras();
    setState(() {});
  }

  /// chooses the camera to use, where the front camera has index = 1, and the rear camera has index = 0
  void setCamera(int index) {
    controller = CameraController(cameras![index], ResolutionPreset.max);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  /// removes the camera controller from memory after use.
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  bool _isTouchOn = false;
  bool _isFrontCamera = false;

  ///Switch
  bool _cameraView = true;

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      /// Performs the actual switch with an animation when _cameraView is toggled
      body: AnimatedSwitcher(
        duration: widget.animationDuration!,
        child: _cameraView == true ? cameraView() : videoView(),
      ),
    );
  }

  /// Take a picture
  /// The picture is returned as an XFile.

  void captureImage() {
    controller!.takePicture().then((value) {
      Navigator.pop(context);
      widget.onImageCaptured!(value);
    });
  }

  /// Start a video recording.
  /// The video is returned as an XFile after recording is stopped.
  void setVideo() {
    controller!.startVideoRecording();
  }

  ///Camera View Layout
  Widget cameraView() {
    return Stack(
      key: const ValueKey(0),
      children: [
        /// Ensures the camera preview covers the screen
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: CameraPreview(
            controller!,
          ),
        ),

        ///Side controls
        Positioned(
            top: 40,
            right: 0,
            child: Column(
              children: [
                closeCameraWidget(),
                cameraSwitcherWidget(),
                flashToggleWidget()
              ],
            )),

        ///Bottom Controls
        Positioned(
          bottom: 0,
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [captureImageButton(), switchToVideoButton()],
            ),
          ),
        )
      ],
    );
  }

  bool _isRecording = false;
  bool _isPaused = false;

  ///Video View
  Widget videoView() {
    return Stack(
      key: const ValueKey(1),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: CameraPreview(
            controller!,
          ),
        ),

        ///Side controlls
        Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 40),
              width: MediaQuery.of(context).size.width,
              color: widget.color,
              height: 100,
              child: Row(
                children: [
                  cameraSwitcherWidget(),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        _isRecording == false
                            ? 'Video recording is off'
                            : 'Video recording is on',
                        style: TextStyle(color: widget.iconColor, fontSize: 22),
                      ),
                    ),
                  ),
                  flashToggleWidget()
                ],
              ),
            )),

        ///Bottom Controls
        Positioned(
          bottom: 0,
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                switchToPictureButton(),
                const SizedBox(
                  width: 0.1,
                ),
                stopAndStartVideoButton(),
                const SizedBox(
                  width: 15,
                ),
                pauseAndResumeVideoButton(),
              ],
            ),
          ),
        )
      ],
    );
  }

  /// button to switch from video mode to picture mode
  IconButton switchToPictureButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          ///Show camera view
          _cameraView = true;
        });
      },
      icon: Icon(
        Icons.camera_alt,
        color: widget.iconColor,
        size: 30,
      ),
    );
  }

  /// button to stop and start video
  Widget stopAndStartVideoButton() {
    return IconButton(
      onPressed: () {
        //Start and stop video
        if (_isRecording == false) {
          ///Start
          controller!.startVideoRecording();
          _isRecording = true;
        } else {
          ///Stop video recording
          controller!.stopVideoRecording().then((value) {
            Navigator.pop(context);
            widget.onVideoRecorded!(value);
          });
          _isRecording = false;
        }
        setState(() {});
      },
      icon: Icon(
        Icons.camera,
        color: widget.iconColor,
        size: 50,
      ),
    );
  }

  ///button to pause and resume video
  IconButton pauseAndResumeVideoButton() {
    return IconButton(
      onPressed: () {
        //pause and resume video
        if (_isRecording == true) {
          //pause
          if (_isPaused == true) {
            ///resume
            controller!.resumeVideoRecording();
            _isPaused = false;
          } else {
            ///resume
            controller!.pauseVideoRecording();
            _isPaused = true;
          }
        }
        setState(() {});
      },
      icon: Icon(
        _isPaused == false ? Icons.pause_circle : Icons.play_circle,
        color: widget.iconColor,
        size: 30,
      ),
    );
  }

  /// button to close the camera view
  Widget closeCameraWidget() {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(
        Icons.clear,
        color: widget.iconColor,
        size: 30,
      ),
    );
  }

  /// button to toggle the flash
  Widget flashToggleWidget() {
    return IconButton(
      onPressed: () {
        if (_isTouchOn == false) {
          controller!.setFlashMode(FlashMode.torch);
          _isTouchOn = true;
        } else {
          controller!.setFlashMode(FlashMode.off);
          _isTouchOn = false;
        }
        setState(() {});
      },
      icon: Icon(_isTouchOn == false ? Icons.flash_on : Icons.flash_off,
          color: widget.iconColor, size: 30),
    );
  }

  /// button to switch between front and rear cameras
  Widget cameraSwitcherWidget() {
    return IconButton(
      onPressed: () {
        if (_isFrontCamera == false) {
          setCamera(1);
          _isFrontCamera = true;
        } else {
          setCamera(0);
          _isFrontCamera = false;
        }
        setState(() {});
      },
      icon:
          Icon(Icons.change_circle_outlined, color: widget.iconColor, size: 30),
    );
  }

  /// Button to switch from picture mode to video mode
  Widget switchToVideoButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _cameraView = false;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 10, right: 10),
        child: CircleAvatar(
          backgroundColor: widget.color,
          child: const Icon(Icons.video_call),
          radius: 13,
        ),
      ),
    );
  }

  /// Button to capture image
  Widget captureImageButton() {
    return IconButton(
      onPressed: () {
        captureImage();
      },
      icon: Icon(
        Icons.camera,
        color: widget.iconColor,
        size: 50,
      ),
    );
  }
}
