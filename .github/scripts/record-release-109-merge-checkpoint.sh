#!/usr/bin/env bash
set -euo pipefail

BASE='b0240a7a4009c41326f459a37b8bedeab080d8d8'
BRANCH='docs/record-109-merge-final-20260821'

git fetch origin release/final-closed-test-aab-1.68.8
test "$(git rev-parse origin/release/final-closed-test-aab-1.68.8)" = "$BASE"
git checkout --detach "$BASE"
grep -Fxq 'version: 1.68.19+109' pubspec.yaml

python3 - <<'PY'
from pathlib import Path

def prepend(path_str, heading, body):
    p = Path(path_str)
    text = p.read_text()
    if heading in text:
        raise SystemExit(f'checkpoint already exists: {heading}')
    first = text.find('\n')
    if first < 0:
        raise SystemExit(f'no title: {path_str}')
    block = heading + '\n\n' + body.strip() + '\n\n---\n\n'
    p.write_text(text[:first+1] + '\n' + block + text[first+1:].lstrip('\n'))

prepend('docs/project-memory/BILGI_ROTASI_DURUM.md',
  '## 0N. 1.68.19+109 AdMob/UMP release merge checkpoint — 21 Ağustos 2026', r'''
- Kanonik release `release/final-closed-test-aab-1.68.8` exact `b0240a7a4009c41326f459a37b8bedeab080d8d8`; sürüm `1.68.19+109`.
- PR #88 final head `1999a049018b5d23eeda59b0b9d2e0e435cf0a64`, Levent'in açık onayı sonrası expected-head ile squash merge edildi; merge SHA `b0240a7a4009c41326f459a37b8bedeab080d8d8`.
- Merge yalnız `lib/ad_monetization.dart`, `lib/app_build_info.dart`, `pubspec.yaml`, `test/ad_monetization_diagnostics_test.dart`, `test/admob_ump_fallback_test.dart` dosyalarını değiştirdi. `assets/questions.json` +108 ve +109'da aynı blob SHA `b19956972c05bdc58e6b9a0c010a407e6c05613f`; +108'deki 81 gerçek soru düzeltmesi korundu.
- Pre-commit run/job `32481091014` / `96767404086`: focused 42/42, tüm Flutter 301/301, analyze non-fatal policy, diff check PASS; artifact ID `9446124898`, digest `sha256:3c9e11123a9203ba1efce156044e72a3cab2a3b8f116f04ab08cb1d26df60c17`.
- Exact-head run/job `32481746889` / `96769404446`: SUCCESS; signing, release APK, package/manifest ve Android 16 app gate PASS. Artifact ID `9446694140`, digest `sha256:c6615ba1ad6ad80137af0218759fa99f946c78554c7ae54100c779a340abfa9a`; APK SHA-256 `0b9cf5e0b3a9568ea4424818cb4162f677bab3ade4fd214e6dc4d6bcdcefb376`; package `com.leventua.bilgirotasi`, versionCode 109, versionName 1.68.19, targetSdk 36, signer SHA-1 `26:3C:70:7C:FE:2E:2E:52:62:52:C3:8E:9B:AB:59:79:8C:FF:81:94`. App-specific crash/ANR/FATAL yok.
- Fiziksel production: banner PASS, rewarded PASS, AdMob Verify URL PASS, SSV selective redeploy PASS, açık cutover sonrası `ssvEnabled=true` readback PASS, gerçek rewarded -> SSV claim -> +10 XP PASS.
- `KARARLAR.md` değişmedi.
- Açık: fiziksel no-double; yarım/başarısız reklamda hak/retry; farklı oyunlarda toplam kota yok; merge SHA'dan production +109 AAB doğrulaması; Play +109 upload/install/rollout.
''')

prepend('docs/project-memory/GOREV_HAVUZU.md',
  '## 0M - 21 Ağustos 2026 / 1.68.19+109 merge ve yayın kapıları', r'''
- **Durum:** PR #88 MERGED / release `b0240a7a4009c41326f459a37b8bedeab080d8d8` / `1.68.19+109` / +108 soru bankası korundu / UMP-AdMob + SSV tek gerçek +10 XP PASS / Play yükleme açık.

**Bitti ölçütü:**
- [x] Exact +108 tabanı ve soru bankası koruması doğrulandı.
- [x] Fiziksel banner + rewarded PASS.
- [x] AdMob Verify URL, SSV selective redeploy, açık cutover/readback ve gerçek +10 XP PASS.
- [x] Pre-commit 42/42 focused, 301/301 tüm Flutter, analyze/diff PASS.
- [x] PR #88 exact-head CI, signing/package/manifest ve Android 16 app gate PASS.
- [x] Levent açık merge onayı ve expected-head squash merge PASS.
- [ ] Aynı `gameId` fiziksel no-double PASS.
- [ ] Yarım/başarısız reklam ödül vermez; hak korunur ve retry PASS.
- [ ] Farklı tamamlanan oyunlarda günlük/oturumluk toplam kota yok — fiziksel PASS.
- [ ] Exact merge SHA'dan production `1.68.19+109` AAB; package/version/signing/production AdMob+Firebase profil doğrulaması.
- [ ] Doğrulanmış +109 AAB Play Console upload/install/rollout kabulü.

Kanıt: ürün head `1999a049018b5d23eeda59b0b9d2e0e435cf0a64`; merge `b0240a7a4009c41326f459a37b8bedeab080d8d8`; run/job `32481746889` / `96769404446`; artifact ID `9446694140`; APK SHA `0b9cf5e0b3a9568ea4424818cb4162f677bab3ade4fd214e6dc4d6bcdcefb376`.
''')

prepend('docs/project-memory/ACIK_SORULAR_VE_DOGRULAMALAR.md',
  '## 1.68.19+109 merge sonrası canlı kabul — AÇIK', r'''
- PR #88 squash merge edildi; release exact `b0240a7a4009c41326f459a37b8bedeab080d8d8`, sürüm `1.68.19+109`.
- `assets/questions.json` +108/+109 blob SHA aynı: `b19956972c05bdc58e6b9a0c010a407e6c05613f`.
- Exact-head CI `32481746889` / `96769404446` SUCCESS; Android 16 app gate PASS; artifact ID `9446694140`; APK SHA `0b9cf5e0b3a9568ea4424818cb4162f677bab3ade4fd214e6dc4d6bcdcefb376`.
- Fiziksel gerçek banner/rewarded/SSV +10 XP tek kabul PASS.
- **DOĞRULANACAK:** aynı `gameId` ikinci +10 XP vermez.
- **DOĞRULANACAK:** yarım/başarısız reklamda ödül yok, hak korunur ve yeniden denenebilir.
- **DOĞRULANACAK:** farklı tamamlanan oyunlarda toplam günlük/oturum kotası yok.
- **DOĞRULANACAK:** merge SHA'dan production +109 AAB; package/version/signing ve gerçek AdMob+Firebase production profili.
- **DOĞRULANACAK:** Play Console +109 upload, Play kurulumu ve rollout/public kabul.
''')

checkpoint = Path('docs/project-memory/checkpoints/RELEASE_109_MERGE_20260821.md')
checkpoint.parent.mkdir(parents=True, exist_ok=True)
checkpoint.write_text(r'''# Bilgi Rotası 1.68.19+109 merge checkpointi

- Release: `b0240a7a4009c41326f459a37b8bedeab080d8d8` / `1.68.19+109`
- PR #88: merged (squash)
- Product head: `1999a049018b5d23eeda59b0b9d2e0e435cf0a64`
- Pre-commit run/job: `32481091014` / `96767404086`
- Exact-head run/job: `32481746889` / `96769404446`
- Artifact: ID `9446694140`, digest `sha256:c6615ba1ad6ad80137af0218759fa99f946c78554c7ae54100c779a340abfa9a`
- APK SHA-256: `0b9cf5e0b3a9568ea4424818cb4162f677bab3ade4fd214e6dc4d6bcdcefb376`
- Questions blob before/after: `b19956972c05bdc58e6b9a0c010a407e6c05613f`
- Physical: banner PASS, rewarded PASS, Verify URL PASS, SSV cutover/readback PASS, +10 XP PASS.
- Open: no-double; failed/aborted retry; different-game no-total-quota; production AAB; Play +109 upload/install/rollout.
- `KARARLAR.md`: unchanged.
''')
PY

git diff --check
git diff --exit-code "$BASE" -- assets/questions.json lib/ad_monetization.dart lib/app_build_info.dart pubspec.yaml test/ad_monetization_diagnostics_test.dart test/admob_ump_fallback_test.dart
test "$(git diff --name-only | grep -v '^docs/project-memory/' | wc -l)" -eq 0

git add \
  docs/project-memory/BILGI_ROTASI_DURUM.md \
  docs/project-memory/GOREV_HAVUZU.md \
  docs/project-memory/ACIK_SORULAR_VE_DOGRULAMALAR.md \
  docs/project-memory/checkpoints/RELEASE_109_MERGE_20260821.md

git diff --cached --check
test "$(git diff --cached --name-only | grep -v '^docs/project-memory/' | wc -l)" -eq 0

git config user.name 'github-actions[bot]'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
git checkout -b "$BRANCH"
git commit -m 'docs: record 1.68.19+109 merge and validation'
git push origin HEAD:refs/heads/$BRANCH
