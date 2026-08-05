# BoardMap parity report

**Result:** `PASS` — 67/67 nodes match.

- Live source: `lib/main.dart`
- Live source SHA-256: `8bdd882fa50f670bfba509a4cfafdce5d2fb237e96a005cae259f17a3677419a`
- Coordinate epsilon: `1e-06`
- Maximum coordinate delta: `0.0`

## Direction and badge mapping

| Direction | Badge node | Category | Inner nodes |
|---|---:|---|---|
| Kuzey | 1 | Coğrafya | 37, 38, 39, 40, 41 |
| Kuzeydoğu | 7 | Eğlence | 42, 43, 44, 45, 46 |
| Güneydoğu | 13 | Tarih | 47, 48, 49, 50, 51 |
| Güney | 19 | Sanat & Edebiyat | 52, 53, 54, 55, 56 |
| Güneybatı | 25 | Bilim & Doğa | 57, 58, 59, 60, 61 |
| Kuzeybatı | 31 | Spor | 62, 63, 64, 65, 66 |

- South/bottom inner path: `[52, 53, 54, 55, 56]`
- Sport badge: node `31`, direction `Kuzeybatı`

## Checks

- `node_ids`: PASS
- `node_types`: PASS
- `category_indexes`: PASS
- `badge_states`: PASS
- `connections`: PASS
- `outer_ring_order`: PASS
- `inner_arm_order`: PASS
- `coordinates_within_epsilon`: PASS
