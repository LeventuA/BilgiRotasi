import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canlı Düello sunucu doğrulaması', () {
    test('istemci seçilen şıkkı ilerleme belgesine gönderir', () {
      final progress = File('lib/live_duel_progress.dart').readAsStringSync();
      final play = File('lib/live_duel_play_screen.dart').readAsStringSync();

      expect(progress, contains('lastSelectedOptionIndex'));
      expect(progress, contains('selectedOptionIndex'));
      expect(play, contains('selectedOptionIndex: optionIndex'));
    });

    test('Firestore özel cevap anahtarıyla skoru doğrular', () {
      final rules = File('firestore.rules').readAsStringSync();

      expect(rules, contains('live_duel_question_keys'));
      expect(rules, contains('validDuelProgressUpdate'));
      expect(rules, contains('lastSelectedOptionIndex == key.answerIndex'));
      expect(rules, contains('allow read, write: if false;'));
    });

    test('cevap anahtarı yükleme aracı repoda bulunur', () {
      final uploader =
          File('tools/upload_live_duel_question_keys.py').readAsStringSync();

      expect(uploader, contains('answerIndex'));
      expect(uploader, contains('live_duel_question_keys'));
      expect(uploader, contains('--validate-only'));
    });
  });
}
