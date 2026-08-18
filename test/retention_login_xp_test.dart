import 'dart:convert';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

const _retentionKey = 'bilgi_rotasi_retention_progress_v1';
const _xpKey = 'bilgi_rotasi_xp_progress_v1';

class _MemoryProgressStore implements ProgressPreferencesStore {
  _MemoryProgressStore(Map<String, Object> initialValues)
    : values = Map<String, Object>.from(initialValues);

  final Map<String, Object> values;

  @override
  Future<String?> read(String key) =>
      Future<String?>.value(values[key] as String?);

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }
}

void _useStore(Map<String, Object> initialValues) {
  final store = _MemoryProgressStore(initialValues);
  RetentionProgressService.debugPreferences = store;
  XpProgressService.debugPreferences = store;
  addTearDown(() {
    RetentionProgressService.debugPreferences = null;
    XpProgressService.debugPreferences = null;
  });
}

Map<String, Object> _xpState(int totalXp) => <String, Object>{
  _xpKey: jsonEncode(<String, Object>{
    'totalXp': totalXp,
    'currentStreak': 3,
    'bestStreak': 5,
    'lastGain': 10,
    'lastReason': 'Mevcut XP',
  }),
};

Map<String, Object> _retentionState({
  required DateTime day,
  required int streak,
  int bestStreak = 0,
  int lastLoginReward = 0,
  String? lastLoginRewardDate,
}) => <String, Object>{
  _retentionKey: jsonEncode(<String, Object>{
    'weekKey': RetentionProgressService.currentWeekKey(),
    'lastLoginDate': RetentionProgressService.dateKey(day),
    'loginStreak': streak,
    'bestLoginStreak': bestStreak,
    'lastLoginReward': lastLoginReward,
    'lastLoginRewardDate': lastLoginRewardDate ?? '',
  }),
};

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('boş state ilk giriş serisini başlatır fakat XP vermez', () async {
    _useStore(_xpState(321));
    final today = _today();

    await RetentionProgressService.initialize(now: today);

    final retention = await RetentionProgressService.load();
    final xp = await XpProgressService.load();
    expect(retention.lastLoginDate, RetentionProgressService.dateKey(today));
    expect(retention.loginStreak, 1);
    expect(retention.bestLoginStreak, 1);
    expect(retention.lastLoginReward, 0);
    expect(retention.lastLoginRewardDate, isEmpty);
    expect(xp.totalXp, 321);
    expect(xp.lastGain, 10);
    expect(xp.lastReason, 'Mevcut XP');
  });

  test('aynı gün tekrar initialize streak veya XP değiştirmez', () async {
    _useStore(_xpState(654));
    final today = _today();

    await RetentionProgressService.initialize(now: today);
    await RetentionProgressService.initialize(now: today);

    final retention = await RetentionProgressService.load();
    final xp = await XpProgressService.load();
    expect(retention.loginStreak, 1);
    expect(retention.bestLoginStreak, 1);
    expect(retention.lastLoginReward, 0);
    expect(xp.totalXp, 654);
  });

  test('ardışık gün streak ilerler fakat XP değişmez', () async {
    final today = _today();
    final yesterday = today.subtract(const Duration(days: 1));
    _useStore(<String, Object>{
      ..._xpState(987),
      ..._retentionState(day: yesterday, streak: 4, bestStreak: 7),
    });

    await RetentionProgressService.initialize(now: today);

    final retention = await RetentionProgressService.load();
    final xp = await XpProgressService.load();
    expect(retention.loginStreak, 5);
    expect(retention.bestLoginStreak, 7);
    expect(retention.lastLoginReward, 0);
    expect(xp.totalXp, 987);
  });

  test('eski login ödülü aynı gün güvenle sıfırlanır', () async {
    final today = _today();
    _useStore(<String, Object>{
      ..._xpState(432),
      ..._retentionState(
        day: today,
        streak: 6,
        bestStreak: 6,
        lastLoginReward: 80,
        lastLoginRewardDate: RetentionProgressService.dateKey(today),
      ),
    });

    await RetentionProgressService.initialize(now: today);

    final retention = await RetentionProgressService.load();
    final xp = await XpProgressService.load();
    expect(retention.loginStreak, 6);
    expect(retention.bestLoginStreak, 6);
    expect(retention.lastLoginReward, 0);
    expect(retention.lastLoginRewardDate, isEmpty);
    expect(xp.totalXp, 432);
  });
}
