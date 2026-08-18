# Bilgi Rotası — Açık PR Temizliği — 18 Ağustos 2026

**Canlı release başlangıcı:** `9e51728889e67efd60dc96c4ea9a2f8cd627c289`

Amaç açık PR listesini tarihsel/stale işlerden arındırmak; branch ve Git geçmişi silinmemiştir.

## Bu gece kapatılan kesin superseded/geçici PR'lar

### PR #52 — `ci: produce fresh closed-test AAB checkpoint`
- **KAPATILDI / MERGE EDİLMEDİ.**
- Kendi PR açıklamasında zaten merge edilmeyeceği ve yalnız `1.68.16+106` artifact checkpoint'i üretmek için geçici tetikleyici olduğu yazılıydı.
- `+106` Play kapalı testte yayımlandı ve yeni `+107` hattı ayrı PR #59 ile yürütülüyor; aktif release değişikliği değildir.

### PR #46 — `docs: record Live Duel cutover merge`
- **KAPATILDI / MERGE EDİLMEDİ.**
- Yalnız eski cutover ara durumunu belgeleyen docs PR'ıydı; listedeki APPLY/index/Functions aşamaları sonradan yürütüldü ve q1214 recovery / PR #54 sonrasındaki gerçek durum tarafından superseded edildi.
- Stale ara durumun release proje hafızasına yanlışlıkla geri taşınmasını engellemek için kapatıldı.

### PR #15 — `feat: pseudonymous oyuncu kullanım analitiği ekle`
- **KAPATILDI / MERGE EDİLMEDİ.**
- Eski stacked base üzerinde ve artık geçersiz ilk-açılış Analytics popup davranışını içeriyordu.
- Güncel Analytics/consent davranışı release üzerinde daha yeni çalışma ve PR #57 tarafından belirlenmiştir: otomatik ilk-açılış Analytics popup'ı yok, Analytics varsayılan kapalı, opt-in Ayarlar üzerinden.
- Eski PR'ın tekrar merge edilmesi güncel kararı geriye götürme riski taşıyordu.

## Açık bırakılan PR'lar

### PR #7 — release → main şemsiye
- **AÇIK / DRAFT KALSIN.**
- Gövdesi ve başlığı stale değerler taşısa da kanonik release branch'i bu PR'ın head'idir.
- Üretim/main entegrasyonu için ayrı bilinçli karar gerekir; gece kapatılmadı/merge edilmedi.

### PR #12 — deterministik 3B tahta geometri önizlemesi
- **AÇIK / DRAFT KALSIN.**
- Kullanıcı görsel kararı ve 8 rozet / 6 fiziksel pozisyon eşlemesi çözülmeden ilerlememeli.
- Bu gece dokunulmadı.

### PR #13 — eski rewarded sonuç reklamı PR'ı
- **AÇIK / DRAFT, DOĞRULANACAK.**
- Eski ve çatışmalı büyük PR; ürün kararının önemli parçaları daha sonraki #25/#48/#50 ve güncel release'e taşınmış olabilir.
- Fakat 18 commit içerdiğinden unique değişiklik kalıp kalmadığı exact diff/commit karşılaştırması yapılmadan kapatılmadı. Merge edilmemeli.

### PR #53 — read-only rewarded claim state
- **AÇIK / DRAFT KALSIN, MERGE YOK.**
- `getRewardedGameState(gameId)` caller-scoped salt-okuma değişikliği faydalı olabilir; ancak base `2976...` ile eski ve tek başına XP reconciliation çözmez.
- Güncel release üzerinde yeniden tasarım/rebase/reimplementation sonrası değerlendirilmeli.

### PR #56 — Live Duel post-match docs checkpoint
- **AÇIK / DRAFT.**
- Runtime değil; #55 merge ve fiziksel kabul borcunu belgeleyen checkpoint.
- #58 ve overnight checkpoint ile belge konsolidasyonu yapılmadan kapatılmadı.

### PR #58 — first-run opt-in docs checkpoint
- **AÇIK / DRAFT.**
- PR #57 merge kanıtını taşıyor; fiziksel +107 kabulü sonrası tek kanonik docs kapanışına konsolide edilebilir.

### PR #59 — `1.68.17+107`
- **AKTİF.**
- Kullanıcının clean-only ön merge onayı var; exact current-head CI ve tam kanıt paketi temiz olmadan merge edilmeyecek.

## Branch temizliği

Bu gece branch silinmedi. Kapatılmış PR branch'leri tarihsel geri dönüş/forensics için korunuyor. Branch silme ancak release stabilizasyonundan sonra ayrı temizlikte yapılmalıdır.

## Sonraki temizlik

1. +107 fiziksel kabul sonrası #56/#58/overnight docs kayıtlarını tek kanonik proje-hafızası PR'ında birleştir.
2. #13'ün release'e göre exact patch/commit farkını analiz et; unique değer yoksa superseded olarak kapat.
3. #53'ü yeni rewarded XP mimarisiyle temiz güncel branch'e taşı; eski branch'i sonra kapat.
4. #7 gövdesini güncel sürüm/release kanıtına göre yalnız main entegrasyonu gerçekten gündeme geldiğinde yenile.
