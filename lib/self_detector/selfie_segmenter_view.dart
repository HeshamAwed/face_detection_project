import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

import '../utils/camera_view.dart';
import 'segmentation_painter.dart';

class SelfieSegmenterView extends StatefulWidget {
  @override
  State<SelfieSegmenterView> createState() => _SelfieSegmenterViewState();
}

class _SelfieSegmenterViewState extends State<SelfieSegmenterView> {
  final SelfieSegmenter _segmenter = SelfieSegmenter(
    mode: SegmenterMode.stream,
    enableRawSizeMask: false,
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  final ValueNotifier<double> xProgressBar = ValueNotifier(0.0),
      zProgressBar = ValueNotifier(0.0),
      yPropgressBar = ValueNotifier(0.0);

  @override
  void dispose() async {
    _canProcess = false;
    _segmenter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      xProgressBar: xProgressBar,
      yProgressBar: yPropgressBar,
      zProgressBar: zProgressBar,
      title: 'Selfie Segmenter',
      customPaint: _customPaint,
      text: _text,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      initialDirection: CameraLensDirection.front,
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final mask = await _segmenter.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null &&
        mask != null) {
      // TODO: Fix SegmentationPainter to rescale on top of camera feed.
      final painter = SegmentationPainter(
        mask,
        inputImage.inputImageData!.size,
        inputImage.inputImageData!.imageRotation,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      // TODO: set _customPaint to draw on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
