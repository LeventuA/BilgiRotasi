part of 'main.dart';

class PawnStepSoundFactory {
  PawnStepSoundFactory._();

  static const int sampleRate = 22050;
  static const int profileCount = 16;

  static const List<String> profileNames = <String>[
    'Renkli Halka Cam Tınısı',
    'Bilgi Taşı Kristal Vuruşu',
    'Beyin Maskotu Yumuşak Dokunuşu',
    'Klasik Piyon Ahşap Tıkırtısı',
    'Bilge At Toynak Sesi',
    'Kristal Zar Küp Tıkırtısı',
    'Pusula Yıldızı Metal Kliği',
    'Açık Kitap Sayfa Dokunuşu',
    'Ampul Fikri Elektrik Parıltısı',
    'Kum Saati Kum Tıkırtısı',
    'Soru İşareti Merak Bipi',
    'Kupa Rozet Zafer Çanı',
    'Minik Galaksi Bilgesi Kozmik Çanı',
    'Fidan Muhafızı Dal ve Yaprak Sesi',
    'Özgür Ev Cini Kumaş ve Sihir Sesi',
    'Mağara Sinsiği Taş ve Yüzük Sesi',
  ];

  static const List<double> _volume = <double>[
    .74, .72, .78, .82, .80, .78, .68, .72,
    .66, .70, .72, .68, .66, .78, .70, .74,
  ];

  static const List<List<num>> _profile = <List<num>>[
    [118, 860, 1290, .02, -.08, 1, 0],
    [132, 1040, 1660, .015, -.14, 1, 0],
    [112, 238, 356, .05, -.30, 1, 2],
    [94, 182, 420, .26, -.20, 1, 1],
    [126, 164, 292, .18, -.12, 2, 1],
    [88, 286, 742, .34, -.16, 2, 3],
    [106, 1180, 1840, .04, -.18, 1, 3],
    [116, 430, 910, .52, .18, 1, 4],
    [128, 1420, 2260, .08, .24, 3, 5],
    [122, 680, 1080, .64, -.12, 3, 4],
    [124, 490, 760, .03, .44, 2, 2],
    [148, 654, 988, .02, -.10, 1, 0],
    [158, 734, 1468, .025, .22, 3, 5],
    [124, 206, 478, .30, -.18, 2, 1],
    [136, 520, 1250, .13, .20, 2, 5],
    [132, 148, 842, .32, -.24, 2, 3],
  ];

  static int normalize(int pawnType) =>
      (pawnType % profileCount + profileCount) % profileCount;

  static String fileNameForPawn(int pawnType) {
    final no = normalize(pawnType) + 1;
    return 'pawn_step_${no.toString().padLeft(2, '0')}.wav';
  }

  static String profileNameForPawn(int pawnType) =>
      profileNames[normalize(pawnType)];

  static double volumeForPawn(int pawnType) =>
      _volume[normalize(pawnType)];

  static double rateForStep(int pawnType, int stepIndex) {
    final values = normalize(pawnType).isEven
        ? const <double>[.97, 1, 1.035]
        : const <double>[1.025, .985, 1];
    return values[stepIndex.abs() % values.length];
  }

  static Map<String, Uint8List> buildAll() => <String, Uint8List>{
        for (var index = 0; index < profileCount; index++)
          fileNameForPawn(index): _build(index),
      };

  static Uint8List _build(int index) {
    final p = _profile[index];
    final durationMs = p[0].toInt();
    final base = p[1].toDouble();
    final second = p[2].toDouble();
    final noiseMix = p[3].toDouble();
    final glide = p[4].toDouble();
    final pulses = p[5].toInt();
    final character = p[6].toInt();
    final count = (sampleRate * durationMs / 1000).round();
    final samples = Int16List(count);
    var state = 0x51F15EED ^ (index * 0x45D9F3B);

    double noise() {
      state = (1664525 * state + 1013904223) & 0x7FFFFFFF;
      return state / 0x7FFFFFFF * 2 - 1;
    }

    for (var i = 0; i < count; i++) {
      final t = i / sampleRate;
      final x = i / max(1, count - 1);
      final attack = min(1.0, t / .006);
      final release = pow(1 - x, 2.25).toDouble();
      final pulseX = (x * pulses) % 1.0;
      final gate = pulses == 1
          ? 1.0
          : pow(max(0.0, 1 - pulseX), .42).toDouble();
      final f1 = base * (1 + glide * x);
      final f2 = second * (1 - glide * x * .35);
      final a = 2 * pi * f1 * t;
      final b = 2 * pi * f2 * t;
      var tone = sin(a) * .72 + sin(b) * .28;

      if (character == 1) {
        tone = 2 / pi * asin(sin(a)) * .72 + sin(b) * .28;
      } else if (character == 2) {
        tone = sin(a) * .76 + sin(a * .5) * .24;
      } else if (character == 3) {
        tone = sin(a) * .55 + sin(b) * .30 + sin(b * 1.51) * .15;
      } else if (character == 4) {
        tone = sin(a) * .44 + sin(b) * .20;
      } else if (character == 5) {
        final sparkle =
            pow(max(0.0, sin(pi * pulseX)), 8).toDouble();
        tone = sin(a) * .50 +
            sin(b) * .28 +
            sin(b * 1.73) * sparkle * .22;
      }

      final transient = exp(-t * (42 + index % 4 * 6)) *
          sin(2 * pi * (1700 + index * 73) * t);
      var value = (tone * (1 - noiseMix) +
              noise() * noiseMix +
              transient * (.15 + noiseMix * .20)) *
          attack *
          release *
          gate;
      value = value.clamp(-1.0, 1.0).toDouble();
      samples[i] = (value * 23500).round();
    }

    return _wav(samples);
  }

  static Uint8List _wav(Int16List samples) {
    final dataLength = samples.length * 2;
    final data = ByteData(44 + dataLength);

    void text(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        data.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    text(0, 'RIFF');
    data.setUint32(4, 36 + dataLength, Endian.little);
    text(8, 'WAVE');
    text(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, sampleRate, Endian.little);
    data.setUint32(28, sampleRate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    text(36, 'data');
    data.setUint32(40, dataLength, Endian.little);

    for (var i = 0; i < samples.length; i++) {
      data.setInt16(44 + i * 2, samples[i], Endian.little);
    }
    return data.buffer.asUint8List();
  }
}
