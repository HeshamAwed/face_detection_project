import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../utils/camera_view.dart';
import '../utils/coordinates_translator.dart';
import 'face_detector_painter.dart';

class FaceDetectorView extends StatefulWidget {
  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  final ValueNotifier<double> xProgressBar = ValueNotifier(0.0),
      yProgressBar = ValueNotifier(0.0),
      zProgressBar = ValueNotifier(0.0);

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Face Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      xProgressBar: xProgressBar,
      yProgressBar: yProgressBar,
      zProgressBar: zProgressBar,
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
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      if (faces.isNotEmpty) {
        log("face.headEulerAngleZ ${faces[0].headEulerAngleZ}", name: "dfsdf");
        log("face.headEulerAngleX ${faces[0].headEulerAngleX}");
        log("face.headEulerAngleY ${faces[0].headEulerAngleY}");

        xProgressBar.value = translateMetricsToProgress(
            validateMetrics(
              faces[0]?.headEulerAngleX?.abs() ?? DimConstants().maxX,
            ),
            dimType: DimType.x);
        yProgressBar.value = translateMetricsToProgress(
            validateMetrics(
                faces[0]?.headEulerAngleY?.abs() ?? DimConstants().maxY,
                dimType: DimType.y),
            dimType: DimType.y);

        zProgressBar.value = translateMetricsToProgress(
            validateMetrics(
                faces[0]?.headEulerAngleZ?.abs() ?? DimConstants().maxZ,
                dimType: DimType.z),
            dimType: DimType.z);
      } else {
        xProgressBar.value = translateMetricsToProgress(
            validateMetrics(DimConstants().maxX, dimType: DimType.x),
            dimType: DimType.x);
        yProgressBar.value = translateMetricsToProgress(
            validateMetrics(DimConstants().maxY, dimType: DimType.y),
            dimType: DimType.y);
        zProgressBar.value = translateMetricsToProgress(
            validateMetrics(DimConstants().maxZ, dimType: DimType.z),
            dimType: DimType.z);
      }
      // if (faces.isNotEmpty) {
      //   final headEulerAngleY = faces[0].headEulerAngleY ?? 0.0;
      //   final headEulerAngleX = faces[0].headEulerAngleX ?? 0.0;
      //   final headEulerAngleZ = faces[0].headEulerAngleZ ?? 0.0;
      //   if (headEulerAngleX >= -5 &&
      //       headEulerAngleX <= 5 &&
      //       headEulerAngleY >= -5 &&
      //       headEulerAngleY <= 5 &&
      //       headEulerAngleZ >= 0 &&
      //       headEulerAngleZ <= 2) {
      //     _customPaint = CustomPaint(painter: painter);
      //   } else {
      //     final painter = FaceDetectorPainter([],
      //         inputImage.inputImageData!.size,
      //         inputImage.inputImageData!.imageRotation);
      //     _customPaint = CustomPaint(painter: painter);
      //   }
      //
      // }
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        print("face.headEulerAngleZ ${face.headEulerAngleZ}");
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
