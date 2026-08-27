# Kelime Avı — Bölüm 1 Gameplay Flow / Edge-case Sözleşmesi

**Tarih:** 27 Ağustos 2026

Bu belge `baslangic-1` production gameplay akışının davranış sözleşmesidir. `BOLUM_1_GAMEPLAY_QA.md` içerik/koordinat kaynağı, `BOLUM_1_PRODUCTION_UI_CONTRACT.md` görünüm kaynağıdır.

## 1. Production modül akışı

İlk slice şu uçtan uca döngüyü çalıştırır:

`WordHuntReferenceRouteScreen → Node 1 → Bölüm 1 production game → result → route → progress update → Node 2 unlock`

Production `lib/main.dart` bu slice'ta değiştirilmez.

Route + gameplay arasında gerçek state sahibi küçük bir Word Hunt flow/controller widget'ı oluşturulabilir. Ama mevcut engine/model/scoring/progress sınıfları gereksiz yeniden yazılmaz.

## 2. Level giriş kuralı

- Level 1 her zaman unlocked.
- Yalnız unlocked node gerçek gameplay açar.
- Locked node callback/game screen üretmez.
- Node tap tek navigation push üretir; hızlı çift dokunma duplicate level route açmamalıdır.

## 3. Attempt başlangıcı

Yeni attempt başlangıcında:

- found target set boş,
- found bonus set boş,
- found paths boş,
- mistakes `0`,
- elapsed `0`,
- active selection boş,
- result/completion guard false.

Level 1'in önceki best stars değeri yeni attempt içi kelimeleri otomatik found yapmaz. Replay temiz attempt olarak başlar; yalnız rota best-star göstergesi korunur.

## 4. Gesture sınıflandırması

### Target

Canonical target ilk kez bulunduğunda:

- found target'a eklenir,
- path permanent found görünür,
- progress sayacı artar,
- hata artmaz.

### Bonus

`ELMA` ilk kez bulunduğunda:

- found bonus'a eklenir,
- permanent bonus-found görünür,
- hata artmaz,
- target completion sayacını artırmaz,
- yıldız hesabına ek bonus koşulu getirmez.

### Already found

Aynı target veya bonus yeniden seçilirse:

- found count değişmez,
- hata değişmez,
- yeni ödül/result üretmez,
- kısa `zaten bulundu` feedback'i verilebilir.

### Geometrik geçerli ama listede olmayan seçim

- `WordHuntSelectionKind.notAWord` → mistakes +1.
- selection temizlenir.
- ağır modal/ceza yok.

### Invalid path

- `invalidPath` → mistakes değişmez.
- progress değişmez.
- selection temizlenir veya son geçerli preview kaldırılır.

### Pointer cancel

- attempt progress/hata değişmez,
- yalnız active selection temizlenir.

## 5. Reverse selection

Mevcut `WordHuntPathEngine` canonical reverse matching aynen korunur.

Bölüm 1 için:

- `KALEM` forward ve `MELAK` gesture yönü aynı canonical `KALEM` sonucuna gider.
- `MASA` forward ve `ASAM` gesture yönü canonical `MASA` olur.
- `ELMA` forward ve `AMLE` gesture yönü canonical `ELMA` olur.

Reverse gesture ayrı kelime/bonus sayılmaz.

## 6. Completion koşulu

Level yalnız iki canonical target da bulunduğunda complete adayı olur:

- `KALEM`
- `MASA`

`ELMA` bulunması zorunlu değildir.

İki target bulunmadan `Bölümü Tamamla` aktif/görünür olmaz.

Son target kabul edildiği anda **completion elapsed time freeze edilir**. Kullanıcının sonuç CTA'sına basmayı beklediği süre skor/result süresini şişirmemelidir. Level 1'de süre yıldız koşulu olmasa da bu davranış sonraki time-rule seviyeleri için doğru temel oluşturur.

## 7. Scoring

Mevcut `WordHuntScoringEngine` tek kaynak olarak kullanılır; UI kendi yıldız formülünü hesaplamaz.

Canonical Bölüm 1 sonucu:

- 0 hata → 3 yıldız,
- 1–2 hata → 2 yıldız,
- 3+ hata → 1 yıldız,
- target'lar tamamlanmamışsa → 0 yıldız / completed false.

Bonus kelime yıldız tier'ını değiştirmez.

## 8. Result idempotency

`Bölümü Tamamla` hızlı/çoklu tap ile:

- birden fazla dialog/sheet açmamalı,
- birden fazla `WordHuntLevelPlayResult` döndürmemeli,
- progress'e aynı attempt sonucu birden fazla uygulanmamalı.

Result en fazla bir kez parent flow'a teslim edilir.

Level 1'in `infoCardIds` alanı boş olduğundan normal Bölüm 1 result'ında `unlockedInfoCardIds` boş set beklenir.

## 9. Rotaya dönüş / progress

Parent flow `WordHuntLevelPlayResult` aldığında mevcut:

`WordHuntProgressSnapshot.recordLevelResult(...)`

kullanılmalıdır.

Beklenen:

- `baslangic-1` best star = kazanılan stars,
- total route stars güncellenir,
- Level 1 completed sayılır (`stars >= 1`),
- Level 2 unlock olur,
- MASTER ART route dynamic state yeni progress'i gösterir.

## 10. Replay / best-star davranışı

Mevcut progress sözleşmesi korunur:

- İlk oyun 2 yıldız, replay 1 yıldız → best `2` kalır.
- İlk oyun 1 yıldız, replay 3 yıldız → best `3` olur.
- Replay hiçbir zaman best star'ı düşürmez.
- Total route stars best-star snapshot üzerinden hesaplanır; attempt yıldızlarının toplamı değildir.

## 11. Yarım oyundan geri çıkma

Gameplay ekranından sistem/app geri veya header geri:

- level result üretmez,
- route progress değiştirmez,
- partial target/bonus/mistake state kaydedilmez.

Production UX:

- attempt henüz hiç anlamlı etkileşim almamışsa doğrudan çıkılabilir,
- target/bonus bulunduysa veya mistake oluştuysa kısa confirmation gösterilir:
  `Bölümden çıkılsın mı? Bu denemedeki ilerleme kaybolacak.`
- `Devam Et` attempt'te kalır,
- `Çık` result vermeden route'a döner.

Bu confirmation yalnız attempt kaybını önlemek içindir; reklam/ödül/analytics içermez.

## 12. Süre / lifecycle

Bölüm 1 time-limit içermez.

- Ekranda elapsed süre gösterilir.
- Timer/widget dispose olduğunda timer iptal edilir.
- Completion freeze sonrası result süresi artmaz.
- Level exit sonrası timer callback'i setState üretmemelidir.

App background süresinin elapsed'a dahil edilmesi Bölüm 1 yıldızını etkilemez; daha ileri timer-policy ayrı karar olabilir. Bu slice'ta lifecycle mimarisi büyütülmez.

## 13. Persistence sınırı

Bu ilk production gameplay slice'ta amaç Word Hunt modülü içindeki gerçek route→level→result→route döngüsüdür.

- In-memory `WordHuntProgressSnapshot` flow için yeterlidir.
- Disk/account persistence bu ilk slice'ın zorunlu kapsamı değildir.
- Ancak flow/controller son progress'i dışarı aktarabilecek/test edilebilecek şekilde tasarlanmalı; sonraki main-navigation/account entegrasyonunu engellememelidir.
- Mevcut `WordHuntProgressCodec` sözleşmesi bozulmaz.

## 14. Hata/risk durumları

Aşağıdakiler blocker sayılır:

- wrong selection invalid path ile karıştırılıp haksız hata yazılması,
- reverse target'ın reddedilmesi,
- bonusun completion için zorunlu hale gelmesi,
- tekrar bulunan kelimenin ikinci progress/hata üretmesi,
- replay'in best stars değerini düşürmesi,
- Level 1 result sonrası Level 2'nin açılmaması,
- route visual state ile interaction state'in ayrışması,
- geri çıkışta partial attempt'in başarı olarak kaydedilmesi,
- duplicate result/navigation,
- MASTER ART route'un redesign edilmesi.

## 15. Bu slice dışında

- production `lib/main.dart` bağlantısı,
- disk/account persistence wiring,
- reklam,
- analytics,
- ses/haptic polish,
- Bölüm 2–10 production gameplay içerik entegrasyonu,
- yeni rota/tema.
