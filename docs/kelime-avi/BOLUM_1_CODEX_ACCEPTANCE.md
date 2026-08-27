# Kelime Avı — Bölüm 1 Codex Acceptance Gate

**Tarih:** 27 Ağustos 2026

Bu dosya `feat/kelime-avi-gameplay-v1-20260826` branch'indeki ilk production gameplay implementasyonunun kabul kapısıdır.

Codex yalnız `çalışıyor` raporu veremez; aşağıdaki davranışları otomatik test ve diff kanıtıyla doğrulamalıdır.

## A. Mevcut testlerde zaten korunan çekirdek

Aşağıdaki davranışlar mevcut suite'te vardır ve regress olmamalıdır:

1. Yatay straight target kabulü.
2. Reverse target kabulü.
3. 8-yön çapraz straight path desteği.
4. Kıvrılan path'in classic modda reddi.
5. Aynı hücrenin bir seçim içinde tekrar kullanılamaması.
6. Grid dışı hücrenin fail-closed reddi.
7. Bonus kelimenin target'tan ayrı sınıflanması.
8. Already-found target'ın ikinci ödül üretmemesi.
9. Türkçe `i/ı` normalizasyonu.
10. Tamamlanmamış level'ın 0 yıldız olması.
11. 0 hata → 3 yıldız.
12. 2 hata → 2 yıldız.
13. 3 hata → 1 yıldız.
14. Düşük replay sonucunun daha iyi best-star'ı düşürmemesi.
15. Önceki level tamamlandığında sonraki level'ın açılması.
16. Başlangıç Limanı 9/10 özel unlock sözleşmesi.

Kaynak testler:
- `test/word_hunt_path_test.dart`
- `test/word_hunt_scoring_test.dart`
- `test/word_hunt_progress_test.dart`
- `test/word_hunt_prototype_screens_test.dart`

Bu mevcut testler silinemez veya anlamı gevşetilemez.

## B. Bölüm 1 canonical engine testleri — ZORUNLU

Yeni/uyarlanmış testler gerçek `WordHuntStarterContent.baslangicLimani.levels.first` verisini kullanmalıdır.

17. `KALEM` canonical path `(0,0)→(0,4)` target olur.
18. `KALEM` reverse `(0,4)→(0,0)` canonical `KALEM` olur.
19. `MASA` `(1,0)→(1,3)` target olur.
20. `ELMA` `(2,0)→(2,3)` bonus olur.
21. `ELMA` bulunmadan `KALEM + MASA` completion için yeterlidir.
22. Canonical Bölüm 1 için geometrik geçerli ama listede olmayan seçim `notAWord` olur.
23. Non-straight/invalid Bölüm 1 path `invalidPath` olur.
24. Aynı canonical `KALEM` ikinci kez evaluate edildiğinde `alreadyFound` olur.

Koordinat tek kaynağı:
`docs/kelime-avi/BOLUM_1_GAMEPLAY_QA.md`.

## C. Production level widget testleri — ZORUNLU

Prototype-only test yeterli değildir. Yeni production oyun widget'ı/flow'u için:

25. İlk render:
   - `Bölüm 1` görünür,
   - target progress `0/2`,
   - mistake `0`,
   - `KALEM`, `MASA`, bonus `ELMA` görünür,
   - completion CTA henüz yok/disabled.

26. KALEM gesture sonrası:
   - progress `1/2`,
   - KALEM permanent found state,
   - hata `0`,
   - completion CTA yok.

27. Reverse KALEM gesture aynı sonucu üretir.

28. Yanlış fakat straight/geçerli seçim sonrası:
   - mistake `1`,
   - target progress değişmez.

29. Invalid/non-straight gesture sonrası:
   - mistake değişmez,
   - target progress değişmez.

30. Aynı KALEM tekrar seçildiğinde:
   - progress `1/2` kalır,
   - mistake değişmez.

31. ELMA bonus seçildiğinde:
   - bonus found görünür,
   - target progress değişmez,
   - completion CTA yalnız bonus nedeniyle açılmaz.

32. KALEM + MASA sonrası:
   - progress `2/2`,
   - completion CTA görünür/aktif.

33. Completion elapsed time final target bulunduğu anda freeze olur; sonuç CTA'sına geç basmak displayed/result elapsed değerini artırmaz.

34. 0 hata ile completion result `3 stars` üretir.

35. 1 veya 2 hata ile completion result `2 stars` üretir.

36. 3+ hata ile completion result `1 star` üretir.

37. Bölüm 1 result'ında `levelId == baslangic-1`.

38. Bölüm 1 canonical içerikte `unlockedInfoCardIds` boş set olur.

39. Completion CTA hızlı çift tap'te tek result/dialog üretir.

40. Widget dispose sonrası timer callback/setState hatası yoktur.

## D. Production route → level → result → route flow testleri — ZORUNLU

41. Empty progress ile production MASTER ART route açıldığında Level 1 tappable, Level 2 locked.

42. Node 1 tap yalnız bir Bölüm 1 gameplay route'u açar.

43. Gameplay result 3 stars döndüğünde parent flow:
   - `baslangic-1 = 3`,
   - total route stars `3`,
   - Level 2 unlocked.

44. Gameplay result 1 star döndüğünde de Level 2 unlocked.

45. Replay daha düşük stars döndürürse previous best düşmez.

46. Replay daha yüksek stars döndürürse best yükselir.

47. Yarım attempt'ten result vermeden geri dönülürse route progress değişmez.

48. Attempt'te anlamlı progress/mistake varken geri çıkış confirmation davranışı test edilir:
   - `Devam Et` level'da bırakır,
   - `Çık` result vermeden route'a döner.

49. Route'a dönüşte MASTER ART dynamic visual state ile interaction state aynı progress'i kullanır.

50. Bu flow hiçbir koşulda production `lib/main.dart` entegrasyonu gerektirmez; test izole `MaterialApp`/module entry ile çalışır.

## E. Scope guard — ZORUNLU

Implementation diff aşağıdaki alanlara dokunmamalıdır:

- `lib/main.dart`
- `assets/questions.json`
- BoardMap / 67 node / 3B dosyaları
- AdMob/Firebase/Android signing-release config
- package name
- version (`1.68.19+109`)
- MASTER ART raster bytes
- kabul edilen production route mimarisini redraw eden yeni Canvas/CustomPainter premium art

`pubspec.yaml` yalnız gerçekten zorunluysa değişebilir; yeni dependency bu slice için beklenmemektedir. Dependency eklenirse ayrı risk olarak raporlanmalıdır.

## F. Static/test gate — ZORUNLU

Codex raporundan önce:

```bash
flutter pub get
dart analyze lib/word_hunt
flutter test test/word_hunt_path_test.dart \
  test/word_hunt_scoring_test.dart \
  test/word_hunt_progress_test.dart \
  test/word_hunt_prototype_screens_test.dart \
  <yeni Bölüm 1 production test dosyaları>
git diff --check
```

Ayrıca mümkünse mevcut bütün focused Word Hunt suite'i çalıştırılmalıdır.

## G. Codex rapor formatı

Commit/PR oluşturmadan önce rapor:

1. Exact branch HEAD başlangıcı.
2. Değişen dosyalar.
3. Yeni/refactor sınıflar ve nedenleri.
4. Production flow'un bir paragraf özeti.
5. Test dosyaları ve toplam PASS sayısı.
6. Analyze sonucu.
7. `git diff --check` sonucu.
8. Scope guard sonucu.
9. Açık riskler / bilinçli kapsam dışı maddeler.
10. `lib/main.dart`, `assets/questions.json`, release config ve MASTER ART bytes'ın değişmediğine açık teyit.

## H. Merge sınırı

- Codex commit/PR hazırlayabilir ancak **merge yapamaz**.
- ChatGPT/GitHub diff review yapılmadan merge-ready sayılmaz.
- Android 16 gerçek cihaz/emulator production gameplay proof ve görsel inceleme sonraki kapıdır.
- Release/main merge için ayrıca açık kullanıcı onayı gerekir.
