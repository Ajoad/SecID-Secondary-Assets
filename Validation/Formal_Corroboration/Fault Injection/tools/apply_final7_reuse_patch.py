#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import itertools
import json
import math
import random
import shutil
import statistics
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

SEEDS = [20260914, 20260915, 20260916, 20260917, 20260918]
BOOT_REPS = 20000
BOOT_SEED = 20260920
EXPECTED_FINAL7 = [
    'core_i.id_stage_i.deassert_we',
    'core_i.data_misaligned',
    'core_i.csr_op',
    'core_i.id_stage_i.decoder_i.csr_op',
    'core_i.id_stage_i.csr_op',
    'core_i.id_ready',
    'core_i.ex_ready',
]


def read_csv(path: Path):
    with path.open(newline='') as f:
        return list(csv.DictReader(f))


def write_csv(path: Path, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    if not rows:
        raise RuntimeError(f'no rows for {path}')
    fields = []
    for r in rows:
        for k in r:
            if k not in fields:
                fields.append(k)
    with path.open('w', newline='') as f:
        w = csv.DictWriter(f, fieldnames=fields, extrasaction='ignore')
        w.writeheader(); w.writerows(rows)


def mean(xs):
    return sum(xs) / len(xs)


def div(a, b):
    return None if b == 0 else a / b


def count_summary(rows):
    valid = [r for r in rows if bool(r.get('valid'))]
    out = {'jobs': len(rows), 'valid_jobs': len(valid), 'invalid_jobs': len(rows) - len(valid)}
    for p in ('c_t_primary', 'c_t_semantic', 'c_t_false_write_semantic', 'c_t_suppression_semantic'):
        out[p + '_sat'] = sum(r.get(p) == 'SAT_WITNESS' for r in valid)
        out[p + '_unsat'] = sum(r.get(p) == 'UNSAT_PROVEN' for r in valid)
        out[p + '_unknown'] = sum(r.get(p) == 'UNKNOWN' for r in valid)
    if valid:
        out['primary_witness_yield_all_valid'] = out['c_t_primary_sat'] / len(valid)
        out['semantic_witness_yield_all_valid'] = out['c_t_semantic_sat'] / len(valid)
        out['unknown_primary_fraction'] = out['c_t_primary_unknown'] / len(valid)
        out['unknown_semantic_fraction'] = out['c_t_semantic_unknown'] / len(valid)
    return out


def per_signal(rows, metadata=None):
    g = defaultdict(list)
    for r in rows:
        g[r['candidate']].append(r)
    out = []
    for name, rr in sorted(g.items()):
        st = count_summary(rr)
        if st['invalid_jobs']:
            raise RuntimeError(f'invalid reused Jasper job(s) for {name}: {st["invalid_jobs"]}')
        md = (metadata or {}).get(name, {})
        out.append({
            'candidate': name,
            'rtl_width': int(rr[0].get('rtl_width') or md.get('rtl_width') or md.get('width') or 0),
            'domain': md.get('domain', rr[0].get('domain', '')),
            'scenario': md.get('scenario', rr[0].get('scenario', '')),
            **st,
        })
    return out


def sig_yield(sigrow, which):
    jobs = int(sigrow['valid_jobs'])
    if not jobs:
        raise RuntimeError(f'no valid jobs for {sigrow["candidate"]}')
    return int(sigrow[f'c_t_{which}_sat']) / jobs


def sig_unknown(sigrow, which):
    jobs = int(sigrow['valid_jobs'])
    return int(sigrow[f'c_t_{which}_unknown']) / jobs


def exact_permutation(a, b, alternative='greater'):
    pool = list(a) + list(b)
    n = len(a); N = len(pool)
    obs = mean(a) - mean(b)
    tsum = sum(pool)
    total = ext = 0
    absobs = abs(obs)
    for idx in itertools.combinations(range(N), n):
        sa = sum(pool[i] for i in idx)
        d = sa / n - (tsum - sa) / (N - n)
        total += 1
        if alternative == 'greater':
            ext += d >= obs - 1e-15
        elif alternative == 'two-sided':
            ext += abs(d) >= absobs - 1e-15
        else:
            raise ValueError(alternative)
    return ext / total


def bootstrap_diff(a, b, reps=BOOT_REPS, seed=BOOT_SEED):
    rng = random.Random(seed)
    vals = []
    for _ in range(reps):
        aa = [a[rng.randrange(len(a))] for _ in a]
        bb = [b[rng.randrange(len(b))] for _ in b]
        vals.append(mean(aa) - mean(bb))
    vals.sort()
    return [vals[int(.025 * (reps - 1))], vals[int(.975 * (reps - 1))]]


def cliffs_delta(a, b):
    gt = lt = 0
    for x in a:
        for y in b:
            gt += x > y
            lt += x < y
    return (gt - lt) / (len(a) * len(b))


def ensure_aggregate(target: Path, run_dir: Path):
    p = run_dir / 'aggregate' / 'per_job.json'
    if p.exists():
        return p
    agg = target / 'tools' / 'target_aggregate.py'
    if run_dir.exists() and agg.exists():
        print(f'[PATCH] aggregate missing; rebuilding {run_dir.name}')
        subprocess.run([sys.executable, str(agg), str(run_dir)], cwd=target, check=True,
                       env={**dict(__import__('os').environ), 'PYTHONPATH': str(target / 'tools')})
    if not p.exists():
        raise RuntimeError(f'missing prior result aggregate: {p}')
    return p


def write_reused_run(outdir: Path, rows, group: str, provenance: dict):
    agg = outdir / 'aggregate'
    agg.mkdir(parents=True, exist_ok=True)
    rows = [dict(r) for r in rows]
    for r in rows:
        r['reuse_original_group'] = r.get('group', '')
        r['group'] = group
        r['final7_reused'] = True
    (agg / 'per_job.json').write_text(json.dumps(rows, indent=2) + '\n')
    write_csv(agg / 'per_job.csv', rows)
    sig = per_signal(rows)
    (agg / 'per_signal.json').write_text(json.dumps(sig, indent=2) + '\n')
    write_csv(agg / 'per_signal.csv', sig)
    summary = {
        'schema': 'secid_cv32_final7_reused_aggregate_v1',
        'group': group,
        **count_summary(rows),
        **provenance,
    }
    (agg / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    return summary


def compare_one(selected_rows, control_rows, selected_manifest, control_manifest, seed, outpath: Path):
    smap = {r['candidate']: r for r in selected_manifest}
    cmap = {r['candidate']: r for r in control_manifest}
    ssig = per_signal(selected_rows, smap)
    csig = per_signal(control_rows, cmap)
    if {x['candidate'] for x in ssig} != set(smap):
        raise RuntimeError(f'selected signal/result mismatch for seed {seed}')
    if {x['candidate'] for x in csig} != set(cmap):
        raise RuntimeError(f'control signal/result mismatch for seed {seed}')

    # Preserve manifest order in reporting.
    sx = {x['candidate']: x for x in ssig}; cx = {x['candidate']: x for x in csig}
    ssig = [sx[r['candidate']] for r in selected_manifest]
    csig = [cx[r['candidate']] for r in control_manifest]

    sp = [sig_yield(x, 'primary') for x in ssig]
    cp = [sig_yield(x, 'primary') for x in csig]
    se = [sig_yield(x, 'semantic') for x in ssig]
    ce = [sig_yield(x, 'semantic') for x in csig]
    spu = [sig_unknown(x, 'primary') for x in ssig]
    cpu = [sig_unknown(x, 'primary') for x in csig]
    seu = [sig_unknown(x, 'semantic') for x in ssig]
    ceu = [sig_unknown(x, 'semantic') for x in csig]

    selected_signals = []
    for x in ssig:
        selected_signals.append({
            'candidate': x['candidate'], 'group': 'SECID_FINAL7', 'rtl_width': x['rtl_width'],
            'domain': smap[x['candidate']].get('domain', ''), 'scenario': smap[x['candidate']].get('scenario', ''),
            'primary_yield': sig_yield(x, 'primary'), 'semantic_yield': sig_yield(x, 'semantic'),
            'primary_unknown_fraction': sig_unknown(x, 'primary'), 'semantic_unknown_fraction': sig_unknown(x, 'semantic'),
            'jobs': x['jobs'], 'valid_jobs': x['valid_jobs'],
        })
    control_signals = []
    for x in csig:
        control_signals.append({
            'candidate': x['candidate'], 'group': 'RANDOM_STRUCTURAL_FROZEN_PREFIX', 'rtl_width': x['rtl_width'],
            'domain': cmap[x['candidate']].get('domain', ''), 'scenario': cmap[x['candidate']].get('scenario', ''),
            'primary_yield': sig_yield(x, 'primary'), 'semantic_yield': sig_yield(x, 'semantic'),
            'primary_unknown_fraction': sig_unknown(x, 'primary'), 'semantic_unknown_fraction': sig_unknown(x, 'semantic'),
            'jobs': x['jobs'], 'valid_jobs': x['valid_jobs'],
        })

    out = {
        'schema': 'secid_cv32_final7_frozenprefix_random_signal_comparison_v1',
        'experimental_unit': 'signal',
        'selected_signal_count': 7,
        'random_control_signal_count': 7,
        'random_seed': seed,
        'macro_primary_yield_selected': mean(sp),
        'macro_primary_yield_random': mean(cp),
        'macro_primary_yield_difference': mean(sp) - mean(cp),
        'macro_primary_yield_ratio_selected_over_random': div(mean(sp), mean(cp)),
        'macro_semantic_yield_selected': mean(se),
        'macro_semantic_yield_random': mean(ce),
        'macro_semantic_yield_difference': mean(se) - mean(ce),
        'macro_semantic_yield_ratio_selected_over_random': div(mean(se), mean(ce)),
        'macro_primary_unknown_selected': mean(spu),
        'macro_primary_unknown_random': mean(cpu),
        'macro_semantic_unknown_selected': mean(seu),
        'macro_semantic_unknown_random': mean(ceu),
        'primary_signal_level_cliffs_delta': cliffs_delta(sp, cp),
        'semantic_signal_level_cliffs_delta': cliffs_delta(se, ce),
        'primary_difference_permutation_p_one_sided_exact': exact_permutation(sp, cp, 'greater'),
        'primary_difference_permutation_p_two_sided_exact': exact_permutation(sp, cp, 'two-sided'),
        'semantic_difference_permutation_p_one_sided_exact': exact_permutation(se, ce, 'greater'),
        'semantic_difference_permutation_p_two_sided_exact': exact_permutation(se, ce, 'two-sided'),
        'primary_difference_independent_bootstrap_95ci': bootstrap_diff(sp, cp, seed=BOOT_SEED + seed % 1000),
        'semantic_difference_independent_bootstrap_95ci': bootstrap_diff(se, ce, seed=BOOT_SEED + 1000 + seed % 1000),
        'signals_with_any_primary_witness_selected': sum(x > 0 for x in sp),
        'signals_with_any_primary_witness_random': sum(x > 0 for x in cp),
        'signals_with_any_semantic_witness_selected': sum(x > 0 for x in se),
        'signals_with_any_semantic_witness_random': sum(x > 0 for x in ce),
        'control_sampling_rule': 'first 7 signals in the previously frozen seed-shuffled 10-signal cohort; the prefix of a random ordered sample is itself a random 7-signal sample from the same frozen eligible pool',
        'claim_boundary': 'Reuses the outcome-blind v1.3.0 frozen 479-signal control sampling frame. That frame remains disjoint from all current final7 assets but omits two signals that became current-eligible after the final10->final7 reduction. UNKNOWN is unresolved, never safe.',
        'selected_signals': selected_signals,
        'random_control_signals': control_signals,
    }
    outpath.write_text(json.dumps(out, indent=2) + '\n')
    write_csv(outpath.with_suffix('.signals.csv'), selected_signals + control_signals)
    return out


def audit_current_pool(target: Path, final7_names: set[str]):
    inp = target / 'input'
    broad = read_csv(inp / 'broad_universe_494.csv')
    p_obj = json.loads((inp / 'physical_dealiased_candidate_manifest.json').read_text())
    pmap = {x['candidate']: x for x in p_obj['candidates']}
    selected_phys = set()
    for name in final7_names:
        p = pmap.get(name)
        if p:
            selected_phys.update(map(int, p.get('bits', [])))
    eligible = set()
    for r in broad:
        name = r['candidate']
        p = pmap.get(name)
        if name in final7_names: continue
        if int(r['width']) > 64: continue
        if not p or not p.get('bits'): continue
        if set(map(int, p['bits'])) & selected_phys: continue
        eligible.add(name)
    old_pool = {r['candidate'] for r in read_csv(inp / 'random_control_eligible_pool_final10.csv')}
    return {
        'current_exact_eligible_pool_size': len(eligible),
        'frozen_v1_3_0_eligible_pool_size': len(old_pool),
        'frozen_pool_fraction_of_current_exact_pool': len(old_pool & eligible) / len(eligible),
        'current_eligible_but_not_in_frozen_pool': sorted(eligible - old_pool),
        'frozen_pool_members_no_longer_current_eligible': sorted(old_pool - eligible),
    }


def main():
    ap = argparse.ArgumentParser(description='Zero-Jasper final10->final7 reuse patch for CV32E40P targeted FI validation')
    ap.add_argument('--target', type=Path, required=True, help='existing cv32e40p_csr_we_int_targeted_fi_v1_3_0_final10_5seed run directory')
    ap.add_argument('--source-json', type=Path, default=Path(__file__).resolve().with_name('final7_source.json'))
    ap.add_argument('--out-name', default='final7_reuse_analysis')
    args = ap.parse_args()

    target = args.target.resolve()
    source = args.source_json.resolve()
    if not target.is_dir(): raise SystemExit(f'target directory not found: {target}')
    required = [
        target/'input/final_sas_10.csv', target/'input/final_selected_opportunities.csv',
        target/'input/random_control_eligible_pool_final10.csv', target/'input/broad_universe_494.csv',
        target/'input/physical_dealiased_candidate_manifest.json',
    ]
    for p in required:
        if not p.exists(): raise SystemExit(f'not a compatible v1.3.0 target; missing {p}')
    if not source.exists(): raise SystemExit(f'new final-asset source JSON not found: {source}')

    src = json.loads(source.read_text())
    names = [x['Name'] for x in src if x.get('decision') == 'retain']
    if names != EXPECTED_FINAL7:
        raise SystemExit('unexpected current asset list; patch is intentionally fail-closed.\n'
                         f'expected={EXPECTED_FINAL7}\nactual={names}')

    final10 = read_csv(target/'input/final_sas_10.csv')
    final10_names = [r['candidate'] for r in final10]
    if not set(names).issubset(final10_names):
        raise SystemExit('current final7 is not a subset of the prior final10 manifest; cannot use zero-rerun subset reuse')

    out = target / args.out_name
    if out.exists():
        backup = target / f'{args.out_name}_backup'
        if backup.exists(): shutil.rmtree(backup)
        shutil.move(str(out), str(backup))
        print(f'[PATCH] prior output backed up to {backup.name}')
    out.mkdir(parents=True)
    out_in = out/'input'; out_in.mkdir()
    shutil.copy2(source, out_in/'final_secid_fi_assets_7_source.json')

    final7_manifest = [r for r in final10 if r['candidate'] in set(names)]
    final7_manifest.sort(key=lambda r: names.index(r['candidate']))
    # Renumber selected IDs for the new cohort, but keep all physical/cutpoint/scenario metadata unchanged.
    for i, r in enumerate(final7_manifest):
        r['selected_id'] = str(i)
    write_csv(out_in/'final_sas_7.csv', final7_manifest)

    old_sel_ops = read_csv(target/'input/final_selected_opportunities.csv')
    final7_ops = [r for r in old_sel_ops if r['candidate'] in set(names)]
    final7_ops.sort(key=lambda r: (names.index(r['candidate']), int(r['sample_rank'])))
    for r in final7_ops:
        r['set_id'] = 'SECID_FINAL7'
        r['group'] = 'FINAL7_SELECTED_REUSED'
        r['stratum'] = 'SECID_FINAL_ASSET'
        r['selected_id'] = str(names.index(r['candidate']))
        r['opportunity_id'] = f"F7S{names.index(r['candidate']):02d}_r{int(r['sample_rank'])}_b{int(r['bit']):03d}"
    write_csv(out_in/'final_selected_opportunities_7.csv', final7_ops)

    # Reuse selected results exactly from the completed final10 campaign.
    sel_p = ensure_aggregate(target, target/'run_final10_selected_combined')
    old_sel_rows = json.loads(sel_p.read_text())
    selected_rows = [r for r in old_sel_rows if r['candidate'] in set(names)]
    wanted_sel_keys = {(r['candidate'], int(r['bit']), r['scenario'], r['injection_path']) for r in final7_ops}
    got_sel_keys = {(r['candidate'], int(r['bit']), r.get('scenario'), r.get('injection_path')) for r in selected_rows}
    if got_sel_keys != wanted_sel_keys:
        raise RuntimeError(f'selected reuse mismatch: missing={wanted_sel_keys-got_sel_keys}, extra={got_sel_keys-wanted_sel_keys}')
    sel_summary = write_reused_run(out/'run_final7_selected_reused', selected_rows, 'FINAL7_SELECTED_REUSED', {
        'reused_from': str(sel_p), 'reuse_contract': 'exact candidate+bit+scenario+cutpoint under unchanged 1-cycle FI and 24-cycle observation contract',
        'jasper_rerun_required': False,
    })

    comparisons = []
    cohort_audit = []
    selected_meta = {r['candidate']: r for r in final7_manifest}
    for seed in SEEDS:
        old_manifest = read_csv(target/f'input/random_signal_controls_10_seed{seed}.csv')
        old_manifest.sort(key=lambda r: int(r['random_id']))
        controls = [dict(r) for r in old_manifest[:7]]
        if len(controls) != 7:
            raise RuntimeError(f'seed {seed}: old frozen cohort has fewer than 7 controls')
        if set(x['candidate'] for x in controls) & set(names):
            raise RuntimeError(f'seed {seed}: frozen-prefix control overlaps current final7')
        for i, r in enumerate(controls):
            r['random_id'] = str(i)
            r['sampling_rule'] = 'prefix-7 reuse of previously frozen v1.3.0 seed-shuffled ordered cohort; no outcome-based reselection'
        write_csv(out_in/f'random_signal_controls_7_seed{seed}.csv', controls)

        old_ops = read_csv(target/f'input/random_control_opportunities_seed{seed}.csv')
        cset = {r['candidate'] for r in controls}
        cops = [dict(r) for r in old_ops if r['candidate'] in cset]
        # Maintain frozen manifest order and within-signal bit order.
        ordmap = {r['candidate']: i for i, r in enumerate(controls)}
        cops.sort(key=lambda r: (ordmap[r['candidate']], int(r['sample_rank'])))
        for r in cops:
            r['set_id'] = f'RANDOM7_FROZEN_PREFIX_SEED_{seed}'
            r['group'] = 'RANDOM_CONTROL_REUSED'
        write_csv(out_in/f'random_control_opportunities_7_seed{seed}.csv', cops)

        ctrl_p = ensure_aggregate(target, target/f'run_random_controls_seed{seed}')
        old_ctrl_rows = json.loads(ctrl_p.read_text())
        control_rows = [r for r in old_ctrl_rows if r['candidate'] in cset]
        expected = {(r['candidate'], int(r['bit']), r['scenario'], r['injection_path']) for r in cops}
        got = {(r['candidate'], int(r['bit']), r.get('scenario'), r.get('injection_path')) for r in control_rows}
        if got != expected:
            raise RuntimeError(f'seed {seed}: random reuse mismatch: missing={expected-got}, extra={got-expected}')
        ctrl_summary = write_reused_run(out/f'run_random_controls_7_reused_seed{seed}', control_rows, 'RANDOM_CONTROL_REUSED', {
            'reused_from': str(ctrl_p), 'random_seed': seed,
            'sampling_rule': 'first 7 of the previously frozen random order; no Jasper rerun and no outcome-based signal selection',
            'jasper_rerun_required': False,
        })
        comp = compare_one(selected_rows, control_rows, final7_manifest, controls, seed,
                           out/f'final7_random_comparison_seed{seed}.json')
        comparisons.append(comp)
        cohort_audit.append({
            'seed': seed,
            'control_signals': [r['candidate'] for r in controls],
            'control_jobs_reused': len(control_rows),
            'control_valid_jobs': ctrl_summary['valid_jobs'],
        })
        print('[FINAL7-COMPARE]', json.dumps({k:v for k,v in comp.items() if k not in ('selected_signals','random_control_signals')}, sort_keys=True))

    comparisons.sort(key=lambda x: x['random_seed'])
    sp = comparisons[0]['macro_primary_yield_selected']
    ss = comparisons[0]['macro_semantic_yield_selected']
    if any(abs(x['macro_primary_yield_selected']-sp) > 1e-15 or abs(x['macro_semantic_yield_selected']-ss) > 1e-15 for x in comparisons):
        raise RuntimeError('selected yield changed across seeds')
    rp = [x['macro_primary_yield_random'] for x in comparisons]
    rs = [x['macro_semantic_yield_random'] for x in comparisons]
    per = [{
        'seed': x['random_seed'],
        'selected_primary_yield': sp,
        'random_primary_yield': x['macro_primary_yield_random'],
        'primary_difference': x['macro_primary_yield_difference'],
        'selected_semantic_yield': ss,
        'random_semantic_yield': x['macro_semantic_yield_random'],
        'semantic_difference': x['macro_semantic_yield_difference'],
        'primary_p_one_sided_exact': x['primary_difference_permutation_p_one_sided_exact'],
        'semantic_p_one_sided_exact': x['semantic_difference_permutation_p_one_sided_exact'],
    } for x in comparisons]
    summary = {
        'schema': 'secid_cv32_final7_frozenprefix_five_seed_sensitivity_v1',
        'seeds': SEEDS,
        'selected_signal_count': 7,
        'random_signal_count_per_seed': 7,
        'selected_primary_yield': sp,
        'selected_semantic_yield': ss,
        'random_primary_mean': mean(rp),
        'random_primary_median': statistics.median(rp),
        'random_primary_min': min(rp),
        'random_primary_max': max(rp),
        'random_semantic_mean': mean(rs),
        'random_semantic_median': statistics.median(rs),
        'random_semantic_min': min(rs),
        'random_semantic_max': max(rs),
        'selected_over_mean_random_primary_ratio': div(sp, mean(rp)),
        'selected_over_mean_random_semantic_ratio': div(ss, mean(rs)),
        'all_five_primary_selected_gt_random': all(sp > x for x in rp),
        'all_five_semantic_selected_gt_random': all(ss > x for x in rs),
        'per_seed': per,
        'inference_boundary': 'Five previously frozen random orders are reused by taking the first seven signals from each. This is an outcome-independent prefix rule. Do not pool the 35 control signal observations as independent because signals may recur across seeds and the same selected cohort is reused.',
    }
    (out/'final7_5seed_summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    write_csv(out/'final7_5seed_summary.csv', per)

    pool_audit = audit_current_pool(target, set(names))
    audit = {
        'schema': 'secid_cv32_final7_zero_rerun_reuse_audit_v1',
        'current_final_assets': names,
        'current_final_asset_count': 7,
        'prior_final10_asset_count': len(final10_names),
        'removed_from_prior_final10': [n for n in final10_names if n not in set(names)],
        'selected_jobs_reused': len(selected_rows),
        'selected_jobs_expected': len(final7_ops),
        'selected_reuse_fraction': len(selected_rows)/len(final7_ops),
        'random_cohorts': cohort_audit,
        'jasper_rerun_required': False,
        'reuse_basis': 'current final7 is an exact subset of the prior final10; all selected jobs and frozen-prefix random-control jobs were already run under identical formal properties, cutpoints, scenarios, FI duration, and observation horizon',
        'frozen_prefix_validity': 'The previous random sampler first seed-shuffled the eligible signals and then took an ordered sample. The first seven entries of that already-frozen random order form a seven-signal random sample from the same frozen sampling frame. The prefix length is dictated by the new selected-cohort size, not by observed Jasper outcomes.',
        'sampling_frame_audit': pool_audit,
        'publication_boundary': 'For zero-rerun reuse, describe controls as sampled from the previously frozen v1.3.0 eligible structural-control pool. Do not state that they were uniformly resampled from the exact updated final7 pool. The frozen pool remains fully disjoint from current final7 assets.',
    }
    (out/'FINAL7_REUSE_AUDIT.json').write_text(json.dumps(audit, indent=2) + '\n')

    print('[FINAL7-5SEED]', json.dumps({k:v for k,v in summary.items() if k!='per_seed'}, sort_keys=True))
    print('[FINAL7-REUSE-AUDIT]', json.dumps({
        'selected_jobs_reused': audit['selected_jobs_reused'],
        'selected_jobs_expected': audit['selected_jobs_expected'],
        'jasper_rerun_required': audit['jasper_rerun_required'],
        **pool_audit,
    }, sort_keys=True))
    print(f'[DONE] outputs: {out}')


if __name__ == '__main__':
    main()
