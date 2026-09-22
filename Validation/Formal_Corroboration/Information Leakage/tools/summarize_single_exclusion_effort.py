#!/usr/bin/env python3
from __future__ import annotations
import argparse,csv,json,re,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def rcsv(p):
    with open(p,newline='') as f:return list(csv.DictReader(f))
def med(xs):
    xs=[float(x) for x in xs if x is not None]
    return statistics.median(xs) if xs else None
def mad(xs):
    xs=[float(x) for x in xs if x is not None]
    if not xs:return None
    m=statistics.median(xs); return statistics.median([abs(x-m) for x in xs])
def firstprop(d): return d.get('properties',[{}])[0] if d.get('properties') else {}
def load_run(p,condition,index,candidate,rep):
    d=json.load(open(p)); pr=firstprop(d); aud=d.get('audit',{}); pm=d.get('process_metrics',{})
    return {'condition':condition,'asset_index':index,'candidate':candidate,'repeat':rep,'run_id':p.parent.name,
            'status':pr.get('normalized_status','UNRESOLVED'),'raw_status':pr.get('raw_status',''),
            'proof_seconds':pr.get('proof_seconds'),'wall_seconds':pm.get('wall_seconds'),'cex_cycles':pr.get('cex_cycles'),
            'exit_code':d.get('exit_code'),'material_signoff_risk':bool(aud.get('material_signoff_risk',False)),
            'blackbox_in_coi':bool(aud.get('blackbox_in_coi',False)),'taint_feedback_incomplete':bool(aud.get('taint_feedback_incomplete',False))}
def ratio(a,b): return None if a is None or b in (None,0) else a/b
def fmt(x,d=3): return 'NA' if x is None else f'{x:.{d}f}'
def write_csv(p,rows,fields):
    p.parent.mkdir(parents=True,exist_ok=True)
    with open(p,'w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=fields); w.writeheader(); w.writerows(rows)
def slug(s):
    return re.sub(r'_+','_',re.sub(r'[^A-Za-z0-9_]+','_',s)).strip('_')[:160]
def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--scope',choices=['core','env'],default='core'); a=ap.parse_args()
    cfg=json.load(open(ROOT/'config/secid_il_jasper.json')); assets=rcsv(ROOT/cfg['secid_assets_csv']); n=int(cfg.get('effort_repeats',5))
    rdir=ROOT/'results'/a.scope; raw=[]
    for rep in range(1,n+1):
        p=rdir/f'50_effort_baseline_r{rep:02d}'/'parsed_results.json'
        if p.exists(): raw.append(load_run(p,'baseline',None,'BASELINE',rep))
        for i,r in enumerate(assets):
            p=rdir/f'60_effort_exclude_{i:02d}_{slug(r["candidate"])}_r{rep:02d}'/'parsed_results.json'
            if p.exists(): raw.append(load_run(p,'exclude',i,r['candidate'],rep))
    od=rdir/'single_exclusion_effort'; od.mkdir(parents=True,exist_ok=True)
    raw_fields=['condition','asset_index','candidate','repeat','run_id','status','raw_status','proof_seconds','wall_seconds','cex_cycles','exit_code','material_signoff_risk','blackbox_in_coi','taint_feedback_incomplete']
    write_csv(od/'raw_runs.csv',raw,raw_fields)
    base=[x for x in raw if x['condition']=='baseline']; bp=med([x['proof_seconds'] for x in base]); bw=med([x['wall_seconds'] for x in base]); bc=med([x['cex_cycles'] for x in base if x['status']=='FLOW_FOUND']); b_by_rep={x['repeat']:x for x in base}
    summary=[]
    for i,r in enumerate(assets):
        xs=[x for x in raw if x['condition']=='exclude' and x['asset_index']==i]
        st={k:sum(x['status']==k for x in xs) for k in ['FLOW_FOUND','NO_FLOW_PROVEN','UNRESOLVED']}
        ps=med([x['proof_seconds'] for x in xs]); ws=med([x['wall_seconds'] for x in xs]); cc=med([x['cex_cycles'] for x in xs if x['status']=='FLOW_FOUND'])
        paired_p=[]; paired_w=[]
        for x in xs:
            b=b_by_rep.get(x['repeat'])
            if b and x['status']==b['status']=='FLOW_FOUND':
                q=ratio(x['proof_seconds'],b['proof_seconds']);
                if q is not None: paired_p.append(q)
                q=ratio(x['wall_seconds'],b['wall_seconds']);
                if q is not None: paired_w.append(q)
        clean_n=sum(not x['material_signoff_risk'] and x['exit_code']==0 for x in xs)
        if xs and st['NO_FLOW_PROVEN']==len(xs) and clean_n==len(xs): kind='CLEAN_NO_FLOW_TRANSITION'
        elif xs and st['FLOW_FOUND']==len(xs): kind='FLOW_REMAINS_COMPARE_SEARCH_EFFORT'
        elif st['UNRESOLVED']>0: kind='MIXED_OR_UNRESOLVED'
        else: kind='MIXED_STATUS_TRANSITION'
        summary.append({'asset_index':i,'candidate':r['candidate'],'runs_found':len(xs),'flow_found':st['FLOW_FOUND'],'no_flow_proven':st['NO_FLOW_PROVEN'],'unresolved':st['UNRESOLVED'],'clean_runs':clean_n,
                        'median_proof_seconds':ps,'mad_proof_seconds':mad([x['proof_seconds'] for x in xs]),'median_wall_seconds':ws,'mad_wall_seconds':mad([x['wall_seconds'] for x in xs]),
                        'median_cex_cycles_flow_found':cc,'ratio_of_median_proof_vs_baseline':ratio(ps,bp),'ratio_of_median_wall_vs_baseline':ratio(ws,bw),
                        'median_paired_proof_ratio_vs_baseline':med(paired_p),'mad_paired_proof_ratio_vs_baseline':mad(paired_p),'median_paired_wall_ratio_vs_baseline':med(paired_w),
                        'comparison_kind':kind})
    if summary: write_csv(od/'asset_effort_summary.csv',summary,list(summary[0].keys()))
    baseline_summary={'runs_found':len(base),'flow_found':sum(x['status']=='FLOW_FOUND' for x in base),'no_flow_proven':sum(x['status']=='NO_FLOW_PROVEN' for x in base),'unresolved':sum(x['status']=='UNRESOLVED' for x in base),'median_proof_seconds':bp,'mad_proof_seconds':mad([x['proof_seconds'] for x in base]),'median_wall_seconds':bw,'mad_wall_seconds':mad([x['wall_seconds'] for x in base]),'median_cex_cycles_flow_found':bc}
    result={'package_version':cfg['package_version'],'scope':a.scope,'planned_repeats':n,'baseline':baseline_summary,'assets':summary,'interpretation_guardrails':['Compare runtime ratios primarily when baseline and exclusion both return FLOW_FOUND.','A clean NO_FLOW_PROVEN transition is stronger mediation evidence and should not be reduced to a runtime ratio.','Runtime and CEX cycles characterize formal search/witness behavior, not security severity or globally shortest path length.','Any material signoff risk or unresolved run must remain qualified.']}
    (od/'summary.json').write_text(json.dumps(result,indent=2)+'\n')
    lines=[f'# Single-exclusion SPV effort report ({a.scope})','',f"Baseline runs found: **{baseline_summary['runs_found']}/{n}**; FLOW={baseline_summary['flow_found']}, NO_FLOW={baseline_summary['no_flow_proven']}, UNRESOLVED={baseline_summary['unresolved']}.",f"Baseline median SPV proof/search time: **{fmt(bp)} s** (MAD {fmt(baseline_summary['mad_proof_seconds'])} s); median wall: **{fmt(bw)} s**; median CEX: **{fmt(bc,1)} cycles**.",'','| # | Excluded asset | FLOW | NO-FLOW | UNRES | Median proof s | Paired proof ratio | Median CEX | Interpretation |','|---:|---|---:|---:|---:|---:|---:|---:|---|']
    for x in summary: lines.append(f"| {x['asset_index']} | `{x['candidate']}` | {x['flow_found']} | {x['no_flow_proven']} | {x['unresolved']} | {fmt(x['median_proof_seconds'])} | {fmt(x['median_paired_proof_ratio_vs_baseline'])} | {fmt(x['median_cex_cycles_flow_found'],1)} | {x['comparison_kind']} |")
    lines += ['','## Guardrails','- Search-effort ratios are interpreted primarily for paired `FLOW_FOUND` runs.','- Clean `NO_FLOW_PROVEN` is a stronger status transition, not merely a larger runtime.','- Remaining `FLOW_FOUND` means an alternate modeled route exists; it does not make the excluded asset irrelevant.','- CEX cycles are observed witness lengths, not guaranteed shortest paths.','- Unresolved or signoff-risk runs remain qualified.','']
    (od/'EFFORT_REPORT.md').write_text('\n'.join(lines))
    print(f'[SUMMARY:{a.scope}] baseline median proof={fmt(bp)}s wall={fmt(bw)}s; assets={len(summary)}')
if __name__=='__main__': main()
