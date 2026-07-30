part of 'main.dart';

class LiveDuelServerGateway {
  LiveDuelServerGateway._();

  static Future<String> joinQueue(int questionCount) async {
    final result = await SecureCallableService.call('joinLiveDuelQueue', {
      'questionCount': questionCount,
    });
    return result['ticketId']?.toString() ?? '';
  }

  static Future<String?> findMatch() async {
    final result = await SecureCallableService.call('findLiveDuelMatch');
    return result['matchId']?.toString();
  }

  static Future<void> cancelQueue() async {
    await SecureCallableService.call('cancelLiveDuelQueue');
  }

  static Future<void> submitAnswer({
    required String matchId,
    required String questionId,
    required int selectedIndex,
  }) async {
    await SecureCallableService.call('submitLiveDuelAnswer', {
      'matchId': matchId,
      'questionId': questionId,
      'selectedIndex': selectedIndex,
    });
  }

  static Future<bool> finalize(String matchId) async {
    final result = await SecureCallableService.call('finalizeLiveDuel', {
      'matchId': matchId,
    });
    return result['status'] == 'complete';
  }

  static Future<bool> resolveForfeit(String matchId) async {
    final result = await SecureCallableService.call('resolveLiveDuelForfeit', {
      'matchId': matchId,
    });
    return result['status'] == 'complete';
  }
}

class PlayerUsernameServerGateway {
  PlayerUsernameServerGateway._();

  static Future<Map<String, dynamic>> claim(String username) {
    return SecureCallableService.call('claimUsername', {'username': username});
  }
}
