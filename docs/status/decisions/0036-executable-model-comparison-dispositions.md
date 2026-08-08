# ADR 0036: Executable-model comparison dispositions

## Status

Accepted.

## Context

`S5-T3` requires PTO to compare its formal model against an independent
executable ISA model without importing that model as normative authority. The
comparison must be exhaustive over the PTO ISA surface, publication-safe, and
stable enough for reviewers to reproduce without publishing private paths,
source identity, prose, code, or diagrams from the comparison source.

PTO currently defines:

- 474 scalar forms;
- 99 bundle/command forms;
- 109 direct tile operations: 87 TEPL, 10 TLSU, and 12 CUBE.

The independent evidence is useful for scalar and command stable form IDs, and
for tile selector/header manifests. It is not a substitute for PTO-owned ASL
semantics, legality, alias, memory, trap, or numeric-profile decisions.

## Decision

PTO records the S5-T3 comparison in
`spec/evidence/executable-model-comparison.json`. The generated matrix contains
one row for every PTO scalar form, command form, and direct tile operation. Each
row has a stable PTO identity, a classification, a PTO-owned disposition,
requirement IDs, and evidence links.

The allowed row classifications are:

- `comparable-match`: the compared stable identity and relevant mask/match,
  selector, function, or executable-subset grade agree, while PTO-owned ASL
  remains authoritative for the normative rule;
- `divergence`: PTO intentionally differs from the independent model, normally
  because PTO-v0 rejects a generic or non-portable command form before effects;
- `non-comparable`: the independent evidence is decode/header/manifest-only or
  lacks an equivalent executable payload contract;
- `intentional-extension`: PTO owns the operation without an independent
  equivalent. The current matrix has no row in this class; missing equivalents
  remain explicit divergences.

The current matrix classifies 682 rows:

| Classification | Rows | Disposition |
| --- | ---: | --- |
| `comparable-match` | 554 | Stable scalar/command identities or tile selector/header patterns agree. |
| `divergence` | 90 | 68 direct-tile and 7 command rows retain accepted ABI remaps; other rows record missing identities or intentional PTO-v0 rejection. |
| `non-comparable` | 38 | Independent evidence is decode-only, header-only, or lacks payload execution. |

These classifications close an exhaustive **independent disposition** review,
not independent executable parity. The orthogonal generated
`spec/evidence/noncomparable-oracle-coverage.json` ledger preserves the exact
38-row non-comparable membership and grades executable-oracle coverage without
changing any matrix classification. Its foundation partition is 10 existing
exact-value candidates, 14 rows with a possible source path but no attributable
oracle, and 14 rows with no executable path. All 38 currently have
`oracle_coverage = none`, so independent executable parity is 0/38.

The comparison explicitly records these model limits:

- Reg5 is not validated as a flat scalar-register model. PTO keeps the
  absolute-GPR plus T/U queue rules from ADR 0008 and scalar operand evidence.
- The comparison model's 64-bit kernel execution mask corroborates the
  separate PTO MPAR/MSEQ mask domain. PTO's eight 32-bit P registers remain
  PTO-owned; the comparison neither defines their selector encoding nor
  proves equivalent warp-predicate execution.
- PTO-v0 bundle commit resolves all canonical direct-operation fields from
  ordered B.IOT/B.IOR bindings, bundle headers, or operation defaults. The
  bundle bridge can represent 87 TEPL, 10 TLSU, and 12 CUBE direct operations;
  this does not turn the independent comparison into payload-execution proof.
- TEPL comparison records 18 comparable selector/pattern rows. The remaining
  selector differences stay explicit row-level divergences, including the
  accepted issue-18/ADR-0045 ABI remaps.
- The independent engine manifest supplies TLSU and CUBE header/function rows, but
  those rows are header/function evidence, not independent tile payload
  execution.
- No independent evidence closes tile payload execution. PTO-owned ASL tests and
  ADRs close legality, definedness, aliases, packed four-bit memory behavior,
  raw-carrier arithmetic, and pre-effect rejection.

## Consequences

The exhaustive comparison-disposition obligation `S5-T3-G1` is closed because
every PTO row is classified and linked to PTO-owned evidence. The aggregate
`S5-T3` target is also closed: its clean, content-addressed independent snapshot
passes every archived repository, parser, and executable-backend gate. Neither
obligation is a numeric, hardware, or full independent tile-payload conformance
claim.

Three closure layers therefore remain distinct:

1. PTO semantic closure is supplied by PTO-owned ASL, legality, fault, state,
   and Stage 4 executable evidence.
2. Independent disposition closure is the complete 682-row S5-T3 matrix.
3. Independent executable parity is a separate 0/38 obligation for rows whose
   comparison evidence is currently decode-, header-, or manifest-only.

Promoting the third layer requires a publication-safe per-row oracle identity,
clean snapshot digest, gate token, input and expected-vector hashes, actual
result/state hash, supported obligations, limitations, execution result, and
reviewed disposition. Missing commands, stale snapshots, timeouts, nonzero
exits, unreviewed records, or structural-only evidence fail closed. Numeric
result parity stays deferred to S5-T2 where applicable.

The comparison snapshot passed the available clean generation, validation,
canonical encoding, operation-manifest, decode-regeneration, semantic-status,
semantic-coverage, Sail parser, and Sail C-backend gates. These results are
archived from commands executed against the clean snapshot by
`scripts/generate-executable-model-comparison`; missing tools, nonzero exits,
or timeouts are recorded as gate failures rather than assumed success. The
snapshot documentation gate includes translation-freshness metadata, generated
instruction pages, and generated diagrams. All are current in the archived
clean-snapshot result, so the former `S5-T3-G2` evidence gap is closed.

Future work that changes scalar forms, command forms, or direct tile selectors
must regenerate the comparison matrix and either preserve these dispositions or
add a new ADR for any changed divergence.

## Evidence

- `spec/evidence/executable-model-comparison.json`
- `scripts/generate-executable-model-comparison`
- `spec/evidence/noncomparable-oracle-coverage.json`
- `scripts/generate-noncomparable-oracle-coverage`
- `spec/evidence/scalar-effect-closure.json`
- `spec/evidence/bundle-command-totality.json`
- `spec/evidence/tepl-totality.json`
- `spec/evidence/tlsu-totality.json`
- `spec/evidence/cube-totality.json`
