# Bilgi Rotası - Görev Havuzu

> 30 Ağustos 2026 aktif kesimidir. Eski tam görev kayıtları Git geçmişi ve `docs/project-memory/archive/` altında korunur. Teknik gerçek her zaman canlı GitHub ve ilgili canlı servislerdir.

## 0R - Başlangıç Limanı production MASTER ART mimari kabulü

**Durum:** TAMAMLANDI.

- [x] Issue #109 `Photo 1.jpg` tek bağlayıcı MASTER ART.
- [x] Production MASTER ART raster + şeffaf hitbox mimarisi kabul edildi.
- [x] Dynamic progression state ve callback sözleşmesi doğrulandı.

---

## 0W - Kelime Avı production ana navigasyon entegrasyonu

**Durum:** AÇIK / AYRI KAPSAM + AYRI ONAY GEREKİYOR.

`lib/main.dart` 8×8 starter-content/tema kapsamı değildir.

**Bitti ölçütü:**
- [ ] Levent açık kapsam/onay verir.
- [ ] Canlı hedef branch/release yeniden kilitlenir.
- [ ] Minimum navigation diff ayrı branch/PR üzerinde yapılır.
- [ ] Giriş, reklam, Firebase, BoardMap/67 node ve diğer oyun modları bozulmaz.
- [ ] Analyze/test/Android kabulü PASS.
- [ ] Ayrı açık merge onayı olmadan merge yapılmaz.

---

## 0X - Başlangıç Limanı 8×8 starter-content dönüşümü

**Durum:** TEKNİK GATE TAMAMLANDI / KULLANICI KABULÜ BEKLENİYOR.

- Branch: `feat/kelime-avi-8x8-content-v1-20260829`
- Ürün commit: `052ea7da775db0b58a5ce0c6731a04f251879008`
- Draft PR #158: **OPEN / DRAFT / merged=false / mergeable=true**.
- Final gate run `33251736068`: **SUCCESS**.
- Artifact `9714700778` / `sha256:dfbca264c2f67bb3549a0e336b075c9238f1a0638962dc69392ea8715b9a2092`.

**Bitti ölçütü:**
- [x] 10 bölümün tüm gridleri 8×8.
- [x] 80 toplam target+bonus sözleşmesi korundu.
- [x] Exactly-one occurrence + intended/reverse path doğrulandı.
- [x] Focused 37/37 + full Flutter 442/442 PASS.
- [x] Android16 B1/B5/B8/B10 64/64 görünürlük PASS.
- [x] B5 soft-time + ANKARA + ters BAŞKENT swipe PASS.
- [x] Crash/ANR/FATAL taraması temiz.
- [ ] B5/B10 gerçek insan süre dengesi.
- [ ] Levent nihai 8×8 + tema görünümünü kabul eder.
- [ ] Kullanıcı kabulünden sonra Ready kararı.
- [ ] Ayrıca açık merge onayı.

---

## 0Y - Başlangıç Limanı referans-birebir bölüm içi tema uygulaması

**Durum:** V4 TEKNİK RUNTIME PASS / V4 GÖRSEL RED / REFERANS-BİREBİR YENİDEN UYGULAMA AÇIK.

Canlı branch:
`feat/kelime-avi-baslangic-limani-theme-clean-v1-20260829`

Tarihsel V4 teknik kanıt:
- Run `33278797412`: **SUCCESS**.
- Job `99170289209`.
- B1/B10 build/install/launch, screenshot, UI XML, logcat PASS.
- API36 / 1080×1920 / 420 dpi PASS.
- Crash/ANR/FATAL/am_crash temiz.
- Artifact `9722440135` / `sha256:bf91d7591b4348b3268983f9938a9042631729b8ad7a126c27e6ba35504f3a70`.

Kullanıcı görsel kararı:
- [x] Beş tema adayı içinden 1. görsel seçildi.
- [x] V4 gerçek Android ekranları kullanıcı tarafından **seçilen görsele uzak** bulunarak reddedildi.
- [x] 30 Ağustos'ta yeniden gönderilen Bölüm 10 / Başlangıç Limanı referansı artık **birebir görsel hedef** olarak kilitlendi.
- [x] Yeni sanat yönü / ekstra çizim / yorum / alternatif dekor eklenmemesi kararı kayda alındı.
- [x] Gerçek canonical grid **8×8** kalacak; referansın örnek harf düzeni oyun verisini değiştirmeyecek.

**Bitti ölçütü:**
- [ ] Referanstaki gece limanı arka planı production ekran boyutuna uygun şekilde aynı kompozisyonla uygulanır.
- [ ] Sağ üst deniz feneri + amber ışık huzmesi + su yansıması referansa sadık görünür.
- [ ] Sol liman feneri/detayları ve koyu liman çevresi referansa sadık görünür.
- [ ] Sayaç panelleri koyu lacivert metal + altın trim/rivet görünümüne geçirilir.
- [ ] Hedef/bonus chipleri referanstaki lacivert-altın metal stile geçirilir.
- [ ] 8×8 harf hücreleri referanstaki lacivert-altın beveled tile stile geçirilir.
- [ ] Selection/found yolu sıcak amber glow ile referanstaki görsel dile yaklaşır.
- [ ] Alt bilgi paneli çapa + pusula motifli koyu lacivert-altın stile geçirilir.
- [ ] UI boyutları/konumları gerçek 8×8 ve mevcut gameplay contract ile uyumlu kalır.
- [ ] `word_hunt_path`, scoring, gesture, canonical content ve soft-time değişmez.
- [ ] Korunan alanlar değişmez.
- [ ] Formatter/analyze/tema+regresyon testleri PASS.
- [ ] Android16 B1/B10 build/install/launch PASS.
- [ ] B1/B10 screenshot/UI XML/logcat + crash/ANR taraması PASS.
- [ ] Yeni screenshot referansla yan yana insan gözüyle karşılaştırılır.
- [ ] Levent açıkça “görsel PASS” verir.
- [ ] Ancak bundan sonra clean theme Draft PR açılır/Ready değerlendirilir.
- [ ] Merge yalnız ayrıca açık kullanıcı onayıyla yapılır.

---

## Korunan açık işler

- Soru geri bildirimleri gerçek soru düzeltmesi merge edilmeden kapatılmaz; metin + seçenekler + doğru indeks + açıklama + kategori + zorluk birlikte kontrol edilir.
- Rewarded/SSV fiziksel kabul maddeleri.
- Play/Firebase signing ve canlı production kabul maddeleri.
- İki cihaz Canlı Düello uçtan uca fiziksel kabulü.
- 3B tahta: BoardMap/67 node korunur; 8 konsept rozet / 6 fiziksel rozet eşlemesi çözülmeden ilerlenmez.
- Mağaza/tanıtım varlıklarının canlı Play Console durumu.

## Kaynak koruması

- `assets/questions.json` kontrolsüz değiştirilmez.
- `main` güncel yayın kaynağı varsayılmaz.
- Release/main'e doğrudan yazılmaz.
- Kritik merge için Levent'in açık onayı gerekir.
- Build PASS tek başına çalışma kanıtı değildir.
