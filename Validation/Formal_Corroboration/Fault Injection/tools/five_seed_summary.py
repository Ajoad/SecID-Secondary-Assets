#!/usr/bin/env python3
from __future__ import annotations
import argparse,csv,json,statistics
from pathlib import Path

def mean(x):return sum(x)/len(x)
def div(a,b):return None if b==0 else a/b

def main():
    ap=argparse.ArgumentParser();ap.add_argument('comparisons',nargs='+',type=Path);ap.add_argument('--out',type=Path,default=Path('final10_5seed_summary.json'));a=ap.parse_args()
    js=[json.loads(p.read_text()) for p in a.comparisons]
    if len(js)!=5:raise SystemExit(f'exactly five comparison JSONs required, got {len(js)}')
    js=sorted(js,key=lambda x:int(x['random_seed']))
    seeds=[int(x['random_seed']) for x in js]
    if seeds!=[20260914,20260915,20260916,20260917,20260918]:raise SystemExit(f'unexpected seed set: {seeds}')
    spy={x['macro_primary_yield_selected'] for x in js};ssy={x['macro_semantic_yield_selected'] for x in js}
    if len(spy)!=1 or len(ssy)!=1:raise SystemExit('selected macro yield changed across comparisons; same selected cohort must be reused')
    sp=next(iter(spy));ss=next(iter(ssy));rp=[x['macro_primary_yield_random'] for x in js];rs=[x['macro_semantic_yield_random'] for x in js]
    per=[]
    for x in js:
        per.append({'seed':int(x['random_seed']),'random_primary_yield':x['macro_primary_yield_random'],'random_semantic_yield':x['macro_semantic_yield_random'],
                    'selected_primary_yield':sp,'selected_semantic_yield':ss,'primary_difference':x['macro_primary_yield_difference'],'semantic_difference':x['macro_semantic_yield_difference'],
                    'primary_p_one_sided_exact':x['primary_difference_permutation_p_one_sided_exact'],'semantic_p_one_sided_exact':x['semantic_difference_permutation_p_one_sided_exact']})
    out={'schema':'secid_cv32_final10_five_seed_sensitivity_v1','seeds':seeds,'selected_signal_count':10,'random_signal_count_per_seed':10,
         'selected_primary_yield':sp,'selected_semantic_yield':ss,
         'random_primary_mean':mean(rp),'random_primary_median':statistics.median(rp),'random_primary_min':min(rp),'random_primary_max':max(rp),
         'random_semantic_mean':mean(rs),'random_semantic_median':statistics.median(rs),'random_semantic_min':min(rs),'random_semantic_max':max(rs),
         'selected_over_mean_random_primary_ratio':div(sp,mean(rp)),'selected_over_mean_random_semantic_ratio':div(ss,mean(rs)),
         'all_five_primary_selected_gt_random':all(sp>x for x in rp),'all_five_semantic_selected_gt_random':all(ss>x for x in rs),
         'per_seed':per,
         'inference_boundary':'Five independent frozen random cohorts are reported as sensitivity analysis. Do not pool the 50 control signal observations into a single independent-sample p-value because signals may recur across seeds and the same selected cohort is reused.'}
    a.out.write_text(json.dumps(out,indent=2)+'\n')
    with a.out.with_suffix('.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(per[0].keys()));w.writeheader();w.writerows(per)
    print('[FINAL10-5SEED]',json.dumps({k:v for k,v in out.items() if k!='per_seed'},sort_keys=True))
if __name__=='__main__':main()
