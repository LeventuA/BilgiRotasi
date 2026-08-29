# Bilgi Rotası — Kesinleşen Kararlar

> Bu dosya aktif/kanonik karar özetidir. 26 Ağustos 2026 release entegrasyonu öncesindeki iki tam karar dosyası `docs/project-memory/archive/` altında birebir korunur. Burada yazılmayan eski kararlar, açıkça supersede edilmedikçe geçerliliğini korur.

---

## 0A. Kelime Avı / Başlangıç Limanı bağlayıcı görsel kararı

- Issue #109 `Photo 1.jpg`, Başlangıç Limanı rota ekranı için tek bağlayıcı görsel kaynaktır.
- **Levent açık mimari onayı:** production rota görünür tabanı MASTER ART raster olacaktır.
- Level 1–10 ile geri/bilgi/pusula/kitap davranışları şeffaf hitbox'larla gerçek callback/progression akışına bağlanır.
- MASTER ART üzerindeki rota, node, plaque, yıldız, crown, pusula, kitap ve panel sanatı ikinci kez komple Flutter katmanı olarak çizilmez.
- Yalnız runtime oyun state'i MASTER ART'tan gerçekten farklı olduğunda minimum lokal override uygulanır.
- MASTER ART içindeki demo `X/30`, yıldız ve lock state'i gerçek progression'ı temsil etmek zorunda değildir; production ekranda gerçek state lokal override ile gösterilir.
- Level 7 tamamlanınca 8 ve normal 9 birlikte açılır. Bonus 8, node 9 için zorunlu kapı değildir.
- Node 9 callback üretir. Node 10, node 9 tamamlanmadan locked ve callback üretmeyen durumda kalır.
- Bu karar Başlangıç Limanı için önceki “tamamen layered/modüler görünür sahne” şartını **supersede eder**.
- Bu istisna diğer Kelime Avı tema/rotalarına otomatik genellenmez; her yeni rota ayrıca görsel/teknik karar ister.
- PR #146 / `c42a9ff...` ve önceki ChatGPT-generated hedef asset'ler görsel kaynak değildir.

---

## 1. Çalışma ve Git düzeni

- `main` otomatik güncel kabul edilmez; canlı hedef branch ve `pubspec.yaml` işe başlamadan doğrulanır.
- Doğrudan main/release'e rastgele yazılmaz; ayrı branch/PR kullanılır.
- Sıra: **test → commit → push → PR → inceleme → merge**.
- Kritik merge/deploy için Levent'in açık onayı gerekir.
- Build PASS tek başına çalışma kanıtı değildir; log, diff, workflow, test ve Git geçmişi birlikte incelenir.
- `assets/questions.json` kontrolsüz değiştirilmez.
- İlgisiz yerel değişiklikler silinmez; `git reset --hard` rutin çözüm değildir.
- Gizli bilgi, testçi e-postası, parola veya anahtar repoya eklenmez.
- Doğrulanmamış bilgi `DOĞRULANACAK` olarak işaretlenir.
- Uzun teknik işler kısa geri alınabilir checkpoint'lere bölünür; merge öncesi base/head/CI tekrar canlı doğrulanır.

---

## 2. Kalıcı proje hafızası

- Yeni sohbet önce `GENEL_PROJE_OZETI.md`, ardından `BILGI_ROTASI_DURUM.md`, `KARARLAR.md`, `GOREV_HAVUZU.md` ve gerektiğinde açık sorular dosyasını okur.
- `GENEL_PROJE_OZETI.md` her proje yanıtından sonra yalnız gerekli farklarla güncel tutulur.
- Özet canlı GitHub doğrulamasının yerine geçmez.
- Önemli geçmiş silinmez; eski tam kayıtlar Git geçmişi ve `docs/project-memory/archive/` altında korunur.

---

## 3. Ürün/yayın temel kararları

- Uygulama: **Bilgi Rotası**; yayıncı **ZMila Studio**.
- Paket adı: `com.leventua.bilgirotasi`.
- Yeni özellik uğruna çalışan yayın sürümü bozulmaz.
- Play yükleme/yayınlama ayrı açık karar gerektirir; teknik release merge otomatik Play yayını anlamına gelmez.
- Kişisel bilgi mağaza/tanıtım görsellerine girmez.

---

## 4. Kelime Avı ürün kararı

- Kelime Avı Bilgi Rotası içinde Flutter ile geliştirilecektir; Godot runtime bağımlılığı değildir.
- İlk rota/paket Başlangıç Limanı'dır.
- Hedef: 10 bölüm / 30 yıldız ve gerçek rota → bölüm → oyun → sonuç/yıldız → rota döngüsü.
- Production `lib/main.dart` ana navigasyon bağlantısı ayrı geliştirme branch/PR kapsamıdır.
- Başlangıç Limanı kabul edilen görünüm tamamlandıktan sonra oyun geliştirmesine devam edilecek; PR zinciri teknik borç olarak bırakılmayacaktır.

---

## 5. Oyun, reklam ve veri koruma kararları

- Yerel oyun 2–6 oyuncuyu destekler.
- Canlı Düello 10/20/30 soru; ana düello otomatik eşleştirme kullanır; oda kodu ana akış değildir.
- BoardMap ve 67 node / 3B tahta sözleşmesi kontrolsüz değiştirilmez.
- Aktif soru ekranında reklam gösterilmez; kritik oyun/canlı maç akışı reklamla kesilmez.
- Ödüllü reklam kullanıcı isteğiyle açılır; aynı tamamlanmış oyun ikinci ödülü vermez.
- Soru kalitesi sayıdan önce gelir; soru + 4 seçenek + doğru indeks + açıklama + kategori + zorluk birlikte doğrulanır.
- Analytics varsayılan kapalı/açık opt-in ilkesini ve kişisel kimlik göndermeme kararını korur.
- FCM bildirimleri açık kullanıcı opt-in'i olmadan başlatılmaz; production bildirim gönderimi ayrıca karar gerektirir.

---

## 6. Release/CI korunacak kararlar

- Android 16 emülatör altyapı arızası ile gerçek uygulama crash/ANR/FATAL/process-death ayrı sınıflandırılır.
- Uygulama hatası infrastructure retry ile PASS'e çevrilmez.
- Canonical release branch'in mevcut artifact-retention politikaları korunur.
- Android release binary'lerinin GitHub Releases üzerinden üretilmesine yönelik mevcut release workflow'ları korunur.
- Kelime Avı release entegrasyonu mevcut AdMob/Firebase/Android release yapılandırmasını değiştirmez.

---

## 7. 26 Ağustos 2026 Başlangıç Limanı kabul/merge durumu

- MASTER ART görsel kullanıcı kabulü: **PASS**.
- MASTER ART raster + transparent hitbox mimari kabulü: **PASS**.
- Dynamic progression görsel/interaction senkronu: **PASS**.
- Final Android 16 production + pixel-proof: **PASS**.
- PR #132 merge: tamamlandı (`60991051a255608bc631b1341001748aa1a754b8`).
- PR #110 merge: tamamlandı (`33a08e589f00928306f759fc4f20738991323896`).
- PR #107 merge: tamamlandı (`ef34a1858d1a16da829a77c125d4953f7336b06d`).
- Eski PR #96 branch'i güncel release ile diverged olduğu için zorla merge edilmez; current release tabanından temiz entegrasyon yapılır.
- Release'e geçmeden exact release-context CI ve Android 16 kanıtı zorunludur.

---

## 8. 29 Ağustos 2026 — Başlangıç Limanı 8×8 ürün geometrisi

- Levent'in yeni ürün kararıyla Başlangıç Limanı bölüm grid standardı **8 satır × 8 sütun**dur.
- Önceki 6×10 starter-content geometrisi bu yeni çalışma için **superseded** edilmiştir; 6×10 geçmiş teknik checkpoint ve kanıtları silinmez.
- 10 bölüm / 30 yıldız / 80 toplam target+bonus kelime eğrisi korunur.
- Her target/bonus 8 düz yönde **exactly one physical occurrence** taşımalıdır.
- Intended ve opposite gesture aynı canonical kelimeye dönmelidir.
- İlk bölümlerde yatay/dikey yollar baskın olabilir; ilerleyen bölümlerde çapraz/ters yön çeşitliliği artırılır.
- B5 ve B10 yatay + dikey + çapraz yön ailelerini birlikte taşımalıdır.
- B8 iki bonus (`HIZ`, `SKOR`), B9 `ROKET` bonusu ve B10 `YOL` hedefi / `HAZİNE` bonusu korunur; `AY` ve `ROTA` geri dönmez.
- Süreler hard-fail değildir; B5 60 saniye, B10 120 saniye soft challenge sözleşmesi korunur.
- 8×8 dönüşümü `lib/main.dart`, `assets/questions.json`, MASTER ART, AdMob/Firebase, signing veya BoardMap/67 node kapsamını açmaz.
- Final 8×8 teknik gate run `33251736068`: **SUCCESS**. Dart formatter, analyze, focused 37/37, full Flutter 442/442, Android 16 B1/B5/B8/B10 64/64 görünürlük, B5 soft-time, ANKARA ve ters BAŞKENT gesture ve crash/ANR taraması PASS.
- Temiz 8×8 ürün commit: `052ea7da775db0b58a5ce0c6731a04f251879008`.
- 8×8 Draft PR #158 OPEN/DRAFT/merged=false/mergeable=true kalır; kullanıcı kabulü olmadan Ready/merge yapılmaz.

---

## 9. 29 Ağustos 2026 — Başlangıç Limanı bölüm içi tema kararı

- Beş özgün tema adayı arasından kullanıcı **1. görseli** seçti.
- Başlangıç Limanı Bölüm 1–10 ana oyun ekranı teması: **derin lacivert gece limanı + sıcak altın/amber deniz feneri ışığı**.
- Tema yalnız bölüm içi Kelime Avı oyun ekranına uygulanır; Issue #109 MASTER ART rota ekranı ve route geometry değişmez.
- Bölüm 1–10 aynı ana görsel kimliği taşır; ileride yalnız küçük atmosfer varyasyonları yapılabilir.
- 8×8 grid, target/bonus içerikleri, path/scoring/gesture motoru ve süre sözleşmeleri tema nedeniyle değiştirilmez.
- Tema uygulaması ayrı clean branch üzerinde yürütülür: `feat/kelime-avi-baslangic-limani-theme-clean-v1-20260829`.
- Doğrulanmış `word_hunt_screens.dart` doğrudan yeniden yazılmaz; temalı wrapper mevcut production ekranını sarar ve `word_hunt_gameplay_flow.dart` varsayılan açılışı wrapper'a yönlendirir.
- `lib/main.dart`, `assets/questions.json`, MASTER ART, AdMob/Firebase/signing, package/version tema kapsamı dışındadır.
- Tema için yeni Actions koşusu açık izin olmadan çalıştırılmaz.
- Gerçek Flutter analyze/test ve Android 16 tema görsel kabulü tamamlanana kadar tema runtime durumu **DOĞRULANACAK**.
