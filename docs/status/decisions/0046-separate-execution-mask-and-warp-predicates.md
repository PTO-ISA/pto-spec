# ADR 0046: Separate execution-mask and predicate domains (superseded)

> The historical `B.Z`/`B.NZ` consumer clause is also superseded by ADR 0067.
> PTO has no accepted conditional-branch consumer for the machine execution
> mask.

- Status: superseded by PRD-039 in
  [ADR 0062](0062-mnemonic-review-decisions.md#prd-039-machine-parallel-and-machine-sequential-block-starts-are-extension-reserved)
- Decision date: 2026-07-31

## Superseding decision

The earlier decision modeled a separate execution mask for machine-parallel
and machine-sequential block bodies. PTO no longer accepts those block-start
families and reserves their complete encoding space. PTO therefore has no
machine-body execution-mask state, entry behavior, trap payload, or branch
selection rule.

P0 through P7 remain distinct 32-bit predicate registers. P0 reads all ones
and ignores writes; P1 through P7 reset to zero and are trap-preserved. No
accepted PTO instruction produces or consumes them. `B.Z` and `B.NZ` consume
the bundle commit argument established by `SETC.*`.

This file records the superseded decision only. The current executable
contract is defined by the ASL architecture and scalar BRU units.
