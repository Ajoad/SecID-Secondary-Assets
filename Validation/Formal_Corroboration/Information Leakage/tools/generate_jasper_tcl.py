#!/usr/bin/env python3
from __future__ import annotations
import argparse, csv, json, re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def rcsv(p):
    with open(p,newline='') as f: return list(csv.DictReader(f))
def safe(s):
    s=re.sub(r'[^A-Za-z0-9_]+','_',s)
    return re.sub(r'_+','_',s).strip('_')[:160]
def scope_sig(sig,scope,cfg):
    if scope=='core' or sig==cfg['uop']: return sig
    return cfg['env_core_prefix']+sig
def header(cfg,scope,rid):
    top=cfg['core_top'] if scope=='core' else cfg['env_top']
    files=list(cfg['rtl_files']) + ([cfg['env_wrapper']] if scope=='env' else [])
    fl=' \\\n'.join(f'    [file join $RTL {x}]' for x in files)
    assumptions='\n'.join(f'assume {{{a}}}' for a in cfg['assumptions'])
    audit=''
    if cfg.get('baseline_reset_audit',True) and rid in ('00_baseline','50_effort_baseline_r01'):
        audit='\n# Audit reset semantics without changing constraints.\ncatch {get_reset_info -x_value -with_reset_pin} SECID_RESET_AUDIT_MSG\n'
    return f'''# AUTO-GENERATED -- do not hand-edit.
# Package: {cfg['package_version']}
# Campaign: {rid}   Scope: {scope}
if {{[info exists ::env(SECID_ROOT)] && $::env(SECID_ROOT) ne ""}} {{
  set ROOT [file normalize $::env(SECID_ROOT)]
}} else {{
  set ROOT {{{ROOT}}}
}}
set RTL [file join $ROOT rtl]
set RESULT_DIR [file join $ROOT results {scope} {rid}]
file mkdir $RESULT_DIR
set RTL_FILES [list \\
{fl}
]

check_spv -init
analyze -v2k +incdir+$RTL {{*}}$RTL_FILES
elaborate -top {top} -bbox_mul {int(cfg.get('bbox_mul_threshold',64))}
clock {cfg['clock']}
reset -expression {{{cfg['reset_expression']}}}
{audit}
# Fixed environment: identical for baseline and every exclusion.
{assumptions}

'''
def prop(name,src,dst,blocked=None):
    extra=f' -not_through {{{blocked}}}' if blocked else ''
    extra+=' -taint_feedback_loop'
    return f'check_spv -create -name {name} -from {{{src}}} -to {{{dst}}}{extra}\n'
def footer(rid,pname):
    return f'''
set SECID_TARGET_PROPERTIES [list {pname}]
check_spv -prove -property $SECID_TARGET_PROPERTIES

set cf [open [file join $RESULT_DIR consistency.txt] w]
set CONS_RC [catch {{set CONS_MSG [check_spv -consistency -property $SECID_TARGET_PROPERTIES -list both -include_stopats]}} CONS_ERR]
if {{$CONS_RC == 0}} {{ puts $cf $CONS_MSG }} else {{ puts $cf "ERROR: $CONS_ERR" }}
close $cf

set sf2 [open [file join $RESULT_DIR signoff.txt] w]
set SIGN_RC [catch {{set SIGN_MSG [check_spv -signoff -properties $SECID_TARGET_PROPERTIES]}} SIGN_ERR]
if {{$SIGN_RC == 0}} {{ puts $sf2 $SIGN_MSG }} else {{ puts $sf2 "ERROR: $SIGN_ERR" }}
close $sf2

set REPORT_RC [catch {{report -summary -force -result -file [file join $RESULT_DIR report.rpt]}} REPORT_MSG]
if {{$REPORT_RC != 0}} {{
  set rf [open [file join $RESULT_DIR report_command_warning.txt] w]
  puts $rf $REPORT_MSG
  close $rf
}}

set stf [open [file join $RESULT_DIR status.tsv] w]
puts $stf "property\tstatus"
if {{[llength [info commands get_property_list]] > 0}} {{
  if {{![catch {{set SECID_PROPS [get_property_list]}}]}} {{
    foreach p $SECID_PROPS {{
      if {{[string match "*SECID_*" $p]}} {{
        set st "UNKNOWN"
        if {{[catch {{set st [get_property_info -property $p -list status]}}]}} {{
          catch {{set st [get_property_info $p -list status]}}
        }}
        puts $stf "$p\t$st"
      }}
    }}
  }}
}}
close $stf
puts "SECID_RUN_COMPLETE\t{rid}\t[file normalize $RESULT_DIR]"
'''
def write(scope,rid,pname,src,dst,cfg,blocked=None):
    gd=ROOT/'generated'/scope; gd.mkdir(parents=True,exist_ok=True)
    p=gd/(rid+'.tcl')
    p.write_text(header(cfg,scope,rid)+prop(pname,src,dst,blocked)+footer(rid,pname))
    return p

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--scope',choices=['core','env','both'],default='both'); a=ap.parse_args()
    cfg=json.load(open(ROOT/'config/secid_il_jasper.json')); assets=rcsv(ROOT/cfg['secid_assets_csv'])
    scopes=['core','env'] if a.scope=='both' else [a.scope]
    made=[]; nrep=int(cfg.get('effort_repeats',5))
    for scope in scopes:
        gd=ROOT/'generated'/scope; gd.mkdir(parents=True,exist_ok=True)
        for old in gd.glob('*.tcl'): old.unlink()
        primary=scope_sig(cfg['primary'],scope,cfg); uop=scope_sig(cfg['uop'],scope,cfg)
        made.append(write(scope,'00_baseline','SECID_BASE_PRIMARY_TO_UOP',primary,uop,cfg))
        for i,r in enumerate(assets):
            c=scope_sig(r['candidate'],scope,cfg); slug=safe(r['candidate'])
            made.append(write(scope,f'10_exclude_{i:02d}_{slug}',f'SECID_EXCLUDE_SA{i:02d}_PRIMARY_TO_UOP',primary,uop,cfg,c))
        for rep in range(1,nrep+1):
            made.append(write(scope,f'50_effort_baseline_r{rep:02d}',f'SECID_EFFORT_BASE_R{rep:02d}_PRIMARY_TO_UOP',primary,uop,cfg))
            for i,r in enumerate(assets):
                c=scope_sig(r['candidate'],scope,cfg); slug=safe(r['candidate'])
                made.append(write(scope,f'60_effort_exclude_{i:02d}_{slug}_r{rep:02d}',f'SECID_EFFORT_EXCL_SA{i:02d}_R{rep:02d}_PRIMARY_TO_UOP',primary,uop,cfg,c))
    print(f'[GENERATE] wrote {len(made)} Tcl scripts')
if __name__=='__main__': main()
