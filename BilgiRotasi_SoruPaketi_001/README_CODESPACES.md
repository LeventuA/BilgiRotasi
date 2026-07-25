# Bilgi Rotası — Soru Paketi 001

Bu ZIP, repodaki mevcut `assets/questions.json` dosyasını **komple değiştirmez**. Kurulum betiği dosyayı Codespaces içinde okur, çakışmaları denetler ve yalnızca yeni soruları listenin sonuna ekler.

## Paket içeriği

- `packages/package_001_q3001_q3120.json` — 120 yeni soru
- `verification/package_001_sources.json` — soru bazında kaynak ve kontrol kaydı
- `install_questions.py` — doğrulama, tekrar taraması, yedekleme ve ekleme betiği
- `MANIFEST.json` — paket özeti

Mevcut `q001–q3000` kayıtlarına ve kimliklerine dokunulmaz. Bu paket `q3001–q3120` aralığını kullanır. Her kategoride 20 soru vardır.

## Codespaces kurulumu

ZIP dosyasını BilgiRotasi reposuna yükleyip Codespaces terminalini açın. Repo kökünde:

```bash
unzip -o BilgiRotasi_SoruPaketi_001.zip
python3 BilgiRotasi_SoruPaketi_001/install_questions.py --repo-root . --check
```

Kontrol sonucu `Çakışma: 0` ise kurulumu uygulayın:

```bash
python3 BilgiRotasi_SoruPaketi_001/install_questions.py --repo-root . --apply
```

Sonucu inceleyin:

```bash
git diff -- assets/questions.json
python3 -m json.tool assets/questions.json > /dev/null
```

Ardından commit edin:

```bash
git add assets/questions.json
git commit -m "Soru paketi 001: q3001-q3120"
git push
```

## Güvenlik davranışı

- Paket başına 500 soru sınırı uygulanır.
- ID biçimi ve `q3001+` şartı denetlenir.
- Dört seçenek, benzersiz seçenekler, `answerIndex`, kategori ve zorluk alanları doğrulanır.
- Mevcut dosya ve paketler içinde ID çakışması aranır.
- Aynı soru metni ve çok benzer soru metni taranır.
- Varsayılan davranış “hata varsa dur” şeklindedir.
- Uygulamadan önce `.question_backups/` klasörüne zaman damgalı yedek alınır.
- Yazma işlemi geçici dosya ve atomik değiştirme yöntemiyle yapılır.

Çakışmaları bilinçli olarak atlamak mümkündür, fakat önerilmez:

```bash
python3 BilgiRotasi_SoruPaketi_001/install_questions.py --repo-root . --apply --skip-conflicts
```

Her çalıştırmada ZIP klasörü içinde ayrıntılı `install_report_*.json` raporu oluşturulur.
