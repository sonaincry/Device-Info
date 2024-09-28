import 'dart:async';
import 'dart:ui' as ui;
import 'package:device_info_application/repository/display_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DisplayDevice extends StatefulWidget {
  final int deviceId;

  const DisplayDevice({Key? key, required this.deviceId}) : super(key: key);

  @override
  _DisplayDeviceState createState() => _DisplayDeviceState();
}

class _DisplayDeviceState extends State<DisplayDevice> {
  final DisplayRepository displayRepository = DisplayRepository();
  List<Image> _currentImages = [];
  List<Image> _newImages = [];
  late Timer _timer;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _fetchImagesAndSetOrientation();
    _startTimer();
    _setFullScreen();
  }

  Future<void> _fetchImagesAndSetOrientation() async {
    try {
      final fetchedImages =
          await displayRepository.getDeviceImage(widget.deviceId);
      if (fetchedImages.isNotEmpty) {
        final image = fetchedImages[0];
        final completer = Completer<ui.Image>();
        image.image
            .resolve(const ImageConfiguration())
            .addListener(ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(info.image);
        }));
        final uiImage = await completer.future;
        final isHorizontal = uiImage.width > uiImage.height;
        _setLandscapeOrientation(isHorizontal);
      }
      setState(() {
        if (_isInitialLoad) {
          _currentImages = fetchedImages;
          _isInitialLoad = false;
        } else {
          _newImages = fetchedImages;
          if (_newImages.isNotEmpty) {
            _currentImages = _newImages;
          }
        }
      });
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 40), (timer) {
      _fetchImagesAndSetOrientation();
    });
  }

  void _setLandscapeOrientation(bool isHorizontal) {
    if (isHorizontal) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _setFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _timer.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        return true;
      },
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: _isInitialLoad
              ? const Center(child: CircularProgressIndicator())
              : _currentImages.isEmpty
                  ? const Center(child: Text('No images found'))
                  : PageView.builder(
                      itemCount: _currentImages.length,
                      itemBuilder: (context, index) {
                        return FittedBox(
                          fit: BoxFit.contain,
                          child: _currentImages[index],
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
