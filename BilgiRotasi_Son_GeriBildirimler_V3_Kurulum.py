#!/usr/bin/env python3
from pathlib import Path
import copy
import json
import re
import shutil
import subprocess

QUESTIONS = Path("assets/questions.json")
CORRECTIONS = None
MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")

for path in [QUESTIONS, MAIN, PUBSPEC]:
    if not path.exists():
        raise SystemExit(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Bu betiği BilgiRotasi deposunun ana klasöründe çalıştır."
        )

try:
    questions = json.loads(QUESTIONS.read_text(encoding="utf-8"))
    corrections = json.loads('[{"id": "q1121", "expectedCategoryIndex": 2, "acceptedOldQuestions": ["Sokrates’in idam edilmesi ile en çok ilişkilendirilen kişi, taraf veya gelişme hangisidir?"], "question": "Sokrates MÖ 399\'da hangi şehir devletinde ölüme mahkûm edildi?", "options": ["Sparta", "Atina", "Korint", "Teb"], "answerIndex": 1, "difficulty": "Kolay", "explanation": "Sokrates, MÖ 399\'da Atina\'da yargılandı ve ölüme mahkûm edildi.", "reviewNote": "Cevabı soru kökünde bulunan yapay eşleştirme kaldırıldı; yer bilgisi doğrudan soruldu.", "sources": ["https://www.britannica.com/biography/Socrates"]}, {"id": "q658", "expectedCategoryIndex": 1, "acceptedOldQuestions": ["Geleceğe Dönüş için doğru yayın yılı eşleştirmesi hangisidir?"], "question": "Robert Zemeckis\'in yönettiği Geleceğe Dönüş filmi hangi yılda gösterime girdi?", "options": ["1982", "1984", "1985", "1989"], "answerIndex": 2, "difficulty": "Kolay", "explanation": "Robert Zemeckis\'in yönettiği Geleceğe Dönüş filmi 1985 yılında gösterime girdi.", "reviewNote": "Yapay \'yayın yılı eşleştirmesi\' kalıbı kaldırıldı; film ve yönetmen belirtilerek soru netleştirildi.", "sources": ["https://www.history.com/articles/back-to-the-future-delorean-car"]}, {"id": "q2548", "expectedCategoryIndex": 5, "acceptedOldQuestions": ["7 oyuncu düzeniyle oynanan ve “elle oynanan hentbol topu” kullanılan spor hangisidir?"], "question": "Bir hentbol takımında sahada kaleci dâhil kaç oyuncu bulunur?", "options": ["5", "6", "7", "8"], "answerIndex": 2, "difficulty": "Kolay", "explanation": "Salon hentbolunda her takım sahada kaleci dâhil yedi oyuncuyla yer alır.", "reviewNote": "Soru kökündeki \'hentbol topu\' ipucu kaldırıldı; doğrudan oyuncu sayısı soruldu.", "sources": ["https://www.ihf.info/media-center/news/how-did-we-get-here-evolution-indoor-handball"]}, {"id": "q1345", "expectedCategoryIndex": 2, "acceptedOldQuestions": ["Kanuni Sultan Süleyman’ın tahta çıkması için doğru yer eşleştirmesi hangisidir?"], "question": "Kanuni Sultan Süleyman hangi yılda Osmanlı tahtına çıktı?", "options": ["1512", "1520", "1566", "1453"], "answerIndex": 1, "difficulty": "Orta", "explanation": "Kanuni Sultan Süleyman 1520 yılında Osmanlı tahtına çıktı ve 1566\'ya kadar hüküm sürdü.", "reviewNote": "Anlamsız yer eşleştirmesi kaldırıldı; kesin tarih bilgisi soruldu.", "sources": ["https://www.britishmuseum.org/collection/term/BIOG14584"]}, {"id": "q1044", "expectedCategoryIndex": 1, "acceptedOldQuestions": ["Thriller ilk kez hangi yıl izleyici, oyuncu veya dinleyiciyle buluştu?"], "question": "Michael Jackson\'ın Thriller albümü hangi yılda yayımlandı?", "options": ["1982", "1979", "1987", "1991"], "answerIndex": 0, "difficulty": "Orta", "explanation": "Michael Jackson\'ın Thriller albümü 30 Kasım 1982\'de yayımlandı.", "reviewNote": "Thriller\'ın albüm mü, şarkı mı yoksa klip mi olduğu belirsizdi; eser türü açıkça belirtildi.", "sources": ["https://www.grammy.com/news/michael-jackson-10-achievements-that-made-him-the-king-of-pop/"]}, {"id": "q2919", "expectedCategoryIndex": 5, "acceptedOldQuestions": ["1936 yılında düzenlenen spor organizasyonu hangisidir?"], "question": "1936 Berlin Olimpiyatları\'nda dört altın madalya kazanan atlet kimdir?", "options": ["Carl Lewis", "Paavo Nurmi", "Emil Zátopek", "Jesse Owens"], "answerIndex": 3, "difficulty": "Zor", "explanation": "Jesse Owens, 1936 Berlin Olimpiyatları\'nda dört altın madalya kazandı.", "reviewNote": "Cevabı soru kökünde bulunan organizasyon sorusu kaldırıldı; ayırt edici bir spor tarihi sorusu yazıldı.", "sources": ["https://www.iwm.org.uk/history/the-1936-berlin-olympics"]}, {"id": "q829", "expectedCategoryIndex": 1, "acceptedOldQuestions": ["2014 yılında ilk kez yayımlanan eser hangisidir?"], "question": "Christopher Nolan\'ın yönettiği Yıldızlararası filmi hangi yılda gösterime girdi?", "options": ["2012", "2014", "2016", "2010"], "answerIndex": 1, "difficulty": "Orta", "explanation": "Christopher Nolan\'ın yönettiği Yıldızlararası filmi 2014 yılında gösterime girdi.", "reviewNote": "Genel \'eser\' ifadesi kaldırıldı; film ve yönetmen bilgisi eklendi.", "sources": ["https://www.bfi.org.uk/film/b07de850-8dd4-5fe1-a1e1-8d27fec041c1/interstellar"]}, {"id": "q19744", "expectedCategoryIndex": 3, "acceptedOldQuestions": ["Karamazov Kardeşler, Bahar Ayini, American Gothic ve Ulysses arasından hangisi Just what is it that makes today’s homes so different, so appealing? ile aynı sanat veya edebiyat alanına aittir?"], "question": "1956 tarihli Just what is it that makes today\'s homes so different, so appealing? adlı kolajın sanatçısı kimdir?", "options": ["Andy Warhol", "Roy Lichtenstein", "Richard Hamilton", "David Hockney"], "answerIndex": 2, "difficulty": "Orta", "explanation": "Pop artın erken örneklerinden sayılan bu kolajı İngiliz sanatçı Richard Hamilton hazırladı.", "reviewNote": "Aşırı uzun ve dolaylı alan eşleştirmesi kaldırıldı; eser sanatçısı doğrudan soruldu.", "sources": ["https://artsandculture.google.com/asset/just-what-is-it-that-makes-today-s-home-so-different-and-so-appealing-richard-hamilton/WQGp_dXaX9kjnQ"]}, {"id": "q2726", "expectedCategoryIndex": 5, "acceptedOldQuestions": ["Topa ağırlıkla ayak ve başla vurulması formatı hangi sporla ilişkilidir?"], "question": "Sepak takraw sporunda oyuncular topa vücutlarının hangi bölümüyle dokunamaz?", "options": ["Ayak", "Baş", "Diz", "El ve kol"], "answerIndex": 3, "difficulty": "Orta", "explanation": "Sepak takrawda topa ayak, diz, baş ve gövdeyle dokunulabilir; el ve kollar kullanılamaz.", "reviewNote": "Futbol ile sepak takrawı aynı anda düşündüren belirsiz tanım kaldırıldı; ayırt edici kural soruldu.", "sources": ["https://www.ocasia.org/sports/info/63/74/"]}, {"id": "q634", "expectedCategoryIndex": 1, "acceptedOldQuestions": ["Rocky Balboa karakteri hangi filmde yer alır?"], "question": "Rocky Balboa karakterini sinema serisinde hangi oyuncu canlandırmıştır?", "options": ["Arnold Schwarzenegger", "Sylvester Stallone", "Robert De Niro", "Jean-Claude Van Damme"], "answerIndex": 1, "difficulty": "Kolay", "explanation": "Rocky Balboa karakterini Rocky film serisinde Sylvester Stallone canlandırdı.", "reviewNote": "Karakter birçok Rocky filminde yer aldığı için film adı sorusu kaldırıldı; oyuncu soruldu.", "sources": ["https://www.biography.com/actors/sylvester-stallone"]}, {"id": "q19350", "expectedCategoryIndex": 1, "acceptedOldQuestions": ["9/8 ölçü işaretinde toplam 117 sekizlik zaman birimi kaç tam ölçü doldurur?"], "question": "9/8\'lik ölçüde bir ana vuruş genellikle hangi nota değeriyle gösterilir?", "options": ["Dörtlük", "Sekizlik", "Noktalı dörtlük", "İkilik"], "answerIndex": 2, "difficulty": "Orta", "explanation": "Standart 9/8\'lik bileşik üçlü ölçüde üç ana vuruş bulunur ve her ana vuruş noktalı dörtlük değerindedir.", "reviewNote": "Sık tekrarlanan uzun aritmetik ölçü sorusu kaldırıldı; kısa ve kavramsal bir müzik teorisi sorusu yazıldı.", "sources": ["https://odp.library.tamu.edu/stepstomusictheory/chapter/compound-meters/"]}, {"id": "q2913", "expectedCategoryIndex": 5, "acceptedOldQuestions": ["İlk modern Yaz Olimpiyatları organizasyonunun şampiyonu veya öne çıkan galibi kimdir?"], "question": "1896 Atina Olimpiyatları\'ndaki erkekler maraton yarışını kim kazandı?", "options": ["Spyridon Louis", "Jesse Owens", "Paavo Nurmi", "Abebe Bikila"], "answerIndex": 0, "difficulty": "Zor", "explanation": "Yunan atlet Spyridon Louis, 1896 Atina Olimpiyatları\'ndaki ilk Olimpiyat maratonunu kazandı.", "reviewNote": "Olimpiyatların tek bir şampiyonu varmış gibi yazılan hatalı soru kaldırıldı; belirli bir yarışın galibi soruldu.", "sources": ["https://worldathletics.org/news/heritage/1896-olympic-marathon-spiridon-louis-125-anniversary-breal-cup"]}, {"id": "q19143", "expectedCategoryIndex": 0, "acceptedOldQuestions": ["Norfolk, hangi ülkenin alt ulusal bölümlerinden biri olarak kayıtlıdır?"], "question": "Norfolk kontluğu Birleşik Krallık\'ın hangi ülkesinde yer alır?", "options": ["İskoçya", "Galler", "İngiltere", "Kuzey İrlanda"], "answerIndex": 2, "difficulty": "Kolay", "explanation": "Norfolk, İngiltere\'nin doğusunda yer alan bir kontluktur.", "reviewNote": "Norfolk ile Norfolk Adası karışıklığı giderildi; \'kontluk\' ifadesiyle coğrafi bağlam netleştirildi.", "sources": ["https://www.ons.gov.uk/explore-local-statistics/areas/E10000020-norfolk"]}, {"id": "q19497", "expectedCategoryIndex": 2, "acceptedOldQuestions": ["Trento Konsili’nin başlaması, Roma’daki büyük yangın, Berlin Duvarı’nın inşası ve Meksika Devrimi’nin başlaması arasından hangisi Protestan Reformu’nun başlangıcı ile aynı yüzyılda gerçekleşmiştir?"], "question": "Trento Konsili’nin başlaması, Roma’daki büyük yangın, Berlin Duvarı’nın inşası ve Meksika Devrimi’nin başlaması arasından hangisi Protestan Reformu’nun başlangıcı ile aynı yüzyılda gerçekleşmiştir?", "options": ["Trento Konsili’nin başlaması", "Roma’daki büyük yangın", "Berlin Duvarı’nın inşası", "Meksika Devrimi’nin başlaması"], "answerIndex": 0, "difficulty": "Orta", "explanation": "Protestan Reformu 1517\'de, Trento Konsili ise 1545\'te başladı; her ikisi de 16. yüzyılda gerçekleşti.", "reviewNote": "Sistemdeki doğru cevap korunarak zorluk Kolay\'dan Orta\'ya çıkarıldı ve tarih açıklaması netleştirildi.", "sources": ["https://www.britannica.com/event/Council-of-Trent"]}]')
except Exception as error:
    raise SystemExit(f"Dosyalar okunamadı: {error}")

if not isinstance(questions, list):
    raise SystemExit("assets/questions.json bir JSON listesi olmalı.")
if not isinstance(corrections, list) or len(corrections) != 14:
    raise SystemExit("Paket içinde 14 soru güncellemesi bulunmalı.")

question_ids = [str(item.get("id", "")) for item in questions]
if len(question_ids) != len(set(question_ids)):
    raise SystemExit("Soru bankasında yinelenen soru kimliği bulundu.")

correction_ids = [str(item.get("id", "")) for item in corrections]
if len(correction_ids) != len(set(correction_ids)):
    raise SystemExit("Düzeltme paketinde yinelenen soru kimliği bulundu.")

index_by_id = {
    str(item.get("id", "")): index
    for index, item in enumerate(questions)
}
missing = [qid for qid in correction_ids if qid not in index_by_id]
if missing:
    raise SystemExit(
        "Soru bankasında bulunamayan kimlikler: " + ", ".join(missing)
    )

updated_questions = copy.deepcopy(questions)
changed_ids = []
already_current_ids = []
conflicts = []

for correction in corrections:
    qid = correction["id"]
    item = updated_questions[index_by_id[qid]]
    current_question = str(item.get("question", "")).strip()
    target_question = correction["question"]
    accepted_old = correction.get("acceptedOldQuestions", [])

    if item.get("categoryIndex") != correction["expectedCategoryIndex"]:
        conflicts.append(
            f"{qid}: kategori değişmiş ({item.get('categoryIndex')})"
        )
        continue

    target_options = correction["options"]
    target_answer = correction["answerIndex"]
    target_difficulty = correction["difficulty"]
    target_explanation = correction["explanation"]

    target_matches = (
        current_question == target_question
        and item.get("options") == target_options
        and item.get("answerIndex") == target_answer
        and item.get("difficulty") == target_difficulty
        and item.get("explanation") == target_explanation
    )
    if target_matches:
        already_current_ids.append(qid)
        continue

    if current_question != target_question and current_question not in accepted_old:
        conflicts.append(
            f"{qid}: soru başka bir çalışma tarafından değiştirilmiş.\n"
            f"  Mevcut: {current_question}"
        )
        continue

    if not isinstance(target_options, list) or len(target_options) != 4:
        raise SystemExit(f"{qid}: tam dört seçenek bulunmalı.")
    if len({str(value).strip().casefold() for value in target_options}) != 4:
        raise SystemExit(f"{qid}: seçeneklerin tamamı farklı olmalı.")
    if target_answer not in (0, 1, 2, 3):
        raise SystemExit(f"{qid}: cevap indeksi geçersiz.")
    if target_difficulty not in ("Kolay", "Orta", "Zor"):
        raise SystemExit(f"{qid}: zorluk değeri geçersiz.")
    if not str(target_explanation).strip():
        raise SystemExit(f"{qid}: açıklama boş.")

    item["question"] = target_question
    item["options"] = target_options
    item["answerIndex"] = target_answer
    item["difficulty"] = target_difficulty
    item["explanation"] = target_explanation
    changed_ids.append(qid)

if conflicts:
    print("")
    print("❌ Çakışma bulundu; hiçbir dosya değiştirilmedi.")
    for conflict in conflicts:
        print(conflict)
    print("")
    print("Başka bir soru paketi aynı kimlikleri değiştirmiş olabilir.")
    print("Bu çıktıyı ChatGPT'ye gönder.")
    raise SystemExit(1)

main_text = MAIN.read_text(encoding="utf-8")
new_main = main_text

question_bank_marker = "static String questionFamilyKey(String text)"
if question_bank_marker not in new_main:
    old_header = """class QuestionBank {
  QuestionBank(this.questionsByCategory);

  final Map<int, List<QuizQuestion>> questionsByCategory;
"""
    new_header = r"""class QuestionBank {
  QuestionBank(this.questionsByCategory) {
    for (final question in questionsByCategory.values.expand(
      (questions) => questions,
    )) {
      _familyKeyById[question.id] = questionFamilyKey(question.text);
    }
  }

  final Map<int, List<QuizQuestion>> questionsByCategory;
  final Map<String, String> _familyKeyById = <String, String>{};

  static String questionFamilyKey(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'\d+(?:[.,/]\d+)*'), '#')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Set<String> _familyKeysForIds(Set<String> questionIds) {
    final keys = <String>{};

    for (final id in questionIds) {
      final key = _familyKeyById[id];
      if (key != null && key.isNotEmpty) {
        keys.add(key);
      }
    }

    return keys;
  }

  List<QuizQuestion> diverseQuestions({
    required List<QuizQuestion> pool,
    required int count,
    required Random random,
  }) {
    if (pool.isEmpty || count <= 0) {
      return const <QuizQuestion>[];
    }

    final shuffled = List<QuizQuestion>.from(pool)..shuffle(random);
    final selected = <QuizQuestion>[];
    final deferred = <QuizQuestion>[];
    final seenFamilies = <String>{};

    for (final question in shuffled) {
      final familyKey =
          _familyKeyById[question.id] ?? questionFamilyKey(question.text);

      if (seenFamilies.add(familyKey)) {
        selected.add(question);
      } else {
        deferred.add(question);
      }

      if (selected.length >= count) {
        return selected;
      }
    }

    for (final question in deferred) {
      selected.add(question);
      if (selected.length >= count) {
        break;
      }
    }

    return selected;
  }
"""
    if old_header not in new_main:
        raise SystemExit(
            "QuestionBank başlangıç bölümü bulunamadı; main.dart değiştirilmedi."
        )
    new_main = new_main.replace(old_header, new_header, 1)

family_filter_marker = "final familyFresh = available"
if family_filter_marker not in new_main:
    old_candidates = """    var candidates = available;

    if (preferredDifficulty != null) {
"""
    new_candidates = """    final usedFamilyKeys = _familyKeysForIds(usedQuestionIds);
    final familyFresh = available
        .where(
          (question) => !usedFamilyKeys.contains(
            _familyKeyById[question.id] ??
                questionFamilyKey(question.text),
          ),
        )
        .toList();

    if (familyFresh.isNotEmpty) {
      available = familyFresh;
    }

    var candidates = available;

    if (preferredDifficulty != null) {
"""
    if old_candidates not in new_main:
        raise SystemExit(
            "Soru seçim bölümü bulunamadı; main.dart değiştirilmedi."
        )
    new_main = new_main.replace(old_candidates, new_candidates, 1)

marathon_marker = "questionBank.diverseQuestions("
if marathon_marker not in new_main:
    old_marathon = """    pool.shuffle(Random());
    final questions = pool
        .take(min(_questionCount, pool.length))
        .toList(growable: false);
"""
    new_marathon = """    final questions = widget.questionBank.diverseQuestions(
      pool: pool,
      count: min(_questionCount, pool.length),
      random: Random(),
    );
"""
    if old_marathon not in new_main:
        raise SystemExit(
            "Maraton soru seçim bölümü bulunamadı; main.dart değiştirilmedi."
        )
    new_main = new_main.replace(old_marathon, new_marathon, 1)

questions_changed = bool(changed_ids)
main_changed = new_main != main_text

pubspec_text = PUBSPEC.read_text(encoding="utf-8")
version_match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec_text,
    flags=re.MULTILINE,
)
if not version_match:
    raise SystemExit("pubspec.yaml sürüm satırı okunamadı.")

major, minor, patch, build = map(int, version_match.groups())
new_version = f"{major}.{minor}.{patch + 1}+{build + 1}"
display_version = f"{major}.{minor}.{patch + 1}"

new_pubspec = re.sub(
    r"^version:\s*.*$",
    f"version: {new_version}",
    pubspec_text,
    count=1,
    flags=re.MULTILINE,
)

new_main, version_replacements = re.subn(
    r"Bilgi Rotası • Sürüm \d+\.\d+(?:\.\d+)?",
    f"Bilgi Rotası • Sürüm {display_version}",
    new_main,
    count=1,
)
if version_replacements != 1:
    raise SystemExit("Ana menü sürüm metni güncellenemedi.")

backup_dir = Path("/tmp/bilgi_rotasi_v3_yedek")
backup_dir.mkdir(parents=True, exist_ok=True)
shutil.copy2(QUESTIONS, backup_dir / "questions.json")
shutil.copy2(MAIN, backup_dir / "main.dart")
shutil.copy2(PUBSPEC, backup_dir / "pubspec.yaml")

QUESTIONS.write_text(
    json.dumps(updated_questions, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
)
MAIN.write_text(new_main, encoding="utf-8")
PUBSPEC.write_text(new_pubspec, encoding="utf-8")

# Yazılan dosyaları yeniden okuyarak temel doğrulama yap.
verified_questions = json.loads(QUESTIONS.read_text(encoding="utf-8"))
verified_by_id = {
    str(item.get("id", "")): item
    for item in verified_questions
}
for correction in corrections:
    item = verified_by_id[correction["id"]]
    if item.get("question") != correction["question"]:
        raise SystemExit(f"{correction['id']}: yeni soru doğrulanamadı.")
    if item.get("options") != correction["options"]:
        raise SystemExit(f"{correction['id']}: seçenekler doğrulanamadı.")
    if item.get("answerIndex") != correction["answerIndex"]:
        raise SystemExit(f"{correction['id']}: doğru cevap doğrulanamadı.")
    if item.get("difficulty") != correction["difficulty"]:
        raise SystemExit(f"{correction['id']}: zorluk doğrulanamadı.")

if shutil.which("dart"):
    subprocess.run(["dart", "format", "lib/main.dart"], check=True)

subprocess.run(["git", "diff", "--check"], check=True)

if shutil.which("flutter"):
    subprocess.run(
        ["flutter", "analyze", "--no-fatal-infos"],
        check=True,
    )

subprocess.run(
    [
        "git",
        "add",
        "assets/questions.json",
        "lib/main.dart",
        "pubspec.yaml",
    ],
    check=True,
)

has_staged_changes = subprocess.run(
    ["git", "diff", "--cached", "--quiet"],
    check=False,
).returncode != 0

if has_staged_changes:
    subprocess.run(
        [
            "git",
            "commit",
            "-m",
            "Son geri bildirim sorularini ve tekrar kontrolunu duzelt",
        ],
        check=True,
    )

subprocess.run(["git", "push", "origin", "main"], check=True)

print("")
print("✅ Son geri bildirim düzeltmeleri V3 uygulandı.")
print(f"✅ Güncellenen soru sayısı: {len(changed_ids)}")
print(f"✅ Zaten güncel soru sayısı: {len(already_current_ids)}")
print(f"✅ Soru ailesi tekrar kontrolü: {'Eklendi' if main_changed else 'Zaten vardı'}")
print(f"✅ Yeni sürüm: {new_version}")
print("✅ Değişiklikler GitHub'a gönderildi.")
print(f"ℹ️ Geçici yedek klasörü: {backup_dir}")
