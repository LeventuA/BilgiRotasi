# Kelime Avı — Dynamic Progression Finalization Checkpoint

**Tarih:** 26 Ağustos 2026

## Canlı kaynak

- Repo: `ZMilaStudio/BilgiRotasi`
- PR #132 branch: `feat/kelime-avi-baslangic-limani-asset-first-20260824`
- Sürüm: `1.68.19+109`
- PR #150 merge SHA: `d64fcd4ea63f173c6653ff33926b12a6c99ef37d`
- PR #149 merge SHA: `adb4557a9a95dd624166b6b08a9e0ab27b1e4f80`

## Tamamlanan düzeltme

PR #132 final incelemesinde flattened MASTER ART içindeki demo progression state'inin gerçek runtime state ile çelişebildiği tespit edildi. Draft PR #150 ile bu açık kapatıldı.

Production görünür taban hâlâ Issue #109 MASTER ART raster sahnesidir. Yalnız runtime'da değişen küçük alanlar lokal override alır:

- gerçek `X / 30` toplam yıldız,
- level 1–10 gerçek `0–3` yıldız state'i,
- gerçek locked/open state,
- node 9 open state'i.

İlk dynamic-star denemesi ikinci yıldız satırı oluşturduğu için görsel FAIL kabul edildi. MASTER ART'ın gerçek star-slot pikselleri ölçüldü; generic node-diameter hesabı kaldırıldı. 1–10 için ölçülmüş yıldız yuvaları kullanıldı ve final 10'un büyük yıldız hiyerarşisi ayrı boyutta korundu.

## Progression sözleşmesi

- Level 7 tamamlanınca bonus 8 + normal 9 birlikte açılır.
- Bonus 8, node 9 için zorunlu kapı değildir.
- Node 9 gerçek callback üretir.
- Node 10, node 9 tamamlanmadan locked ve callback üretmez.
- Görünür yıldız/lock state'i interaction/progression gerçeğiyle aynı olmalıdır.

## Android 16 kanıtı

Son kod HEAD'i: `aebb384912d379fc87908e4e79b31aecdaba427b`

- Production run: `32969604847` — SUCCESS
- Artifact: `9607328059`
- Artifact digest: `sha256:a1c01a5acb1c515b584e6cf1d24dea63ece57eaa9417f279f4b52f17e41ef776`
- Focused production progression/route test adımı: PASS
- Android 16 runtime: PASS
- MASTER ART comparison üretimi: PASS
- Node 9 callback: PASS
- Node 10 locked/no callback: PASS
- App process failure taraması: PASS

Artifact screenshot görsel incelemesinde eski demo yıldız kalıntıları temizlenmiş, `21 / 30` ve level state'leri gerçek proof progression ile tutarlı görülmüştür.

## Sözleşme güncellemesi

`docs/kelime-avi/BASLANGIC_LIMANI_PRODUCTION_ASSET_CONTRACT.md` artık bağlayıcı production mimarisini açıkça şöyle tanımlar:

`MASTER ART RASTER → TRANSPARENT INTERACTION HITBOXES → MINIMUM LOCAL STATE OVERRIDES`

Eski tamamen-layered scene/node/plaque üretim zorunluluğu Başlangıç Limanı için supersede edilmiştir.

## Merge zinciri

- PR #150 → PR #132 feature branch: MERGED (`d64fcd4e...`).
- PR #149 → PR #132 feature branch: MERGED (`adb4557a...`).
- PR #132 → üst hedef: HENÜZ MERGE EDİLMEDİ.

## Kalan tek final kapı

PR #132'nin yeni exact HEAD'i üzerinde:

1. focused test + analyze + `git diff --check`,
2. Android 16 production route proof,
3. crash/ANR/FATAL/process-death taraması,
4. final production screenshot/artifact incelemesi,
5. açık kullanıcı PR #132 merge onayı

tamamlanmadan PR #132 merge edilmez.
