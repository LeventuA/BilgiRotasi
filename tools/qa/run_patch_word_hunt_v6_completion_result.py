from pathlib import Path

source_path = Path('tools/qa/patch_word_hunt_v6_completion_result.py')
source = source_path.read_text(encoding='utf-8')

old_helper = """def replace_once(text: str, old: str, new: str, label: str) -> str:\n    count = text.count(old)\n    if count != 1:\n        raise SystemExit(f'{label}: expected exactly one match, got {count}')\n    return text.replace(old, new, 1)\n"""
new_helper = """def replace_once(text: str, old: str, new: str, label: str) -> str:\n    count = text.count(old)\n    if label == 'auto completion scheduler':\n        if count != 2:\n            raise SystemExit(f'{label}: expected production+prototype matches, got {count}')\n        return text.replace(old, new, 1)\n    if count != 1:\n        raise SystemExit(f'{label}: expected exactly one match, got {count}')\n    return text.replace(old, new, 1)\n"""
if source.count(old_helper) != 1:
    raise SystemExit('replace_once helper source mismatch')
source = source.replace(old_helper, new_helper, 1)

old_replay_tail = """      expect(\n        find.byKey(const Key('word_hunt_production_result_panel')),\n        findsOneWidget,\n      );\n    }\n  });\n"""
new_replay_tail = """      expect(\n        find.byKey(const Key('word_hunt_production_result_panel')),\n        findsOneWidget,\n      );\n      await tester.tap(\n        find.byKey(const Key('word_hunt_production_return_route')),\n      );\n      await tester.pumpAndSettle();\n    }\n  });\n"""
if source.count(old_replay_tail) != 1:
    raise SystemExit('replay test tail source mismatch')
source = source.replace(old_replay_tail, new_replay_tail, 1)

exec(compile(source, str(source_path), 'exec'), {'__name__': '__main__'})