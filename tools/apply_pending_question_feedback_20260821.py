#!/usr/bin/env python3
"""Apply the 2026-08-21 pending question-feedback resolution fail-closed."""
from __future__ import annotations

import copy
import hashlib
import json
import re
from pathlib import Path

QUESTIONS = Path('assets/questions.json')
PUBSPEC = Path('pubspec.yaml')
AUDIT = Path('reports/pending_question_feedback_live_audit_20260821.json')
MANIFEST = Path('reports/pending_question_feedback_resolution_manifest_20260821.json')
REPORT = Path('reports/pending_question_feedback_resolution_20260821.md')
VALID_DIFFICULTIES = {'Kolay', 'Orta', 'Zor'}
CATEGORY_NAMES = {
    0: 'Coğrafya',
    1: 'Eğlence',
    2: 'Tarih',
    3: 'Sanat & Edebiyat',
    4: 'Bilim & Doğa',
    5: 'Spor',
}
AUDIT_FIELDS = ('question', 'options', 'answerIndex', 'difficulty', 'explanation', 'categoryIndex')


def fail(message: str) -> None:
    raise SystemExit(f'❌ {message}')


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def normalized(value: object) -> str:
    return re.sub(r'\s+', ' ', str(value).strip().casefold())


def canonical_json(data: object) -> str:
    return json.dumps(data, ensure_ascii=False, indent=2) + '\n'


def read_json(path: Path):
    try:
        return json.loads(path.read_text(encoding='utf-8'))
    except Exception as error:
        fail(f'{path} okunamadı: {error}')


for required in (QUESTIONS, PUBSPEC, AUDIT, MANIFEST):
    if not required.exists():
        fail(f'Gerekli dosya bulunamadı: {required}')

manifest = read_json(MANIFEST)
audit = read_json(AUDIT)
raw_questions = QUESTIONS.read_bytes()
source_sha = sha256_bytes(raw_questions)
if source_sha != manifest['expectedQuestionBankSha256']:
    fail(
        'questions.json SHA-256 beklenenden farklı. '
        f"Beklenen {manifest['expectedQuestionBankSha256']}, bulunan {source_sha}."
    )

try:
    questions = json.loads(raw_questions.decode('utf-8'))
except Exception as error:
    fail(f'questions.json JSON olarak okunamadı: {error}')

if canonical_json(questions).encode('utf-8') != raw_questions:
    fail('questions.json mevcut biçimi canonical indent=2 çıktısıyla birebir değil; toplu yeniden biçimlendirme riski nedeniyle durduruldu.')
if not isinstance(questions, list):
    fail('questions.json en üst düzeyde liste olmalı.')
if len(questions) != manifest['expectedQuestionBankCount']:
    fail(f"Soru sayısı beklenenden farklı: {len(questions)}")

by_id = {}
for item in questions:
    if not isinstance(item, dict):
        fail('Soru bankasında nesne olmayan kayıt bulundu.')
    qid = str(item.get('id', '')).strip()
    if not qid or qid in by_id:
        fail(f'Boş veya yinelenen soru kimliği: {qid!r}')
    by_id[qid] = item

if audit.get('questionBankSha256') != source_sha:
    fail('Audit raporu ile canlı soru bankası SHA-256 değeri uyuşmuyor.')
if audit.get('targetCount') != manifest['expectedTargetCount']:
    fail('Audit hedef sayısı manifest ile uyuşmuyor.')

audit_targets = audit.get('targets')
if not isinstance(audit_targets, list):
    fail('Audit targets listesi yok.')
audit_by_id = {str(item['id']): item for item in audit_targets}
if len(audit_by_id) != manifest['expectedTargetCount']:
    fail('Audit hedef kimlikleri benzersiz değil veya eksik.')

for qid, snapshot in audit_by_id.items():
    current = by_id.get(qid)
    if current is None:
        fail(f'Audit hedefi soru bankasında yok: {qid}')
    for field in AUDIT_FIELDS:
        if current.get(field) != snapshot.get(field):
            fail(f'{qid}: canlı kayıt audit snapshotından sapmış ({field}).')

content_changes = manifest['contentChanges']
difficulty_changes = manifest['difficultyChanges']
category_changes = manifest['categoryChanges']
no_change = manifest['noChange']

counts = manifest['counts']
if len(content_changes) != counts['contentFixes']:
    fail('contentFixes sayısı manifest içeriğiyle uyuşmuyor.')
if len(difficulty_changes) != counts['difficultyFixes']:
    fail('difficultyFixes sayısı manifest içeriğiyle uyuşmuyor.')
if len(category_changes) != counts['categoryFixes']:
    fail('categoryFixes sayısı manifest içeriğiyle uyuşmuyor.')
if len(no_change) != counts['noChange']:
    fail('noChange sayısı manifest içeriğiyle uyuşmuyor.')

content_ids = set(content_changes)
difficulty_ids = set(difficulty_changes)
category_ids = set(category_changes)
no_change_ids = set(no_change)
if content_ids & difficulty_ids:
    fail('İçerik ve zorluk değişiklikleri aynı ID üzerinde olmamalı.')
action_ids = content_ids | difficulty_ids | category_ids
if action_ids & no_change_ids:
    fail('Değişiklik ve noChange kümeleri çakışıyor.')
if action_ids | no_change_ids != set(audit_by_id):
    fail('Manifest 122 audit hedefini eksiksiz partition etmiyor.')
if len(action_ids) != 81:
    fail(f'Beklenen 81 değişecek soru yerine {len(action_ids)} bulundu.')

before = copy.deepcopy(questions)
before_by_id = {item['id']: item for item in before}

for qid, change in content_changes.items():
    item = by_id[qid]
    expected = audit_by_id[qid]
    for field in AUDIT_FIELDS:
        if item.get(field) != expected.get(field):
            fail(f'{qid}: içerik düzeltmesi ön koşulu başarısız ({field}).')
    item['question'] = change['question']
    item['options'] = list(change['options'])
    item['answerIndex'] = int(change['answerIndex'])
    item['explanation'] = change['explanation']

for qid, change in difficulty_changes.items():
    item = by_id[qid]
    if item.get('difficulty') != change['from']:
        fail(f"{qid}: zorluk beklenen {change['from']} değil.")
    item['difficulty'] = change['to']

for qid, change in category_changes.items():
    item = by_id[qid]
    if item.get('categoryIndex') != change['from']:
        fail(f"{qid}: kategori beklenen {change['from']} değil.")
    item['categoryIndex'] = int(change['to'])

for qid in sorted(action_ids):
    item = by_id[qid]
    options = item.get('options')
    if not isinstance(options, list) or len(options) != 4:
        fail(f'{qid}: tam 4 seçenek bulunmalı.')
    if any(not str(option).strip() for option in options):
        fail(f'{qid}: boş seçenek bulundu.')
    if len({normalized(option) for option in options}) != 4:
        fail(f'{qid}: seçenekler birbirinden farklı değil.')
    answer = item.get('answerIndex')
    if not isinstance(answer, int) or answer not in (0, 1, 2, 3):
        fail(f'{qid}: answerIndex geçersiz.')
    if item.get('difficulty') not in VALID_DIFFICULTIES:
        fail(f'{qid}: zorluk geçersiz.')
    category_index = item.get('categoryIndex')
    if not isinstance(category_index, int) or category_index not in CATEGORY_NAMES:
        fail(f'{qid}: kategori geçersiz.')
    if not str(item.get('question', '')).strip() or not str(item.get('explanation', '')).strip():
        fail(f'{qid}: soru veya açıklama boş.')

changed_ids = {qid for qid in by_id if by_id[qid] != before_by_id[qid]}
if changed_ids != action_ids:
    extra = sorted(changed_ids - action_ids)
    missing = sorted(action_ids - changed_ids)
    fail(f'Değişen ID kümesi beklenenden farklı. Fazla={extra}, eksik={missing}')

for qid in no_change_ids:
    if by_id[qid] != before_by_id[qid]:
        fail(f'{qid}: noChange kaydı değiştirildi.')

for qid in set(by_id) - action_ids:
    if by_id[qid] != before_by_id[qid]:
        fail(f'{qid}: kapsam dışı soru değiştirildi.')

pubspec_text = PUBSPEC.read_text(encoding='utf-8')
old_version_line = f"version: {manifest['expectedVersion']}"
new_version_line = f"version: {manifest['targetVersion']}"
if pubspec_text.count(old_version_line) != 1:
    fail(f'pubspec beklenen sürüm satırını tam bir kez içermiyor: {old_version_line}')
if new_version_line in pubspec_text:
    fail('Hedef sürüm pubspec içinde zaten mevcut; tekrar uygulama durduruldu.')

new_questions_text = canonical_json(questions)
post_sha = sha256_bytes(new_questions_text.encode('utf-8'))
QUESTIONS.write_text(new_questions_text, encoding='utf-8')
PUBSPEC.write_text(pubspec_text.replace(old_version_line, new_version_line, 1), encoding='utf-8')

lines = [
    '# Bilgi Rotası — Bekleyen Soru Geri Bildirimi Çözüm Raporu',
    '',
    '- Tarih: 21 Ağustos 2026',
    f"- Kaynak sürüm: `{manifest['expectedVersion']}`",
    f"- Hedef sürüm: `{manifest['targetVersion']}`",
    f"- Kaynak soru bankası SHA-256: `{source_sha}`",
    f"- Yeni soru bankası SHA-256: `{post_sha}`",
    f"- Sheet olay sayısı: **{counts['sheetEvents']}**",
    f"- Benzersiz soru: **{counts['uniqueQuestions']}**",
    f"- İçerik/şık düzeltmesi: **{counts['contentFixes']}**",
    f"- Zorluk düzeltmesi: **{counts['difficultyFixes']}**",
    f"- Kategori düzeltmesi: **{counts['categoryFixes']}**",
    f"- Değişiklik gerektirmeyen: **{counts['noChange']}**",
    '',
    '## İçerik ve şık düzeltmeleri',
    '',
    '| ID | Yeni soru | Doğru cevap | Kategori | Zorluk |',
    '|---|---|---|---|---|',
]
for qid in sorted(content_ids):
    item = by_id[qid]
    answer = item['options'][item['answerIndex']]
    lines.append(f"| `{qid}` | {item['question'].replace('|', '/')} | {str(answer).replace('|', '/')} | {CATEGORY_NAMES[item['categoryIndex']]} | {item['difficulty']} |")

lines += ['', '## Zorluk düzeltmeleri', '', '| ID | Önce | Sonra |', '|---|---|---|']
for qid in sorted(difficulty_ids):
    change = difficulty_changes[qid]
    lines.append(f"| `{qid}` | {change['from']} | {change['to']} |")

lines += ['', '## Kategori düzeltmeleri', '', '| ID | Önce | Sonra |', '|---|---|---|']
for qid in sorted(category_ids):
    change = category_changes[qid]
    lines.append(f"| `{qid}` | {CATEGORY_NAMES[change['from']]} | {CATEGORY_NAMES[change['to']]} |")

lines += ['', '## Değişiklik gerektirmeyen kayıtlar', '', ', '.join(f'`{qid}`' for qid in sorted(no_change_ids)), '']
lines += [
    '## Sheet kapanış kapısı',
    '',
    'Bu rapor Sheet satırlarını kapatmaz. İlgili satırlar ancak bu soru bankası değişiklikleri merge edilip yeni AAB/Play dağıtımı doğrulandıktan sonra `Düzeltildi` veya `İşlem dışı` olarak kapatılacaktır.',
    '',
]
REPORT.write_text('\n'.join(lines), encoding='utf-8')

print('RESOLUTION_GATE=PASS')
print(f'CHANGED_UNIQUE_QUESTIONS={len(changed_ids)}')
print(f'CONTENT_FIXES={len(content_ids)}')
print(f'DIFFICULTY_FIXES={len(difficulty_ids)}')
print(f'CATEGORY_FIXES={len(category_ids)}')
print(f'NO_CHANGE={len(no_change_ids)}')
print(f'QUESTION_BANK_SHA256_BEFORE={source_sha}')
print(f'QUESTION_BANK_SHA256_AFTER={post_sha}')
print(f'TARGET_VERSION={manifest["targetVersion"]}')
