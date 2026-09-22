#!/usr/bin/env python3
from __future__ import annotations
import argparse,csv,json
from pathlib import Path
from collections import defaultdict
ROOT=Path(__file__).resolve().parents[1]

def readcsv(p):
    with p.open(newline='') as f:return list(csv.DictReader(f))
def count_summary(rows):
    valid=[r for r in rows if r.get('valid')]
    x={'jobs':len(rows),'valid_jobs':len(valid),'invalid_jobs':len(rows)-len(valid)}
    for p in ('c_t_primary','c_t_semantic','c_t_false_write_semantic','c_t_suppression_semantic'):
        x[p+'_sat']=sum(r.get(p)=='SAT_WITNESS' for r in valid);x[p+'_unsat']=sum(r.get(p)=='UNSAT_PROVEN' for r in valid);x[p+'_unknown']=sum(r.get(p)=='UNKNOWN' for r in valid)
    if valid:
        x['primary_witness_yield_all_valid']=x['c_t_primary_sat']/len(valid);x['semantic_witness_yield_all_valid']=x['c_t_semantic_sat']/len(valid)
        x['unknown_primary_fraction']=x['c_t_primary_unknown']/len(valid);x['unknown_semantic_fraction']=x['c_t_semantic_unknown']/len(valid)
    return x

def write_aggregate(out,rows,meta):
    agg=out/'aggregate';agg.mkdir(parents=True,exist_ok=True)
    (agg/'per_job.json').write_text(json.dumps(rows,indent=2)+'\n')
    fields=[]
    for r in rows:
        for k in r:
            if k not in fields:fields.append(k)
    with (agg/'per_job.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=fields,extrasaction='ignore');w.writeheader();w.writerows(rows)
    s={'schema':'secid_cv32_final10_reuse_v1','group':'FINAL10_SELECTED_REUSED_PARTIAL',**count_summary(rows),**meta}
    (agg/'summary.json').write_text(json.dumps(s,indent=2)+'\n')
    return s

def main():
    ap=argparse.ArgumentParser();ap.add_argument('old_package_root',type=Path);ap.add_argument('--out',type=Path,default=Path('run_final10_selected_reused_partial'));a=ap.parse_args()
    roots=[a.old_package_root/'run_balanced_selected_reused/aggregate/per_job.json',a.old_package_root/'run_balanced_controls/aggregate/per_job.json']
    old=[]
    for p in roots:
        if p.exists():old.extend(json.loads(p.read_text()))
    if not old:raise SystemExit('no compatible v1.1 aggregate files found; expected run_balanced_selected_reused and/or run_balanced_controls')
    mp=defaultdict(list)
    for r in old:mp[(r['candidate'],int(r['bit']),r.get('scenario'),r.get('injection_path'))].append(r)
    want=readcsv(ROOT/'input/final_selected_opportunities.csv');reused=[];missing=[]
    for w in want:
        key=(w['candidate'],int(w['bit']),w['scenario'],w['injection_path'])
        hits=mp.get(key,[])
        if hits:
            src=hits[0]
            if int(src.get('duration_cycles',1))!=1 or int(src.get('observation_horizon_cycles',24))!=24:
                raise SystemExit(f'incompatible duration/horizon for {key}')
            r=dict(src);r['reuse_original_group']=r.get('group');r['reuse_original_opportunity_id']=r.get('opportunity_id')
            r['group']='FINAL10_SELECTED_REUSED';r['stratum']='SECID_FINAL_ASSET';r['set_id']='SECID_FINAL10';r['selected_id']=w['selected_id'];r['opportunity_id']=w['opportunity_id']
            r['sample_rank']=int(w['sample_rank']);r['signal_bit_budget']=int(w['signal_bit_budget']);r['selection_origin']=w['selection_origin'];r['physical_identity_status']=w['physical_identity_status'];r['final10_reused']=True
            reused.append(r)
        else:missing.append(w)
    a.out.mkdir(parents=True,exist_ok=True)
    s=write_aggregate(a.out,reused,{'reused_from':str(a.old_package_root),'missing_jobs':len(missing),'reuse_note':'Exact candidate+bit+scenario+cutpoint reuse under unchanged 1-cycle FI and 24-cycle observation contract.'})
    # Preserve the exact standard opportunity schema for target_build.py.
    if missing:
        with (ROOT/'input/final_selected_missing_opportunities.csv').open('w',newline='') as f:
            w=csv.DictWriter(f,fieldnames=list(missing[0].keys()));w.writeheader();w.writerows(missing)
    (a.out/'reuse_manifest.json').write_text(json.dumps({'reused_jobs':len(reused),'missing_jobs':len(missing),'reused_candidates':sorted({r['candidate'] for r in reused}),'missing_candidates':sorted({r['candidate'] for r in missing})},indent=2)+'\n')
    print('[REUSE-FINAL10]',json.dumps(s,sort_keys=True))
    print('[REUSE-FINAL10-MISSING]',sorted({r['candidate'] for r in missing}),f'jobs={len(missing)}')
if __name__=='__main__':main()
