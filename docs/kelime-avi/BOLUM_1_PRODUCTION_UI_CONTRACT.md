# Kelime Avı — Bölüm 1 Production UI Sözleşmesi

**Tarih:** 27 Ağustos 2026

Bu sözleşme Başlangıç Limanı `baslangic-1` oyun ekranının production v1 görünüm/hiyerarşisini tanımlar. Amaç yeni bir görsel dil icat etmek değil; onaylı Başlangıç Limanı renk/atmosferini çalışan kelime grid'ine taşımaktır.

## 1. Görsel yön

Başlangıç Limanı rota ekranıyla aynı aile:

- koyu gece laciverti ana zemin,
- teal/cyan aktif oyun feedback'i,
- altın yıldız/bonus vurgusu,
- mor yalnız ikincil vurgu,
- yüksek kontrast beyaz harfler,
- yumuşak yuvarlatılmış panel/hücreler.

Mevcut prototip palette başlangıç noktası olarak korunabilir:

- background: `#06142E`
- panel: `#0D203D` / `#102443`
- idle cell: `#142A4C`
- cell border: `#34527A`
- teal success: `#5EEAD4` / `#0F766E`
- cyan metric: `#22D3EE`
- gold: `#FFD166`
- purple selection: `#8B5CF6`

Yeni AI-generated tam ekran UI veya yeni premium sanat üretilmez. Grid/hud işlevsel Flutter UI bileşenleridir. MASTER ART rota ekranı değiştirilmez.

## 2. Ekran hiyerarşisi

Portrait telefon, `SafeArea` içinde yukarıdan aşağı:

1. **Header**
2. **Metric row**
3. **Target/bonus panel**
4. **6×6 grid — ekranın ana odağı**
5. **Durum/feedback alanı**
6. **Contextual action alanı**

Ekran küçük cihazda taşmamalı. Grid kare kalmalı; gereğinde dikey scroll kullanılabilir fakat normal telefon yüksekliğinde grid ve ana metrikler ilk viewport'ta görünmelidir.

## 3. Header

- Sol: geri butonu, minimum 48×48 touch target.
- Orta/ana başlık: `Bölüm 1`.
- Küçük üst/alt bağlam: `Başlangıç Limanı` veya `Kelime Avı`; ikisi birden büyük başlık olarak tekrarlanmaz.
- Default Material AppBar görünümüne mahkûm olmak zorunda değildir; ancak production-safe basit Flutter widget'ları kullanılır.

Geri butonu yarım oyunu otomatik başarı olarak kaydetmez.

## 4. Metric row

Üç eşit veya dengeli kompakt gösterge:

- hedef ilerleme: `0/2`, `1/2`, `2/2`
- hata: `0 hata`, `1 hata`...
- süre: `0s`, `1s`...

Bölüm 1 süre limitli değildir; burada geçen süre gösterilir.

Metric row grid'den görsel olarak daha baskın olmamalıdır.

## 5. Hedef/bonus paneli

Hedefler:

- `KALEM`
- `MASA`

Bonus:

- `✦ ELMA`

Kurallar:

- bulunmamış hedef okunaklı nötr chip,
- bulunan hedef teal/success durumuna geçer,
- bulunan hedefte check veya strike-through kullanılabilir; sadece renge güvenilmez,
- bonus altın vurguyla hedeflerden ayrılır,
- bonus bulunmasa da level tamamlanabilir,
- bonus bulunduğunda kalıcı olarak found görünür.

Kelime listesi grid alanını boğmamalıdır.

## 6. Grid

- 6×6 sabit kare grid.
- Harfler Türkçe karakterleri doğru göstermeli.
- Her hücre minimum okunabilir touch alanı sunmalı; ekran genişliğine responsive ölçeklenir.
- Grid spacing tutarlı ve dar; parmak sürüklemesini kesmeyecek kadar küçük olmalı.
- Harfler yüksek kontrast, yaklaşık 22–26sp bandında responsive olabilir.

### Hücre state'leri

En az dört görünür state:

1. idle
2. currently selected
3. previously found target/bonus path
4. selection error sonrası kısa feedback

Current selection bütün path boyunca kesintisiz algılanmalıdır. V1 için CustomPainter/Canvas ile dekoratif selection line zorunlu değildir; hücrelerin belirgin ortak selection state'i yeterlidir.

Bulunmuş bir path yeni gesture sırasında kaybolmaz.

Aynı hücre farklı bulunmuş kelimelerin kesişiminde kullanılabilirse state deterministik kalmalıdır; Bölüm 1 canonical kelimeleri kesişmediği için bu edge case core model testleri dışında UI v1'i bloklamaz.

## 7. Gesture feedback

- Pointer down: ilk hücre anında selected.
- Pointer move: geçerli düz path boyunca hücreler canlı selected.
- Geçersiz/non-straight harekette son geçerli selection korunabilir veya invalid preview reddedilebilir; hayalet hücreler seçilmiş görünmez.
- Pointer up: engine evaluate edilir.

Doğru target:
- selected → permanent found state,
- kısa pozitif status: `KALEM bulundu!` gibi.

Bonus:
- permanent bonus-found state,
- kısa status: `Bonus kelime: ELMA ✨`.

Yanlış fakat geometrik geçerli kelime:
- hata +1,
- kısa nötr/kırmızımsı feedback,
- ağır ceza, modal veya uzun animasyon yok.

Invalid path:
- hata +0,
- kısa yönlendirici feedback olabilir.

Already found:
- progress/hata değişmez,
- `KALEM zaten bulundu.` benzeri kısa status.

## 8. Status alanı

Başlangıç metni kısa olmalı:

`İlk harfe dokun, parmağını kelimenin üzerinde sürükle.`

Status paneli sabit yükseklik/denge kullanmalı; mesaj uzunluğu değiştikçe grid zıplamamalıdır.

## 9. Bölüm tamamlanma aksiyonu

İki hedef de bulunmadan completion CTA görünmez/aktif olmaz.

İki hedef bulunduğunda belirgin primary CTA:

`Bölümü Tamamla`

Bu ilk production v1'de mevcut çalışan davranışı korur; otomatik modal açılışı zorunlu değildir. Böylece final doğru kelime feedback'i oyuncu tarafından görülür ve gereksiz lifecycle riski eklenmez.

## 10. Sonuç görünümü

`Bölümü Tamamla` sonrası modal/sheet:

- başlık: `Bölüm Tamamlandı`
- 3 büyük yıldız slotu
- kazanılan yıldız sayısı belirgin
- geçen süre
- hata sayısı
- bonus bulunduysa bonus bilgisi
- primary: `Rotaya Dön`

İlk v1'de `Rotaya Dön` sonucu parent route akışına döndürür.

Opsiyonel `Tekrar Oyna` ancak state/result akışı testli ve basitse eklenebilir; Bölüm 1 production acceptance için zorunlu değildir.

## 11. Rota dönüşü

`Rotaya Dön` sonrası beklenen kullanıcı görünümü:

- Başlangıç Limanı MASTER ART route geri gelir,
- Node 1 kazanılan 1–3 yıldızı gösterir,
- total stars artar,
- Bölüm 2 unlock olur,
- route visual state ile interaction state uyuşur.

Route MASTER ART kompozisyonu redesign edilmez.

## 12. Responsive / accessibility

- 48dp civarı minimum ana touch targets.
- Harfler contrast kaybetmez.
- Sadece renk ile found/error bilgisi verilmez; icon/text/decoration desteği kullanılır.
- Turkish `İ/ı/Ş/Ğ/Ü/Ö/Ç` glyph'leri clipping yapmaz.
- TextScale makul sistem ölçeklerinde kritik CTA veya grid'i kullanılamaz hale getirmemeli.
- Portrait Android ana hedeftir.

## 13. Production v1 dışında

Bu aşamada eklenmez:

- particle/confetti sistemi,
- yeni ses paketi,
- haptic tasarım sistemi,
- karmaşık CustomPainter premium art,
- reklam,
- yeni analytics event'leri,
- global leaderboard,
- main app navigation integration,
- Bölüm 2–10 ekranlarına özgü yeni UI.

Önce Bölüm 1 tam döngüsü çalışıp Android 16'da görsel/işlevsel kabul alacaktır.
