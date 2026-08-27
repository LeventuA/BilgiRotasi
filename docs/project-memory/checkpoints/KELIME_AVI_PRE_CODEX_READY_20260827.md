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
7. Kullanıcı kararıyla target/bonus kelimelerde minimum 3 harf kuralı bağlayıcı hale getirildi.
8. Bölüm 8 `TOP` duplicate occurrence giderildi: `TAKIMI → RAKİBİ`.
9. Bölüm 9 iki harfli `AY` bonusu kaldırıldı; tek hatlı `ROKET` bonusu kullanılıyor.

## Codex'in ilk okuyacağı gameplay belgeleri

- `docs/project-memory/checkpoints/KELIME_AVI_RELEASE_TO_GAMEPLAY_20260827.md`
- `docs/project-memory/checkpoints/KELIME_AVI_PRE_CODEX_READY_20260827.md`
- `docs/kelime-avi/BOLUM_1_GAMEPLAY_QA.md`
- `docs/kelime-avi/BOLUM_1_PRODUCTION_UI_CONTRACT.md`
- `docs/kelime-avi/BOLUM_1_GAMEPLAY_FLOW_CONTRACT.md`
- `docs/kelime-avi/BOLUM_1_CODEX_ACCEPTANCE.md`
- `docs/kelime-avi/BASLANGIC_LIMANI_CONTENT_QA_RESOLUTION_20260827.md`

## Bölüm 2–10 QA güncel durumu

- Teknik olarak tüm target/bonus kelimeler çözülebilir.
- Bütün target/bonus kelimeler artık en az 3 harftir.
- Bölüm 8 `TOP` artık yalnız tek fiziksel hatta bulunur.
- Bölüm 9 bonusu artık `ROKET` ve tek fiziksel hatta bulunur.
- Önceki `TOP`/`AY` bulguları **RESOLVED** durumundadır.
- Bölüm 2–10 içerikleri hâlâ ağırlıklı olarak satır başı yatay kelimelerden oluşuyor; production zorluk/8-yön çeşitliliği ayrıca iyileştirilecek.
- Bu kalan çeşitlilik işi Bölüm 1 implementation'ını bloklamaz.

## Sıradaki gerçek adım

Codex, mevcut branch üzerinde yalnız **Bölüm 1 production gameplay** implementation'ını yapacak. Commit/PR öncesi `BOLUM_1_CODEX_ACCEPTANCE.md` formatında rapor verecek; merge yapmayacak.
