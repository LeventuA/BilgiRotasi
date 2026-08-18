# SupportRewardCard Kapsam Denetimi

**Kaynak kesimi:** release `9e51728889e67efd60dc96c4ea9a2f8cd627c289`
**Tarih:** 18 Ağustos 2026

Ürün kararı: aktif soru/maç akışında reklam yok; tamamlanan oyun bir kez isteğe bağlı `Bize destek olmak ister misiniz?` / +10 XP hakkı üretir; aynı oyun ikinci kez ödül vermez.

## Mevcut / doğrulanan

| Mod | Durum | Not |
|---|---|---|
| Standart yerel tahta oyunu | VAR | `lib/main.dart` sonuç akışında SupportRewardCard mevcut. |
| Canlı Düello — normal tamamlanma | VAR | `lib/live_duel_play_screen.dart`; `gameId = live_duel:<matchId>`. |
| Canlı Düello — forfeit/kaçış | BİLEREK YOK | `!isForfeitResolution` koşulu; ürün açısından doğru. |

## Eksik ve aktif/release açısından değerlendirilmesi gerekenler

Öncelik sırası:

1. **Soru Maratonu** — sonuç ekranında SupportRewardCard bulunmadı.
2. **Günlük Meydan Okuma / Daily Challenge** — `lib/daily_challenge.dart` içinde kart bulunmadı.
3. **Hayatta Kalma** — `lib/quick_modes.dart` sonuç akışında kart bulunmadı.
4. **60 Saniye** — `lib/quick_modes.dart` içinde kart bulunmadı.
5. **Kategori Düellosu** — `lib/quick_modes.dart` içinde kart bulunmadı.
6. **Takım modu** — `lib/quick_modes.dart` içinde kart bulunmadı.
7. **Karışık / Mixed Madness** — `lib/quick_modes.dart` içinde kart bulunmadı.
8. **Kısa Meydan Okuma / Short Challenge** — `lib/short_challenge_mode.dart` içinde kart bulunmadı.

## Kapsam dışı / aktif ürün değil

- `advanced_modes.dart` içindeki Aile/Turnuva akışlarında kart yok; ancak ürün kararında bu modlar navigasyondan kaldırılmış durumda. Yeniden etkinleştirilmedikçe release blocker sayılmaz.
- `gameplay_boost.dart` içinde SupportRewardCard bulunmadı; bu dosyanın tamamlanan bağımsız oyun üretip üretmediği uygulama sırasında ayrıca doğrulanmalıdır.

## Uygulama ilkesi

Eksik modlar tek dev PR'ında körlemesine değiştirilmemeli. Her mod için:

- tamamlanmış oyunu temsil eden stabil ve benzersiz `gameId` belirlenir;
- aynı oyun yeniden sonuç ekranına açıldığında aynı `gameId` kullanılmalıdır;
- yarım kalan/abandon/forfeit akışında hak üretmemelidir;
- aktif soru ekranına reklam taşınmamalıdır;
- card yalnız gerçek sonuç ekranında olmalıdır;
- aynı gameId ikinci ödülü vermemelidir;
- closed-test Google demo reklamı ve production SSV davranışı birbirinden ayrılmalıdır.

## Önerilen geliştirme sırası

1. Marathon + Daily Challenge
2. Survival + 60 Seconds
3. Category Duel + Short Challenge
4. Team + Mixed Madness
5. Sonrasında tüm aktif oyun modlarının merkezi sonuç/reward envanter testi

Production SSV/XP reconciliation tamamlanmadan gerçek production rewarded cutover yapılmamalıdır.
