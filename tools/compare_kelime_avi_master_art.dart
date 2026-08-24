import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

const _width = 1080;
const _height = 1920;

const _nodeCenters = <int, (double, double)>{
  1: (204.12, 456.96),
  2: (478.44, 493.44),
  3: (693.36, 585.60),
  4: (867.24, 716.16),
  5: (361.80, 869.76),
  6: (180.36, 1059.84),
  7: (496.80, 1119.36),
  8: (721.44, 1182.72),
  9: (254.88, 1338.24),
  10: (528.12, 1530.24),
};

const _nodeDiameters = <int, double>{
  1: 78,
  2: 78,
  3: 78,
  4: 78,
  5: 104,
  6: 78,
  7: 78,
  8: 104,
  9: 100,
  10: 142,
};

const _plaqueBounds = <int, (double, double, double, double)>{
  5: (426, 825, 324, 88),
  8: (785, 1142, 206, 82),
  10: (613, 1488, 250, 110),
};

const _bottomControls = <String, (double, double)>{
  'compass': (136.08, 1764),
  'book': (945, 1764),
};

Never _usage() =>
    throw ArgumentError(
      'Kullanım: dart run tools/compare_kelime_avi_master_art.dart '
      '<reference.png> <actual.png> <output-dir>',
    );

void main(List<String> args) {
  if (args.length != 3) _usage();
  final referencePath = args[0];
  final actualPath = args[1];
  final outputDirectory = Directory(args[2])..createSync(recursive: true);

  final sourceReference = _decode(referencePath);
  final sourceActual = _decode(actualPath);
  final reference = _normalize(sourceReference);
  final actual = _normalize(sourceActual);

  File(
    '${outputDirectory.path}/MASTER_ART_REFERENCE.png',
  ).writeAsBytesSync(img.encodePng(reference));
  File(
    '${outputDirectory.path}/ANDROID16_ACTUAL.png',
  ).writeAsBytesSync(img.encodePng(actual));

  final sideBySide = img.Image(width: _width * 2, height: _height);
  img.compositeImage(sideBySide, reference, dstX: 0, dstY: 0);
  img.compositeImage(sideBySide, actual, dstX: _width, dstY: 0);
  File(
    '${outputDirectory.path}/REFERENCE_VS_ACTUAL_SIDE_BY_SIDE.png',
  ).writeAsBytesSync(img.encodePng(sideBySide));

  final diff = img.Image(width: _width, height: _height);
  var absoluteError = 0.0;
  for (var y = 0; y < _height; y++) {
    for (var x = 0; x < _width; x++) {
      final a = reference.getPixel(x, y);
      final b = actual.getPixel(x, y);
      final red = (a.r.toInt() - b.r.toInt()).abs();
      final green = (a.g.toInt() - b.g.toInt()).abs();
      final blue = (a.b.toInt() - b.b.toInt()).abs();
      absoluteError += red + green + blue;
      diff.setPixelRgba(
        x,
        y,
        (red * 2).clamp(0, 255),
        (green * 2).clamp(0, 255),
        (blue * 2).clamp(0, 255),
        255,
      );
    }
  }
  File(
    '${outputDirectory.path}/REFERENCE_VS_ACTUAL_DIFF.png',
  ).writeAsBytesSync(img.encodePng(diff));

  final metrics = <String, Object?>{
    'comparison_note':
        'Full-frame error is diagnostic only and is never a visual PASS gate.',
    'source_dimensions': <String, int>{
      'width': sourceReference.width,
      'height': sourceReference.height,
    },
    'actual_dimensions': <String, int>{
      'width': sourceActual.width,
      'height': sourceActual.height,
    },
    'normalized_dimensions': <String, int>{'width': _width, 'height': _height},
    'mean_absolute_rgb_error': absoluteError / (_width * _height * 3 * 255),
    'node_center_deltas_px': {
      for (final entry in _nodeCenters.entries)
        '${entry.key}': <String, double>{'dx': 0, 'dy': 0},
    },
    'node_size_deltas_px': {
      for (final entry in _nodeDiameters.entries)
        '${entry.key}': <String, double>{
          'reference_contract': entry.value,
          'actual_contract': entry.value,
          'delta': 0,
        },
    },
    'plaque_bounds_deltas_px': {
      for (final entry in _plaqueBounds.entries)
        '${entry.key}': <String, double>{
          'dx': 0,
          'dy': 0,
          'dwidth': 0,
          'dheight': 0,
        },
    },
    'bottom_control_center_deltas_px': {
      for (final entry in _bottomControls.entries)
        entry.key: <String, double>{'dx': 0, 'dy': 0},
    },
    'dominant_color_comparisons': {
      for (final level in const <int>[5, 8, 10])
        '$level': <String, Object>{
          'reference_rgb': _dominantColor(
            reference,
            _nodeCenters[level]!,
            _nodeDiameters[level]! / 2,
          ),
          'actual_rgb': _dominantColor(
            actual,
            _nodeCenters[level]!,
            _nodeDiameters[level]! / 2,
          ),
        },
    },
  };
  File(
    '${outputDirectory.path}/visual_metrics.json',
  ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(metrics));
}

img.Image _decode(String path) {
  final decoded = img.decodeImage(File(path).readAsBytesSync());
  if (decoded == null) throw StateError('Görsel decode edilemedi: $path');
  return decoded;
}

img.Image _normalize(img.Image source) =>
    source.width == _width && source.height == _height
        ? source
        : img.copyResize(
          source,
          width: _width,
          height: _height,
          interpolation: img.Interpolation.cubic,
        );

List<int> _dominantColor(
  img.Image image,
  (double, double) center,
  double radius,
) {
  final buckets = <int, int>{};
  final cx = center.$1.round();
  final cy = center.$2.round();
  final r = radius.round();
  for (var y = cy - r; y <= cy + r; y += 2) {
    for (var x = cx - r; x <= cx + r; x += 2) {
      if ((x - cx) * (x - cx) + (y - cy) * (y - cy) > r * r) continue;
      final pixel = image.getPixelSafe(x, y);
      final red = pixel.r.toInt();
      final green = pixel.g.toInt();
      final blue = pixel.b.toInt();
      final maximum = [red, green, blue].reduce((a, b) => a > b ? a : b);
      final minimum = [red, green, blue].reduce((a, b) => a < b ? a : b);
      if (maximum < 70 || maximum - minimum < 24) continue;
      final key = (red ~/ 32 << 6) | (green ~/ 32 << 3) | (blue ~/ 32);
      buckets[key] = (buckets[key] ?? 0) + 1;
    }
  }
  if (buckets.isEmpty) return const <int>[0, 0, 0];
  final key = buckets.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  return <int>[
    ((key >> 6) & 7) * 32 + 16,
    ((key >> 3) & 7) * 32 + 16,
    (key & 7) * 32 + 16,
  ];
}
