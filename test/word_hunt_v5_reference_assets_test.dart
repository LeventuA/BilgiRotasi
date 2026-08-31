import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('approved V5 reference assets keep exact SHA-256 contract', () {
    const expected = <String, String>{
      'harbor_background_1080x1920.png':
          '0482adfa9ce8b2eb3b3637a7ef9976984650368a43f539f999842437a69d4368',
      'cell_idle.png':
          '052ac36a48cd0bac06bfbd6221e28c77bd32a4b1e9f08ded0e7fabefbf56c529',
      'cell_selected_found.png':
          '57d620263cae231c4b8983cc8fab7732db7733a78fae9e620abaaec7dc8aac87',
      'status_panel_empty.png':
          '0f5fd5aac1f94fa644a3f19c4147e2747fd639b0041a12e94df8198201fc95f4',
      'word_plaque_empty.png':
          '90d15d496a1a22fdee1014ffc2921ef8569863570b3c61141417cf9fb941c04a',
      'bonus_plaque_empty.png':
          'e3bfe4b5a958ec945a76cdd0cc48d2ae3e93f4340ccf5b778ad63663787a79bf',
      'instruction_panel_empty.png':
          '71aa162fc3dd24ef6f84c04792c87eb8800e63ff8b92b933bab13f2b72731c5c',
      'icon_back.png':
          '4d086841a7fc4cb4bb194ab72fd3f9f34c3d84adc836b965ab15e651ac92b24f',
      'icon_search.png':
          'da26169dc521284e58144453ce756053a1b153e7c467d90a860d1cf5c2ec71fe',
      'icon_mistake.png':
          'b77fe3628dc98162e1d739d649dffc426ec293f88579716c25e459de2e0d6253',
      'icon_timer.png':
          'f276c862e3ecae30853ff8d0f3fe8e08d2878e1357d67a4eb3e13c95affa54ec',
    };

    for (final entry in expected.entries) {
      final file = File('assets/word_hunt/v5_reference_assets/${entry.key}');
      expect(file.existsSync(), isTrue, reason: entry.key);
      expect(
        sha256.convert(file.readAsBytesSync()).toString(),
        entry.value,
        reason: entry.key,
      );
    }
  });
}
