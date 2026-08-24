from pathlib import Path
import os

ROOT = Path.cwd()
BRANCH = "feat/kelime-avi-baslangic-limani-asset-first-20260824"
RUN_ID = os.environ.get("GITHUB_RUN_ID", "DOĞRULANACAK")


def read(path):
    return (ROOT / path).read_text(encoding="utf-8")


def write(path, text):
    p = ROOT / path
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text, encoding="utf-8")


def replace_once(path, old, new, label):
    text = read(path)
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"{label}: expected exactly 1 occurrence, found {count}")
    write(path, text.replace(old, new, 1))


def prepend_section(path, marker, section):
    text = read(path)
    if marker in text:
        print(f"{path}: marker already present; skipping.")
        return
    first_nl = text.find("\n")
    if first_nl < 0:
        raise RuntimeError(f"{path}: heading newline not found")
    insert_at = first_nl + 1
    updated = (
        text[:insert_at]
        + "\n"
        + section.strip()
        + "\n\n"
        + text[insert_at:].lstrip("\n")
    )
    write(path, updated)


route_path = "lib/word_hunt/word_hunt_route_stop.dart"
route = read(route_path)
import_line = "import 'word_hunt_production_assets.dart';"
if import_line not in route:
    old = "import 'word_hunt_models.dart';\n"
    new = (
        "import 'word_hunt_models.dart';\n"
        "import 'word_hunt_production_assets.dart';\n"
    )
    if route.count(old) != 1:
        raise RuntimeError("route_stop import anchor mismatch")
    route = route.replace(old, new, 1)

start_marker = "class _RouteStopOrb extends StatelessWidget {"
end_marker = "\nclass _MedallionFramePainter extends CustomPainter {"
start = route.find(start_marker)
end = route.find(end_marker, start)
if start < 0 or end < 0:
    raise RuntimeError("_RouteStopOrb section markers not found")

new_orb = r'''class _RouteStopOrb extends StatelessWidget {
  const _RouteStopOrb({
    required this.level,
    required this.unlocked,
    required this.lockedFinal,
    required this.accent,
    required this.theme,
    required this.diameter,
  });

  final WordHuntLevelDefinition level;
  final bool unlocked;
  final bool lockedFinal;
  final Color accent;
  final WordHuntRouteStopTheme theme;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final numberSize = switch (level.type) {
      WordHuntLevelType.normal => 30.0,
      WordHuntLevelType.challenge => 39.0,
      WordHuntLevelType.bonus => 40.0,
      WordHuntLevelType.routeFinal => 58.0,
    };
    final visuallyHighlighted = unlocked || lockedFinal;

    // Asset-first pilot: normal and locked-normal medallion bodies are real
    // production raster assets. Dynamic number/lock/stars remain code-driven.
    // Special 5/8/10 artwork remains transitional until its own production
    // assets are integrated in the next pilot step.
    final productionAsset =
        level.type == WordHuntLevelType.normal
            ? WordHuntProductionAssets.nodeFor(
              type: level.type,
              unlocked: unlocked,
            )
            : null;

    return SizedBox.square(
      key: Key('word_hunt_route_stop_orb_${level.index}'),
      dimension: diameter,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          if (productionAsset != null)
            Image.asset(
              productionAsset,
              key: Key('word_hunt_route_stop_asset_${level.index}'),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            )
          else
            CustomPaint(
              key: Key('word_hunt_route_stop_frame_${level.index}'),
              painter: _MedallionFramePainter(
                accent: accent,
                surfaceOuter: theme.surfaceOuter,
                surfaceInner: theme.surfaceInner,
                unlocked: visuallyHighlighted,
                type: level.type,
              ),
            ),
          Center(
            child:
                visuallyHighlighted
                    ? Text(
                      '${level.index}',
                      key: Key('word_hunt_route_stop_number_${level.index}'),
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: numberSize,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        shadows: const <Shadow>[
                          Shadow(
                            color: Color(0xDD000000),
                            blurRadius: 3,
                            offset: Offset(0, 1.5),
                          ),
                        ],
                      ),
                    )
                    : Icon(
                      Icons.lock_rounded,
                      key: Key('word_hunt_route_stop_lock_${level.index}'),
                      color: theme.lockColor,
                      size: 34,
                      shadows: const <Shadow>[
                        Shadow(color: Color(0xCC000000), blurRadius: 3),
                      ],
                    ),
          ),
          if (level.type == WordHuntLevelType.routeFinal)
            Positioned(
              key: Key('word_hunt_route_stop_crown_${level.index}'),
              top: -42,
              left: -6,
              width: 154,
              height: 94,
              child: CustomPaint(painter: _FinalCrownPainter(accent: accent)),
            ),
        ],
      ),
    );
  }
}
'''
route = route[:start] + new_orb + route[end:]
write(route_path, route)

test_path = "test/word_hunt_route_stop_test.dart"
old_assert = '''    expect(
      find.byKey(const Key('word_hunt_route_stop_frame_1')),
      findsOneWidget,
      reason: 'Düz daire yerine dekoratif medalyon çerçevesi bulunmalı.',
    );

    final number = tester.widget<Text>(
'''
new_assert = '''    expect(
      find.byKey(const Key('word_hunt_route_stop_asset_1')),
      findsOneWidget,
      reason: 'Normal durak final render yolunda production asset kullanmalı.',
    );
    final normalImage = tester.widget<Image>(
      find.byKey(const Key('word_hunt_route_stop_asset_1')),
    );
    expect(
      (normalImage.image as AssetImage).assetName,
      'assets/word_hunt/baslangic_limani/node_normal.webp',
    );
    expect(
      find.byKey(const Key('word_hunt_route_stop_frame_1')),
      findsNothing,
      reason: 'Normal production medalyonu procedural painter kullanmamalı.',
    );

    final number = tester.widget<Text>(
'''
replace_once(test_path, old_assert, new_assert, "normal asset assertion")

old_locked = '''    expect(
      find.byKey(const Key('word_hunt_route_stop_lock_9')),
      findsOneWidget,
    );
'''
new_locked = '''    expect(
      find.byKey(const Key('word_hunt_route_stop_lock_9')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_route_stop_asset_9')),
      findsOneWidget,
    );
    final lockedImage = tester.widget<Image>(
      find.byKey(const Key('word_hunt_route_stop_asset_9')),
    );
    expect(
      (lockedImage.image as AssetImage).assetName,
      'assets/word_hunt/baslangic_limani/node_locked.webp',
    );
    expect(
      find.byKey(const Key('word_hunt_route_stop_frame_9')),
      findsNothing,
      reason: 'Kilitli normal production medalyonu procedural painter kullanmamalı.',
    );
'''
replace_once(test_path, old_locked, new_locked, "locked asset assertion")

status_section = f'''
## 0Q. PR #132 Başlangıç Limanı asset-first normal/kilitli medalyon entegrasyonu — 24 Ağustos 2026

- Bağlayıcı standart PR #131: `REFERENCE → PRODUCTION-READY LAYERED ASSETS → THIN INTERACTION CODE`.
- Branch: `{BRANCH}`; Draft PR #132; merge yapılmadı.
- İlk gerçek raster production asset'ler: `assets/word_hunt/baslangic_limani/node_normal.webp` ve `node_locked.webp`.
- Normal ve kilitli normal durakların medalyon gövdesi `Image.asset` ile production asset'ten çizilir; bölüm numarası, kilit ikonu, yıldızlar, progression ve interaction dinamik kalır.
- 1080×1920 canonical geometri, 1–10 koordinatları, route geometry ve progression değiştirilmedi.
- 5/8/10 özel medalyon/plaka/taç katmanı bu adımda hâlâ geçici procedural render kullanır; final görsel PASS değildir.
- Uygulama/test workflow run: `{RUN_ID}`. Commit yalnız focused test + analyze + diff/scope kontrolleri geçerse push edilir.

**Durum:** İlk asset-backed dikey dilim uygulanıyor; özel production asset seti, Android gerçek ekran kanıtı ve Levent görsel kabulü açık. **MERGE YOK.**
'''
prepend_section(
    "docs/project-memory/BILGI_ROTASI_DURUM.md",
    "## 0Q. PR #132 Başlangıç Limanı asset-first normal/kilitli medalyon entegrasyonu",
    status_section,
)

task_section = f'''
## 0P - 24 Ağustos 2026 / PR #132 Başlangıç Limanı asset-first pilotu

**Durum:** UYGULANIYOR / Draft PR #132 / MERGE YOK

- [x] PR #110 güncel teknik çekirdeğinden ayrı asset-first branch açıldı.
- [x] PR #131 bağlayıcı görsel üretim standardı esas alındı.
- [x] MASTER ART'tan numarasız `node_normal.webp` ve kilit ikonu gömülmemiş `node_locked.webp` production raster asset'leri üretildi.
- [x] Normal/kilitli normal medalyon render yolu `Image.asset` tabanlı hale getirildi; sayı/kilit/yıldız/progression dinamik bırakıldı.
- [x] Canonical transform, progression/unlock, 1–10 koordinatları ve route geometry değiştirilmedi.
- [x] Focused test + analyze + diff/scope kontrolü workflow `{RUN_ID}` içinde commit öncesi kapı olarak çalışır.
- [ ] Challenge/bonus/final node asset'leri entegre edilecek.
- [ ] Challenge/bonus/final plaque, final crown, compass ve book production asset'leri entegre edilecek.
- [ ] Procedural premium-art final render yolundan tamamen çıkarılacak.
- [ ] Exact-head CI kanıtı alınacak.
- [ ] Android 16 gerçek screenshot referansla yan yana incelenecek.
- [ ] Levent açık görsel kabul verecek.
- [ ] Levent ayrıca açık merge onayı verecek.
'''
prepend_section(
    "docs/project-memory/GOREV_HAVUZU.md",
    "## 0P - 24 Ağustos 2026 / PR #132 Başlangıç Limanı asset-first pilotu",
    task_section,
)

decision_section = '''
## 0A0. Kelime Avı asset-first production görsel standardı — 24 Ağustos 2026

- PR #131 içindeki `görsel oyun üretimstandartı.md` Kelime Avı için bağlayıcıdır.
- Ana üretim zinciri: `REFERENCE → PRODUCTION-READY LAYERED ASSETS → THIN INTERACTION CODE`.
- Önceki kararlardaki premium medalyon/plaka/taç/ikonların Flutter `CustomPainter` veya Dart Canvas ile final sanat olarak çizilmesi yaklaşımı bu konularda **GEÇERSİZ KILINDI**.
- Dinamik bölüm numarası, yıldız/kilit state'i, progression, interaction ve canonical koordinatlar kodda kalır.
- Başlangıç Limanı pilotunda ilk geçiş normal ve kilitli normal medalyon gövdeleridir.
- Teknik PASS görsel PASS değildir; Levent gerçek Android görüntüsünü açıkça kabul etmeden Ready/merge yoktur.
'''
prepend_section(
    "docs/project-memory/KARARLAR.md",
    "## 0A0. Kelime Avı asset-first production görsel standardı",
    decision_section,
)

open_section = '''
## PR #132 / Başlangıç Limanı asset-first açıkları — 24 Ağustos 2026

- Challenge, bonus ve final medalyon asset entegrasyonu açık.
- `MEYDAN OKUMA`, `BONUS DURAK`, `ROTA FİNALİ` plaque asset entegrasyonu açık.
- Final crown, compass ve book production asset entegrasyonu açık.
- Procedural premium-art sınıflarının final render yolundan tamamen çıkarılması açık.
- Exact-head CI ve Android 16 screenshot kanıtı açık.
- Levent'in nihai görsel kabulü ve ayrıca merge onayı açık.
'''
prepend_section(
    "docs/project-memory/ACIK_SORULAR_VE_DOGRULAMALAR.md",
    "## PR #132 / Başlangıç Limanı asset-first açıkları",
    open_section,
)

summary_path = "docs/project-memory/GENEL_PROJE_OZETI.md"
summary = read(summary_path)
summary_marker = "- İlk normal/kilitli medalyon production asset entegrasyonu:"
if summary_marker not in summary:
    anchor = "- Asset mapping testi: `test/word_hunt_production_assets_test.dart`.\n"
    if summary.count(anchor) != 1:
        raise RuntimeError("GENEL_PROJE_OZETI PR132 anchor mismatch")
    addition = (
        anchor
        + "- İlk normal/kilitli medalyon production asset entegrasyonu: "
        "`node_normal.webp` + `node_locked.webp`; render `Image.asset`, dinamik sayı/kilit/yıldız kodda.\n"
        + f"- Bu adımın test/apply workflow run'ı: `{RUN_ID}`; final özel asset seti ve Android görsel onayı açık.\n"
    )
    summary = summary.replace(anchor, addition, 1)
    write(summary_path, summary)

print("Asset-first normal/locked production render patch applied.")
