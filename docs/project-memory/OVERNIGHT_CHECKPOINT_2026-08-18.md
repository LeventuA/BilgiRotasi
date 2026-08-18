# Bilgi Rotası — Overnight Checkpoint — 18 Ağustos 2026

Bu dosya, bağlantı kopması veya sohbet devri durumunda 18 Ağustos gecesi yapılan işleri tekrar etmemek için güvenli checkpoint olarak tutulur. Teknik kaynak yine canlı GitHub ve ilgili canlı servislerdir.

## Başlangıç kilidi

- Kanonik release: `release/final-closed-test-aab-1.68.8`
- Başlangıç release HEAD: `9e51728889e67efd60dc96c4ea9a2f8cd627c289`
- Başlangıç sürümü: `1.68.16+106`
- PR #57 bu HEAD ile release'e merge edilmişti.
- Kullanıcı, `1.68.17+107` sürüm bump PR'ı temiz ve CI yeşil olursa merge için önceden açık onay verdi.

## Gece planı

1. `1.68.17+107` sürüm branch/PR, CI, diff, log, artifact; temizse merge.
2. Yeni build sonrası iki cihazlık Canlı Düello + reklam + bildirim first-run kabul planı hazırlama.
3. Rewarded `serverRewardXp` ↔ local XP idempotent reconciliation mimarisi tasarlama; merge/deploy yok.
4. Tüm oyun modlarında `SupportRewardCard` kapsamını canlı koddan sıralama.
5. Soru kalite düzeltmesi için ayrı sohbette kullanılacak güvenli görev komutu hazırlama; bu branch'te `assets/questions.json` değişmeyecek.
6. Açık PR/branch temizliği ve stale/riskli işlerin sınıflandırılması.
7. Production başvurusu dışında kalan yayın hazırlık açıklarını değerlendirme; production Firebase/SSV/AdMob deploy yok.

## Uygulanan ilk adım

- Branch: `release/closed-test-1.68.17-107`
- Base SHA: `9e51728889e67efd60dc96c4ea9a2f8cd627c289`
- Commit: `2079d3ccf5bd08bfaed90fa2a5c0f8371e80b8d2`
- Commit adı: `chore: bump closed-test version to 1.68.17+107`
- Diff: yalnız `pubspec.yaml`, `1.68.16+106` → `1.68.17+107`.
- Merge durumu: henüz merge edilmedi; CI ve tam inceleme bekleniyor.

## Güvenlik sınırı

- `main` veya kanonik release'e doğrudan yazma yok.
- Production Firebase/SSV deploy yok.
- Play Console yükleme/yayın yok.
- Production gerçek AdMob açılışı yok.
- `assets/questions.json`, BoardMap, 67 node, 3B ve canlı oyun mantığına bu geceki sürüm bump işi kapsamında dokunulmaz.
