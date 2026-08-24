import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;

const _width = 1080;
const _height = 1920;

const _sourceWidth = 720;
const _sourceHeight = 1280;
const _uniformScale = 1.5;

Never _usage() =>
    throw ArgumentError(
      'Kullanım: dart run tools/compare_kelime_avi_master_art.dart '
      '<source-photo.jpg> <android16.png> <output-dir>',
    );

void main(List<String> args) {
  if (args.length != 3) _usage();
  final referencePath = args[0];
  final actualPath = args[1];
  final outputDirectory = Directory(args[2])..createSync(recursive: true);

  final sourceReference = _decode(referencePath);
  final actual = _decode(actualPath);
  if (sourceReference.width != _sourceWidth ||
      sourceReference.height != _sourceHeight) {
    throw StateError(
      'MASTER ART 720x1280 olmalı, alınan: '
      '${sourceReference.width}x${sourceReference.height}',
    );
  }
  if (actual.width != _width || actual.height != _height) {
    throw StateError(
      'Android 16 kanıtı 1080x1920 olmalı; crop/zoom/normalize yasak. '
      'Alınan: ${actual.width}x${actual.height}',
    );
  }
  final reference = img.copyResize(
    sourceReference,
    width: _width,
    height: _height,
    interpolation: img.Interpolation.nearest,
  );

  File(
    '${outputDirectory.path}/REFERENCE.png',
  ).writeAsBytesSync(img.encodePng(reference));
  File(
    '${outputDirectory.path}/ANDROID16.png',
  ).writeAsBytesSync(img.encodePng(actual));

  final sideBySide = img.Image(width: _width * 2, height: _height);
  img.compositeImage(sideBySide, reference, dstX: 0, dstY: 0);
  img.compositeImage(sideBySide, actual, dstX: _width, dstY: 0);
  File(
    '${outputDirectory.path}/SIDE_BY_SIDE.png',
  ).writeAsBytesSync(img.encodePng(sideBySide));

  final diff = img.Image(width: _width, height: _height);
  var absoluteError = 0.0;
  var squaredError = 0.0;
  var exactPixels = 0;
  var withinOnePixels = 0;
  var withinTwoPixels = 0;
  var maximumChannelError = 0;
  for (var y = 0; y < _height; y++) {
    for (var x = 0; x < _width; x++) {
      final a = reference.getPixel(x, y);
      final b = actual.getPixel(x, y);
      final red = (a.r.toInt() - b.r.toInt()).abs();
      final green = (a.g.toInt() - b.g.toInt()).abs();
      final blue = (a.b.toInt() - b.b.toInt()).abs();
      absoluteError += red + green + blue;
      squaredError += red * red + green * green + blue * blue;
      final pixelMaximum = [red, green, blue].reduce((a, b) => a > b ? a : b);
      if (pixelMaximum == 0) exactPixels++;
      if (pixelMaximum <= 1) withinOnePixels++;
      if (pixelMaximum <= 2) withinTwoPixels++;
      if (pixelMaximum > maximumChannelError) {
        maximumChannelError = pixelMaximum;
      }
      diff.setPixelRgba(
        x,
        y,
        (red * 4).clamp(0, 255),
        (green * 4).clamp(0, 255),
        (blue * 4).clamp(0, 255),
        255,
      );
    }
  }
  File(
    '${outputDirectory.path}/DIFF.png',
  ).writeAsBytesSync(img.encodePng(diff));

  final metrics = <String, Object?>{
    'comparison_note':
        'Only the 1080x1920 app-owned scene is compared. The proof uses one '
        'untouched 720x1280 JPEG with a uniform 1.5 transform.',
    'source_sha256':
        sha256.convert(File(referencePath).readAsBytesSync()).toString(),
    'source_dimensions': <String, int>{
      'width': sourceReference.width,
      'height': sourceReference.height,
    },
    'actual_dimensions': <String, int>{
      'width': actual.width,
      'height': actual.height,
    },
    'canonical_dimensions': <String, int>{'width': _width, 'height': _height},
    'uniform_scale': _uniformScale,
    'source_aspect_ratio': sourceReference.width / sourceReference.height,
    'actual_aspect_ratio': actual.width / actual.height,
    'scene_rect': <String, int>{
      'left': 0,
      'top': 0,
      'right': _width,
      'bottom': _height,
    },
    'masked_android_pixels': 0,
    'compared_pixels': _width * _height,
    'mean_absolute_rgb_error': absoluteError / (_width * _height * 3 * 255),
    'root_mean_square_rgb_error':
        math.sqrt(squaredError / (_width * _height * 3)) / 255,
    'maximum_channel_error': maximumChannelError,
    'exact_pixel_ratio': exactPixels / (_width * _height),
    'within_one_channel_value_ratio': withinOnePixels / (_width * _height),
    'within_two_channel_values_ratio': withinTwoPixels / (_width * _height),
  };
  File(
    '${outputDirectory.path}/pixel_geometry_metrics.json',
  ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(metrics));
}

img.Image _decode(String path) {
  final decoded = img.decodeImage(File(path).readAsBytesSync());
  if (decoded == null) throw StateError('Görsel decode edilemedi: $path');
  return decoded;
}
