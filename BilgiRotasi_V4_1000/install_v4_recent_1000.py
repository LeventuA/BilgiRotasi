#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, os, re, shutil, tempfile, unicodedata
from collections import Counter, defaultdict
from datetime import datetime, timezone
from difflib import SequenceMatcher
from pathlib import Path
from typing import Any

REQUIRED_KEYS={"id","categoryIndex","question","options","answerIndex","difficulty","explanation"}
DIFFICULTIES={"Kolay","Orta","Zor"}
STOPWORDS={"hangi","hangisi","nedir","kimdir","icin","ile","bir","ve","olarak","bilinen","olan","ne","neden","nasil","kac","daha","en","nerede","neye","ad","adi","denir","yilinda","yili","gerceklesti","yapimi","odulu","odulleri","filmi","dizisi","oyunu","gorevi","calismasi","hakkinda","dogru","bilgi","organizasyonu","sampiyonu","ilk","kez","ilgili","tarihli"}

def normalize(value:Any)->str:
    text=str(value).replace("ı","i").replace("İ","I").replace("i\u0307","i")
    text=unicodedata.normalize("NFKD",text)
    text="".join(ch for ch in text if not unicodedata.combining(ch))
    return " ".join(re.sub(r"[^a-z0-9]+"," ",text.casefold()).split())

def content_tokens(value:Any)->set[str]:
    return {t for t in normalize(value).split() if t not in STOPWORDS and len(t)>2}

def correct_answer(q:dict[str,Any])->str:
    o=q.get("options"); i=q.get("answerIndex")
    return str(o[i]) if isinstance(o,list) and isinstance(i,int) and i in range(len(o)) else ""

def load(path:Path)->list[dict[str,Any]]:
    try: value=json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc: raise SystemExit(f"JSON okunamadı: {path} — {exc}")
    if not isinstance(value,list) or not all(isinstance(x,dict) for x in value): raise SystemExit(f"JSON kökünde nesne listesi gerekli: {path}")
    return value

def atomic_write(path:Path,value:list[dict[str,Any]])->None:
    payload=json.dumps(value,ensure_ascii=False,indent=2)+"\n"
    with tempfile.NamedTemporaryFile("w",encoding="utf-8",dir=path.parent,delete=False) as h:
        h.write(payload); tmp=Path(h.name)
    os.replace(tmp,path)

def validate(q:dict[str,Any],label:str)->list[str]:
    e=[]
    if set(q)!=REQUIRED_KEYS:e.append(f"{label}: şema anahtarları hatalı")
    if not re.fullmatch(r"q\d+",str(q.get("id",""))):e.append(f"{label}: ID biçimi hatalı")
    if q.get("categoryIndex") not in range(6):e.append(f"{label}: kategori 0–5 arasında değil")
    text=q.get("question")
    if not isinstance(text,str) or not text.endswith("?") or text.count("?")!=1:e.append(f"{label}: soru tek soru işaretiyle bitmeli")
    opts=q.get("options")
    if not isinstance(opts,list) or len(opts)!=4 or len({normalize(x) for x in opts})!=4:e.append(f"{label}: dört farklı seçenek gerekli")
    idx=q.get("answerIndex")
    if not isinstance(idx,int) or idx not in range(4):e.append(f"{label}: answerIndex 0–3 arasında değil")
    if q.get("difficulty") not in DIFFICULTIES:e.append(f"{label}: zorluk değeri hatalı")
    exp=q.get("explanation")
    if not isinstance(exp,str) or len(exp.strip())<38:e.append(f"{label}: açıklama çok kısa")
    return e

def similarity(a:dict[str,Any],b:dict[str,Any]):
    na,nb=normalize(a.get("question","")),normalize(b.get("question",""))
    seq=SequenceMatcher(None,na,nb).ratio()
    ta,tb=content_tokens(a.get("question","")),content_tokens(b.get("question",""))
    union=ta|tb; jac=len(ta&tb)/len(union) if union else 0.0
    same=normalize(correct_answer(a))==normalize(correct_answer(b)); shared=len(ta&tb)
    return seq,jac,same,shared

def probable(a:dict[str,Any],b:dict[str,Any]):
    seq,jac,same,shared=similarity(a,b)
    ya=set(re.findall(r"\b202[0-6]\b",str(a.get("question",""))))
    yb=set(re.findall(r"\b202[0-6]\b",str(b.get("question",""))))
    different_years=bool(ya and yb and ya!=yb)
    dup=(same and not different_years and seq>=0.94 and jac>=0.72 and shared>=4)
    return dup,seq,jac,shared

def main()->int:
    p=argparse.ArgumentParser(description="Bilgi Rotası V4 — 2020–2026 odaklı 1.000 soruyu güvenli biçimde ekler.")
    p.add_argument("--repo-root",default=".")
    mode=p.add_mutually_exclusive_group(required=True); mode.add_argument("--check",action="store_true"); mode.add_argument("--apply",action="store_true")
    p.add_argument("--skip-conflicts",action="store_true",help="Çakışanları atlayıp yalnız temiz soruları ekler.")
    a=p.parse_args(); root=Path(a.repo_root).resolve(); target=root/"assets"/"questions.json"
    incoming_path=Path(__file__).resolve().parent/"v4_recent_1000_q56121_q57120.json"
    if not target.exists(): raise SystemExit(f"Ana soru dosyası bulunamadı: {target}")
    existing=load(target); incoming=load(incoming_path); errors=[]
    for pos,q in enumerate(incoming,1): errors.extend(validate(q,f"yeni#{pos}"))
    expected=[f"q{x}" for x in range(56121,57121)]
    if len(incoming)!=1000:errors.append("Yeni soru sayısı 1.000 değil")
    if [q.get("id") for q in incoming]!=expected:errors.append("ID aralığı/sırası q56121–q57120 değil")
    if len({normalize(q["question"]) for q in incoming})!=len(incoming):errors.append("V4 paketinin kendi içinde aynı soru metni var")
    if len({q["id"] for q in incoming})!=len(incoming):errors.append("V4 paketinin kendi içinde aynı ID var")
    if errors:
        for e in errors:print("HATA:",e)
        return 2

    existing_ids={str(q.get("id")) for q in existing}
    existing_text={normalize(q.get("question","")):q for q in existing}
    by_answer=defaultdict(list); token_index=defaultdict(list)
    for j,old in enumerate(existing):
        cat=old.get("categoryIndex")
        if cat not in range(6):continue
        by_answer[(cat,normalize(correct_answer(old)))].append(j)
        for t in content_tokens(old.get("question","")):token_index[(cat,t)].append(j)
    accepted=[]; conflicts=[]
    for q in incoming:
        reasons=[]; nq=normalize(q["question"]); cat=q["categoryIndex"]
        if q["id"] in existing_ids:reasons.append("ID mevcut")
        if nq in existing_text:reasons.append(f"Soru metni {existing_text[nq].get('id')} ile aynı")
        if not reasons:
            candidate=Counter()
            for t in content_tokens(q["question"]):candidate.update(token_index.get((cat,t),[]))
            for j in by_answer.get((cat,normalize(correct_answer(q))),[]):candidate[j]+=3
            for j,hits in candidate.most_common(100):
                if hits<2:break
                old=existing[j]; dup,seq,jac,shared=probable(q,old)
                if dup:
                    reasons.append(f"{old.get('id')} ile olası aynı bilgi (J={jac:.2f}, S={seq:.2f}, ortak={shared})")
                    break
        if reasons:conflicts.append({"id":q["id"],"question":q["question"],"reasons":reasons})
        else:accepted.append(q)

    stamp=datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    out=root/"quality_v4_1000_install_output"; out.mkdir(exist_ok=True)
    report_path=out/f"v4_install_report_{stamp}.json"
    report={"existingCount":len(existing),"incomingCount":len(incoming),"acceptedCount":len(accepted),"conflictCount":len(conflicts),"newTotalIfApplied":len(existing)+len(accepted),"incomingCategoryCounts":dict(Counter(q["categoryIndex"] for q in incoming)),"acceptedCategoryCounts":dict(Counter(q["categoryIndex"] for q in accepted)),"conflicts":conflicts}
    report_path.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print("Mevcut soru       :",len(existing)); print("V4 paketi         :",len(incoming)); print("Temiz kabul       :",len(accepted)); print("Çakışma           :",len(conflicts)); print("Yeni olası toplam :",len(existing)+len(accepted)); print("Rapor             :",report_path)
    if conflicts and not a.skip_conflicts:
        print("\nÇakışma bulundu; questions.json değiştirilmedi. Temizleri eklemek için --skip-conflicts kullanın."); return 3
    if a.check:print("\nKontrol tamamlandı; ana dosya değiştirilmedi."); return 0
    if not accepted:print("Eklenecek temiz soru yok."); return 0
    backup_dir=root/".question_backups"; backup_dir.mkdir(exist_ok=True)
    backup=backup_dir/f"questions.json.{stamp}.before_v4_1000.bak"; shutil.copy2(target,backup)
    final=existing+accepted; atomic_write(target,final); reloaded=load(target)
    if len(reloaded)!=len(final) or len({q.get("id") for q in reloaded})!=len(reloaded):
        shutil.copy2(backup,target); raise SystemExit("Yazma sonrası doğrulama başarısız; tam yedek geri yüklendi.")
    print("\nBaşarıyla eklendi :",len(accepted)); print("Yeni toplam       :",len(reloaded)); print("Tam yedek         :",backup); return 0
if __name__=="__main__":raise SystemExit(main())
