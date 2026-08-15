from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    target = Path(path)
    text = target.read_text(encoding="utf-8")
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{path}: expected exactly one match, found {count}")
    target.write_text(text.replace(old, new, 1), encoding="utf-8")


# BILGI_ROTASI_DURUM.md
status_path = "docs/project-memory/BILGI_ROTASI_DURUM.md"
replace_once(
    status_path,
    "**Kesim noktası:** 14 Ağustos 2026",
    "**Kesim noktası:** 15 Ağustos 2026",
)
replace_once(
    status_path,
    "- **DOĞRULANACAK:** fiziksel telefondan ADB/logcat ile Bilgi Rotası paketine ait\n"
    "  crash/ANR/`FATAL EXCEPTION`/process-death taraması alınmadı. Kullanıcı görünür\n"
    "  testlerinde çökme görülmemesi bu log kanıtının yerine yazılmaz.",
    "- Fiziksel ADB/logcat kabulü 15 Ağustos 2026'da **PASS**. İlk metadata ZIP'i\n"
    "  `BilgiRotasi_Fiziksel_Logcat_20260815_215920.zip` Android 16 üzerinde gerçek\n"
    "  Play closed-test `1.68.15+105` / versionCode 105 / targetSdk 36 kurulumunu\n"
    "  doğruladı. Final kanıt ZIP'i `BilgiRotasi_FINAL_ADB_20260815_220727.zip`;\n"
    "  SHA-256 `cd1930a7bbc55cd448815bb2662cfc5b2f9785a8d7001cd0bb736301ae3cbba7`.\n"
    "- Final ADB penceresi `22:07:28 → 22:07:40`; `PID_START=14450` ve\n"
    "  `PID_END=14450`. `ACTIVITY_START.txt` ve `ACTIVITY_END.txt` aynı\n"
    "  `com.leventua.bilgirotasi/.MainActivity` kaydını `visible=true`,\n"
    "  `visibleRequested=true` ve `topResumedActivity` olarak gösterir. Full logcat\n"
    "  taramasında Bilgi Rotası için `FATAL EXCEPTION`, ANR/`am_anr`, `am_crash`,\n"
    "  `am_proc_died`, native tombstone/signal veya beklenmeyen process-death kaydı\n"
    "  yoktur. `PROCESS_EXIT_INFO.txt` test saatinde yeni uygulama çıkışı içermez;\n"
    "  görülen tarihsel kayıtlar 14 Ağustos kullanıcı `REMOVE TASK` ve izin değişimi\n"
    "  olaylarıdır. Ayrı PID `14546` üzerindeki Firebase Installations/Messaging\n"
    "  hatası Samsung Game Launcher sürecine aittir, Bilgi Rotası sürecine değil."
)

# GOREV_HAVUZU.md
task_path = "docs/project-memory/GOREV_HAVUZU.md"
replace_once(
    task_path,
    "**Durum:** DRAFT PR #39 / KOD-HEAD CI PASS / FİZİKSEL FCM DAVRANIŞI PASS / FİZİKSEL LOGCAT DOĞRULANACAK / MERGE KARARI BEKLİYOR",
    "**Durum:** DRAFT PR #39 / KOD-HEAD CI PASS / FİZİKSEL FCM + ADB/LOGCAT KABULÜ PASS / MERGE KARARI BEKLİYOR",
)
replace_once(
    task_path,
    "- Fiziksel cihaz ADB/logcat crash/ANR/FATAL/process-death taraması alınmadı;\n"
    "  `DOĞRULANACAK` kalır.",
    "- Fiziksel ADB/logcat kabulü **PASS**: Android 16 / Play closed-test\n"
    "  `1.68.15+105`; final ZIP SHA-256\n"
    "  `cd1930a7bbc55cd448815bb2662cfc5b2f9785a8d7001cd0bb736301ae3cbba7`;\n"
    "  başlangıç/son PID `14450`, MainActivity iki uçta visible/top-resumed,\n"
    "  FATAL/ANR/crash/process-death yok ve test saatinde yeni exit-info kaydı yok.",
)
replace_once(
    task_path,
    "- [ ] Fiziksel ADB/logcat crash/ANR/FATAL/process-death taraması.",
    "- [x] Fiziksel ADB/logcat crash/ANR/FATAL/process-death taraması PASS.",
)

# ACIK_SORULAR_VE_DOGRULAMALAR.md
open_path = "docs/project-memory/ACIK_SORULAR_VE_DOGRULAMALAR.md"
replace_once(
    open_path,
    "**Kesim noktası:** 14 Ağustos 2026",
    "**Kesim noktası:** 15 Ağustos 2026",
)
replace_once(
    open_path,
    "## Issue #37 gerçek FCM fiziksel kabulü - DAVRANIŞ PASS / LOGCAT AÇIK",
    "## Issue #37 gerçek FCM fiziksel kabulü - FİZİKSEL KABUL PASS / MERGE KARARI AÇIK",
)
replace_once(
    open_path,
    "**DOĞRULANACAK:** fiziksel telefondan ADB/logcat crash/ANR/`FATAL EXCEPTION`/\n"
    "process-death taraması alınmadı. Kullanıcı görünür kabulündeki çökmesiz davranış\n"
    "fiziksel log kanıtı olarak yazılmaz.",
    "**FİZİKSEL ADB/LOGCAT PASS:** `BilgiRotasi_FINAL_ADB_20260815_220727.zip`\n"
    "SHA-256 `cd1930a7bbc55cd448815bb2662cfc5b2f9785a8d7001cd0bb736301ae3cbba7`.\n"
    "Test penceresi `22:07:28 → 22:07:40`; `PID_START=14450` = `PID_END=14450`;\n"
    "MainActivity başlangıç/sonda visible ve top-resumed. Bilgi Rotası için FATAL,\n"
    "ANR, am_crash, am_proc_died/native crash veya beklenmeyen process-death yok;\n"
    "exit-info test saatinde yeni kayıt içermiyor. Ayrı PID 14546 üzerindeki Firebase\n"
    "Installations/Messaging hatası Samsung Game Launcher'a aittir.",
)
replace_once(
    open_path,
    "Public Analytics + FCM gizlilik metni GitHub Pages kaynağı `main:/docs` için ayrı\n"
    "Draft PR #40'tadır (`08da14a4d9669438195d50278c5adcdffe0529cc`); Quality Checks\n"
    "`31806007248` ve AdMob PR doğrulaması `31806007246` SUCCESS. PR #40 merge\n"
    "edilmediğinden canlı Pages güncellenmiş sayılmaz.",
    "Public Analytics + FCM gizlilik metni PR #40 ile `main` dalına squash merge\n"
    "edildi: `c7b3be9925344f3c8f6bc608a1f7d98a42c0a210`. GitHub Pages build\n"
    "`1152991654` bu commit üzerinde **built** ve hata yok; güncel destek adresi\n"
    "`BilgiRotasidestek@gmail.com` korunur.",
)

print("Physical ADB/logcat acceptance recorded successfully.")
