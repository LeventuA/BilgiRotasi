# Kelime Avı — Codex Öncesi Hazırlık Tamamlandı

**Tarih:** 27 Ağustos 2026

Branch: `feat/kelime-avi-gameplay-v1-20260826`

## Tamamlanan hazırlıklar

1. Release → gameplay bağlayıcı checkpoint oluşturuldu.
2. Bölüm 1 canonical grid ve seçim koordinatları QA ile kilitlendi.
3. Bölüm 1 production UI sözleşmesi kilitlendi.
4. Gameplay flow / edge-case sözleşmesi kilitlendi.
5. Codex için 50 maddelik acceptance gate tanımlandı.
6. Bölüm 2–10 starter content production öncesi QA'dan geçirildi.

## Codex'in ilk okuyacağı gameplay belgeleri

- `docs/project-memory/checkpoints/KELIME_AVI_RELEASE_TO_GAMEPLAY_20260827.md`
- `docs/kelime-avi/BOLUM_1_GAMEPLAY_QA.md`
- `docs/kelime-avi/BOLUM_1_PRODUCTION_UI_CONTRACT.md`
- `docs/kelime-avi/BOLUM_1_GAMEPLAY_FLOW_CONTRACT.md`
- `docs/kelime-avi/BOLUM_1_CODEX_ACCEPTANCE.md`

## Bölüm 2–10 QA notu

- Teknik olarak tüm target/bonus kelimeler çözülebilir.
- Bölüm 8 `TOP` iki fiziksel hatta bulunuyor.
- Bölüm 9 bonus `AY` beş fiziksel hatta bulunuyor.
- Bölüm 2–10 içerikleri ağırlıklı olarak satır başı yatay kelimelerden oluşuyor; production zorluk çeşitliliği ayrıca iyileştirilecek.
- Bu bulgular Bölüm 1 implementation'ını bloklamaz ve Codex ilk slice'ta Bölüm 2–10 grid'lerini değiştirmemelidir.

## Sıradaki gerçek adım

Codex, mevcut branch üzerinde yalnız **Bölüm 1 production gameplay** implementation'ını yapacak. Commit/PR öncesi `BOLUM_1_CODEX_ACCEPTANCE.md` formatında rapor verecek; merge yapmayacak.
