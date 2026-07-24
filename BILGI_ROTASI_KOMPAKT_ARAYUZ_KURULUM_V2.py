#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

OLD_VERSION = "1.44.1+58"
NEW_VERSION = "1.45.0+59"
COMMIT_MESSAGE = "Mobil arayuzu kompakt ve sade hale getir"

ROOT = Path.cwd()

FILES = {
    "main": ROOT / "lib/main.dart",
    "nav": ROOT / "lib/main_navigation.dart",
    "daily": ROOT / "lib/daily_challenge.dart",
    "social": ROOT / "lib/social_features.dart",
    "access": ROOT / "lib/accessibility_settings.dart",
    "boost": ROOT / "lib/gameplay_boost.dart",
    "collection": ROOT / "lib/visual_collection.dart",
    "about": ROOT / "lib/about_privacy.dart",
    "pubspec": ROOT / "pubspec.yaml",
}

STAGE_PATHS = [
    "lib/main.dart",
    "lib/main_navigation.dart",
    "lib/daily_challenge.dart",
    "lib/social_features.dart",
    "lib/accessibility_settings.dart",
    "lib/gameplay_boost.dart",
    "lib/visual_collection.dart",
    "lib/about_privacy.dart",
    "pubspec.yaml",
]


def run(*args: str, check: bool = True, capture: bool = False):
    kwargs = {"cwd": ROOT, "text": True, "check": check}
    if capture:
        kwargs["stdout"] = subprocess.PIPE
        kwargs["stderr"] = subprocess.PIPE
    return subprocess.run(args, **kwargs)


def out(*args: str) -> str:
    return run(*args, capture=True).stdout.strip()


def fail(message: str) -> None:
    raise RuntimeError(message)


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        fail(f"{label}: beklenen parça {count} kez bulundu.")
    return text.replace(old, new, 1)


def replace_at_least(
    text: str,
    old: str,
    new: str,
    label: str,
    minimum: int = 1,
) -> str:
    count = text.count(old)
    if count < minimum:
        fail(f"{label}: beklenen en az {minimum}, bulunan {count}.")
    return text.replace(old, new)


def segment(
    text: str,
    start_marker: str,
    end_marker: str,
    label: str,
) -> tuple[str, str, str]:
    start = text.find(start_marker)
    if start < 0:
        fail(f"{label}: başlangıç bulunamadı.")
    end = text.find(end_marker, start + len(start_marker))
    if end < 0:
        fail(f"{label}: bitiş bulunamadı.")
    return text[:start], text[start:end], text[end:]


def apply_segment(
    text: str,
    start_marker: str,
    end_marker: str,
    replacements: list[tuple[str, str, int]],
    label: str,
) -> str:
    before, body, after = segment(
        text,
        start_marker,
        end_marker,
        label,
    )
    for old, new, minimum in replacements:
        body = replace_at_least(
            body,
            old,
            new,
            f"{label} / {old[:45]!r}",
            minimum,
        )
    return before + body + after


def apply_tail(
    text: str,
    start_marker: str,
    replacements: list[tuple[str, str, int]],
    label: str,
) -> str:
    start = text.find(start_marker)
    if start < 0:
        fail(f"{label}: başlangıç bulunamadı.")

    before = text[:start]
    body = text[start:]

    for old, new, minimum in replacements:
        body = replace_at_least(
            body,
            old,
            new,
            f"{label} / {old[:45]!r}",
            minimum,
        )

    return before + body


def ensure_repo() -> None:
    if not (ROOT / ".git").exists():
        fail(
            "Bu dosyayı Codespaces içinde BilgiRotasi "
            "depo kökünde çalıştır."
        )

    if out("git", "branch", "--show-current") != "main":
        fail("Aktif dal main olmalı.")

    for path in FILES.values():
        if not path.exists():
            fail(f"Gerekli dosya yok: {path.relative_to(ROOT)}")

    pubspec = FILES["pubspec"].read_text(encoding="utf-8")
    match = re.search(r"(?m)^version:\s*([^\s]+)\s*$", pubspec)
    current = match.group(1) if match else None
    if current != OLD_VERSION:
        fail(
            f"Beklenen sürüm {OLD_VERSION}; mevcut sürüm {current!r}."
        )

    for relative in STAGE_PATHS:
        if out("git", "status", "--porcelain", "--", relative):
            fail(
                f"{relative} dosyasında yerel değişiklik var. "
                "Üzerine yazılmadı."
            )

    if out(
        "git",
        "status",
        "--porcelain",
        "--",
        "assets/questions.json",
    ):
        fail(
            "assets/questions.json yerelde değiştirilmiş. "
            "Arayüz ve soru çalışması karıştırılmadı."
        )


def patch_main(text: str) -> str:
    text = apply_segment(
        text,
        "class _HomeScreenState extends State<HomeScreen> {",
        "class PlayerSetupScreen",
        [
            (
                "padding: const EdgeInsets.fromLTRB(20, 18, 20, 26)",
                "padding: const EdgeInsets.fromLTRB(16, 10, 16, 22)",
                1,
            ),
            ("const SizedBox(height: 18)", "const SizedBox(height: 12)", 2),
            ("const SizedBox(height: 14)", "const SizedBox(height: 10)", 2),
            ("const SizedBox(height: 16)", "const SizedBox(height: 12)", 2),
            ("const SizedBox(height: 20)", "const SizedBox(height: 16)", 1),
            ("width: 118,", "width: 84,", 1),
            ("height: 118,", "height: 84,", 1),
            ("padding: const EdgeInsets.all(6)", "padding: const EdgeInsets.all(4)", 1),
            ("blurRadius: 28,", "blurRadius: 20,", 1),
            ("spreadRadius: 3,", "spreadRadius: 1,", 1),
            ("fontSize: 31,", "fontSize: 26,", 1),
            ("fontSize: 15,", "fontSize: 13,", 1),
            ("padding: const EdgeInsets.all(22)", "padding: const EdgeInsets.all(16)", 1),
            ("BorderRadius.circular(28)", "BorderRadius.circular(22)", 1),
            ("style: TextStyle(fontSize: 36)", "style: TextStyle(fontSize: 29)", 1),
            ("fontSize: 23,", "fontSize: 20,", 1),
            ("minimumSize: const Size.fromHeight(56)", "minimumSize: const Size.fromHeight(50)", 1),
            ("fontSize: 16,", "fontSize: 14,", 1),
            ("Bilgi Rotası • Sürüm 1.43.1", "Bilgi Rotası • Sürüm 1.45.0", 1),
        ],
        "Ana sayfa",
    )
    return text


def patch_daily(text: str) -> str:
    return apply_segment(
        text,
        "class _DailyChallengeHomeCardState",
        "class DailyChallengeHubScreen",
        [
            ("padding: const EdgeInsets.all(19)", "padding: const EdgeInsets.all(15)", 1),
            ("BorderRadius.circular(26)", "BorderRadius.circular(22)", 1),
            ("blurRadius: 16,", "blurRadius: 12,", 1),
            ("offset: Offset(0, 8)", "offset: Offset(0, 6)", 1),
            ("style: const TextStyle(fontSize: 40)", "style: const TextStyle(fontSize: 31)", 1),
            ("const SizedBox(width: 12)", "const SizedBox(width: 10)", 1),
            ("fontSize: 20,", "fontSize: 17,", 1),
            ("const SizedBox(height: 14)", "const SizedBox(height: 10)", 1),
            (
                "foregroundColor: const Color(0xFF3A2448),\n                ),",
                "foregroundColor: const Color(0xFF3A2448),\n"
                "                  minimumSize: const Size.fromHeight(47),\n"
                "                  visualDensity: VisualDensity.compact,\n"
                "                ),",
                1,
            ),
        ],
        "Ana sayfa günlük görev kartı",
    )


def patch_nav(text: str) -> str:
    text = replace_once(
        text,
        "'Ses, görünüm, erişilebilirlik ve teknik araçlar',",
        "'Ses, görünüm, erişilebilirlik ve oyun tercihleri',",
        "Ana menü ayarlar açıklaması",
    )
    text = replace_once(
        text,
        "'Tahta temalarını, favori piyonu ve '\n"
        "              'ses atmosferini seç.'",
        "'Tahta temalarını ve favori piyonu seç.'",
        "Kariyer koleksiyon açıklaması",
    )
    text = replace_once(
        text,
        "'Ses, görünüm, erişilebilirlik, jokerler ve '\n"
        "          'teknik araçlar artık tek bölümde.'",
        "'Ses, görünüm, erişilebilirlik ve oyun tercihleri '\n"
        "          'tek bölümde.'",
        "Ayar merkezi açıklaması",
    )
    text = replace_once(
        text,
        "title: 'Tema, Piyon & Ses Atmosferi',",
        "title: 'Tema & Piyon',",
        "Tema ayarı adı",
    )

    health = """        _HubActionCard(
          emoji: '🛡️',
          title: 'Sistem Sağlığı & Teknik Kontrol',
          description:
              'Kayıt yedeğini, soru bankasını ve '
              'teknik hata günlüğünü kontrol et.',
          accent: const Color(0xFF047857),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SystemHealthScreen(
                questionBank: questionBank,
              ),
            ),
          ),
        ),
"""
    text = replace_once(
        text,
        health,
        "",
        "Sistem Sağlığı kullanıcı kartı",
    )

    text = apply_segment(
        text,
        "class _MainNavigationCard extends StatelessWidget {",
        "class PlayCenterScreen",
        [
            ("fontSize: 19,", "fontSize: 17,", 1),
            ("fontSize: 11,", "fontSize: 10.5,", 1),
            ("BorderRadius.circular(23)", "BorderRadius.circular(19)", 2),
            ("padding: const EdgeInsets.all(16)", "padding: const EdgeInsets.all(13)", 1),
            ("blurRadius: 12,", "blurRadius: 9,", 1),
            ("offset: Offset(0, 6)", "offset: Offset(0, 4)", 1),
            ("style: const TextStyle(fontSize: 39)", "style: const TextStyle(fontSize: 31)", 1),
            ("const SizedBox(width: 13)", "const SizedBox(width: 10)", 1),
            ("style: const TextStyle(fontSize: 36)", "style: const TextStyle(fontSize: 29)", 1),
            ("const SizedBox(height: 9)", "const SizedBox(height: 6)", 1),
            ("const SizedBox(height: 10)", "const SizedBox(height: 6)", 1),
        ],
        "Ana bölüm kartları",
    )

    text = apply_segment(
        text,
        "class _NavigationHubScaffold extends StatelessWidget {",
        "class _HubActionCard extends StatelessWidget {",
        [
            ("18,\n              16,\n              18,\n              28,", "14,\n              10,\n              14,\n              22,", 1),
            ("padding: const EdgeInsets.all(22)", "padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13)", 1),
            ("BorderRadius.circular(28)", "BorderRadius.circular(21)", 1),
            ("blurRadius: 14,", "blurRadius: 10,", 1),
            ("offset: Offset(0, 7)", "offset: Offset(0, 5)", 1),
            ("style: const TextStyle(fontSize: 54)", "style: const TextStyle(fontSize: 36)", 1),
            ("fontSize: 24,", "fontSize: 20,", 1),
            ("const SizedBox(height: 16)", "const SizedBox(height: 10)", 1),
            ("const SizedBox(height: 11)", "const SizedBox(height: 8)", 1),
        ],
        "Ortak bölüm ekranları",
    )

    text = apply_tail(
        text,
        "class _HubActionCard extends StatelessWidget {",
        [
            ("padding: const EdgeInsets.all(16)", "padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11)", 1),
            ("width: 54,", "width: 46,", 1),
            ("height: 54,", "height: 46,", 1),
            ("BorderRadius.circular(16)", "BorderRadius.circular(14)", 1),
            ("style: const TextStyle(fontSize: 29)", "style: const TextStyle(fontSize: 24)", 1),
            ("const SizedBox(width: 13)", "const SizedBox(width: 11)", 1),
            ("fontSize: 17,", "fontSize: 15.5,", 1),
            ("fontSize: 12,", "fontSize: 11,", 1),
        ],
        "Ortak ayar kartları",
    )

    return text


def patch_social(text: str) -> str:
    info = """              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0x16FFFFFF),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: const Color(0x33FFFFFF),
                  ),
                ),
                child: const Text(
                  'Meydan Okuma artık Oyna bölümünde. Sosyal bölümünde '
                  'aile rekorları ve paylaşım araçları bulunur.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD8CCEA),
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
"""
    text = replace_once(
        text,
        info,
        "",
        "Sosyal alt açıklama kutusu",
    )
    return apply_segment(
        text,
        "class SocialHubScreen extends StatelessWidget {",
        "class FamilyRecordsScreen",
        [
            ("18,\n              16,\n              18,\n              28,", "14,\n              10,\n              14,\n              22,", 1),
            ("padding: const EdgeInsets.all(22)", "padding: const EdgeInsets.all(15)", 1),
            ("BorderRadius.circular(28)", "BorderRadius.circular(21)", 1),
            ("style: TextStyle(fontSize: 52)", "style: TextStyle(fontSize: 38)", 1),
            ("fontSize: 20,", "fontSize: 17,", 1),
            ("fontSize: 24,", "fontSize: 20,", 1),
            ("const SizedBox(height: 16)", "const SizedBox(height: 11)", 1),
            ("const SizedBox(height: 12)", "const SizedBox(height: 8)", 1),
            ("BorderRadius.circular(24)", "BorderRadius.circular(20)", 2),
            ("padding: const EdgeInsets.all(18)", "padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)", 1),
            ("style: const TextStyle(fontSize: 44)", "style: const TextStyle(fontSize: 34)", 1),
            ("fontSize: 12,", "fontSize: 11,", 1),
        ],
        "Sosyal ekran",
    )


def patch_access(text: str) -> str:
    return apply_segment(
        text,
        "class _AccessibilitySettingsScreenState",
        "class AccessibilityCategoryLegend",
        [
            ("18,\n          16,\n          18,\n          28,", "14,\n          10,\n          14,\n          22,", 1),
            ("const SizedBox(height: 18)", "const SizedBox(height: 12)", 4),
            ("padding: const EdgeInsets.all(21)", "padding: const EdgeInsets.all(14)", 1),
            ("BorderRadius.circular(27)", "BorderRadius.circular(20)", 1),
            ("style: TextStyle(fontSize: 45)", "style: TextStyle(fontSize: 32)", 1),
            ("fontSize: 23,", "fontSize: 19,", 1),
            ("fontSize: 20,", "fontSize: 16,", 1),
            ("padding: const EdgeInsets.all(15)", "padding: const EdgeInsets.all(12)", 4),
            ("width: 45,", "width: 38,", 1),
            ("height: 45,", "height: 38,", 1),
            ("style: TextStyle(fontSize: 29)", "style: TextStyle(fontSize: 24)", 1),
            ("margin: const EdgeInsets.only(bottom: 10)", "margin: const EdgeInsets.only(bottom: 7)", 3),
            ("style: const TextStyle(fontSize: 30)", "style: const TextStyle(fontSize: 24)", 1),
            (
                "child: SwitchListTile(\n        value: value,",
                "child: SwitchListTile(\n"
                "        value: value,\n"
                "        dense: true,\n"
                "        visualDensity: VisualDensity.compact,",
                1,
            ),
        ],
        "Genel ayarlar ekranı",
    )


def patch_boost(text: str) -> str:
    return apply_segment(
        text,
        "class _GameplayBoostSettingsScreenState",
        "enum JokerKind",
        [
            ("18,\n          16,\n          18,\n          28,", "14,\n          10,\n          14,\n          22,", 1),
            ("padding: const EdgeInsets.all(20)", "padding: const EdgeInsets.all(14)", 1),
            ("BorderRadius.circular(20)", "BorderRadius.circular(17)", 1),
            ("BorderRadius.circular(26)", "BorderRadius.circular(20)", 1),
            ("style: TextStyle(fontSize: 43)", "style: TextStyle(fontSize: 32)", 1),
            ("fontSize: 19,", "fontSize: 16,", 1),
            ("fontSize: 22,", "fontSize: 19,", 1),
            ("const SizedBox(height: 16)", "const SizedBox(height: 11)", 2),
            ("padding: const EdgeInsets.all(16)", "padding: const EdgeInsets.all(13)", 1),
            ("margin: const EdgeInsets.only(bottom: 10)", "margin: const EdgeInsets.only(bottom: 7)", 1),
            ("style: const TextStyle(fontSize: 28)", "style: const TextStyle(fontSize: 24)", 1),
            (
                "child: SwitchListTile(\n        value: value,",
                "child: SwitchListTile(\n"
                "        value: value,\n"
                "        dense: true,\n"
                "        visualDensity: VisualDensity.compact,",
                1,
            ),
        ],
        "Canlı oyun ayarları",
    )


def patch_collection(text: str) -> str:
    return apply_segment(
        text,
        "class _CollectionScreenState",
        "class ThemePreviewScreen",
        [
            ("18,\n              16,\n              18,\n              28,", "14,\n              10,\n              14,\n              22,", 1),
            ("const SizedBox(height: 18)", "const SizedBox(height: 12)", 2),
            ("fontSize: 21,", "fontSize: 17,", 2),
            ("padding: const EdgeInsets.all(22)", "padding: const EdgeInsets.all(15)", 1),
            ("BorderRadius.circular(28)", "BorderRadius.circular(21)", 1),
            ("style: const TextStyle(fontSize: 58)", "style: const TextStyle(fontSize: 38)", 1),
            ("fontSize: 24,", "fontSize: 19,", 1),
            ("margin: const EdgeInsets.only(bottom: 9)", "margin: const EdgeInsets.only(bottom: 7)", 1),
            ("padding: const EdgeInsets.fromLTRB(14, 14, 10, 8)", "padding: const EdgeInsets.fromLTRB(12, 11, 9, 6)", 1),
            ("width: 57,", "width: 48,", 1),
            ("height: 57,", "height: 48,", 1),
            ("style: const TextStyle(fontSize: 28)", "style: const TextStyle(fontSize: 24)", 1),
            ("crossAxisSpacing: 9,", "crossAxisSpacing: 7,", 1),
            ("mainAxisSpacing: 9,", "mainAxisSpacing: 7,", 1),
            ("childAspectRatio: 0.76,", "childAspectRatio: 0.86,", 1),
            ("padding: const EdgeInsets.all(8)", "padding: const EdgeInsets.all(6)", 1),
            ("width: 58,", "width: 50,", 1),
            ("height: 72,", "height: 62,", 1),
            (
                "SwitchListTile(\n                value:",
                "SwitchListTile(\n"
                "                dense: true,\n"
                "                visualDensity: VisualDensity.compact,\n"
                "                value:",
                1,
            ),
            ("style: TextStyle(fontSize: 30)", "style: TextStyle(fontSize: 24)", 1),
        ],
        "Koleksiyon ekranı",
    )


def patch_about(text: str) -> str:
    technical_section = """          const SizedBox(height: 10),
          _section(
            emoji: '🛠️',
            title: 'Teknik kontrol',
            text:
                'Soru bankası, kayıt yedeği ve teknik hata '
                'günlüğü Sistem Sağlığı ekranından kontrol '
                'edilebilir.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SystemHealthScreen(
                    questionBank: questionBank,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.health_and_safety_rounded,
            ),
            label: const Text(
              'Sistem Sağlığını Aç',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
"""
    replacement = """          const SizedBox(height: 8),
          _section(
            emoji: '🛡️',
            title: 'Otomatik koruma',
            text:
                'Oyun kayıtları yerel yedekle korunur. '
                'Teknik hata günlüğü ve kayıt kurtarma sistemi '
                'arka planda otomatik çalışır.',
          ),
"""
    text = replace_once(
        text,
        technical_section,
        replacement,
        "Hakkında ekranı teknik araç bağlantısı",
    )

    return apply_tail(
        text,
        "class AboutPrivacyScreen",
        [
            ("padding: const EdgeInsets.fromLTRB(18, 16, 18, 28)", "padding: const EdgeInsets.fromLTRB(14, 10, 14, 22)", 1),
            ("padding: const EdgeInsets.all(22)", "padding: const EdgeInsets.all(15)", 1),
            ("BorderRadius.circular(21)", "BorderRadius.circular(17)", 1),
            ("BorderRadius.circular(28)", "BorderRadius.circular(21)", 1),
            ("width: 92,", "width: 64,", 1),
            ("height: 92,", "height: 64,", 1),
            ("fontSize: 26,", "fontSize: 20,", 1),
            ("Sürüm 1.43.1+56", "Sürüm 1.45.0+59", 1),
            ("const SizedBox(height: 16)", "const SizedBox(height: 11)", 1),
            ("const SizedBox(height: 10)", "const SizedBox(height: 8)", 3),
            ("padding: const EdgeInsets.all(17)", "padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11)", 1),
            ("style: const TextStyle(fontSize: 30)", "style: const TextStyle(fontSize: 24)", 1),
            ("fontSize: 17,", "fontSize: 15,", 1),
            ("height: 1.42,", "height: 1.3,\n                  fontSize: 11.5,", 1),
        ],
        "Hakkında ve Gizlilik ekranı",
    )


def verify() -> None:
    visible_files = [
        FILES["nav"],
        FILES["social"],
        FILES["about"],
    ]
    combined = "\n".join(
        p.read_text(encoding="utf-8")
        for p in visible_files
    )
    forbidden = [
        "Tema, Piyon & Ses Atmosferi",
        "Meydan Okuma artık Oyna bölümünde",
        "Sistem Sağlığını Aç",
    ]
    remaining = [item for item in forbidden if item in combined]
    if remaining:
        fail("Kaldırılmamış metinler: " + ", ".join(remaining))


def main() -> None:
    ensure_repo()
    originals = {
        path: path.read_bytes()
        for path in FILES.values()
    }
    committed = False

    try:
        patches = {
            "main": patch_main,
            "daily": patch_daily,
            "nav": patch_nav,
            "social": patch_social,
            "access": patch_access,
            "boost": patch_boost,
            "collection": patch_collection,
            "about": patch_about,
        }

        for key, patcher in patches.items():
            path = FILES[key]
            path.write_text(
                patcher(path.read_text(encoding="utf-8")),
                encoding="utf-8",
            )

        pubspec = FILES["pubspec"].read_text(encoding="utf-8")
        FILES["pubspec"].write_text(
            replace_once(
                pubspec,
                f"version: {OLD_VERSION}",
                f"version: {NEW_VERSION}",
                "Sürüm",
            ),
            encoding="utf-8",
        )

        verify()

        dart = shutil.which("dart")
        flutter = shutil.which("flutter")

        if dart:
            run(dart, "format", *STAGE_PATHS[:-1])
        else:
            print("UYARI: dart bulunamadı; format atlandı.")

        run("git", "diff", "--check", "--", *STAGE_PATHS)

        if flutter:
            run(flutter, "pub", "get")
            run(flutter, "analyze")
            run(flutter, "test")
        else:
            print("UYARI: flutter bulunamadı; kontroller atlandı.")

        if out(
            "git",
            "status",
            "--porcelain",
            "--",
            "assets/questions.json",
        ):
            fail("Soru dosyası değişti.")

        run("git", "add", "--", *STAGE_PATHS)

        staged = out(
            "git",
            "diff",
            "--cached",
            "--name-only",
            "--",
            *STAGE_PATHS,
        )
        if not staged:
            fail("Değişiklik oluşmadı.")

        run(
            "git",
            "commit",
            "-m",
            COMMIT_MESSAGE,
            "--",
            *STAGE_PATHS,
        )
        committed = True

        try:
            run("git", "push", "origin", "main")
        except Exception:
            print(
                "\nCommit oluşturuldu fakat push başarısız.\n"
                "Sonra çalıştır: git push origin main\n"
            )
            raise

        print(
            "\n✅ Kompakt mobil arayüz tamamlandı.\n"
            f"✅ Sürüm: {NEW_VERSION}\n"
            "✅ Ana sayfa küçültüldü.\n"
            "✅ Günlük görev kartı küçültüldü.\n"
            "✅ Ayarlar ve alt ekranlar sıkılaştırıldı.\n"
            "✅ Ses Atmosferi metinleri temizlendi.\n"
            "✅ Sistem Sağlığı kullanıcı menüsünden kaldırıldı.\n"
            "✅ Otomatik yedek, hata kaydı ve kurtarma korundu.\n"
            "✅ Sosyal alt açıklama kutusu kaldırıldı.\n"
            "✅ Soru dosyasına dokunulmadı.\n"
            "✅ Commit main dalına gönderildi.\n"
        )

    except Exception as error:
        if not committed:
            for path, content in originals.items():
                path.write_bytes(content)
            run(
                "git",
                "reset",
                "--quiet",
                "--",
                *STAGE_PATHS,
                check=False,
            )
            print("\nHedef dosyalar eski hâline döndürüldü.")

        print(f"\n❌ Kurulum başarısız: {error}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
