#!/usr/bin/env python3
from __future__ import annotations
import argparse,json,os,re,shutil,tempfile,unicodedata
from collections import Counter,defaultdict
from datetime import datetime,timezone
from difflib import SequenceMatcher
from pathlib import Path
from typing import Any
REQ={'id','categoryIndex','question','options','answerIndex','difficulty','explanation'}
DIFF={'Kolay','Orta','Zor'}
STOP={'hangi','hangisi','nedir','kimdir','icin','ile','bir','ve','olarak','bilinen','olan','ne','neden','nasil','kac','daha','en','nerede','neye'}
def norm(x:Any)->str:
 s=str(x).replace('ı','i').replace('İ','I'); s=unicodedata.normalize('NFKD',s); s=''.join(c for c in s if not unicodedata.combining(c)); return ' '.join(re.sub(r'[^a-z0-9]+',' ',s.casefold()).split())
def toks(x): return {t for t in norm(x).split() if t not in STOP and len(t)>2}
def ans(q):
 o=q.get('options');i=q.get('answerIndex');return str(o[i]) if isinstance(o,list) and isinstance(i,int) and i in range(len(o)) else ''
def load(p):
 try:v=json.loads(p.read_text(encoding='utf-8'))
 except Exception as e: raise SystemExit(f'JSON okunamadı: {p} — {e}')
 if not isinstance(v,list) or not all(isinstance(x,dict) for x in v): raise SystemExit(f'Liste biçimi gerekli: {p}')
 return v
def atomic(p,v):
 s=json.dumps(v,ensure_ascii=False,indent=2)+'\n'
 with tempfile.NamedTemporaryFile('w',encoding='utf-8',dir=p.parent,delete=False) as f:f.write(s);t=Path(f.name)
 os.replace(t,p)
def validate(q,label):
 e=[]
 if set(q)!=REQ:e.append(f'{label}: şema')
 if not re.fullmatch(r'q\d+',str(q.get('id',''))):e.append(f'{label}: id')
 if q.get('categoryIndex') not in range(6):e.append(f'{label}: kategori')
 text=q.get('question','')
 if not isinstance(text,str) or not text.endswith('?') or text.count('?')!=1:e.append(f'{label}: soru biçimi')
 o=q.get('options');i=q.get('answerIndex')
 if not isinstance(o,list) or len(o)!=4 or len({norm(x) for x in o})!=4:e.append(f'{label}: seçenek')
 if not isinstance(i,int) or i not in range(4):e.append(f'{label}: cevap indeksi')
 if q.get('difficulty') not in DIFF:e.append(f'{label}: zorluk')
 if not isinstance(q.get('explanation'),str) or len(q['explanation'].strip())<38:e.append(f'{label}: açıklama')
 return e
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--repo-root',default='.')
 m=ap.add_mutually_exclusive_group(required=True);m.add_argument('--check',action='store_true');m.add_argument('--apply',action='store_true')
 ap.add_argument('--skip-conflicts',action='store_true');a=ap.parse_args()
 root=Path(a.repo_root).resolve();target=root/'assets'/'questions.json';incoming_path=Path(__file__).resolve().parent/'v2_quality_1000_q54121_q55120.json'
 old=load(target);new=load(incoming_path);errors=[]
 for i,q in enumerate(new):errors+=validate(q,f'yeni#{i+1}')
 if len(new)!=1000:errors.append('Yeni soru sayısı 1000 değil')
 if [q.get('id') for q in new]!=[f'q{i}' for i in range(54121,55121)]:errors.append('ID aralığı q54121-q55120 değil')
 if errors:
  for e in errors:print('HATA:',e)
  return 2
 old_ids={str(q.get('id')) for q in old};old_text={norm(q.get('question','')):q for q in old};by=defaultdict(list)
 for q in old:
  if q.get('categoryIndex') in range(6):by[q['categoryIndex']].append(q)
 accepted=[];conf=[]
 for q in new:
  reasons=[];nq=norm(q['question']);na=norm(ans(q))
  if q['id'] in old_ids:reasons.append('ID mevcut')
  if nq in old_text:reasons.append(f"Soru metni {old_text[nq].get('id')} ile aynı")
  if not reasons:
   for o in by[q['categoryIndex']]:
    if norm(ans(o))!=na:continue
    a1,a2=toks(q['question']),toks(o.get('question',''));u=a1|a2;j=len(a1&a2)/len(u) if u else 0;r=SequenceMatcher(None,nq,norm(o.get('question',''))).ratio()
    if j>=.70 or r>=.87:
     reasons.append(f"{o.get('id')} ile olası aynı bilgi (J={j:.2f}, S={r:.2f})");break
  if reasons:conf.append({'id':q['id'],'question':q['question'],'reasons':reasons})
  else:accepted.append(q)
 ts=datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ');out=root/'v2_1000_install_output';out.mkdir(exist_ok=True)
 rp=out/f'v2_install_report_{ts}.json';rp.write_text(json.dumps({'existingCount':len(old),'incomingCount':len(new),'acceptedCount':len(accepted),'conflictCount':len(conf),'newTotalIfApplied':len(old)+len(accepted),'conflicts':conf},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 print('Mevcut soru       :',len(old));print('V2 paketi         :',len(new));print('Temiz kabul       :',len(accepted));print('Çakışma           :',len(conf));print('Rapor             :',rp)
 if conf and not a.skip_conflicts:
  print('\nÇakışma bulundu; questions.json değiştirilmedi. Temizleri eklemek için --skip-conflicts kullanın.');return 3
 if a.check:print('\nKontrol tamamlandı; ana dosya değiştirilmedi.');return 0
 if not accepted:print('Eklenecek temiz soru yok.');return 0
 bd=root/'.question_backups';bd.mkdir(exist_ok=True);bp=bd/f'questions.json.{ts}.before_v2_1000.bak';shutil.copy2(target,bp)
 final=old+accepted;atomic(target,final);reload=load(target)
 if len(reload)!=len(final) or len({q.get('id') for q in reload})!=len(reload):shutil.copy2(bp,target);raise SystemExit('Yazma kontrolü başarısız; yedek geri yüklendi.')
 print('\nBaşarıyla eklendi :',len(accepted));print('Yeni toplam       :',len(reload));print('Tam yedek         :',bp);return 0
if __name__=='__main__':raise SystemExit(main())
