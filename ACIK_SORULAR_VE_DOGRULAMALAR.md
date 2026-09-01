# Bilgi Rotası — Açık Sorular ve Doğrulamalar

**Son güncelleme:** 1 Eylül 2026

## Kelime Avı V6

Kapanan görsel kabul kapıları:
- `USER_VISUAL_ACCEPTANCE_INITIAL` — Raw Android 16 B10 initial görüntüsü Levent görsel kabulü: **PASS / KAPANDI — 1 Eylül 2026**.
- `USER_VISUAL_ACCEPTANCE_FOUND` — Raw Android 16 B10 `YOL / 1/9` edge-fuse found-state Levent görsel kabulü: **PASS / KAPANDI — 1 Eylül 2026**.
- Kanıt run: `33486609120` — SUCCESS; artifact `9792346079`; exact tested blob `f43deaad5328f6263f9479de1738cc1f4ac465e0`.

Açık kalanlar:
- `ERROR_STATE_VISUAL` — Hatalı seçim durumunun referansla görsel eşleşmesi: **DOĞRULANACAK**.
- `REFERENCE_FONT` — Referanstaki exact font ailesi/weight sözleşmesi: **DOĞRULANACAK**.
- `B5_60S_HUMAN_PLAYTEST` — Gerçek insan süre-zorluk dengesi: **AÇIK**.
- `B10_120S_HUMAN_PLAYTEST` — Gerçek insan süre-zorluk dengesi: **AÇIK**.
- `PR_161_READY_DECISION` — Parent V5 integration PR #161 Ready kararı: **AÇIK**.
- `PR_162_READY_DECISION` — V6 visual PR #162 Ready kararı: **AÇIK**.
- `PR_163_READY_DECISION` — Edge-fuse PR #163 Ready kararı: **AÇIK**.
- `PRODUCTION_MAIN_NAVIGATION` — `lib/main.dart` production ana navigasyon entegrasyonu ayrı scope: **AÇIK**.

Kaynak konumları doğrulandı:
- Kanonik karar dosyası: `docs/project-memory/KARARLAR.md`.
- Ayrıntılı görev geçmişi: `docs/project-memory/GOREV_HAVUZU.md` + Git geçmişi.
- Ayrıntılı devir: `docs/project-memory/GENEL_PROJE_OZETI.md`.

## Merge güvenliği

PR #161, #162 veya #163, Levent’in ayrı ve açık merge onayı olmadan merge edilmeyecek. Görsel PASS, merge onayı değildir.
