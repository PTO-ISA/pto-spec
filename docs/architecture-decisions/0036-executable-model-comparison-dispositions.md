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
- 107 bundle/command forms;
- 120 direct tile operations: 98 TEPL, 9 TMA, and 13 CUBE.

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
  equivalent.

The current matrix classifies 701 rows:

| Classification | Rows | Disposition |
| --- | ---: | --- |
| `comparable-match` | 649 | Stable scalar/command identities or tile selector/header patterns agree. |
| `divergence` | 12 | PTO-v0 rejects these command forms before effects or routes semantics through PTO-owned direct tile dispatch. |
| `non-comparable` | 39 | Independent evidence is decode-only, header-only, or lacks payload execution. |
| `intentional-extension` | 1 | `TPRELU` is a PTO-owned TEPL extension. |

The comparison explicitly records these model limits:

- Reg5 is not validated as a flat scalar-register model. PTO keeps the
  absolute-GPR plus T/U queue rules from ADR 0008 and scalar operand evidence.
- P0..P7 predicate-register state is PTO-owned. The comparison does not prove
  equivalent predicate execution.
- PTO-v0 bundle commit binds only `destination0`, `source0`, and `source1`.
  The bundle bridge can represent 63 TEPL, 1 TMA, and 5 CUBE direct operations;
  other direct operations either use direct tile dispatch or reject at bundle
  commit before effects.
- TEPL comparison covers 97 shared selector/pattern rows after PTO spelling
  normalization for transpose. `TPRELU` is the one PTO-owned extension.
- The independent engine manifest contains 9 TMA and 13 CUBE functions, but
  those rows are header/function evidence, not independent tile payload
  execution.
- No independent evidence closes tile payload execution. PTO-owned ASL tests and
  ADRs close legality, definedness, aliases, packed four-bit memory behavior,
  raw-carrier arithmetic, and pre-effect rejection.

## Consequences

The exhaustive comparison-disposition obligation `S5-T3-G1` is closed because
every PTO row is classified and linked to PTO-owned evidence. The aggregate
`S5-T3` target remains in progress: its `S5-T3-G2` clean-gate criterion is not
satisfied by the current independent snapshot. Neither obligation is a numeric,
hardware, or full independent tile-payload conformance claim.

The comparison snapshot passed the available clean generation, validation,
canonical encoding, operation-manifest, decode-regeneration, semantic-status,
semantic-coverage, Sail parser, and Sail C-backend gates. These results are
archived from commands executed against the clean snapshot by
`scripts/generate-executable-model-comparison`; missing tools, nonzero exits,
or timeouts are recorded as gate failures rather than assumed success. The
snapshot documentation gate still reports stale translation freshness metadata,
while generated instruction pages and diagrams are current. PTO therefore
records that limitation and does not promote the aggregate comparison target
until a clean snapshot passes the documentation gate as well.

Future work that changes scalar forms, command forms, or direct tile selectors
must regenerate the comparison matrix and either preserve these dispositions or
add a new ADR for any changed divergence.

## Evidence

- `spec/evidence/executable-model-comparison.json`
- `scripts/generate-executable-model-comparison`
- `spec/evidence/scalar-effect-closure.json`
- `spec/evidence/bundle-command-totality.json`
- `spec/evidence/tepl-totality.json`
- `spec/evidence/tma-totality.json`
- `spec/evidence/cube-totality.json`
