import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

LiveDuelPresence presence({
  required String uid,
  required LiveDuelPresenceState state,
  required DateTime now,
  bool connected = false,
  bool leaveRequested = false,
  Duration? grace,
}) {
  return LiveDuelPresence(
    uid: uid,
    state: state,
    connected: connected,
    leaveRequested: leaveRequested,
    disconnectedAt: now,
    graceUntil: grace == null ? null : now.add(grace),
  );
}

void main() {
  group('Canlı düello bağlantı politikası', () {
    test('aktif oyuncu hükmen yenik sayılmaz', () {
      final now = DateTime.utc(2026, 7, 26, 12);

      final loser = LiveDuelConnectionPolicy.forfeitLoser(
        playerUids: const <String>['levent', 'emel'],
        presences: <LiveDuelPresence>[
          presence(
            uid: 'levent',
            state: LiveDuelPresenceState.active,
            now: now,
            connected: true,
          ),
          presence(
            uid: 'emel',
            state: LiveDuelPresenceState.active,
            now: now,
            connected: true,
          ),
        ],
        now: now,
      );

      expect(loser, isNull);
    });

    test('yeniden bağlanma süresi dolmayan oyuncu korunur', () {
      final now = DateTime.utc(2026, 7, 26, 12);

      final loser = LiveDuelConnectionPolicy.forfeitLoser(
        playerUids: const <String>['levent', 'emel'],
        presences: <LiveDuelPresence>[
          presence(
            uid: 'levent',
            state: LiveDuelPresenceState.active,
            now: now,
            connected: true,
          ),
          presence(
            uid: 'emel',
            state: LiveDuelPresenceState.background,
            now: now,
            grace: const Duration(seconds: 30),
          ),
        ],
        now: now,
      );

      expect(loser, isNull);
    });

    test('yeniden bağlanma süresi dolan oyuncu hükmen yenilir', () {
      final now = DateTime.utc(2026, 7, 26, 12);

      final loser = LiveDuelConnectionPolicy.forfeitLoser(
        playerUids: const <String>['levent', 'emel'],
        presences: <LiveDuelPresence>[
          presence(
            uid: 'levent',
            state: LiveDuelPresenceState.active,
            now: now,
            connected: true,
          ),
          presence(
            uid: 'emel',
            state: LiveDuelPresenceState.background,
            now: now.subtract(const Duration(minutes: 2)),
            grace: const Duration(seconds: 60),
          ),
        ],
        now: now,
      );

      expect(loser, 'emel');
    });

    test('maçtan ayrılan oyuncu anında hükmen yenilir', () {
      final now = DateTime.utc(2026, 7, 26, 12);

      final loser = LiveDuelConnectionPolicy.forfeitLoser(
        playerUids: const <String>['levent', 'emel'],
        presences: <LiveDuelPresence>[
          presence(
            uid: 'levent',
            state: LiveDuelPresenceState.left,
            now: now,
            leaveRequested: true,
          ),
          presence(
            uid: 'emel',
            state: LiveDuelPresenceState.active,
            now: now,
            connected: true,
          ),
        ],
        now: now,
      );

      expect(loser, 'levent');
    });
  });

  test('hükmen tamamlanan maç skordan bağımsız kazananı korur', () {
    final match = LiveDuelCompletedMatch.fromMap(
      matchId: 'forfeit-1',
      data: <String, dynamic>{
        'resultProcessed': true,
        'completionType': 'forfeit',
        'forfeitLoserUid': 'levent',
        'playerUids': const <String>['levent', 'emel'],
        'scores': const <String, int>{'levent': 8, 'emel': 4},
        'winnerUid': 'emel',
        'draw': false,
      },
    );

    expect(match.forfeited, isTrue);
    expect(match.resultFor('levent'), LiveDuelResult.loss);
    expect(match.resultFor('emel'), LiveDuelResult.win);
  });
}
