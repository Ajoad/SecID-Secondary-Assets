#!/usr/bin/env python3
from __future__ import annotations
import csv, sys, re
from pathlib import Path

def read_status(path):
    out={}
    with open(path,newline='') as f:
        for r in csv.DictReader(f,delimiter='\t'):
            out[r['property']]=r['status'].strip().lower()
    return out

def canonical_property_name(name):
    # Jasper can prefix properties with namespaces and elaborated instance names,
    # e.g. <embedded>::ua_med_golden_s0_a0.UA_GOLDEN_... .  Keep only
    # the leaf property label while preserving :precondition1.
    name=name.strip().strip('{}"')
    name=name.split('::')[-1]
    name=name.split('.')[-1]
    return name

def find(st,suffix):
    want=suffix.lower()
    hits=[v for k,v in st.items() if canonical_property_name(k).lower()==want]
    if hits:
        return hits[-1]
    # Conservative compatibility fallback for unexpected Jasper naming.
    hits=[v for k,v in st.items() if k.strip().lower().endswith(want)]
    return hits[-1] if hits else 'missing'

def is_proven(s):
    s=s.strip().lower()
    return (s in {'proven','bounded_proven','pass','passed'} or ('proven' in s and 'unproven' not in s))

def is_cex(s):
    s=s.strip().lower()
    return s in {'cex','counterexample','falsified','fail','failed'} or 'counterexample' in s or s.endswith('_cex')

def is_covered(s):
    s=s.strip().lower()
    return (s in {'covered','ar_covered'} or ('covered' in s and 'uncovered' not in s))

def classify(path,mode):
    st=read_status(path)
    golden=find(st,'UA_GOLDEN_NONVACUOUS_BY_BOUND') if mode!='golden' else find(st,'UA_GOLDEN_SEMANTIC_DENY_BY_BOUND')
    golden_pre=find(st,('UA_GOLDEN_NONVACUOUS_BY_BOUND' if mode!='golden' else 'UA_GOLDEN_SEMANTIC_DENY_BY_BOUND')+':precondition1')
    if mode=='golden':
        valid=is_proven(golden) and is_covered(golden_pre)
        return {'valid':valid,'outcome':'GOLDEN_PASS' if valid else 'INVALID','golden':golden,'golden_pre':golden_pre}
    attack_cover=find(st,'UA_COVER_ATTACK')
    primary_cover=find(st,'UA_COVER_PRIMARY_COMPROMISE_AFTER_UCP')
    valid=is_proven(golden) and is_covered(golden_pre) and is_covered(attack_cover)
    if mode=='ucp_baseline':
        # For a baseline result, require a non-vacuous UCP->primary compromise witness.
        valid=valid and is_covered(primary_cover)
        main=find(st,'UA_UCP_BASE_NO_BYPASS_BY_BOUND')
    elif mode=='mediation':
        sa_cover=find(st,'UA_COVER_SA_DIVERGENCE_AFTER_UCP')
        # Mediation is meaningful only when the UCP can also compromise the primary.
        valid=valid and is_covered(primary_cover) and is_covered(sa_cover)
        main=find(st,'UA_UCP_SA_NO_MEDIATED_BYPASS_BY_BOUND')
    elif mode=='exclusion': main=find(st,'UA_EXCLUSION_NO_BYPASS_BY_BOUND')
    elif mode=='cumulative': main=find(st,'UA_CUMULATIVE_EXCLUSION_NO_BYPASS_BY_BOUND')
    else: raise ValueError(mode)
    if not valid: outcome='INVALID_OR_UNRESOLVED'
    elif is_cex(main): outcome='BYPASS_CEX' if mode!='mediation' else 'MEDIATED_BYPASS_CEX'
    elif is_proven(main): outcome='NO_BYPASS_PROVEN' if mode!='mediation' else 'NO_MEDIATED_BYPASS_PROVEN'
    else: outcome='UNRESOLVED'
    d={'valid':valid,'outcome':outcome,'golden':golden,'golden_pre':golden_pre,'attack_cover':attack_cover,'primary_cover':primary_cover,'main':main}
    if mode=='mediation': d['sa_cover']=find(st,'UA_COVER_SA_DIVERGENCE_AFTER_UCP')
    return d

def main():
    if len(sys.argv)<3:
        print('usage: status.py MODE status.tsv'); return 2
    d=classify(Path(sys.argv[2]),sys.argv[1])
    print(' '.join(f'{k}={v}' for k,v in d.items()))
    return 0 if d['valid'] else 3
if __name__=='__main__': raise SystemExit(main())
