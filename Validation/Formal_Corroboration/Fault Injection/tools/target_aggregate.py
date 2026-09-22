#!/usr/bin/env python3
from __future__ import annotations
import argparse,csv,json
from pathlib import Path
from collections import defaultdict

def normalize(raw,is_cover):
    s=(raw or '').lower()
    if is_cover:
        if 'unreachable' in s:return 'UNSAT_PROVEN'
        if any(k in s for k in ('covered','reachable','witness')):return 'SAT_WITNESS'
        return 'UNKNOWN'
    if any(k in s for k in ('counterexample','cex','falsified','failed')):return 'CEX'
    if any(k in s for k in ('proven','pass')) and 'unproven' not in s:return 'PROVEN'
    return 'UNKNOWN'

def marker(p:Path):
    out={}
    if not p.exists():return out
    for line in p.read_text(errors='replace').splitlines():
        if line.startswith('SECID_PROP\t'):
            a=line.split('\t',2)
            if len(a)==3:out[a[1].split('.')[-1]]=a[2].strip()
    return out

def launcher(root):
    p=root/'launcher_results.json'
    if not p.exists():return {},{}
    o=json.loads(p.read_text());return {str(Path(r['job']).resolve()):r for r in o.get('results',[])},o

def extract(job:Path,lmap):
    m=json.loads((job/'job.json').read_text()); st=marker(job/'reports/secid_status.tsv'); r=dict(m)
    for p in m['property_names']:
        raw=st.get(p,'');r[p+'_raw']=raw;r[p]=normalize(raw,p.startswith('c_'))
    r['sanity_assertions_valid']=all(r[p]=='PROVEN' for p in m['sanity_names'])
    r['fault_nonvacuity_valid']=all(r[p]=='SAT_WITNESS' for p in m['nonvacuity_names'])
    r['valid']=r['sanity_assertions_valid'] and r['fault_nonvacuity_valid']
    lr=lmap.get(str(job.resolve()),{})
    for k in ('returncode','launcher_state','elapsed_s','max_rss_kb','user_cpu_s','system_cpu_s'):r[k]=lr.get(k)
    r['primary_class']=r['c_t_primary'] if r['valid'] else 'INVALID';r['semantic_class']=r['c_t_semantic'] if r['valid'] else 'INVALID'
    return r

def count_summary(rows):
    valid=[r for r in rows if r['valid']]
    x={'jobs':len(rows),'valid_jobs':len(valid),'invalid_jobs':len(rows)-len(valid)}
    for p in ('c_t_primary','c_t_semantic','c_t_false_write_semantic','c_t_suppression_semantic'):
        x[p+'_sat']=sum(r.get(p)=='SAT_WITNESS' for r in valid);x[p+'_unsat']=sum(r.get(p)=='UNSAT_PROVEN' for r in valid);x[p+'_unknown']=sum(r.get(p)=='UNKNOWN' for r in valid)
    if valid:
        x['primary_witness_yield_all_valid']=x['c_t_primary_sat']/len(valid);x['semantic_witness_yield_all_valid']=x['c_t_semantic_sat']/len(valid)
        x['unknown_primary_fraction']=x['c_t_primary_unknown']/len(valid);x['unknown_semantic_fraction']=x['c_t_semantic_unknown']/len(valid)
    return x

def main():
    ap=argparse.ArgumentParser();ap.add_argument('job_root',type=Path);a=ap.parse_args();root=a.job_root.resolve()
    jobs=sorted(p for p in root.iterdir() if p.is_dir() and (p/'job.json').exists());lm,lmeta=launcher(root);rows=[extract(j,lm) for j in jobs]
    if not rows:raise SystemExit('no jobs')
    out=root/'aggregate';out.mkdir(exist_ok=True);fields=[]
    for r in rows:
        for k in r:
            if k not in fields:fields.append(k)
    with (out/'per_job.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=fields,extrasaction='ignore');w.writeheader();w.writerows(rows)
    (out/'per_job.json').write_text(json.dumps(rows,indent=2)+'\n')
    s={'schema':'secid_cv32_targeted_fi_aggregate_v1','group':rows[0]['group'],**count_summary(rows),
       'campaign_elapsed_s':lmeta.get('campaign_elapsed_s'),'parallel_jobs':lmeta.get('parallel_jobs'),
       'elapsed_s_sum':sum(float(r.get('elapsed_s') or 0) for r in rows),
       'max_rss_kb_peak':max([int(r['max_rss_kb']) for r in rows if r.get('max_rss_kb') is not None] or [0])}
    strata={}
    for st in sorted({r.get('stratum','') for r in rows}):
        if st: strata[st]=count_summary([r for r in rows if r.get('stratum')==st])
    if strata:s['by_stratum']=strata
    (out/'summary.json').write_text(json.dumps(s,indent=2)+'\n')
    # Signal-level view (important because SELECTED exhaustively faults wide vectors).
    groups=defaultdict(list)
    for r in rows:groups[r['candidate']].append(r)
    sig=[]
    for name,rr in sorted(groups.items()):
        z={'candidate':name,'group':rr[0]['group'],'stratum':rr[0].get('stratum',''),'rtl_width':rr[0]['rtl_width'],**count_summary(rr)}
        sig.append(z)
    if sig:
        with (out/'per_signal.csv').open('w',newline='') as f:
            w=csv.DictWriter(f,fieldnames=list(sig[0].keys()));w.writeheader();w.writerows(sig)
        (out/'per_signal.json').write_text(json.dumps(sig,indent=2)+'\n')
    print('[AGG-TARGET]',json.dumps(s,sort_keys=True))
if __name__=='__main__':main()
