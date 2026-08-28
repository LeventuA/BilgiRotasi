from pathlib import Path

path = Path('lib/word_hunt/word_hunt_screens.dart')
text = path.read_text(encoding='utf-8')


def once(old: str, new: str, label: str) -> None:
    global text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected 1 match, got {count}')
    text = text.replace(old, new, 1)


once(
    '  int? _completionElapsedSeconds;\n  int _mistakes = 0;\n',
    '  int? _completionElapsedSeconds;\n  int? _completionMistakes;\n  int _mistakes = 0;\n',
    'production completion mistake field',
)
once(
    '  int get _displayedElapsedSeconds =>\n      _completionElapsedSeconds ?? _elapsedSeconds;\n\n  DateTime _now()',
    '  int get _displayedElapsedSeconds =>\n      _completionElapsedSeconds ?? _elapsedSeconds;\n\n  int get _scoredMistakes => _completionMistakes ?? _mistakes;\n\n  DateTime _now()',
    'production scored mistakes getter',
)
once(
    '  void _pointerDown(Offset position, Size size) {\n    if (_completionElapsedSeconds != null) return;\n',
    '  void _pointerDown(Offset position, Size size) {\n    if (_resultDelivered || _completionDialogOpen) return;\n',
    'production pointer down gate',
)
once(
    '    if (_completionElapsedSeconds != null || start == null) return;\n',
    '    if (_resultDelivered || _completionDialogOpen || start == null) return;\n',
    'production pointer move gate',
)
once(
    '  void _pointerUp() {\n    if (_dragStart == null || _completionElapsedSeconds != null) return;\n',
    '  void _pointerUp() {\n    if (_dragStart == null || _resultDelivered || _completionDialogOpen) return;\n',
    'production pointer up gate',
)
once(
    '            _completionElapsedSeconds = elapsed;\n            _timer?.cancel();\n',
    '            _completionElapsedSeconds = elapsed;\n            _completionMistakes = _mistakes;\n            _timer?.cancel();\n',
    'production completion snapshot',
)
once(
    "        case WordHuntSelectionKind.notAWord:\n          _startErrorFeedback(selectedPath);\n          _mistakes++;\n          _status = 'Bu seçim listede yok. Başka bir yol dene.';\n",
    "        case WordHuntSelectionKind.notAWord:\n          _startErrorFeedback(selectedPath);\n          if (_completionElapsedSeconds == null) {\n            _mistakes++;\n            _status = 'Bu seçim listede yok. Başka bir yol dene.';\n          } else {\n            _status = 'Ana hedefler tamam. İstersen bonus kelimeyi ara.';\n          }\n",
    'production post-target mistake freeze',
)
once(
    '      mistakes: _mistakes,\n      elapsedSeconds: elapsed,\n',
    '      mistakes: _scoredMistakes,\n      elapsedSeconds: elapsed,\n',
    'production score mistakes',
)
once(
    "                  '$_mistakes hata',\n                  key: const Key('word_hunt_production_result_mistakes'),\n",
    "                  '$_scoredMistakes hata',\n                  key: const Key('word_hunt_production_result_mistakes'),\n",
    'production dialog mistakes',
)
once(
    "                        label: '$_mistakes hata',\n                        key: const Key('word_hunt_production_mistakes'),\n",
    "                        label: '$_scoredMistakes hata',\n                        key: const Key('word_hunt_production_mistakes'),\n",
    'production metric mistakes',
)

aspect_count = text.count('                AspectRatio(\n                  aspectRatio: 1,\n')
if aspect_count != 2:
    raise SystemExit(f'aspect ratio: expected 2 matches, got {aspect_count}')
text = text.replace(
    '                AspectRatio(\n                  aspectRatio: 1,\n',
    '                AspectRatio(\n                  aspectRatio: widget.level.columnCount / widget.level.rowCount,\n',
)

once(
    '  int _elapsedSeconds = 0;\n  int _mistakes = 0;\n  bool _timeExpired = false;\n',
    '  int _elapsedSeconds = 0;\n  int? _completionElapsedSeconds;\n  int? _completionMistakes;\n  int _mistakes = 0;\n',
    'prototype completion fields',
)
once(
    '  bool get _allTargetsFound =>\n      _foundTargets.length >= widget.level.targetWords.length;\n\n  void _resetAttempt()',
    '  bool get _allTargetsFound =>\n      _foundTargets.length >= widget.level.targetWords.length;\n\n  int get _displayedElapsedSeconds =>\n      _completionElapsedSeconds ?? _elapsedSeconds;\n\n  int get _scoredMistakes => _completionMistakes ?? _mistakes;\n\n  void _resetAttempt()',
    'prototype display getters',
)
once(
    '    _elapsedSeconds = 0;\n    _mistakes = 0;\n    _timeExpired = false;\n',
    '    _elapsedSeconds = 0;\n    _completionElapsedSeconds = null;\n    _completionMistakes = null;\n    _mistakes = 0;\n',
    'prototype reset snapshots',
)
once(
    "    _timer = Timer.periodic(const Duration(seconds: 1), (_) {\n      if (!mounted || _timeExpired) return;\n      final elapsed = DateTime.now().difference(_startedAt).inSeconds;\n      final limit = widget.level.timeLimitSeconds;\n      if (limit != null && elapsed >= limit && !_allTargetsFound) {\n        setState(() {\n          _elapsedSeconds = limit;\n          _timeExpired = true;\n          _selectedPath = const <WordHuntCell>[];\n          _status = 'Süre doldu. Tekrar deneyebilirsin.';\n        });\n        _timer?.cancel();\n        return;\n      }\n      setState(() => _elapsedSeconds = elapsed);\n    });\n",
    "    _timer = Timer.periodic(const Duration(seconds: 1), (_) {\n      if (!mounted || _completionElapsedSeconds != null) return;\n      final elapsed = DateTime.now().difference(_startedAt).inSeconds;\n      if (elapsed == _elapsedSeconds) return;\n      setState(() => _elapsedSeconds = elapsed);\n    });\n",
    'prototype soft timer',
)
once(
    '  void _pointerDown(Offset position, Size size) {\n    if (_timeExpired) return;\n',
    '  void _pointerDown(Offset position, Size size) {\n',
    'prototype pointer down',
)
once(
    '  void _pointerMove(Offset position, Size size) {\n    if (_timeExpired || _dragStart == null) return;\n',
    '  void _pointerMove(Offset position, Size size) {\n    if (_dragStart == null) return;\n',
    'prototype pointer move',
)
once(
    '  void _pointerUp() {\n    if (_selectedPath.isEmpty || _timeExpired) return;\n',
    '  void _pointerUp() {\n    if (_selectedPath.isEmpty) return;\n',
    'prototype pointer up',
)
once(
    "          _status =\n              cardTitle == null\n                  ? 'Harika! $word bulundu.'\n                  : 'Bilgi kartı açıldı: $cardTitle';\n        case WordHuntSelectionKind.bonus:",
    "          _status =\n              cardTitle == null\n                  ? 'Harika! $word bulundu.'\n                  : 'Bilgi kartı açıldı: $cardTitle';\n          if (_allTargetsFound && _completionElapsedSeconds == null) {\n            final elapsed = DateTime.now().difference(_startedAt).inSeconds;\n            _elapsedSeconds = elapsed;\n            _completionElapsedSeconds = elapsed;\n            _completionMistakes = _mistakes;\n            _timer?.cancel();\n          }\n        case WordHuntSelectionKind.bonus:",
    'prototype completion snapshot',
)
once(
    "        case WordHuntSelectionKind.notAWord:\n          _mistakes++;\n          _status = 'Bu seçim listede yok. Başka bir yol dene.';\n",
    "        case WordHuntSelectionKind.notAWord:\n          if (_completionElapsedSeconds == null) {\n            _mistakes++;\n            _status = 'Bu seçim listede yok. Başka bir yol dene.';\n          } else {\n            _status = 'Ana hedefler tamam. İstersen bonus kelimeyi ara.';\n          }\n",
    'prototype post-target mistake freeze',
)
once(
    "    _timer?.cancel();\n    final elapsed = DateTime.now().difference(_startedAt).inSeconds;\n    final score = WordHuntScoringEngine.calculate(\n      level: widget.level,\n      foundTargetCount: _foundTargets.length,\n      mistakes: _mistakes,\n      elapsedSeconds: elapsed,\n",
    "    _timer?.cancel();\n    final elapsed = _displayedElapsedSeconds;\n    final score = WordHuntScoringEngine.calculate(\n      level: widget.level,\n      foundTargetCount: _foundTargets.length,\n      mistakes: _scoredMistakes,\n      elapsedSeconds: elapsed,\n",
    'prototype finish snapshot score',
)
once(
    "                  '${elapsed}s • $_mistakes hata • ${_foundBonus.length} bonus',\n",
    "                  '${elapsed}s • $_scoredMistakes hata • ${_foundBonus.length} bonus',\n",
    'prototype result mistakes',
)
once(
    "    final remaining =\n        widget.level.timeLimitSeconds == null\n            ? null\n            : math.max(0, widget.level.timeLimitSeconds! - _elapsedSeconds);\n\n    return Scaffold(\n",
    "    final challengeSeconds = widget.level.timeLimitSeconds;\n\n    return Scaffold(\n",
    'prototype remaining removal',
)
once(
    "                      label: '$_mistakes hata',\n",
    "                      label: '$_scoredMistakes hata',\n",
    'prototype metric mistakes',
)
once(
    "                      label:\n                          remaining == null\n                              ? '${_elapsedSeconds}s'\n                              : '${remaining}s',\n                      warning: remaining != null && remaining <= 10,\n",
    "                      label: '${_displayedElapsedSeconds}s',\n                      warning:\n                          challengeSeconds != null &&\n                          _displayedElapsedSeconds > challengeSeconds,\n",
    'prototype elapsed metric',
)
once(
    "              if (_timeExpired)\n                FilledButton.icon(\n                  onPressed: () => setState(_resetAttempt),\n                  icon: const Icon(Icons.refresh_rounded),\n                  label: const Text('Tekrar Dene'),\n                )\n              else if (_allTargetsFound)\n",
    "              if (_allTargetsFound)\n",
    'prototype hard-timeout button',
)

if '_timeExpired' in text:
    raise SystemExit('prototype hard-timeout state still present')

path.write_text(text, encoding='utf-8')
print('6x10 screen patch applied')
