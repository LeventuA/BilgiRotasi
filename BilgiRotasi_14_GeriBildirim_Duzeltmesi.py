#!/usr/bin/env python3
from pathlib import Path
import copy
import json
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
QUALITY = Path("lib/question_quality.dart")
QUESTIONS = Path("assets/questions.json")
PUBSPEC = Path("pubspec.yaml")
REPORT = Path("reports/feedback_14_questions_20260723.txt")

REWRITES = json.loads('[{"id": "q4026", "categoryIndex": 5, "oldQuestion": "Rugby league sporunda bir takım sahada kaç oyuncuyla yer alır?", "oldOptions": ["21,0975", "6", "22", "13"], "oldAnswerIndex": 3, "question": "Rugby league maçında bir takım sahada kaç oyuncuyla yer alır?", "options": ["13", "11", "15", "7"], "answerIndex": 0, "difficulty": "Orta", "explanation": "Standart rugby league oyununda bir takım sahada 13 oyuncuyla yer alır.", "note": "Anlamsız 21,0975 seçeneği kaldırıldı; seçenekler geçerli oyuncu sayılarından oluşturuldu."}, {"id": "q52738", "categoryIndex": 3, "oldQuestion": "“Horatius Kardeşlerin Yemini” başlığında kaç kelime vardır?", "oldOptions": ["5", "4", "3", "2"], "oldAnswerIndex": 2, "question": "Horatius Kardeşlerin Yemini adlı tablonun ressamı kimdir?", "options": ["Jacques-Louis David", "Eugène Delacroix", "Théodore Géricault", "Jean-Auguste-Dominique Ingres"], "answerIndex": 0, "difficulty": "Orta", "explanation": "Horatius Kardeşlerin Yemini tablosunu Jacques-Louis David yapmıştır.", "note": "Başlıktaki kelimeleri saydıran düşük kaliteli soru, gerçek sanat bilgisiyle değiştirildi."}, {"id": "q51994", "categoryIndex": 3, "oldQuestion": "“Araba Sevdası” başlığının ilk kelimesi hangisidir?", "oldOptions": ["Sanat", "Eser", "Araba", "Roman"], "oldAnswerIndex": 2, "question": "Araba Sevdası romanının yazarı kimdir?", "options": ["Recaizade Mahmut Ekrem", "Namık Kemal", "Halit Ziya Uşaklıgil", "Şemsettin Sami"], "answerIndex": 0, "difficulty": "Kolay", "explanation": "Araba Sevdası romanını Recaizade Mahmut Ekrem yazmıştır.", "note": "Başlığın ilk kelimesini soran soru, eser–yazar bilgisiyle değiştirildi."}, {"id": "q15473", "categoryIndex": 2, "oldQuestion": "Londra Yaz Olimpiyat Oyunları sürecinin başlıca kurumu, ekibi veya kişisi hangisidir?", "oldOptions": ["Birleşmiş Milletler Genel Kurulu", "BP ve ABD makamları", "Uluslararası Olimpiyat Komitesi", "Nükleer Silahların Kaldırılması İçin Uluslararası Kampanya"], "oldAnswerIndex": 2, "question": "2012 Yaz Olimpiyatları hangi şehirde düzenlendi?", "options": ["Londra", "Atina", "Pekin", "Rio de Janeiro"], "answerIndex": 0, "difficulty": "Kolay", "explanation": "2012 Yaz Olimpiyatları Birleşik Krallık\'ın başkenti Londra\'da düzenlendi.", "note": "Belirsiz kurum–ekip–kişi kalıbı kaldırıldı; ev sahibi şehir doğrudan soruldu."}, {"id": "q52470", "categoryIndex": 2, "oldQuestion": "1318 yılı hangi on yıllık dönemde yer alır?", "oldOptions": ["1330\'li yıllar", "1300\'li yıllar", "1290\'li yıllar", "1310\'li yıllar"], "oldAnswerIndex": 3, "question": "Osmanlı Devleti\'nin kurucusu kimdir?", "options": ["Osman Gazi", "Orhan Gazi", "I. Murad", "Yıldırım Bayezid"], "answerIndex": 0, "difficulty": "Kolay", "explanation": "Osmanlı Devleti\'nin kurucusu Osman Gazi\'dir.", "note": "Yılı on yıllığa dönüştüren aritmetik soru, temel tarih bilgisiyle değiştirildi."}, {"id": "q6966", "categoryIndex": 5, "oldQuestion": "2024 Yaz Olimpiyatları hangi on yılda düzenlenmiştir?", "oldOptions": ["2020’lar", "1960’lar", "1930’lar", "1900’lar"], "oldAnswerIndex": 0, "question": "2024 Yaz Olimpiyatları hangi şehirde düzenlendi?", "options": ["Paris", "Tokyo", "Los Angeles", "Roma"], "answerIndex": 0, "difficulty": "Kolay", "explanation": "2024 Yaz Olimpiyatları Fransa\'nın başkenti Paris\'te düzenlendi.", "note": "Cevabı yıldan kolayca çıkarılan on yıl sorusu, ev sahibi şehir sorusuyla değiştirildi."}, {"id": "q43910", "categoryIndex": 2, "oldQuestion": "1904 yılı hangi yüzyılın içindedir?", "oldOptions": ["19. yüzyıl", "20. yüzyıl", "18. yüzyıl", "21. yüzyıl"], "oldAnswerIndex": 1, "question": "I. Dünya Savaşı hangi yılda başladı?", "options": ["1914", "1918", "1939", "1923"], "answerIndex": 0, "difficulty": "Kolay", "explanation": "I. Dünya Savaşı 1914 yılında başladı.", "note": "Yılı yüzyıla dönüştüren mekanik soru, doğrudan tarih bilgisiyle değiştirildi."}, {"id": "q14957", "categoryIndex": 5, "oldQuestion": "Su topu sporundaki “Bir takımın suda, kaleci dâhil, kaç oyuncusu bulunur?” kuralı ile Netbol sporundaki “Bir takım sahada kaç oyuncuyla yer alır?” kuralının ortak sayısal cevabı nedir?", "oldOptions": ["21", "7", "16", "15"], "oldAnswerIndex": 1, "question": "Su topunda bir takım oyun alanında aynı anda kaç oyuncuyla yer alır?", "options": ["7", "6", "8", "11"], "answerIndex": 0, "difficulty": "Orta", "explanation": "Su topunda bir takım oyun alanında aynı anda yedi oyuncuyla yer alır.", "note": "İki ayrı sporu aynı soruda birleştiren yapı kaldırıldı; tek bir spor kuralı soruldu."}, {"id": "q2603", "categoryIndex": 5, "oldQuestion": "Beyzboldan daha büyük top hangi sporla ilişkilidir?", "oldOptions": ["Softbol", "Squash", "Beyzbol", "On lobutlu bowling"], "oldAnswerIndex": 0, "question": "Softbol topu, beyzbol topuna göre genellikle nasıldır?", "options": ["Daha büyük çevreye sahiptir", "Daha küçük çevreye sahiptir", "Aynı çevreye sahiptir", "Köşeli bir şekle sahiptir"], "answerIndex": 0, "difficulty": "Orta", "explanation": "Standart softbol topu, beyzbol topuna göre daha büyük bir çevreye sahiptir.", "note": "Bowling topunun da koşulu sağlaması nedeniyle belirsiz olan soru, softbol–beyzbol karşılaştırmasına çevrildi."}]')
DIFFICULTY_UPDATES = json.loads('[{"id": "q3513", "categoryIndex": 2, "question": "Karanfil Devrimi hangi yılda gerçekleşmiştir?", "correctAnswer": "1974", "difficulty": "Orta", "note": "Tekil tarih bilgisi genel oyuncu kitlesi için Kolay değil, Orta kabul edildi."}, {"id": "q10306", "categoryIndex": 1, "question": "Dogville aşağıdaki yapım türlerinden hangisidir?", "correctAnswer": "Sinema filmi", "difficulty": "Orta", "note": "Niş yapım bilgisi Kolay\'dan Orta\'ya taşındı."}, {"id": "q5266", "categoryIndex": 0, "question": "Banff hangi kıtada veya coğrafi bölgede yer alır?", "correctAnswer": "Kuzey Amerika", "difficulty": "Orta", "note": "Banff bilgisi genel oyuncu için Kolay\'dan Orta\'ya taşındı."}, {"id": "q4923", "categoryIndex": 4, "question": "Eşdeğer doz büyüklüğünün SI birimi hangisidir?", "correctAnswer": "sievert", "difficulty": "Zor", "note": "Uzmanlık gerektiren radyasyon birimi sorusu Zor yapıldı."}, {"id": "q9365", "categoryIndex": 1, "question": "Killing Eve aşağıdaki yapım türlerinden hangisidir?", "correctAnswer": "Televizyon dizisi", "difficulty": "Orta", "note": "Niş dizi bilgisi Kolay\'dan Orta\'ya taşındı."}]')


def fail(message: str) -> None:
    raise SystemExit(f"\n❌ {message}\n")


def run(command: list[str], **kwargs):
    return subprocess.run(command, check=True, **kwargs)


for path in (MAIN, QUALITY, QUESTIONS, PUBSPEC):
    if not path.exists():
        fail(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Kurulum dosyasını BilgiRotasi deposunun ana klasöründe çalıştır."
        )

branch = run(
    ["git", "branch", "--show-current"],
    capture_output=True,
    text=True,
).stdout.strip()

if branch != "main":
    fail(f"Bu paket main dalında çalıştırılmalı. Mevcut dal: {branch or 'bilinmiyor'}")

run(["git", "pull", "--ff-only", "origin", "main"])

if subprocess.run(["git", "diff", "--quiet"], check=False).returncode != 0:
    fail(
        "Repoda commit edilmemiş değişiklik var. "
        "Önce mevcut çalışmayı commit et veya temizle."
    )

main_text = MAIN.read_text(encoding="utf-8")
quality_text = QUALITY.read_text(encoding="utf-8")
pubspec_text = PUBSPEC.read_text(encoding="utf-8")

try:
    questions = json.loads(QUESTIONS.read_text(encoding="utf-8"))
except Exception as error:
    fail(f"questions.json okunamadı: {error}")

if not isinstance(questions, list):
    fail("assets/questions.json bir JSON listesi olmalı.")

ids = [str(item.get("id", "")) for item in questions if isinstance(item, dict)]
if len(ids) != len(set(ids)):
    fail("Soru bankasında yinelenen soru kimliği bulundu.")

by_id = {
    str(item.get("id", "")): item
    for item in questions
    if isinstance(item, dict)
}

target_ids = [item["id"] for item in REWRITES + DIFFICULTY_UPDATES]
missing = [question_id for question_id in target_ids if question_id not in by_id]
if missing:
    fail("Soru bankasında bulunamayan kimlikler: " + ", ".join(missing))

updated = copy.deepcopy(questions)
updated_by_id = {
    str(item.get("id", "")): item
    for item in updated
    if isinstance(item, dict)
}

changed_rewrites = []
already_rewritten = []
changed_difficulties = []
already_difficulties = []
conflicts = []

for correction in REWRITES:
    item = updated_by_id[correction["id"]]

    if item.get("categoryIndex") != correction["categoryIndex"]:
        conflicts.append(
            f"{correction['id']}: kategori değişmiş "
            f"({item.get('categoryIndex')})"
        )
        continue

    target_matches = (
        item.get("question") == correction["question"]
        and item.get("options") == correction["options"]
        and item.get("answerIndex") == correction["answerIndex"]
        and item.get("difficulty") == correction["difficulty"]
        and item.get("explanation") == correction["explanation"]
    )
    if target_matches:
        already_rewritten.append(correction["id"])
        continue

    old_matches = (
        item.get("question") == correction["oldQuestion"]
        and item.get("options") == correction["oldOptions"]
        and item.get("answerIndex") == correction["oldAnswerIndex"]
    )
    if not old_matches:
        conflicts.append(
            f"{correction['id']} başka bir çalışma tarafından değiştirilmiş.\n"
            f"  Mevcut soru: {item.get('question')}"
        )
        continue

    if len(correction["options"]) != 4:
        fail(f"{correction['id']}: dört seçenek bulunmalı.")
    if len({str(value).strip().casefold() for value in correction["options"]}) != 4:
        fail(f"{correction['id']}: seçenekler birbirinden farklı olmalı.")
    if correction["answerIndex"] not in (0, 1, 2, 3):
        fail(f"{correction['id']}: doğru cevap indeksi geçersiz.")

    item["question"] = correction["question"]
    item["options"] = correction["options"]
    item["answerIndex"] = correction["answerIndex"]
    item["difficulty"] = correction["difficulty"]
    item["explanation"] = correction["explanation"]
    changed_rewrites.append(correction["id"])

for correction in DIFFICULTY_UPDATES:
    item = updated_by_id[correction["id"]]

    if item.get("categoryIndex") != correction["categoryIndex"]:
        conflicts.append(
            f"{correction['id']}: kategori değişmiş "
            f"({item.get('categoryIndex')})"
        )
        continue

    if item.get("question") != correction["question"]:
        conflicts.append(
            f"{correction['id']} başka bir çalışma tarafından değiştirilmiş.\n"
            f"  Mevcut soru: {item.get('question')}"
        )
        continue

    options = item.get("options")
    answer_index = item.get("answerIndex")
    if (
        not isinstance(options, list)
        or not isinstance(answer_index, int)
        or answer_index < 0
        or answer_index >= len(options)
        or options[answer_index] != correction["correctAnswer"]
    ):
        conflicts.append(
            f"{correction['id']}: doğru cevap yapısı beklenenle uyuşmuyor."
        )
        continue

    if item.get("difficulty") == correction["difficulty"]:
        already_difficulties.append(correction["id"])
        continue

    item["difficulty"] = correction["difficulty"]
    changed_difficulties.append(correction["id"])

if conflicts:
    print("\n❌ Çakışma bulundu; hiçbir dosya değiştirilmedi.")
    for conflict in conflicts:
        print(conflict)
    print("\nBu çıktıyı ChatGPT'ye gönder.")
    raise SystemExit(1)

guard_marker = "Kategori dışı tarih/metin işlemi"
if guard_marker not in quality_text:
    reasons_marker = "  static List<String> reasons(QuizQuestion question) {"
    if quality_text.count(reasons_marker) != 1:
        fail("Soru kalite filtresine yeni denetim eklenemedi.")

    helper = r"""  static bool _looksLikeLowValueTextOrDateTask(
    QuizQuestion question,
    String normalizedQuestion,
  ) {
    final hasYear = RegExp(r'\b\d{3,4}\b')
        .hasMatch(normalizedQuestion);

    final trivialDateTask = hasYear &&
        const <String>[
          'hangi on yilda',
          'hangi on yillik donemde',
          'hangi yuzyilin icindedir',
          'hangi yuzyilda yer alir',
        ].any(normalizedQuestion.contains);

    final trivialTitleTask = const <String>[
      'basliginda kac kelime',
      'basliginin ilk kelimesi',
      'eser adinda kac kelime',
      'eser adinin ilk kelimesi',
      'kelimesinde kac harf',
      'basliginda kac harf',
    ].any(normalizedQuestion.contains);

    final combinedTask = const <String>[
      'ortak sayisal cevabi',
      'sirasiyla dogru cevaplar',
      'dogru cevap cifti',
    ].any(normalizedQuestion.contains) &&
        (normalizedQuestion.contains('kural') ||
            normalizedQuestion.contains('soru'));

    final vagueInstitutionTask = normalizedQuestion.contains(
      'kurumu ekibi veya kisisi',
    );

    return trivialDateTask ||
        trivialTitleTask ||
        combinedTask ||
        vagueInstitutionTask;
  }

"""
    quality_text = quality_text.replace(
        reasons_marker,
        helper + reasons_marker,
        1,
    )

    return_marker = "    return reasons.toSet().toList(growable: false);"
    if quality_text.count(return_marker) != 1:
        fail("Soru kalite filtresinin sonuç bölümü bulunamadı.")

    call = """    if (_looksLikeLowValueTextOrDateTask(
      question,
      normalizedQuestion,
    )) {
      reasons.add('Kategori dışı tarih/metin işlemi');
    }

"""
    quality_text = quality_text.replace(
        return_marker,
        call + return_marker,
        1,
    )

version_match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec_text,
    flags=re.MULTILINE,
)
if not version_match:
    fail("pubspec.yaml sürüm satırı okunamadı.")

major, minor, patch, build = map(int, version_match.groups())
new_version = f"{major}.{minor + 1}.0+{build + 1}"
display_version = f"{major}.{minor + 1}.0"

pubspec_text = re.sub(
    r"^version:\s*.*$",
    f"version: {new_version}",
    pubspec_text,
    count=1,
    flags=re.MULTILINE,
)

main_text, version_count = re.subn(
    r"Bilgi Rotası • Sürüm \d+\.\d+(?:\.\d+)?",
    f"Bilgi Rotası • Sürüm {display_version}",
    main_text,
    count=1,
)
if version_count != 1:
    fail("Ana menü sürüm yazısı güncellenemedi.")

report_lines = [
    "BİLGİ ROTASI – 14 GERİ BİLDİRİM DÜZELTMESİ",
    "=" * 82,
    "",
    "TAMAMEN YENİLENEN 9 SORU",
    "-" * 82,
]
for correction in REWRITES:
    report_lines.extend(
        [
            correction["id"],
            f"Eski: {correction['oldQuestion']}",
            f"Yeni: {correction['question']}",
            f"Doğru cevap: {correction['options'][correction['answerIndex']]}",
            f"Zorluk: {correction['difficulty']}",
            f"Not: {correction['note']}",
            "",
        ]
    )

report_lines.extend(
    [
        "ZORLUĞU GÜNCELLENEN 5 SORU",
        "-" * 82,
    ]
)
for correction in DIFFICULTY_UPDATES:
    report_lines.extend(
        [
            f"{correction['id']}: {correction['difficulty']}",
            f"Soru: {correction['question']}",
            f"Not: {correction['note']}",
            "",
        ]
    )

report_lines.extend(
    [
        "KAYNAK KONTROLÜ",
        "-" * 82,
        "Rugby league: https://www.internationalrugbyleague.com/about/laws-of-the-game",
        "Horatius Kardeşlerin Yemini: https://collections.louvre.fr/ark:/53355/cl010062239",
        "Araba Sevdası: https://islamansiklopedisi.org.tr/araba-sevdasi",
        "Londra 2012 / Paris 2024: https://olympics.com/",
        "Su topu: https://www.worldaquatics.com/",
        "Softbol: https://www.wbsc.org/",
        "",
        "Ek filtre: başlıkta kelime/harf sayma, başlığın ilk kelimesi,",
        "yılı on yıl/yüzyıla dönüştürme ve iki soruyu birleştirme kalıpları",
        "bundan sonra otomatik olarak oyundan elenir.",
    ]
)
report_text = "\n".join(report_lines) + "\n"

backup = Path("/tmp/bilgi_rotasi_14_geri_bildirim_yedek")
backup.mkdir(parents=True, exist_ok=True)
for source in (MAIN, QUALITY, QUESTIONS, PUBSPEC):
    shutil.copy2(source, backup / source.name)

report_existed = REPORT.exists()
if report_existed:
    shutil.copy2(REPORT, backup / REPORT.name)

try:
    MAIN.write_text(main_text, encoding="utf-8")
    QUALITY.write_text(quality_text, encoding="utf-8")
    QUESTIONS.write_text(
        json.dumps(updated, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    PUBSPEC.write_text(pubspec_text, encoding="utf-8")
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text(report_text, encoding="utf-8")

    verified = json.loads(QUESTIONS.read_text(encoding="utf-8"))
    verified_by_id = {
        str(item.get("id", "")): item
        for item in verified
        if isinstance(item, dict)
    }

    for correction in REWRITES:
        item = verified_by_id[correction["id"]]
        if (
            item.get("question") != correction["question"]
            or item.get("options") != correction["options"]
            or item.get("answerIndex") != correction["answerIndex"]
            or item.get("difficulty") != correction["difficulty"]
            or item.get("explanation") != correction["explanation"]
        ):
            fail(f"{correction['id']} düzeltmesi doğrulanamadı.")

    for correction in DIFFICULTY_UPDATES:
        if verified_by_id[correction["id"]].get("difficulty") != correction["difficulty"]:
            fail(f"{correction['id']} zorluk güncellemesi doğrulanamadı.")

    if shutil.which("dart"):
        run(["dart", "format", "lib/main.dart", "lib/question_quality.dart"])

    run(["git", "diff", "--check"])

    if shutil.which("flutter"):
        run(["flutter", "analyze", "--no-fatal-infos"])
        if Path("test").exists():
            run(["flutter", "test"])

except Exception:
    shutil.copy2(backup / MAIN.name, MAIN)
    shutil.copy2(backup / QUALITY.name, QUALITY)
    shutil.copy2(backup / QUESTIONS.name, QUESTIONS)
    shutil.copy2(backup / PUBSPEC.name, PUBSPEC)
    if report_existed:
        shutil.copy2(backup / REPORT.name, REPORT)
    elif REPORT.exists():
        REPORT.unlink()
    print("\n❌ Hata oluştu; değiştirilen dosyalar eski hâline döndürüldü.\n")
    raise

run(
    [
        "git",
        "add",
        "lib/main.dart",
        "lib/question_quality.dart",
        "assets/questions.json",
        "reports/feedback_14_questions_20260723.txt",
        "pubspec.yaml",
    ]
)

if subprocess.run(
    ["git", "diff", "--cached", "--quiet"],
    check=False,
).returncode == 0:
    fail("Commit edilecek değişiklik bulunamadı.")

run(
    [
        "git",
        "commit",
        "-m",
        "On dort geri bildirim sorusunu duzelt",
    ]
)
run(["git", "push", "origin", "main"])

print("")
print("✅ 14 geri bildirim sorusu düzenlendi.")
print(f"✅ Tamamen yenilenen soru: {len(changed_rewrites)}")
print(f"✅ Zaten yenilenmiş soru: {len(already_rewritten)}")
print(f"✅ Zorluğu değiştirilen soru: {len(changed_difficulties)}")
print(f"✅ Zorluğu zaten güncel soru: {len(already_difficulties)}")
print("✅ Düşük kaliteli tarih/metin kalıpları için kalıcı filtre eklendi.")
print(f"✅ Yeni sürüm: {new_version}")
print("✅ Değişiklikler GitHub'a gönderildi.")
print(f"📄 Rapor: {REPORT}")
