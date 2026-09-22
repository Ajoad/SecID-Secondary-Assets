#!/usr/bin/env python3
from __future__ import annotations
import csv,json,re,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def rows(p):
    with open(p,newline='') as f:return list(csv.DictReader(f))
def main():
    cfg=json.load(open(ROOT/'config/secid_il_jasper.json')); sas=rows(ROOT/cfg['secid_assets_csv']); uni=rows(ROOT/cfg['candidate_universe_csv'])
    errs=[]; names=[r['candidate'] for r in sas]; unames={r['candidate'] for r in uni}
    if len(names)!=10 or len(set(names))!=10: errs.append(f'expected 10 unique SecID assets, got {len(names)}/{len(set(names))}')
    source_names=[x['Name'] for x in json.load(open(ROOT/cfg['asset_source_json']))]
    if names!=source_names: errs.append('asset CSV does not exactly preserve supplied JSON Name order')
    missing93=[n for n in names if n not in unames]
    expected=set()
    if set(missing93)!=expected: errs.append(f'unexpected assets outside old 93-candidate universe: {missing93}')
    for fn in cfg['rtl_files']:
        if not (ROOT/'rtl'/fn).exists(): errs.append(f'missing RTL {fn}')
    text='\n'.join((ROOT/'rtl'/fn).read_text(errors='ignore') for fn in cfg['rtl_files'])
    for n in [cfg['primary'],*names,cfg['uop']]:
        leaf=n.split('.')[-1]
        if not re.search(r'\b'+re.escape(leaf)+r'\b',text): errs.append(f"leaf '{leaf}' for {n} not found in RTL")
    if errs:
        print('[VALIDATE] FAIL'); [print(' -',e) for e in errs]; return 2
    print(f'[VALIDATE] PASS assets={len(names)} old_universe_members={len(names)-len(missing93)} restored_outside_old_universe={len(missing93)}')
    print('[VALIDATE] restored outside old 93:', ', '.join(missing93))
    return 0
if __name__=='__main__': sys.exit(main())
