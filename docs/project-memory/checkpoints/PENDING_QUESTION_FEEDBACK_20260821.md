# Bilgi Rotası — Bekleyen Soru Geri Bildirimleri Checkpoint

**Tarih:** 21 Ağustos 2026  
**Görev:** `BR-P0-003 - Kalan geri bildirimleri değerlendir`

## Canlı başlangıç kilidi

- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Exact başlangıç SHA: `9331802b9a2b12d1f4ec6715da96dc7d0f60b24b`
- Kaynak sürüm: `1.68.17+107`
- Hedef sürüm: `1.68.18+108`
- Çalışma branch'i: `fix/all-pending-question-feedback-20260821`
- Draft PR: `#79 - fix: resolve all pending question feedback`

## Canlı geri bildirim envanteri

Görev başında ve düzeltme öncesi canlı Google Sheet yeniden okundu:

- `Bekliyor` olay: **128**
- Benzersiz soru: **122**
- İçerik / soru / seçenek düzeltmesi: **53**
- Zorluk düzeltmesi: **27**
- Kategori düzeltmesi: **1** (`q56861`: Tarih → Spor)
- Değişiklik gerektirmeyen / geçersiz geri bildirim: **41**
- Gerçekte değişen benzersiz soru: **81**

Sheet satırları bu aşamada kapatılmadı veya silinmedi. Merge + yeni AAB/Play doğrulaması yapılmadan `Düzeltildi` yazılmayacak.

## Soru bankası kanıtı

- Toplam soru: **8710**
- Kaynak `assets/questions.json` SHA-256: `e71c4ff991873499b986952835b9bb8e0995d2791c47ce4085d7ab9a502299d4`
- Düzeltme sonrası SHA-256: `b92a62902e237d5cc9e1a856f6ea2f23ee53ae2e0c4ba0cd09044e8eccfd518a`
- `pubspec.yaml` ve `lib/app_build_info.dart` birlikte `1.68.18+108` olarak güncellendi.

## Test-before-commit kanıtı

Fail-closed düzeltme ve test workflow'u:

- Run: `32467695836`
- Job: `96727717049`
- Sonuç: **SUCCESS**
- Final ürün commit'i: `23b6602b2e2968b87c167dcf57e5310462ca2420`
- Commit mesajı: `fix: resolve all pending question feedback`

Kanıtlanan kapılar:

- Exact release base: PASS
- Kaynak sürüm kilidi: PASS
- 122/122 soru audit eşleşmesi: PASS
- 81 değişen soru kapsamı: PASS
- `tools/validate_questions.py`: PASS
- RC1 Production kalite kapısı: PASS
- Kritik soru bankası sorunu: 0
- Soru diff'i: 598 satır; sınır içinde
- `flutter analyze --no-fatal-warnings --no-fatal-infos`: PASS
- Tüm Flutter testleri: PASS
- Canlı Düello oynanabilir katalog sözleşmesi: **8603 uygun / 107 elendi** — korundu
- `git diff --check`: PASS

Kalite filtresinin matematik sanmaması için `q60654`, `q60756` ve `q61051` soru kökleri anlam ve doğru cevap değişmeden doğal Türkçeyle normalleştirildi. Test beklentisi 8603'ten düşürülmedi.

## Final PR kapsamı

Ürün commit'i sonrasında PR #79 net diff'i yalnız:

1. `assets/questions.json`
2. `lib/app_build_info.dart`
3. `pubspec.yaml`
4. `reports/RC1_QUALITY_GATE_PENDING_FEEDBACK.md`
5. `reports/pending_question_feedback_live_audit_20260821.json`
6. `reports/pending_question_feedback_resolution_20260821.md`
7. `reports/pending_question_feedback_resolution_manifest_20260821.json`

Geçici audit/uygulama workflow ve scriptleri final ürün commit'inde kaldırıldı. BoardMap, 67 node, 3B tahta, reklam runtime kodu, Firebase yapılandırması ve diğer açık PR kapsamları değiştirilmedi.

## Merge ve yayın kapıları

Levent, bu görev için düzeltmelerin tamamlanıp gerekli kontrollerin geçmesi koşuluyla açık onay verdi. Bu onay final CI başarısızsa veya kapsam beklenmedik biçimde değişirse merge yetkisi sayılmaz.

Bot tarafından oluşturulan ürün commit'inin otomatik standart PR koşusu GitHub tarafından `action_required` / jobsuz bırakıldığı için bu checkpoint commit'iyle standart `AdMob PR doğrulaması` yeniden tetiklenecek. Merge için aşağıdakiler hâlâ zorunludur:

1. Bu checkpoint sonrası exact PR head üzerinde standart AdMob PR doğrulaması ve Android 16 kapısı SUCCESS.
2. Final diff ve Git geçmişinin tekrar incelenmesi.
3. PR #79'un kullanıcı onayı kapsamından sapmadığının doğrulanması.
4. Merge sonrası release HEAD ve `1.68.18+108` sürümünün doğrulanması.
5. Yeni `1.68.18+108` AAB'nin kanonik kapalı-test release hattında üretilmesi ve artifact/AAB kanıtının doğrulanması.
6. Play dağıtımı doğrulanmadan Sheet kayıtlarının kapatılmaması.
7. Play doğrulaması sonrası gerçek düzeltmelerin `Düzeltildi`, değişiklik gerektirmeyenlerin `İşlem dışı` kapatılması ve canlı `Bekliyor = 0` kontrolü.
