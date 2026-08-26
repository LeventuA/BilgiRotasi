# Kelime Avı Asset-First Pilot — 24 Ağustos 2026

## Canlı başlangıç

- Repo: `ZMilaStudio/BilgiRotasi`
- Kaynak PR: #110
- Kaynak branch: `fix/kelime-avi-approved-reference-pixel-match-20260823`
- Kaynak exact HEAD: `bc8a03bfefd401570e0c51cc4aab4206ea45d363`
- Sürüm: `1.68.19+109`
- Yeni çalışma branch'i: `feat/kelime-avi-baslangic-limani-asset-first-20260824`

## Bağlayıcı standart

PR #131 içindeki `görsel oyun üretimstandartı.md` tamamen okundu ve bu pilot için bağlayıcı kabul edildi.

Ana kural:

`REFERENCE → PRODUCTION-READY LAYERED ASSETS → THIN INTERACTION CODE`

## Korunacaklar

- 1080×1920 canonical coordinate-space
- tek scene transform
- 1–10 koordinatları ve route geometry
- progression/unlock
- interaction
- davranışsal/regresyon testleri

## Final çözüm sayılmayacaklar

- `_FinalCrownPainter`
- `_TreasureChestPainter`
- `_FantasyPlaquePainter`
- premium final-art için benzeri procedural painter yaklaşımı

## İlk pilot

Yalnız Başlangıç Limanı production asset yaklaşımıyla tamamlanacak. Diğer paket/temalara kullanıcı görsel kabulünden önce geçilmeyecek.

## İlk commitler

- `8334bffef405c282e2e7c40041ee5606267e5bd6` — `docs: start Kelime Avi asset-first pilot checkpoint`
- `cf5b4848ac2ea8f19b0c7f9e492b5b8950436180` — `docs: define Baslangic Limani production asset contract`

## İlk diff doğrulaması

Kaynak PR #110 branch'ine göre branch 2 commit önde / 0 gerideydi ve ilk diff yalnız iki yeni dokümantasyon dosyası içeriyordu. Bu checkpoint üçüncü docs commit'idir.

## Açık kapılar

- MASTER ART'tan gerçek transparan production asset üretimi.
- Asset-backed widget entegrasyonu.
- Procedural premium-art final render yolunun kaldırılması.
- Exact-head focused/tam test/analyze.
- Android gerçek screenshot ve referans yan yana inceleme.
- Levent nihai görsel kabulü.
- Levent ayrıca açık merge onayı vermeden merge yok.
