# Canlı Düello backend dağıtımı

Bu PR server-authoritative Functions, kapalı istemci yazma kuralları ve emulator
testlerini hazırlar. Production'a deploy edilmemiştir.

## Staging sırası

1. Ayrı bir Firebase development projesi oluşturun; production
   `google-services.json` dosyasını test uygulamasına kopyalamayın.
2. `live_duel_config/question_catalog` belgesini geçerli soru kimlikleriyle,
   `live_duel_answer_keys/{questionId}` belgelerini yalnız Admin SDK ile yükleyin.
3. `firestore.indexes.json`, Functions ve Rules'u emulator'da test edin.
4. `joinLiveDuelQueue`, `findLiveDuelMatch`, `cancelLiveDuelQueue`,
   `submitLiveDuelAnswer`, `finalizeLiveDuel` ve
   `resolveLiveDuelForfeit` callable fonksiyonlarıyla
   hız sınırlı `claimUsername` callable fonksiyonunu ve
   `syncUsernameToLeaderboard` tetikleyicisini staging'e deploy edin.
5. İki staging hesapla tekrar katılma, aynı ticket, aynı cevap ve aynı finalize
   çağrılarını tekrarlayın; ikinci maç/BR ödülü oluşmamalı.
6. Engelli iki hesabın eşleşmediğini ve istemcinin kuyruk, maç, progress, BR ve
   leaderboard yazılarının Rules tarafından reddedildiğini doğrulayın.
7. Bu daldaki Flutter istemcisi kritik yazımları `LiveDuelServerGateway`
   üzerinden yapar. Backend'i staging'de doğrulamadan bu istemciyi dağıtmayın.
   Production geçişinde Functions önce, uyumlu istemci ikinci, istemci
   yayılımı doğrulandıktan sonra kapalı yazma Rules'u son olarak dağıtılmalıdır;
   Rules'u önce dağıtmak mağazadaki eski istemciyi kilitler.

## Public player ID migration

`functions/scripts/migrate_public_player_ids.js` varsayılan olarak dry-run
çalışır. Application Default Credentials ve doğru proje açıkça doğrulandıktan
sonra yalnız planlanan sayı/örnekler kontrol edilerek
`APPLY_PUBLIC_ID_MIGRATION=YES` ile uygulanır. UID tabanlı eski leaderboard
belgesi yeni `publicPlayerId` belgesine transaction ile taşınir; sıralama
alanları kaybedilmez. Servis hesabı anahtarı repoya konmaz.

## Geri alma

Yeni istemciyi durdurun, Functions sürümünü geri alın ve yalnız uyumlu eski
Rules'u yeniden dağıtın. Migration sonrasında public ID belgelerini silmeyin;
geri alma betiği ayrı inceleme gerektirir.
