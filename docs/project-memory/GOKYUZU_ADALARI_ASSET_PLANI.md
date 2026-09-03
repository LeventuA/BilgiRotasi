# Gökyüzü Adaları — Modüler Asset Planı

**Durum:** V1 üretim sözleşmesi / 3 Eylül 2026

## Kilitli ürün yönü

- Paket: **Gökyüzü Adaları**.
- Görsel yön: **C — Neşeli & Parlak**.
- Teknik görsel mimari: **modüler asset yaklaşımı**.
- Rota: 10 bölüm / 30 yıldız.
- Canonical gameplay: **8×8 / 64 hücre**; gameplay engine bu görsel iş nedeniyle değişmez.
- Başlangıç Limanı MASTER ART raster mimarisi bu pakete kopyalanmaz.

## Kilitli rota sırası

1. Rüzgâr Kapısı
2. Bulut Bahçesi
3. Kuş Geçidi
4. Gökkuşağı Köprüsü
5. Fırtına Kulesi
6. Hava Gemisi Limanı
7. Ay İskelesi
8. Gizli Ada — bonus rota node'u
9. Yıldız Gözlemevi
10. Güneş Sarayı

## Üretim ilkeleri

- Referans tasarım tuvali: **1080×1920, dikey**.
- Büyük renk/gradient alanları mümkün olduğunca Flutter tarafından çizilir; illüstratif dünya parçaları modüler raster asset olur.
- Şeffaf dünya/UI parçaları PNG veya kayıpsız WebP olabilir; format final kalite/boyut testiyle seçilir.
- Asset içine bölüm numarası, yıldız sayısı, kilit durumu, sayaç veya dinamik metin bake edilmez.
- Node/state, yıldız, kilit ve bölüm numarası runtime tarafından değiştirilir.
- Her modül bağımsız taşınabilir/ölçeklenebilir olmalı; başka asset'e zorunlu olarak gömülü olmamalı.
- Final ekran tek flatten edilmiş MASTER ART olarak kullanılmaz.
- Safe-area ve mobil okunabilirlik korunur; rota takibi ilk bakışta anlaşılır olmalıdır.

## V1 zorunlu atomik asset seti

### A. Atmosfer — 8

1. `cloud_far_01.png`
2. `cloud_far_02.png`
3. `cloud_mid_01.png`
4. `cloud_mid_02.png`
5. `cloud_front_01.png`
6. `cloud_front_02.png`
7. `wind_streak_01.png`
8. `sparkle_cluster_01.png`

### B. Yüzen adalar — 7

9. `island_small_01.png`
10. `island_small_02.png`
11. `island_medium_01.png`
12. `island_medium_02.png`
13. `island_large_01.png`
14. `island_large_02.png`
15. `island_final_01.png`

### C. Rota bağlantıları — 6

16. `cloud_path_short.png`
17. `cloud_path_medium.png`
18. `cloud_path_curve.png`
19. `wind_stream_path.png`
20. `rainbow_bridge.png`
21. `golden_final_path.png`

### D. Bölüm landmarkları — 10

22. `landmark_wind_gate.png`
23. `landmark_cloud_garden.png`
24. `landmark_bird_pass.png`
25. `landmark_rainbow_arch.png`
26. `landmark_storm_tower.png`
27. `landmark_airship_harbor.png`
28. `landmark_moon_dock.png`
29. `landmark_hidden_island.png`
30. `landmark_star_observatory.png`
31. `landmark_sun_palace.png`

### E. Node / progression UI — 9

32. `route_node_base.png`
33. `route_node_active_ring.png`
34. `route_node_completed_ring.png`
35. `route_node_locked_overlay.png`
36. `route_node_bonus_badge.png`
37. `route_star_empty.png`
38. `route_star_filled.png`
39. `route_crown.png`
40. `route_lock.png`

### F. Dekor — 8

41. `airship_small.png`
42. `airship_large.png`
43. `balloon_01.png`
44. `balloon_02.png`
45. `bird_flock.png`
46. `sky_windmill.png`
47. `flag_banner.png`
48. `flower_cluster.png`

**V1 toplam zorunlu atomik asset: 48.**

## Hızlı üretim yöntemi — 5 sprite sheet

48 ayrı görsel çağrısı yapılmaz. Stil tutarlılığı ve hız için üretim 5 ana sheet halinde yapılır, ardından bağımsız asset'lere ayrılır:

1. **Sheet A — Atmosfer + yollar**: 14 parça.
2. **Sheet B — Yüzen adalar**: 7 parça.
3. **Sheet C — Landmark 1–5**: Rüzgâr Kapısı → Fırtına Kulesi.
4. **Sheet D — Landmark 6–10**: Hava Gemisi Limanı → Güneş Sarayı.
5. **Sheet E — Node UI + dekor**: 17 parça.

Bu yöntem WORK V2'ye uygundur: tek tek 48 üretim döngüsü yerine toplu stil üretimi, toplu QA ve yalnız başarısız parçanın yeniden üretimi kullanılır.

## Stil sözleşmesi

- Açık gök mavisi / camgöbeği / turkuaz ana dünya.
- Canlı ama doğal yeşil adalar.
- Sarı / turuncu sıcak vurgu; pembe / mercan yalnız destek.
- Parlak beyaz, yumuşak hacimli bulutlar.
- Sevimli ve premium 2D/3D hibrit illüstrasyon hissi; ağır gerçekçilik yok.
- Silüetler mobilde tek bakışta okunmalı.
- Fırtına Kulesi dramatik olabilir fakat korkutucu/karanlık olmamalı.
- Güneş Sarayı en büyük ve ödüllendirici görsel odak olmalı.
- Gizli Ada bonus node'u normal rota node'larından görsel olarak özel ama rota akışını bozmayacak biçimde ayrılmalı.

## Runtime / progression sınırı

- Bölüm 8 `Gizli Ada` bonus node'dur.
- Bölüm 7 sonrası bonus 8 ve normal 9 birlikte erişilebilir olmalıdır; bonus 8, node 9 için zorunlu kapı değildir.
- Node 10, node 9 tamamlanmadan kilitli kalır.
- Bu progression davranışı asset içine bake edilmez; runtime state ile uygulanır.

## Bitti ölçütü — asset üretim aşaması

Asset paketi ancak şu koşullarla tamamlanmış sayılır:

1. 48 atomik asset'in tamamı dosya adlarıyla mevcut.
2. Şeffaflık/kenar temizliği ve aynı ışık yönü korunmuş.
3. Beş sheet arasında stil tutarlılığı var.
4. 1080×1920 rota mock'ında 10 node açıkça okunuyor.
5. Node active/completed/locked/bonus state'leri birbirinden net ayrılıyor.
6. Dinamik metin/numara/yıldız asset içine bake edilmemiş.
7. Flutter veya APK entegrasyonuna geçmeden önce Levent rota mock'ını görsel olarak onaylıyor.

## Sonraki sıra

1. Beş sprite sheet için üretim prompt/kompozisyonu hazırla.
2. Sheet A–E üret.
3. Asset'leri ayır ve toplu görsel QA yap.
4. 1080×1920 statik rota mock'ı oluştur.
5. Levent görsel kabulü sonrası Flutter entegrasyon branch'ine geç.
