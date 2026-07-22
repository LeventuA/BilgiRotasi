part of 'main.dart';

enum DifficultyMode {
  relaxed,
  balanced,
  expert,
}

DifficultyMode difficultyModeFromName(Object? value) {
  final name = value?.toString();

  for (final mode in DifficultyMode.values) {
    if (mode.name == name) return mode;
  }

  return DifficultyMode.relaxed;
}

extension DifficultyModeX on DifficultyMode {
  String get label {
    switch (this) {
      case DifficultyMode.relaxed:
        return 'Rahat';
      case DifficultyMode.balanced:
        return 'Dengeli';
      case DifficultyMode.expert:
        return 'Uzman';
    }
  }

  String get emoji {
    switch (this) {
      case DifficultyMode.relaxed:
        return '🌿';
      case DifficultyMode.balanced:
        return '⚖️';
      case DifficultyMode.expert:
        return '🔥';
    }
  }

  String get description {
    switch (this) {
      case DifficultyMode.relaxed:
        return '%80 kolay • %18 orta • %2 zor';
      case DifficultyMode.balanced:
        return '%60 kolay • %30 orta • %10 zor';
      case DifficultyMode.expert:
        return '%30 kolay • %45 orta • %25 zor';
    }
  }

  Map<String, int> get weights {
    switch (this) {
      case DifficultyMode.relaxed:
        return <String, int>{
          'Kolay': 80,
          'Orta': 18,
          'Zor': 2,
        };
      case DifficultyMode.balanced:
        return <String, int>{
          'Kolay': 60,
          'Orta': 30,
          'Zor': 10,
        };
      case DifficultyMode.expert:
        return <String, int>{
          'Kolay': 30,
          'Orta': 45,
          'Zor': 25,
        };
    }
  }

  DifficultyMode get oneStepHarder {
    switch (this) {
      case DifficultyMode.relaxed:
        return DifficultyMode.balanced;
      case DifficultyMode.balanced:
      case DifficultyMode.expert:
        return DifficultyMode.expert;
    }
  }

  String chooseDifficulty(
    Random random, {
    int correctStreak = 0,
    int wrongStreak = 0,
    bool finalQuestion = false,
    bool forceRelaxed = false,
  }) {
    var effectiveMode =
        forceRelaxed ? DifficultyMode.relaxed : this;

    if (finalQuestion) {
      effectiveMode = effectiveMode.oneStepHarder;
    }

    final values = Map<String, int>.from(effectiveMode.weights);

    if (wrongStreak >= 2) {
      final hardShift = min(12, values['Zor'] ?? 0);
      final mediumShift = min(13, values['Orta'] ?? 0);

      values['Zor'] = (values['Zor'] ?? 0) - hardShift;
      values['Orta'] = (values['Orta'] ?? 0) - mediumShift;
      values['Kolay'] =
          (values['Kolay'] ?? 0) + hardShift + mediumShift;
    } else if (correctStreak >= 3) {
      final easyShift = min(15, values['Kolay'] ?? 0);
      final mediumShift = min(5, values['Orta'] ?? 0);

      values['Kolay'] = (values['Kolay'] ?? 0) - easyShift;
      values['Orta'] =
          (values['Orta'] ?? 0) + easyShift - mediumShift;
      values['Zor'] = (values['Zor'] ?? 0) + mediumShift;
    }

    final total = values.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    var roll = random.nextInt(max(1, total));

    for (final difficulty in const ['Kolay', 'Orta', 'Zor']) {
      roll -= values[difficulty] ?? 0;
      if (roll < 0) return difficulty;
    }

    return 'Kolay';
  }
}

extension PlayerDifficultyBalanceX on PlayerData {
  void registerAdaptiveAnswer(bool correct) {
    if (correct) {
      correctStreak++;
      wrongStreak = 0;
    } else {
      wrongStreak++;
      correctStreak = 0;
    }
  }

  String get adaptiveDifficultyLabel {
    if (wrongStreak >= 2) {
      return 'Destek aktif';
    }

    if (correctStreak >= 3) {
      return 'Meydan okuma aktif';
    }

    return 'Dengeleniyor';
  }
}

class DifficultyModeDropdown extends StatelessWidget {
  const DifficultyModeDropdown({
    required this.value,
    required this.onChanged,
    this.label = 'Soru seviyesi',
    super.key,
  });

  final DifficultyMode value;
  final ValueChanged<DifficultyMode> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DifficultyMode>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Text(
          value.emoji,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 42,
        ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: DifficultyMode.values
          .map(
            (mode) => DropdownMenuItem<DifficultyMode>(
              value: mode,
              child: Text(
                '${mode.label} — ${mode.description}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
          .toList(growable: false),
      onChanged: (mode) {
        if (mode != null) onChanged(mode);
      },
    );
  }
}

class DifficultyModeCard extends StatelessWidget {
  const DifficultyModeCard({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final DifficultyMode value;
  final ValueChanged<DifficultyMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Soru seviyesi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Başlangıç seviyesi oyun sırasında verdiğin '
              'cevaplara göre yumuşak biçimde dengelenir.',
              style: TextStyle(
                color: Colors.blueGrey.shade700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            DifficultyModeDropdown(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class DifficultyBalance {
  DifficultyBalance._();

  static List<QuizQuestion> pickMarathonQuestions({
    required QuestionBank questionBank,
    required List<QuizQuestion> pool,
    required int count,
    required Random random,
    required DifficultyMode mode,
  }) {
    if (pool.isEmpty || count <= 0) {
      return const <QuizQuestion>[];
    }

    final available = List<QuizQuestion>.from(pool);
    final selected = <QuizQuestion>[];
    final usedFamilies = <String>{};

    while (available.isNotEmpty && selected.length < count) {
      final targetDifficulty = mode.chooseDifficulty(random);

      var candidates = available
          .where(
            (question) =>
                question.difficulty == targetDifficulty &&
                !usedFamilies.contains(
                  QuestionBank.questionFamilyKey(question.text),
                ),
          )
          .toList();

      if (candidates.isEmpty) {
        candidates = available
            .where(
              (question) => !usedFamilies.contains(
                QuestionBank.questionFamilyKey(question.text),
              ),
            )
            .toList();
      }

      if (candidates.isEmpty) {
        candidates = List<QuizQuestion>.from(available);
      }

      final chosen =
          candidates[random.nextInt(candidates.length)];
      selected.add(chosen);
      available.removeWhere((question) => question.id == chosen.id);
      usedFamilies.add(
        QuestionBank.questionFamilyKey(chosen.text),
      );
    }

    return selected;
  }
}
