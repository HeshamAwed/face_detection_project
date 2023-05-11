import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:google_mlkit_commons/google_mlkit_commons.dart';

double translateX(
    double x, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x *
          size.width /
          (Platform.isIOS ? absoluteImageSize.width : absoluteImageSize.height);
    case InputImageRotation.rotation270deg:
      return size.width -
          x *
              size.width /
              (Platform.isIOS
                  ? absoluteImageSize.width
                  : absoluteImageSize.height);
    default:
      return x * size.width / absoluteImageSize.width;
  }
}

double translateY(
    double y, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y *
          size.height /
          (Platform.isIOS ? absoluteImageSize.height : absoluteImageSize.width);
    default:
      return y * size.height / absoluteImageSize.height;
  }
}

double validateMetrics(double value, {DimType dimType = DimType.x}) {
  if (dimType == DimType.x) {
    if (value > DimConstants().maxX) {
      value = DimConstants().maxX;
    }
    value = DimConstants().maxX - value;
  } else if (dimType == DimType.y) {
    if (value > DimConstants().maxY) {
      value = DimConstants().maxY;
    }
    value = DimConstants().maxY - value;
  } else {
    if (value > DimConstants().maxZ) {
      value = DimConstants().maxZ;
    }
    value = DimConstants().maxZ - value;
  }

  return value;
}

double translateMetricsToProgress(double value, {DimType dimType = DimType.x}) {
  double min, max;
  if (dimType == DimType.x) {
    // x

    min = DimConstants().minX;
    max = DimConstants().maxX;
  } else if (dimType == DimType.y) {
    min = DimConstants().minY;
    max = DimConstants().maxY;
  } else {
    min = DimConstants().minZ;
    max = DimConstants().maxZ;
  }
  value = (value - min) / (max - min);

  log("Translated value $dimType : $value ");
  return value;
}

enum DimType { x, y, z }

class DimConstants {
  /// Constrains
  double minX = 0; // centerlized range value 0-20
  double maxX = 60;
  double minY = 0;
  double maxY = 60;
  double minZ = 0; // centerlized range value 0-3
  double maxZ = 20;

  ///
}
