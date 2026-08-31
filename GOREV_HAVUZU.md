# Bilgi Rotası — Görev Havuzu

**Canlı dosya başlangıç durumu:** 1 Eylül 2026 tarihinde canlı GitHub reposunda bu dosya bulunamadı. Bu kayıt yalnız doğrulanmış mevcut Kelime Avı görevini yeniden kurar; daha eski görev havuzunun kanonik geçmişi **DOĞRULANACAK**.

## Aktif görev — Kelime Avı V6 gameplay görsel hizalama

**Durum:** TEKNİK QA PASS / KULLANICI GÖRSEL KABULÜ AÇIK

**Parent çalışma:** PR #161 — `feat/kelime-avi-v5-reference-assets-integration-20260831`

**Ürün branch:** `fix/kelime-avi-v6-visual-found-state-20260901`

**Ürün commit:** `e62314cb5874f6b290c70a59061255440c6f00e9` — `fix(kelime-avi): productize verified V6 cell visuals`

**Draft PR:** #162 — `fix(kelime-avi): productize Android-verified V6 cell visuals`

### Kapsam

- Canonical gameplay grid 8×8 / 64 hücre korunacak.
- V5 locked reference asset SHA sözleşmesi değişmeyecek.
- Gameplay hücre aralığı, hücre görsel ölçeği ve found-state sunumu gerçek Android runtime hedefiyle hizalanacak.
- Engine, path, scoring, timer, progression, içerik, `assets/questions.json` ve `lib/main.dart` bu görevde değişmeyecek.

### Bitti ölçütü

1. Ürün diffinde canonical 8×8/64 sözleşmesi bozulmamış olacak. **PASS**
2. `dart analyze lib/word_hunt` temiz olacak. **PASS**
3. Focused Kelime Avı testleri geçecek. **138/138 PASS**
4. Android API 36 / 1080×1920 / 420 dpi raw runtime initial ekranı üretilecek. **PASS**
5. Gerçek gesture ile B10 `0/9 → 1/9` found-state üretilecek. **PASS**
6. Android’de koşan dosya ile ürün commitindeki dosya blob’u birebir aynı olacak. **PASS — `d415876b1311362a8de6220cfcfe2978fce514dd`**
7. Raw initial ve found-state görüntüleri Levent tarafından görsel olarak kabul edilecek. **AÇIK**
8. `ERROR_STATE_VISUAL` ve `REFERENCE_FONT` belirsizlikleri çözülecek veya ayrıca açıkça ertelenecek. **DOĞRULANACAK**
9. B5 60s / B10 120s gerçek insan süre-zorluk playtesti tamamlanacak veya ayrıca açıkça ertelenecek. **AÇIK**
10. PR Ready/merge kararı ayrı verilecek; Levent’in açık merge onayı olmadan merge yapılmayacak. **AÇIK**

### Kanıt

- Productization run: `33443015882` — SUCCESS.
- Android 16 raw proof run: `33436607792` — SUCCESS.
- Android artifact: `9775000736`.
- YOL semantic visual gate: PASS; başarılı swipe süresi 1800 ms.
