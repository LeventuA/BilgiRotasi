import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ilerleme deterministik biçimde encode/decode olur', () {
    final snapshot = WordHuntProgressSnapshot(
      bestStarsByLevelId: const <String, int>{
        'baslangic-2': 3,
        'baslangic-1': 2,
      },
      unlockedInfoCardIds: const <String>{'kart-z', 'kart-a'},
    );

    final raw = WordHuntProgressCodec.encode(
      snapshot,
      ownerScope: 'user_abc',
    );
    final restored = WordHuntProgressCodec.decode(
      raw,
      expectedOwnerScope: 'user_abc',
    );

    expect(restored.starsFor('baslangic-1'), 2);
    expect(restored.starsFor('baslangic-2'), 3);
    expect(restored.unlockedInfoCardIds, containsAll(<String>['kart-a', 'kart-z']));
    expect(raw.indexOf('baslangic-1'), lessThan(raw.indexOf('baslangic-2')));
    expect(raw.indexOf('kart-a'), lessThan(raw.indexOf('kart-z')));
  });

  test('misafir ve hesap storage anahtarları birbirinden ayrılır', () {
    expect(
      WordHuntProgressCodec.storageKeyForUid(null),
      'bilgi_rotasi_word_hunt_progress_v1_guest',
    );
    expect(
      WordHuntProgressCodec.storageKeyForUid('  uid123  '),
      'bilgi_rotasi_word_hunt_progress_v1_user_uid123',
    );
    expect(
      WordHuntProgressCodec.storageKeyForUid(null),
      isNot(WordHuntProgressCodec.storageKeyForUid('uid123')),
    );
  });

  test('başka hesaba ait ilerleme fail-closed reddedilir', () {
    final raw = WordHuntProgressCodec.encode(
      const WordHuntProgressSnapshot(),
      ownerScope: 'user_a',
    );

    expect(
      () => WordHuntProgressCodec.decode(
        raw,
        expectedOwnerScope: 'user_b',
      ),
      throwsFormatException,
    );
  });

  test('bilinmeyen şema reddedilir', () {
    const raw = '''{"schema":99,"ownerScope":"guest","bestStarsByLevelId":{},"unlockedInfoCardIds":[]}''';

    expect(
      () => WordHuntProgressCodec.decode(raw, expectedOwnerScope: 'guest'),
      throwsFormatException,
    );
  });

  test('0..3 dışındaki yıldız değeri reddedilir', () {
    const raw = '''{"schema":1,"ownerScope":"guest","bestStarsByLevelId":{"baslangic-1":4},"unlockedInfoCardIds":[]}''';

    expect(
      () => WordHuntProgressCodec.decode(raw, expectedOwnerScope: 'guest'),
      throwsFormatException,
    );
  });

  test('bozuk JSON güvenli biçimde reddedilir', () {
    expect(
      () => WordHuntProgressCodec.decode(
        '{not-json',
        expectedOwnerScope: 'guest',
      ),
      throwsFormatException,
    );
  });

  test('boş owner scope encode aşamasında reddedilir', () {
    expect(
      () => WordHuntProgressCodec.encode(
        const WordHuntProgressSnapshot(),
        ownerScope: '   ',
      ),
      throwsFormatException,
    );
  });
}
