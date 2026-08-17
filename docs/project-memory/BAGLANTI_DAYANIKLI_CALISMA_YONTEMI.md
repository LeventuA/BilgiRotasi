# Bilgi Rotası - Bağlantı Kopmasına Dayanıklı Çalışma Yöntemi

**Karar tarihi:** 17 Ağustos 2026

Bu yöntem, ChatGPT/GitHub/Cloud bağlantısının uzun teknik işlemler sırasında kesilmesi halinde yapılan işin kaybolmaması ve aynı mutasyonun yanlışlıkla iki kez uygulanmaması için kullanılır.

## 1. Küçük ve geri alınabilir adımlar

- Uzun görevler tek seferde yürütülmez; kısa teknik adımlara bölünür.
- Her adım yalnız bir ana amacı değiştirir.
- Bir adım doğrulanmadan sonraki mutasyona geçilmez.
- Kör V2/V3 yaması veya bağlantı koptu diye aynı komutu tekrar çalıştırma yapılmaz.

## 2. Uzak checkpoint zorunluluğu

Değerli her ilerleme mümkün olduğunca uzak ve kalıcı bir checkpoint ile sabitlenir:

- branch adı,
- base SHA,
- güncel head SHA,
- commit adı ve SHA,
- PR numarası ve durumu,
- CI run/job kimliği,
- son tamamlanan adım,
- sıradaki tek adım,
- varsa kesin hata/engel.

Önemli ilerleme yalnız sohbet hafızasında veya geçici yerel terminal durumunda bırakılmaz.

## 3. Bağlantı kesilince devam protokolü

Bağlantı yeniden geldiğinde önce canlı kaynak okunur. Son işlem tekrar gönderilmeden önce gerçekten uygulanıp uygulanmadığı doğrulanır.

Özellikle commit, push, deploy, PR durumu değiştirme ve merge gibi mutasyonlarda şu sıra zorunludur:

1. Son bilinen checkpoint'i oku.
2. Canlı branch/PR/SHA/servis durumunu doğrula.
3. Önceki mutasyon gerçekleşmişse tekrar uygulama.
4. Gerçekleşmemişse yalnız aynı doğrulanmış parametrelerle tek tekrar yap.
5. Yeni sonucu yeni checkpoint olarak kaydet.

## 4. Belirsiz HTTP/connector hataları

- `502`, timeout veya bağlantı kopması bir mutasyonun kesin başarısız olduğu anlamına gelmez.
- Böyle bir hata sonrası aynı write/merge/deploy çağrısı hemen tekrar gönderilmez.
- Önce hedef sistemden son durum okunur.
- `429 Too Many Requests` gibi GitHub-hosted runner indirme hataları uygulama hatası sayılmaz; tam logdaki ilk kesin hata satırı bulunur ve sınırlı retry uygulanır.
- Aynı transient hataya sonsuz retry yapılmaz.
- Alternatif güvenli yol kullanılırsa aynı branch/head/base korunur ve değişiklik kapsamı büyütülmez.

## 5. CI izleme

- Uzun CI koşuları sürekli sorgulanmaz; yalnız aşama değişimleri kontrollü aralıklarla izlenir.
- Build başarısı tek başına çalışma kanıtı değildir.
- Analyze/test/build/manifest/emulator veya ilgili release gate sonuçları birlikte değerlendirilir.
- CI fail olursa önce tam logdaki ilk kesin hata satırı bulunur; kod değiştirmeden önce bunun uygulama, workflow veya altyapı hatası olduğu ayrılır.

## 6. Kritik merge/deploy kapısı

Kritik merge veya production deploy öncesi son kez:

- hedef branch,
- base SHA,
- exact head SHA,
- PR mergeability/draft durumu,
- ilgili final CI sonucu,
- kullanıcı açık onayı

doğrulanır.

Merge çağrısı timeout/502 verirse merge **tekrar gönderilmeden önce** PR `merged` durumu ve hedef branch HEAD okunur.

## 7. Telefon kullanımı

Levent telefondayken verilecek komutlar mümkün olduğunca tek parça ve uygulanabilir tutulur. Uzun işlemlerde kullanıcıya yalnız mevcut checkpoint ve bir sonraki kısa adım söylenir.

## 8. Bu yöntemin ilk canlı kanıtı

17 Ağustos 2026 production rewarded SSV istemci çalışmasında yöntem fiilen uygulandı:

- PR #49 Draft→Ready çağrısı GitHub connector tarafında iki kez `502` verdi.
- Aynı `ceed28bddfa2fc87dc90cff4fd6903417fc0e961` head korunarak PR #49 kapatıldı ve aynı head/base ile non-draft PR #50 açıldı.
- Fresh Run #222 ilk denemede `actions/setup-java@v4` indirilirken GitHub `codeload.github.com` tarafından `429 Too Many Requests` ile job başlamadan düştü.
- Tam logdaki ilk kesin hata satırı doğrulandı; kod değiştirilmeden yalnız başarısız job tekrar çalıştırıldı ve ikinci attempt tamamen PASS oldu.
- Squash merge çağrısı bir kez `502` verdi. Aynı merge hemen tekrarlanmadı; PR #50'nin hâlâ `merged=false` ve release HEAD'in hâlâ eski SHA olduğu canlı olarak doğrulandıktan sonra tek kontrollü tekrar yapıldı.
- İkinci merge çağrısı başarıyla tamamlandı ve release HEAD `78a462c34f2c6dbf4d25b8450b75fa99990690a1` oldu.

Bu davranış bundan sonraki Bilgi Rotası teknik çalışmalarında varsayılan bağlantı-kopması protokolüdür.
