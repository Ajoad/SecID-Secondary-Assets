#!/usr/bin/env python3
from __future__ import annotations
import argparse,csv,itertools,json,random
from pathlib import Path
from collections import defaultdict
ROOT=Path(__file__).resolve().parents[1]
BOOT_REPS=40000
BOOT_SEED=2026092003

def read_csv(p):
    with p.open(newline='') as f:return list(csv.DictReader(f))
def load_jobs(root):
    p=Path(root)/'aggregate/per_job.json'
    if not p.exists():raise SystemExit(f'missing aggregate: {p}')
    return json.loads(p.read_text())
def mean(xs):return sum(xs)/len(xs) if xs else None
def div(a,b):return None if b in (0,None) or a is None else a/b
def group(rows):
    g=defaultdict(list)
    for r in rows:g[r['candidate']].append(r)
    return g

def sig_stats(rows):
    valid=[r for r in rows if r.get('valid')]
    n=len(valid)
    def sat(p):return sum(r.get(p)=='SAT_WITNESS' for r in valid)
    def unk(p):return sum(r.get(p)=='UNKNOWN' for r in valid)
    return {'jobs':len(rows),'valid_jobs':n,'invalid_jobs':len(rows)-n,
            'primary_sat':sat('c_t_primary'),'semantic_sat':sat('c_t_semantic'),
            'false_write_sat':sat('c_t_false_write_semantic'),'suppression_sat':sat('c_t_suppression_semantic'),
            'primary_unknown':unk('c_t_primary'),'semantic_unknown':unk('c_t_semantic'),
            'primary_yield':sat('c_t_primary')/n if n else None,'semantic_yield':sat('c_t_semantic')/n if n else None,
            'primary_unknown_fraction':unk('c_t_primary')/n if n else None,'semantic_unknown_fraction':unk('c_t_semantic')/n if n else None}

def exact_permutation(a,b,alternative='greater'):
    # For 10-vs-10 there are C(20,10)=184,756 labelings, so exact enumeration
    # is feasible and avoids Monte-Carlo p-value noise.
    pool=list(a)+list(b);n=len(a);N=len(pool);obs=mean(a)-mean(b);total=0;ext=0;absobs=abs(obs)
    tsum=sum(pool)
    for idx in itertools.combinations(range(N),n):
        sa=sum(pool[i] for i in idx);d=sa/n-(tsum-sa)/(N-n);total+=1
        if alternative=='greater':
            if d>=obs-1e-15:ext+=1
        elif alternative=='two-sided':
            if abs(d)>=absobs-1e-15:ext+=1
        else:raise ValueError(alternative)
    return ext/total

def bootstrap_diff(a,b,reps=BOOT_REPS,seed=BOOT_SEED):
    rng=random.Random(seed);vals=[]
    for _ in range(reps):
        aa=[a[rng.randrange(len(a))] for _ in a];bb=[b[rng.randrange(len(b))] for _ in b]
        vals.append(mean(aa)-mean(bb))
    vals.sort();return [vals[int(.025*(reps-1))],vals[int(.975*(reps-1))]]
def cliffs_delta(a,b):
    gt=lt=0
    for x in a:
        for y in b:
            if x>y:gt+=1
            elif x<y:lt+=1
    return (gt-lt)/(len(a)*len(b))

def main():
    ap=argparse.ArgumentParser();ap.add_argument('selected',type=Path);ap.add_argument('controls',type=Path)
    ap.add_argument('--control-set',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
    sm=read_csv(ROOT/'input/final_sas_10.csv');cm=read_csv(a.control_set)
    if len(sm)!=10 or len({r['candidate'] for r in sm})!=10:raise SystemExit('final selected manifest must contain 10 unique signals')
    if len(cm)!=10 or len({r['candidate'] for r in cm})!=10:raise SystemExit('random control manifest must contain 10 unique signals')
    if {r['candidate'] for r in sm}&{r['candidate'] for r in cm}:raise SystemExit('selected/control overlap')
    sg=group(load_jobs(a.selected));cg=group(load_jobs(a.controls))
    ps=[];pc=[]
    for r in sm:
        n=r['candidate']
        if n not in sg:raise SystemExit(f'missing selected jobs for {n}')
        st=sig_stats(sg[n])
        if st['invalid_jobs']:raise SystemExit(f'invalid selected job(s): {n}')
        ps.append({'candidate':n,'group':'SECID_FINAL10','rtl_width':int(r['width']),'domain':r['domain'],'scenario':r['scenario'],'selection_origin':r['selection_origin'],**st})
    cmap={r['candidate']:r for r in cm}
    for n in [r['candidate'] for r in cm]:
        if n not in cg:raise SystemExit(f'missing random-control jobs for {n}')
        st=sig_stats(cg[n]);m=cmap[n]
        if st['invalid_jobs']:raise SystemExit(f'invalid random-control job(s): {n}')
        pc.append({'candidate':n,'group':'RANDOM_STRUCTURAL','rtl_width':int(m['rtl_width']),'domain':m['domain'],'scenario':m['scenario'],**st})
    sp=[x['primary_yield'] for x in ps];cp=[x['primary_yield'] for x in pc]
    ss=[x['semantic_yield'] for x in ps];cs=[x['semantic_yield'] for x in pc]
    spu=[x['primary_unknown_fraction'] for x in ps];cpu=[x['primary_unknown_fraction'] for x in pc]
    ssu=[x['semantic_unknown_fraction'] for x in ps];csu=[x['semantic_unknown_fraction'] for x in pc]
    seed=int(cm[0]['seed'])
    out={
      'schema':'secid_cv32_final10_random_signal_comparison_v1','experimental_unit':'signal','selected_signal_count':10,'random_control_signal_count':10,'random_seed':seed,
      'macro_primary_yield_selected':mean(sp),'macro_primary_yield_random':mean(cp),'macro_primary_yield_difference':mean(sp)-mean(cp),'macro_primary_yield_ratio_selected_over_random':div(mean(sp),mean(cp)),
      'macro_semantic_yield_selected':mean(ss),'macro_semantic_yield_random':mean(cs),'macro_semantic_yield_difference':mean(ss)-mean(cs),'macro_semantic_yield_ratio_selected_over_random':div(mean(ss),mean(cs)),
      'macro_primary_unknown_selected':mean(spu),'macro_primary_unknown_random':mean(cpu),'macro_semantic_unknown_selected':mean(ssu),'macro_semantic_unknown_random':mean(csu),
      'primary_signal_level_cliffs_delta':cliffs_delta(sp,cp),'semantic_signal_level_cliffs_delta':cliffs_delta(ss,cs),
      'primary_difference_permutation_p_one_sided_exact':exact_permutation(sp,cp,'greater'),'primary_difference_permutation_p_two_sided_exact':exact_permutation(sp,cp,'two-sided'),
      'semantic_difference_permutation_p_one_sided_exact':exact_permutation(ss,cs,'greater'),'semantic_difference_permutation_p_two_sided_exact':exact_permutation(ss,cs,'two-sided'),
      'primary_difference_independent_bootstrap_95ci':bootstrap_diff(sp,cp),'semantic_difference_independent_bootstrap_95ci':bootstrap_diff(ss,cs,seed=BOOT_SEED+1),
      'signals_with_any_primary_witness_selected':sum(x>0 for x in sp),'signals_with_any_primary_witness_random':sum(x>0 for x in cp),
      'signals_with_any_semantic_witness_selected':sum(x>0 for x in ss),'signals_with_any_semantic_witness_random':sum(x>0 for x in cs),
      'claim_boundary':'Equal-weight signal-level enrichment comparison of the current 10 final SecID FI outputs against one frozen 10-signal random structural cohort. UNKNOWN is unresolved, never safe.',
      'selected_signals':ps,'random_control_signals':pc}
    a.out.write_text(json.dumps(out,indent=2)+'\n')
    rowsout=ps+pc
    with a.out.with_suffix('.signals.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(rowsout[0].keys()));w.writeheader();w.writerows(rowsout)
    print('[COMPARE-FINAL10]',json.dumps({k:v for k,v in out.items() if k not in ('selected_signals','random_control_signals')},sort_keys=True))
if __name__=='__main__':main()
